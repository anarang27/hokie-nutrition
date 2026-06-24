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
npm run scrape         # scrape today's FoodPro menus
```

Apply the database schema:

```bash
# With Supabase CLI linked to your project:
supabase db push
# Or run backend/supabase/migrations/001_initial_schema.sql in the SQL editor.
```

## iOS setup

```bash
cd ios
open HokieNutrition.xcodeproj
```

Build and run on a simulator. Signup requires a `@vt.edu` email.

## Specs

- [Onboarding & nutrition targets](docs/onboarding-spec.md)
- [Recommendation engine](docs/recommender-spec.md)
- [Admin dashboard](docs/admin-dashboard-spec.md)
- [Design system](docs/design-system.md)

## MVP scope

Included: auth, onboarding, location/quadrant recommendations, explore/browse,
saved custom bowls, settings, basic notifications (stub), admin metrics backend.

V2: meal logging, remaining macro tracking, Apple Health.
