export type CampusQuadrant = "NW" | "NE" | "SW" | "SE";

export interface VenueConfig {
  foodproLocationNum: number;
  name: string;
  slug: string;
  quadrant: CampusQuadrant;
}

/** Known VT dining venues. Location numbers verified for D2 (15); others are seeded and updated by scraper discovery. */
export const VENUES: VenueConfig[] = [
  { foodproLocationNum: 15, name: "D2 at Dietrick Hall", slug: "d2-dietrick", quadrant: "NW" },
  { foodproLocationNum: 16, name: "West End Market", slug: "west-end-market", quadrant: "NW" },
  { foodproLocationNum: 17, name: "Turner Place", slug: "turner-place", quadrant: "SW" },
  { foodproLocationNum: 18, name: "Owens Food Court", slug: "owens-food-court", quadrant: "NE" },
  { foodproLocationNum: 19, name: "Deet's Place", slug: "deets-place", quadrant: "NE" },
];

export const FOODPRO_BASE = "https://foodpro.students.vt.edu/menus";

export function menuAtLocationUrl(locationNum: number, date?: Date): string {
  const params = new URLSearchParams({ locationNum: String(locationNum), naFlag: "1" });
  if (date) {
    const mm = date.getMonth() + 1;
    const dd = date.getDate();
    const yyyy = date.getFullYear();
    params.set("myaction", "read");
    params.set("dtdate", `${mm}/${dd}/${yyyy}`);
  }
  return `${FOODPRO_BASE}/MenuAtLocation.aspx?${params}`;
}

export function labelUrl(locationNum: number, menuDate: string, recNumAndPort: string): string {
  const params = new URLSearchParams({
    locationNum: String(locationNum),
    dtdate: menuDate,
    RecNumAndPort: recNumAndPort,
  });
  return `${FOODPRO_BASE}/label.aspx?${params}`;
}

/** Format date as MM/DD/YYYY for FoodPro URLs */
export function formatFoodProDate(date: Date): string {
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const dd = String(date.getDate()).padStart(2, "0");
  const yyyy = date.getFullYear();
  return `${mm}/${dd}/${yyyy}`;
}

export const CAMPUS_CENTER = { lat: 37.2285, lng: -80.4234 };

export function resolveQuadrant(lat: number, lng: number): CampusQuadrant {
  const north = lat >= CAMPUS_CENTER.lat;
  const east = lng >= CAMPUS_CENTER.lng;
  if (north && !east) return "NW";
  if (north && east) return "NE";
  if (!north && !east) return "SW";
  return "SE";
}

export const QUADRANT_VENUES: Record<CampusQuadrant, string[]> = {
  NW: ["d2-dietrick", "west-end-market"],
  NE: ["owens-food-court", "deets-place"],
  SW: ["turner-place"],
  SE: ["turner-place", "owens-food-court"],
};
