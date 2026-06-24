-- Hokie Nutrition initial schema
-- Run via Supabase CLI or SQL editor

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Dining data (FoodPro)
-- ---------------------------------------------------------------------------

create type campus_quadrant as enum ('NW', 'NE', 'SW', 'SE');
create type meal_period as enum ('breakfast', 'lunch', 'dinner', 'snack');

create table dining_venues (
  id uuid primary key default gen_random_uuid(),
  foodpro_location_num int not null unique,
  name text not null,
  slug text not null unique,
  quadrant campus_quadrant not null,
  latitude double precision,
  longitude double precision,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table restaurants (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references dining_venues(id) on delete cascade,
  name text not null,
  slug text not null,
  created_at timestamptz not null default now(),
  unique (venue_id, slug)
);

create table menu_items (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references dining_venues(id) on delete cascade,
  restaurant_id uuid references restaurants(id) on delete set null,
  foodpro_rec_num text not null,
  foodpro_portion text not null,
  name text not null,
  description text,
  meal meal_period,
  serving_size text,
  calories int,
  protein_g numeric(6,1),
  carbs_g numeric(6,1),
  fat_g numeric(6,1),
  fiber_g numeric(6,1),
  ingredients text,
  allergens text[] not null default '{}',
  dietary_tags text[] not null default '{}',
  menu_date date not null,
  label_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (venue_id, foodpro_rec_num, foodpro_portion, menu_date)
);

create table scrape_runs (
  id uuid primary key default gen_random_uuid(),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null default 'running',
  menu_date date not null,
  venues_attempted int not null default 0,
  venues_succeeded int not null default 0,
  items_ingested int not null default 0,
  error_message text
);

-- ---------------------------------------------------------------------------
-- User profiles (extends auth.users)
-- ---------------------------------------------------------------------------

create type user_sex as enum ('male', 'female');
create type class_year as enum ('freshman', 'sophomore', 'junior', 'senior', 'grad', 'other');
create type activity_level as enum ('sedentary', 'light', 'moderate', 'active', 'very_active');
create type gym_goal as enum ('cutting', 'bulking', 'lean', 'maintenance', 'high_protein', 'balanced');
create type goal_pace as enum ('relaxed', 'steady', 'aggressive');
create type protein_emphasis as enum ('standard', 'high');
create type dietary_pattern as enum ('none', 'vegetarian', 'vegan', 'pescatarian', 'halal');
create type units_preference as enum ('imperial', 'metric');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  phone text,
  dob date not null,
  sex user_sex not null,
  class_year class_year,
  height_cm numeric(5,1) not null,
  weight_kg numeric(5,1) not null,
  target_weight_kg numeric(5,1),
  units units_preference not null default 'imperial',
  workouts_per_week int not null default 0,
  activity_level activity_level not null,
  goal gym_goal not null,
  pace goal_pace,
  protein_emphasis protein_emphasis not null default 'standard',
  dietary_pattern dietary_pattern not null default 'none',
  allergens text[] not null default '{}',
  dislikes text[] not null default '{}',
  calorie_target int not null,
  protein_target int not null,
  carb_target int not null,
  fat_target int not null,
  targets_overridden boolean not null default false,
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_email_vt check (email ~* '^[A-Za-z0-9._%+-]+@vt\.edu$')
);

-- ---------------------------------------------------------------------------
-- Saved bowls & favorites
-- ---------------------------------------------------------------------------

create table saved_bowls (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  venue_id uuid references dining_venues(id) on delete set null,
  restaurant_id uuid references restaurants(id) on delete set null,
  name text not null,
  ingredient_item_ids uuid[] not null default '{}',
  calories int not null default 0,
  protein_g numeric(6,1) not null default 0,
  carbs_g numeric(6,1) not null default 0,
  fat_g numeric(6,1) not null default 0,
  is_favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  menu_item_id uuid references menu_items(id) on delete cascade,
  venue_id uuid references dining_venues(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, menu_item_id),
  unique (user_id, venue_id)
);

-- ---------------------------------------------------------------------------
-- Analytics events (pseudonymous, no PII)
-- ---------------------------------------------------------------------------

create table analytics_events (
  id uuid primary key default gen_random_uuid(),
  analytics_id uuid not null,
  event_name text not null,
  properties jsonb not null default '{}',
  app_version text,
  platform text not null default 'ios',
  created_at timestamptz not null default now()
);

create index analytics_events_name_created on analytics_events (event_name, created_at);
create index analytics_events_analytics_id on analytics_events (analytics_id);
create index menu_items_venue_date on menu_items (venue_id, menu_date);
create index menu_items_meal on menu_items (meal);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table profiles enable row level security;
alter table saved_bowls enable row level security;
alter table favorites enable row level security;
alter table dining_venues enable row level security;
alter table restaurants enable row level security;
alter table menu_items enable row level security;

create policy "Public read venues" on dining_venues for select using (true);
create policy "Public read restaurants" on restaurants for select using (true);
create policy "Public read menu items" on menu_items for select using (true);

create policy "Users read own profile" on profiles
  for select using (auth.uid() = id);
create policy "Users update own profile" on profiles
  for update using (auth.uid() = id);
create policy "Users insert own profile" on profiles
  for insert with check (auth.uid() = id);

create policy "Users manage own bowls" on saved_bowls
  for all using (auth.uid() = user_id);
create policy "Users manage own favorites" on favorites
  for all using (auth.uid() = user_id);

-- VT email enforcement on signup (Supabase Auth hook alternative: validate in app + DB check above)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.email !~* '^[A-Za-z0-9._%+-]+@vt\.edu$' then
    raise exception 'Signup requires a @vt.edu email address';
  end if;
  return new;
end;
$$;

create trigger enforce_vt_email_before_signup
  before insert on auth.users
  for each row execute function public.handle_new_user();

-- Seed VT dining venues (FoodPro location numbers; expand as discovered)
insert into dining_venues (foodpro_location_num, name, slug, quadrant, latitude, longitude) values
  (15, 'D2 at Dietrick Hall', 'd2-dietrick', 'NW', 37.2256, -80.4247),
  (16, 'West End Market', 'west-end-market', 'NW', 37.2228, -80.4275),
  (17, 'Turner Place', 'turner-place', 'SW', 37.2289, -80.4189),
  (18, 'Owens Food Court', 'owens-food-court', 'NE', 37.2295, -80.4205),
  (19, 'Deet''s Place', 'deets-place', 'NE', 37.2301, -80.4198)
on conflict (foodpro_location_num) do nothing;
