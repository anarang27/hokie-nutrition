# Hokie Nutrition

iOS food recommender for Virginia Tech students. Recommends campus dining meals
based on gym goals, macro targets, location (campus quadrants), and dietary
preferences. Nutrition data is scraped from [FoodPro](https://foodpro.students.vt.edu/menus/).

## Project structure

```
backend/          Supabase schema, FoodPro scraper, API helpers
ios/              SwiftUI iOS app
docs/             Product specs (onboarding, recommender, admin, design system)
stitch_hokie_nutrition_ui_kit/   Stitch UI reference designs
```

## Requirements

- Xcode 15+ (iOS 17+)
- Node.js 20+
- Supabase account (free tier works for MVP)

## Backend setup

```bash
cd backend
npm install
cp .env.example .env   # add Supabase URL + service role key
```

Apply database migrations in order in the Supabase SQL editor:
1. `backend/supabase/migrations/001_initial_schema.sql`
2. `backend/supabase/migrations/002_menu_view.sql`

Scrape today's FoodPro menus into Supabase:

```bash
cd backend
npm run scrape          # requires .env with service role key
npm run scrape:local    # export JSON to scraper/output/ without Supabase
npm run scrape:dry      # quick 5-item sample per venue
npm run discover:venues # probe FoodPro locationNum values
```

## iOS setup

1. Copy Supabase credentials into the app:

```bash
cp ios/HokieNutrition/Supabase.plist.example ios/HokieNutrition/Supabase.plist
# Edit Supabase.plist with your project URL + anon key
```

2. Open and run:

```bash
cd ios && xcodegen generate && open HokieNutrition.xcodeproj
```

Build and run on a simulator. Signup requires a `@vt.edu` email.

For development, disable email confirmation in Supabase Auth settings so sign-up works immediately.

## Specs

- [Onboarding & nutrition targets](docs/onboarding-spec.md)
- [Recommendation engine](docs/recommender-spec.md)
- [Admin dashboard](docs/admin-dashboard-spec.md)
- [Design system](docs/design-system.md)

## MVP scope

Included: auth, onboarding, location/quadrant recommendations, explore/browse,
saved custom bowls, settings, basic notifications (stub), admin metrics backend.

V2: meal logging, remaining macro tracking, Apple Health.
