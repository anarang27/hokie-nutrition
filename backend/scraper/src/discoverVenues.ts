import { FOODPRO_BASE } from "./config.js";

/** Probe FoodPro locationNum values and print those with menu content. */
async function main() {
  const start = parseInt(process.argv[2] ?? "1", 10);
  const end = parseInt(process.argv[3] ?? "30", 10);
  console.log(`Probing FoodPro locationNum ${start}-${end}...\n`);

  for (let n = start; n <= end; n++) {
    const url = `${FOODPRO_BASE}/MenuAtLocation.aspx?locationNum=${n}&naFlag=1`;
    try {
      const res = await fetch(url, {
        headers: { "User-Agent": "HokieNutritionScraper/1.0" },
      });
      const html = await res.text();
      const nameMatch = html.match(/<h2>([^<]+)<\/h2>/);
      const labelCount = (html.match(/label\.aspx\?/g) ?? []).length;
      const name = nameMatch?.[1]?.trim() ?? "Unknown";
      if (labelCount > 10) {
        console.log(`✓ locationNum=${n}  items≈${labelCount}  name="${name}"`);
      } else if (labelCount > 0) {
        console.log(`· locationNum=${n}  items≈${labelCount}  name="${name}" (sparse)`);
      }
    } catch (err) {
      console.log(`✗ locationNum=${n}  error: ${err}`);
    }
  }
}

main();
