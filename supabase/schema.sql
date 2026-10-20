-- Menu Djib schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.restaurants (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null, slug text not null unique, logo_url text, whatsapp text not null check (whatsapp ~ '^\\+253[0-9]{8}$'),
 opening_hours jsonb not null default '{}'::jsonb, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.categories (
 id uuid primary key default gen_random_uuid(), restaurant_id uuid not null references public.restaurants(id) on delete cascade,
 name_fr text not null, name_en text not null default '', name_ar text not null default '', sort_order int not null default 0, created_at timestamptz not null default now()
);
create table if not exists public.menu_items (
 id uuid primary key default gen_random_uuid(), restaurant_id uuid not null references public.restaurants(id) on delete cascade,
 category_id uuid references public.categories(id) on delete set null, name_fr text not null, name_en text not null default '', name_ar text not null default '',
 description_fr text not null default '', description_en text not null default '', description_ar text not null default '', price_djf int not null check (price_djf >= 0),
 photo_url text, is_available boolean not null default true, is_sold_out boolean not null default false, sort_order int not null default 0, created_at timestamptz not null default now()
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(), restaurant_id uuid not null references public.restaurants(id) on delete cascade,
 customer_name text not null default 'Client', fulfillment text not null check (fulfillment in ('table','delivery','pickup')), table_number text,
 items jsonb not null, total_djf int not null check (total_djf >= 0), status text not null default 'new' check (status in ('new','preparing','ready','done')),
 created_at timestamptz not null default now()
);
create index if not exists categories_restaurant_sort_idx on public.categories(restaurant_id,sort_order);
create index if not exists items_restaurant_sort_idx on public.menu_items(restaurant_id,sort_order);
create index if not exists orders_restaurant_created_idx on public.orders(restaurant_id,created_at desc);
alter table public.restaurants enable row level security; alter table public.categories enable row level security; alter table public.menu_items enable row level security; alter table public.orders enable row level security;
-- Published restaurants and their menu are public; private/unpublished data is not.
create policy "public can read published restaurants" on public.restaurants for select using (published = true or auth.uid() = owner_id);
create policy "owners manage restaurants" on public.restaurants for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "public read categories of published restaurants" on public.categories for select using (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.published=true));
create policy "owners manage categories" on public.categories for all using (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid())) with check (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid()));
create policy "public read available items in published restaurants" on public.menu_items for select using (is_available=true and exists(select 1 from public.restaurants r where r.id=restaurant_id and r.published=true) or exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid()));
create policy "owners manage items" on public.menu_items for all using (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid())) with check (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid()));
create policy "owners read orders" on public.orders for select using (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid()));
create policy "owners update orders" on public.orders for update using (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid())) with check (exists(select 1 from public.restaurants r where r.id=restaurant_id and r.owner_id=auth.uid()));
-- Order inserts happen via a server-only service role after validation in app/api/orders/route.ts.
-- Add orders to Supabase Realtime publication (safe to rerun).
do $$ begin alter publication supabase_realtime add table public.orders; exception when duplicate_object then null; when undefined_object then null; end $$;
-- Storage: create a public bucket named `menu-photos` in Dashboard for logo/food images.
-- Keep uploads owner-only via Storage policies if adding browser upload UI.
