-- Enriched menu view for client queries (joins venue + restaurant names)

create or replace view menu_items_enriched as
select
  mi.id,
  mi.foodpro_rec_num,
  mi.foodpro_portion,
  mi.name,
  mi.description,
  mi.meal,
  mi.serving_size,
  mi.calories,
  mi.protein_g,
  mi.carbs_g,
  mi.fat_g,
  mi.fiber_g,
  mi.ingredients,
  mi.allergens,
  mi.dietary_tags,
  mi.menu_date,
  mi.label_url,
  dv.id as venue_id,
  dv.name as venue_name,
  dv.slug as venue_slug,
  dv.quadrant,
  r.id as restaurant_id,
  r.name as restaurant_name
from menu_items mi
join dining_venues dv on mi.venue_id = dv.id
left join restaurants r on mi.restaurant_id = r.id;

-- Clients can read enriched menu data
grant select on menu_items_enriched to anon, authenticated;

-- Latest scrape status for admin/health checks
create or replace view scrape_health as
select
  id,
  started_at,
  finished_at,
  status,
  menu_date,
  venues_attempted,
  venues_succeeded,
  items_ingested,
  error_message,
  extract(epoch from (coalesce(finished_at, now()) - started_at)) as duration_seconds
from scrape_runs
order by started_at desc
limit 1;

grant select on scrape_health to authenticated;

-- Allow authenticated users to read scrape health (not full scrape_runs history in MVP)
alter table scrape_runs enable row level security;
create policy "Authenticated read latest scrape runs" on scrape_runs
  for select to authenticated using (true);

-- Profile updated_at trigger
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at
  before update on profiles
  for each row execute function public.set_updated_at();

create trigger menu_items_updated_at
  before update on menu_items
  for each row execute function public.set_updated_at();
