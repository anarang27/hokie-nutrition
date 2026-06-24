# Design System & Screen Mapping

Source of truth for visual design is the Stitch export at
`stitch_hokie_nutrition_ui_kit/`. This doc summarizes the design tokens and maps
each delivered screen to the relevant spec so engineering and design stay in
sync. The authoritative tokens live in
`stitch_hokie_nutrition_ui_kit/hokie_nutrition/DESIGN.md`; per-screen HTML and PNG
references live in each screen's folder.

---

## 1. Brand & Style

"Corporate Modern with a Fitness Edge" for the active Virginia Tech student.
Clean white space, large one-handed touch targets, soft ambient shadows, and
sparing Burnt Orange gradients for momentum/progress. Avoid medical-app feel.

## 2. Color Tokens

Anchored on Virginia Tech identity. Chicago Maroon = primary actions, headers,
brand. Burnt Orange = accents, progress, "active" states.

| Role | Token | Hex |
|---|---|---|
| Primary (Chicago Maroon) | `primary` | `#6c012b` |
| On primary | `on-primary` | `#ffffff` |
| Primary container | `primary-container` | `#8b1f41` |
| Secondary (Burnt Orange) | `secondary` | `#994700` |
| Secondary container | `secondary-container` | `#ff8934` |
| Tertiary (Slate) | `tertiary` | `#243449` |
| Background / surface | `background` | `#fff8f7` |
| Card surface (lowest) | `surface-container-lowest` | `#ffffff` |
| On surface (text) | `on-surface` | `#24191b` |
| On surface variant | `on-surface-variant` | `#564145` |
| Outline | `outline` | `#897175` |
| Error | `error` | `#ba1a1a` |

Macro chip color-coding (consistent everywhere):

- Protein -> Maroon tint
- Carbs -> Orange tint
- Fat -> Slate/grey tint

## 3. Typography

Font family **Inter** throughout (emulates SF Pro). Key roles:

| Role | Size / Weight / Line |
|---|---|
| display-lg | 34 / 700 / 41 |
| headline-lg | 28 / 700 / 34 (mobile 24/700/30) |
| headline-md | 22 / 600 / 28 |
| body-lg | 17 / 400 / 24 |
| body-md | 15 / 400 / 20 |
| label-lg | 13 / 600 / 18 |
| label-md | 12 / 500 / 16 |

## 4. Spacing, Radius, Elevation

- 4px baseline grid. Horizontal screen margin 16px. Card gaps 12-16px. Large
  section breaks 32px.
- Radius: cards/containers/buttons 16px ("squircle"); chips & progress bars fully
  pill (9999px).
- Elevation: cards use soft shadow (0,4 / blur 20 / 4% black); primary/floating
  use 0,8 / blur 24 / 10% maroon tint.

## 5. Core Components

- **Primary button**: solid Maroon, white text, 16px radius, min height 54px.
- **Secondary button**: white bg, Burnt Orange border + text.
- **Ghost button**: transparent, slate text (Cancel/Edit).
- **Macro chips**: pill, light tint bg, dark text, color-coded by macro.
- **Progress rings**: 8-12pt rounded-cap stroke; track light slate; fill Burnt
  Orange gradient. Used for daily calorie/protein goals.
- **Input fields**: 16px radius, light grey border; focus -> Maroon border + glow.
- **Cards/lists**: white cards, 16px padding, 1px slate-100 dividers.

## 6. Navigation

Bottom tab bar (confirmed across screens): **Home, Explore, Saved, Profile**.
Header shows "Hokie Nutrition" title with a back chevron and a profile avatar.
Admin dashboard is a separate surface (web-first), not part of the tab bar.

---

## 7. Screen -> Spec Mapping

| Stitch screen | Folder | Drives spec |
|---|---|---|
| Onboarding / Signup | `onboarding_signup/` | `onboarding-spec.md` (VT Email field shown) |
| Location access | `location_access/` | PRD Location Services; recommender Section 4.5 |
| Home dashboard | `home_dashboard/` | PRD Home; recommender (picks, tags) |
| Explore dining | `explore_dining/` | PRD Explore; recommender filters |
| Meal details | `meal_details/` | recommender explanation ("Why it fits your goal") |
| Bowl builder | `bowl_builder/` | PRD Custom Meals And Bowls |
| Saved bowls | `saved_bowls/` | PRD Custom Meals And Bowls |
| Profile / settings | `profile_settings/` | PRD Settings; onboarding profile fields |
| Admin dashboard | `admin_dashboard/` | `admin-dashboard-spec.md` |

### Notable confirmations from the designs

- Onboarding step 1 = Full Name + **VT Email** (placeholder `student@vt.edu`),
  with a top progress bar. Matches the @vt.edu rule.
- Home shows goal "Phase" chip, calorie + protein **rings**, "Best nearby picks"
  with per-card distance and a goal tag ("Top Bulking Pick"), plus "View map".
- Explore has the Nearby / All / Open Now segmented control and macro filter chips
  (High Protein, Under 600 Cal, Vegetarian), with Open/Closed venue badges.
- Meal details has a "Why it fits your goal" explanation block and an Allergens
  row -> matches recommender explanation tags + hard filters.
- Profile shows goal/pace ("+0.5 lbs/week"), Daily Calorie Target, Body Stats
  (imperial), Dietary Restrictions, Notification Settings, Connected Apps.

---

## 8. Design vs MVP Scope Gaps (need decisions)

These appear in the designs but were scoped to V2 or are not yet specced. Calling
them out so we either adjust scope or hide the controls in MVP.

1. **Meal logging / diary is pervasive in the designs** but is V2 per the PRD.
   **Decision: keep logging in V2 and hide these controls in MVP.** MVP control
   substitutions:
   - Home rings: show **static targets** (e.g., "2,450 kcal target" / "160g
     target"); drop the "left" remaining copy until logging ships.
   - Meal details: replace **"Log Portion"** with **"Save"** (save to favorites).
   - Saved bowls: replace **"Add to Diary"** with **"Save"** / quick-select; the
     card still surfaces the bowl for fast reselection, just without logging it.
   - Admin: defer the "Macro Tracking Activity - meals logged per day" card.
   - When V2 logging ships, restore the original design controls as-is.

2. **Distance is displayed per item** ("0.2 mi", "0.5 mi") even though selection
   now uses quadrants. Resolution: compute approximate walking/!straight-line
   distance on-device for **display only**, then discard coordinates; quadrant
   still drives which venues are candidates. Captured in recommender Section 4.5.

3. **Reject-and-propose has no UI yet** in the kit. Needs a new control (e.g., a
   "Not feeling it? Pick a spot" action on home picks / meal details) to drive the
   flow in recommender Section 4.7.

4. **Connected Apps -> Apple Health** shown in Profile, but Health integration is
   a later phase. Either mark it "Coming soon" or defer the row in MVP.

5. **Manual fallback** in location screen is "Select Dining Hall Manually". The
   recommender also allows selecting a quadrant; MVP can ship dining-hall-only
   manual selection to match the design and add quadrant pick later.
