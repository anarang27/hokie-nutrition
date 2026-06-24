import * as cheerio from "cheerio";

export type MealPeriod = "breakfast" | "lunch" | "dinner" | "snack";

export interface ParsedMenuItemRef {
  name: string;
  description?: string;
  recNumAndPort: string;
  labelPath: string;
  restaurantName: string;
  meal: MealPeriod;
}

const MEAL_TAB_MAP: Record<string, MealPeriod> = {
  meal_1: "breakfast",
  meal_2: "lunch",
  meal_3: "dinner",
};

function parseRecNumAndPort(href: string): string | null {
  const match = href.match(/RecNumAndPort=([^&]+)/);
  return match ? decodeURIComponent(match[1]) : null;
}

function splitRecAndPort(recNumAndPort: string): { recNum: string; portion: string } {
  const [recNum, portion = "1"] = recNumAndPort.split("*");
  return { recNum, portion };
}

export function parseLocationPage(html: string, locationNum: number): {
  venueName: string;
  menuDate: string;
  items: ParsedMenuItemRef[];
} {
  const $ = cheerio.load(html);
  const venueName = $("h2").first().text().trim() || `Location ${locationNum}`;

  const selectedDate = $("select#date_select option[selected]").attr("value")
    ?? $("select[name='dtdate'] option[selected]").attr("value")
    ?? new Date().toLocaleDateString("en-US");

  const menuDate = selectedDate.includes("/")
    ? selectedDate
    : new Date(selectedDate).toLocaleDateString("en-US", { month: "2-digit", day: "2-digit", year: "numeric" });

  const items: ParsedMenuItemRef[] = [];
  let currentRestaurant = "General";

  $("[id^='meal_'][id$='_content']").each((_, mealPane) => {
    const paneId = $(mealPane).attr("id") ?? "";
    const mealKey = paneId.replace("_content", "");
    const meal = MEAL_TAB_MAP[mealKey] ?? "snack";

    $(mealPane).find("*").each((__, el) => {
      const tag = el.tagName?.toLowerCase();
      const text = $(el).text().trim();

      if (tag === "h3" || tag === "h4") {
        if (text && !text.toLowerCase().includes("filter")) {
          currentRestaurant = text;
        }
      }

      if (tag === "a") {
        const href = $(el).attr("href") ?? "";
        if (!href.includes("label.aspx") || !href.includes("RecNumAndPort")) return;

        const recNumAndPort = parseRecNumAndPort(href);
        if (!recNumAndPort) return;

        const name = $(el).text().trim();
        if (!name) return;

        const description = $(el).parent().find("em, .description, p").first().text().trim() || undefined;

        items.push({
          name,
          description,
          recNumAndPort,
          labelPath: href.startsWith("http") ? href : `https://foodpro.students.vt.edu/menus/${href.replace(/^\//, "")}`,
          restaurantName: currentRestaurant,
          meal,
        });
      }
    });
  });

  // Deduplicate by recNumAndPort + meal
  const seen = new Set<string>();
  const unique = items.filter((item) => {
    const key = `${item.recNumAndPort}|${item.meal}|${item.name}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  return { venueName, menuDate, items: unique };
}

export interface ParsedLabel {
  name: string;
  servingSize?: string;
  calories?: number;
  proteinG?: number;
  carbsG?: number;
  fatG?: number;
  fiberG?: number;
  ingredients?: string;
  allergens: string[];
}

function parseGrams(text: string): number | undefined {
  const match = text.match(/([\d.]+)\s*g/i);
  return match ? parseFloat(match[1]) : undefined;
}

function parseCalories(text: string): number | undefined {
  const match = text.match(/(\d+)/);
  return match ? parseInt(match[1], 10) : undefined;
}

export function parseLabelPage(html: string): ParsedLabel {
  const $ = cheerio.load(html);

  const name = $("h1, h2, .label_title, #item_name").first().text().trim()
    || $("title").text().replace(/Virginia Tech.*\|/, "").trim();
  const cleanedName = /nutrition facts/i.test(name) ? "" : name;

  const servingSize = $("#serving_size_container").text().replace(/Serving Size/i, "").trim() || undefined;

  const caloriesText = $("#calories_container").text();
  const calories = parseCalories(caloriesText);

  let proteinG: number | undefined;
  let carbsG: number | undefined;
  let fatG: number | undefined;
  let fiberG: number | undefined;

  $(".daily_value, .nutrition_fact_row, .col-lg-12").each((_, row) => {
    const text = $(row).text().replace(/\s+/g, " ").trim();
    if (/protein/i.test(text)) proteinG = parseGrams(text);
    if (/tot\.?\s*carb/i.test(text)) carbsG = parseGrams(text);
    if (/total fat/i.test(text) && !/sat/i.test(text)) fatG = parseGrams(text);
    if (/fiber/i.test(text)) fiberG = parseGrams(text);
  });

  const ingredients = $(".ingredients_container").text().replace(/INGREDIENTS:/i, "").trim() || undefined;

  const allergenText = $(".allergens_container").text().replace(/ALLERGENS:/i, "").trim();
  const allergens = allergenText
    ? allergenText.split(/[,;]/).map((a) => a.trim()).filter(Boolean)
    : [];

  return { name: cleanedName, servingSize, calories, proteinG, carbsG, fatG, fiberG, ingredients, allergens };
}

export { splitRecAndPort };
