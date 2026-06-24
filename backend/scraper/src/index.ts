import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { VENUES, menuAtLocationUrl, formatFoodProDate } from "./config.js";
import { parseLocationPage, parseLabelPage, splitRecAndPort } from "./parseFoodPro.js";

const dryRun = process.argv.includes("--dry-run");
const delayMs = 300;

function sleep(ms: number) {
  return new Promise((r) => setTimeout(r, ms));
}

async function fetchHtml(url: string): Promise<string> {
  const res = await fetch(url, {
    headers: { "User-Agent": "HokieNutritionScraper/1.0 (Virginia Tech student project)" },
  });
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  return res.text();
}

function parseMenuDate(s: string): string {
  // FoodPro uses M/D/YYYY or MM/DD/YYYY -> normalize to ISO date
  const parts = s.split("/");
  if (parts.length === 3) {
    const [m, d, y] = parts.map((p) => parseInt(p, 10));
    return `${y}-${String(m).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
  }
  return new Date().toISOString().slice(0, 10);
}

async function main() {
  const today = new Date();
  const menuDateIso = parseMenuDate(formatFoodProDate(today));
  console.log(`Scraping FoodPro menus for ${menuDateIso}${dryRun ? " (dry run)" : ""}...`);

  const supabase = dryRun
    ? null
    : createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

  let scrapeRunId: string | undefined;
  if (supabase) {
    const { data, error } = await supabase
      .from("scrape_runs")
      .insert({ menu_date: menuDateIso, status: "running" })
      .select("id")
      .single();
    if (error) throw error;
    scrapeRunId = data.id;
  }

  let venuesSucceeded = 0;
  let itemsIngested = 0;
  const output: unknown[] = [];

  for (const venue of VENUES) {
    const url = menuAtLocationUrl(venue.foodproLocationNum, today);
    console.log(`\n→ ${venue.name} (${url})`);

    try {
      const html = await fetchHtml(url);
      const parsed = parseLocationPage(html, venue.foodproLocationNum);
      console.log(`  Found ${parsed.items.length} items at ${parsed.venueName}`);

      if (parsed.items.length === 0) {
        console.log("  Skipping (no menu items — venue may be closed)");
        continue;
      }

      venuesSucceeded++;

      // Upsert venue
      let venueId: string | undefined;
      if (supabase) {
        const { data: venueRow } = await supabase
          .from("dining_venues")
          .upsert({
            foodpro_location_num: venue.foodproLocationNum,
            name: parsed.venueName || venue.name,
            slug: venue.slug,
            quadrant: venue.quadrant,
          }, { onConflict: "foodpro_location_num" })
          .select("id")
          .single();
        venueId = venueRow?.id;
      }

      const restaurantCache = new Map<string, string>();

      for (const item of parsed.items.slice(0, dryRun ? 5 : undefined)) {
        await sleep(delayMs);

        let label;
        try {
          const labelHtml = await fetchHtml(item.labelPath);
          label = parseLabelPage(labelHtml);
        } catch (err) {
          console.warn(`  ⚠ Could not fetch label for ${item.name}: ${err}`);
          label = { name: item.name, allergens: [] as string[] };
        }

        const { recNum, portion } = splitRecAndPort(item.recNumAndPort);
        const row = {
          venue_slug: venue.slug,
          restaurant_name: item.restaurantName,
          foodpro_rec_num: recNum,
          foodpro_portion: portion,
          name: label.name || item.name,
          description: item.description,
          meal: item.meal,
          serving_size: label.servingSize,
          calories: label.calories,
          protein_g: label.proteinG,
          carbs_g: label.carbsG,
          fat_g: label.fatG,
          fiber_g: label.fiberG,
          ingredients: label.ingredients,
          allergens: label.allergens,
          menu_date: menuDateIso,
          label_url: item.labelPath,
        };

        if (dryRun) {
          output.push(row);
          itemsIngested++;
          continue;
        }

        if (!supabase || !venueId) continue;

        // Upsert restaurant
        let restaurantId = restaurantCache.get(item.restaurantName);
        if (!restaurantId) {
          const slug = item.restaurantName.toLowerCase().replace(/[^a-z0-9]+/g, "-");
          const { data: restRow } = await supabase
            .from("restaurants")
            .upsert({ venue_id: venueId, name: item.restaurantName, slug }, { onConflict: "venue_id,slug" })
            .select("id")
            .single();
          restaurantId = restRow?.id;
          if (restaurantId) restaurantCache.set(item.restaurantName, restaurantId);
        }

        const { error } = await supabase.from("menu_items").upsert({
          venue_id: venueId,
          restaurant_id: restaurantId,
          foodpro_rec_num: recNum,
          foodpro_portion: portion,
          name: row.name,
          description: row.description,
          meal: row.meal,
          serving_size: row.serving_size,
          calories: row.calories,
          protein_g: row.protein_g,
          carbs_g: row.carbs_g,
          fat_g: row.fat_g,
          fiber_g: row.fiber_g,
          ingredients: row.ingredients,
          allergens: row.allergens,
          menu_date: menuDateIso,
          label_url: row.label_url,
        }, { onConflict: "venue_id,foodpro_rec_num,foodpro_portion,menu_date" });

        if (error) console.warn(`  ⚠ Upsert failed for ${row.name}: ${error.message}`);
        else itemsIngested++;
      }
    } catch (err) {
      console.error(`  ✗ Failed: ${err}`);
    }
  }

  if (dryRun) {
    console.log("\nSample output:", JSON.stringify(output.slice(0, 3), null, 2));
  }

  if (supabase && scrapeRunId) {
    await supabase.from("scrape_runs").update({
      finished_at: new Date().toISOString(),
      status: "success",
      venues_attempted: VENUES.length,
      venues_succeeded: venuesSucceeded,
      items_ingested: itemsIngested,
    }).eq("id", scrapeRunId);
  }

  console.log(`\nDone. Venues: ${venuesSucceeded}/${VENUES.length}, items: ${itemsIngested}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
