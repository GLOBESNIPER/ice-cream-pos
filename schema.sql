-- Maalem POS — Supabase schema
-- Paste this whole file in the Supabase SQL editor and click Run.
-- Safe to run multiple times.

create table if not exists products (
  id bigint primary key,
  name text not null,
  cost numeric not null,
  price numeric not null,
  per_carton int not null,
  initial_stock int not null,
  stock int not null,
  color text not null
);

create table if not exists sales (
  id bigserial primary key,
  client_ref int,
  device text,
  created_at timestamptz not null default now(),
  total numeric not null,
  profit numeric not null,
  pieces int not null,
  items jsonb not null
);

-- in case an older version of this schema was run before
alter table sales add column if not exists device text;
alter table sales add column if not exists vendor text;
drop function if exists record_sale(int, numeric, numeric, int, jsonb);
drop function if exists record_sale(int, text, numeric, numeric, int, jsonb);

-- Atomic sale: inserts the sale and decrements stock in one transaction
create or replace function record_sale(
  p_client_ref int,
  p_device text,
  p_vendor text,
  p_total numeric,
  p_profit numeric,
  p_pieces int,
  p_items jsonb
) returns bigint
language plpgsql
security definer
as $$
declare
  v_id bigint;
  itm jsonb;
begin
  insert into sales (client_ref, device, vendor, total, profit, pieces, items)
  values (p_client_ref, p_device, p_vendor, p_total, p_profit, p_pieces, p_items)
  returning id into v_id;

  for itm in select * from jsonb_array_elements(p_items) loop
    update products
    set stock = greatest(stock - (itm->>'qty')::int, 0)
    where id = (itm->>'id')::bigint;
  end loop;

  return v_id;
end;
$$;

grant execute on function record_sale(int, text, text, numeric, numeric, int, jsonb) to anon, authenticated;

-- Open access for the app (UI access is PIN-protected; the anon key is public by design)
alter table products enable row level security;
alter table sales enable row level security;

drop policy if exists "app products" on products;
create policy "app products" on products for all using (true) with check (true);

drop policy if exists "app sales" on sales;
create policy "app sales" on sales for all using (true) with check (true);

grant usage on schema public to anon, authenticated;
grant all on products, sales to anon, authenticated;
grant usage, select on sequence sales_id_seq to anon, authenticated;

-- Realtime: push changes to all connected phones (ignore "already added" errors)
do $$ begin
  alter publication supabase_realtime add table products;
exception when duplicate_object then null; end $$;

do $$ begin
  alter publication supabase_realtime add table sales;
exception when duplicate_object then null; end $$;

-- make the API pick up the new function immediately
notify pgrst, 'reload schema';
