import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { VENUES, menuAtLocationUrl, formatFoodProDate } from "./config.js";
import { parseLocationPage, parseLabelPage, splitRecAndPort } from "./parseFoodPro.js";

const dryRun = process.argv.includes("--dry-run");
const localOnly = process.argv.includes("--local");
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
  const parts = s.split("/");
  if (parts.length === 3) {
    const [m, d, y] = parts.map((p) => parseInt(p, 10));
    return `${y}-${String(m).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
  }
  return new Date().toISOString().slice(0, 10);
}

interface ScrapedRow {
  venue_slug: string;
  venue_name: string;
  restaurant_name: string;
  foodpro_rec_num: string;
  foodpro_portion: string;
  name: string;
  description?: string;
  meal: string;
  serving_size?: string;
  calories?: number;
  protein_g?: number;
  carbs_g?: number;
  fat_g?: number;
  fiber_g?: number;
  ingredients?: string;
  allergens: string[];
  menu_date: string;
  label_url: string;
}

async function main() {
  const today = new Date();
  const menuDateIso = parseMenuDate(formatFoodProDate(today));
  const mode = dryRun ? "dry run" : localOnly ? "local export" : "supabase";
  console.log(`Scraping FoodPro menus for ${menuDateIso} (${mode})...`);

  const supabase = dryRun || localOnly
    ? null
    : createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

  if (!supabase && !dryRun && !localOnly) {
    throw new Error("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env, or use --local");
  }

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
  const localRows: ScrapedRow[] = [];

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
      const itemLimit = dryRun ? 5 : undefined;

      for (const item of parsed.items.slice(0, itemLimit)) {
        await sleep(delayMs);

        let label;
        try {
          const labelHtml = await fetchHtml(item.labelPath);
          label = parseLabelPage(labelHtml);
        } catch (err) {
          console.warn(`  ⚠ Could not fetch label for ${item.name}: ${err}`);
          label = { name: "", allergens: [] as string[] };
        }

        const { recNum, portion } = splitRecAndPort(item.recNumAndPort);
        const row: ScrapedRow = {
          venue_slug: venue.slug,
          venue_name: parsed.venueName || venue.name,
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
          localRows.push(row);
          itemsIngested++;
          continue;
        }

        if (localOnly) {
          localRows.push(row);
          itemsIngested++;
          continue;
        }

        if (!supabase || !venueId) continue;

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

  if (localRows.length > 0) {
    const outDir = join(process.cwd(), "scraper/output");
    mkdirSync(outDir, { recursive: true });
    const outPath = join(outDir, `menu-${menuDateIso}.json`);
    writeFileSync(outPath, JSON.stringify(localRows, null, 2));
    console.log(`\nWrote ${localRows.length} items to ${outPath}`);
    if (dryRun) {
      console.log("Sample:", JSON.stringify(localRows.slice(0, 2), null, 2));
    }
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
