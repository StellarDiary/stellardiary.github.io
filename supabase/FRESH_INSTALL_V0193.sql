-- Stellar Diary V0.19.4.0 — FRESH INSTALL for a brand-new Supabase project
-- Generated from migrations 001..035 in filename order.
-- This script intentionally creates NO players, NO system mail, and NO initial GM.
-- Run once in the SQL Editor of an EMPTY project.
-- After the site owner account exists, run supabase/SET_FIRST_GM.sql separately.


-- ============================================================================
-- BEGIN 20260917_001_core_schema.sql
-- ============================================================================
-- Stellar Diary V0.10.7.1 — Core Supabase schema
-- Snapshot of the schema applied manually in Supabase SQL Editor on 2026-09-17.
-- Safe to keep in source control: contains no keys or passwords.

begin;

create schema if not exists private;
revoke all on schema private from public;
revoke all on schema private from anon, authenticated;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  sex text not null default 'unspecified' check (sex in ('male','female','unspecified')),
  locale text not null default 'zh-CN' check (locale in ('zh-CN','zh-TW','en')),
  timezone text not null default 'Asia/Taipei',
  preferences jsonb not null default '{}'::jsonb check (jsonb_typeof(preferences)='object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_display_name_length check (display_name is null or char_length(display_name) between 1 and 50)
);

create table if not exists public.natal_charts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text,
  person_name text,
  calendar_mode text not null default 'solar' check (calendar_mode in ('solar','lunar')),
  birth_date date not null,
  birth_time time,
  birth_time_unknown boolean not null default false,
  birth_timezone text,
  birth_place_label text,
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  input_snapshot jsonb not null default '{}'::jsonb check (jsonb_typeof(input_snapshot)='object'),
  chart_payload jsonb not null check (jsonb_typeof(chart_payload)='object'),
  fingerprint text not null,
  schema_version text not null default '1.0',
  engine_version text,
  is_favorite boolean not null default false,
  calculated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint natal_charts_user_fingerprint_unique unique (user_id,fingerprint),
  constraint natal_charts_id_user_unique unique (id,user_id)
);

create table if not exists public.synastry_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text,
  relationship_type text not null default 'dating',
  chart_a_id uuid references public.natal_charts(id) on delete set null,
  chart_b_id uuid references public.natal_charts(id) on delete set null,
  person_a jsonb not null check (jsonb_typeof(person_a)='object'),
  person_b jsonb not null check (jsonb_typeof(person_b)='object'),
  comparison_payload jsonb not null check (jsonb_typeof(comparison_payload)='object'),
  scores jsonb not null default '{}'::jsonb check (jsonb_typeof(scores)='object'),
  fingerprint text not null,
  schema_version text not null default '1.0',
  engine_version text,
  calculated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint synastry_user_fingerprint_unique unique (user_id,fingerprint),
  constraint synastry_id_user_unique unique (id,user_id)
);

create table if not exists public.ai_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  report_type text not null check (report_type in ('natal','synastry')),
  natal_chart_id uuid,
  synastry_report_id uuid,
  source_fingerprint text not null,
  source_snapshot jsonb not null default '{}'::jsonb check (jsonb_typeof(source_snapshot)='object'),
  prompt_version text not null,
  report_schema_version text not null default '1.0',
  language text not null default 'zh-CN' check (language in ('zh-CN','zh-TW','en')),
  model_provider text,
  model_name text,
  status text not null default 'queued' check (status in ('queued','generating','completed','failed')),
  report_json jsonb check (report_json is null or jsonb_typeof(report_json)='object'),
  report_text text,
  error_message text,
  tokens_input integer check (tokens_input is null or tokens_input>=0),
  tokens_output integer check (tokens_output is null or tokens_output>=0),
  generation_meta jsonb not null default '{}'::jsonb check (jsonb_typeof(generation_meta)='object'),
  idempotency_key text,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ai_reports_source_type_check check (
    (report_type='natal' and natal_chart_id is not null and synastry_report_id is null)
    or (report_type='synastry' and synastry_report_id is not null and natal_chart_id is null)
  ),
  constraint ai_reports_natal_owner_fk foreign key (natal_chart_id,user_id)
    references public.natal_charts(id,user_id) on delete cascade,
  constraint ai_reports_synastry_owner_fk foreign key (synastry_report_id,user_id)
    references public.synastry_reports(id,user_id) on delete cascade
);

create table if not exists public.fortune_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  fortune_date date not null,
  fortune_id smallint not null check (fortune_id between 1 and 60),
  timezone text not null default 'Asia/Taipei',
  language text not null default 'zh-CN' check (language in ('zh-CN','zh-TW','en')),
  fortune_snapshot jsonb not null check (jsonb_typeof(fortune_snapshot)='object'),
  bark_sent_at timestamptz,
  drawn_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint fortune_one_per_user_per_day unique (user_id,fortune_date)
);

create table if not exists public.tarot_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  spread_id text not null,
  topic text,
  question text,
  person_a_name text,
  person_b_name text,
  card_count smallint not null check (card_count between 1 and 10),
  cards jsonb not null check (jsonb_typeof(cards)='array'),
  story text,
  structure jsonb not null default '{}'::jsonb check (jsonb_typeof(structure)='object'),
  final_advice text,
  reading_snapshot jsonb not null check (jsonb_typeof(reading_snapshot)='object'),
  fingerprint text,
  language text not null default 'zh-CN' check (language in ('zh-CN','zh-TW','en')),
  reading_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tarot_question_length check (question is null or char_length(question)<=160)
);

create index if not exists idx_natal_charts_user_created on public.natal_charts (user_id,created_at desc);
create index if not exists idx_natal_charts_user_favorite on public.natal_charts (user_id,is_favorite) where is_favorite=true;
create index if not exists idx_synastry_user_created on public.synastry_reports (user_id,created_at desc);
create index if not exists idx_synastry_relationship_type on public.synastry_reports (user_id,relationship_type);
create index if not exists idx_ai_reports_user_created on public.ai_reports (user_id,created_at desc);
create index if not exists idx_ai_reports_status on public.ai_reports (status,created_at);
create unique index if not exists idx_ai_reports_idempotency on public.ai_reports (user_id,idempotency_key) where idempotency_key is not null;
create unique index if not exists idx_ai_reports_completed_cache on public.ai_reports (user_id,report_type,source_fingerprint,prompt_version,report_schema_version,language) where status='completed';
create index if not exists idx_fortune_user_date on public.fortune_history (user_id,fortune_date desc);
create index if not exists idx_tarot_user_reading_at on public.tarot_history (user_id,reading_at desc);
create unique index if not exists idx_tarot_user_fingerprint on public.tarot_history (user_id,fingerprint) where fingerprint is not null;

create or replace function private.set_updated_at()
returns trigger language plpgsql set search_path='' as $$
begin new.updated_at=now(); return new; end;
$$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['profiles','natal_charts','synastry_reports','ai_reports','fortune_history','tarot_history']
  LOOP
    EXECUTE format('drop trigger if exists trg_%I_updated_at on public.%I', t, t);
    EXECUTE format('create trigger trg_%I_updated_at before update on public.%I for each row execute function private.set_updated_at()', t, t);
  END LOOP;
END $$;

create or replace function private.handle_new_user()
returns trigger language plpgsql security definer set search_path='' as $$
begin
  insert into public.profiles(id,display_name)
  values(new.id,nullif(left(trim(coalesce(new.raw_user_meta_data->>'display_name','')),50),''))
  on conflict(id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function private.handle_new_user();

insert into public.profiles(id,display_name)
select u.id,nullif(left(trim(coalesce(u.raw_user_meta_data->>'display_name','')),50),'')
from auth.users u on conflict(id) do nothing;

alter table public.profiles enable row level security;
alter table public.natal_charts enable row level security;
alter table public.synastry_reports enable row level security;
alter table public.ai_reports enable row level security;
alter table public.fortune_history enable row level security;
alter table public.tarot_history enable row level security;

drop policy if exists profiles_select_own on public.profiles;
drop policy if exists profiles_update_own on public.profiles;
drop policy if exists natal_charts_own_rows on public.natal_charts;
drop policy if exists synastry_reports_own_rows on public.synastry_reports;
drop policy if exists ai_reports_select_own on public.ai_reports;
drop policy if exists ai_reports_delete_own on public.ai_reports;
drop policy if exists fortune_history_own_rows on public.fortune_history;
drop policy if exists tarot_history_own_rows on public.tarot_history;

create policy profiles_select_own on public.profiles for select to authenticated using ((select auth.uid())=id);
create policy profiles_update_own on public.profiles for update to authenticated using ((select auth.uid())=id) with check ((select auth.uid())=id);
create policy natal_charts_own_rows on public.natal_charts for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy synastry_reports_own_rows on public.synastry_reports for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy ai_reports_select_own on public.ai_reports for select to authenticated using ((select auth.uid())=user_id);
create policy ai_reports_delete_own on public.ai_reports for delete to authenticated using ((select auth.uid())=user_id);
create policy fortune_history_own_rows on public.fortune_history for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy tarot_history_own_rows on public.tarot_history for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);

grant usage on schema public to authenticated,service_role;
revoke all on table public.profiles from public,anon,authenticated;
revoke all on table public.natal_charts from public,anon,authenticated;
revoke all on table public.synastry_reports from public,anon,authenticated;
revoke all on table public.ai_reports from public,anon,authenticated;
revoke all on table public.fortune_history from public,anon,authenticated;
revoke all on table public.tarot_history from public,anon,authenticated;

grant select,update on table public.profiles to authenticated;
grant select,insert,update,delete on table public.natal_charts to authenticated;
grant select,insert,update,delete on table public.synastry_reports to authenticated;
grant select,delete on table public.ai_reports to authenticated;
grant select,insert,update,delete on table public.fortune_history to authenticated;
grant select,insert,update,delete on table public.tarot_history to authenticated;
grant all privileges on table public.profiles,public.natal_charts,public.synastry_reports,public.ai_reports,public.fortune_history,public.tarot_history to service_role;

revoke all on function private.set_updated_at() from public,anon,authenticated;
revoke all on function private.handle_new_user() from public,anon,authenticated;

commit;

-- END 20260917_001_core_schema.sql

-- ============================================================================
-- BEGIN 20260919_002_bark_push_quota.sql
-- ============================================================================
-- Apply once in the Supabase SQL Editor before deploying bark-push.
-- Only the Edge Function's service role can reserve a push slot.
begin;

create schema if not exists private;

create table if not exists private.bark_push_quota (
  day_utc date not null,
  user_id uuid not null,
  push_count integer not null default 0 check (push_count >= 0),
  last_push_at timestamptz not null default now(),
  primary key (day_utc, user_id)
);

alter table private.bark_push_quota enable row level security;
revoke all on table private.bark_push_quota from public, anon, authenticated;

create or replace function public.reserve_bark_push(p_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_day date := (now() at time zone 'UTC')::date;
  v_user_count integer;
  v_global_count integer;
  v_last_push timestamptz;
begin
  if p_user_id is null then return false; end if;

  -- Serialize all reservations so limits stay correct for concurrent requests.
  perform pg_catalog.pg_advisory_xact_lock(5827724470231201);

  select coalesce(sum(push_count), 0)::integer
    into v_global_count
    from private.bark_push_quota
   where day_utc = v_day;
  if v_global_count >= 2000 then return false; end if;

  select push_count, last_push_at
    into v_user_count, v_last_push
    from private.bark_push_quota
   where day_utc = v_day and user_id = p_user_id;
  if coalesce(v_user_count, 0) >= 15 then return false; end if;
  if v_last_push is not null and v_last_push > now() - interval '10 seconds' then
    return false;
  end if;

  insert into private.bark_push_quota(day_utc, user_id, push_count, last_push_at)
  values(v_day, p_user_id, 1, now())
  on conflict (day_utc, user_id) do update
    set push_count = private.bark_push_quota.push_count + 1,
        last_push_at = now();

  delete from private.bark_push_quota where day_utc < v_day - 14;
  return true;
end;
$$;

revoke all on function public.reserve_bark_push(uuid) from public, anon, authenticated;
grant execute on function public.reserve_bark_push(uuid) to service_role;

commit;

-- END 20260919_002_bark_push_quota.sql

-- ============================================================================
-- BEGIN 20260923_003_farm_cloud_save.sql
-- ============================================================================
-- Stellar Diary V0.13.0 — Farm cloud save foundation
-- Run once in Supabase SQL Editor before enabling farm cloud sync.
-- This table is a private per-user cloud save. It is NOT used for public rankings yet.

begin;

create schema if not exists private;
revoke all on schema private from public;
revoke all on schema private from anon, authenticated;

create table if not exists public.farm_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb check (jsonb_typeof(state) = 'object'),
  client_updated_at bigint not null default 0 check (client_updated_at >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_farm_saves_updated_at on public.farm_saves;
create trigger trg_farm_saves_updated_at
before update on public.farm_saves
for each row execute function private.set_updated_at();

alter table public.farm_saves enable row level security;

revoke all on table public.farm_saves from public, anon;
grant select, insert, update, delete on table public.farm_saves to authenticated;

drop policy if exists farm_saves_select_own on public.farm_saves;
create policy farm_saves_select_own
on public.farm_saves
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists farm_saves_insert_own on public.farm_saves;
create policy farm_saves_insert_own
on public.farm_saves
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists farm_saves_update_own on public.farm_saves;
create policy farm_saves_update_own
on public.farm_saves
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists farm_saves_delete_own on public.farm_saves;
create policy farm_saves_delete_own
on public.farm_saves
for delete
to authenticated
using (auth.uid() = user_id);

revoke all on function private.set_updated_at() from public, anon, authenticated;

commit;

-- END 20260923_003_farm_cloud_save.sql

-- ============================================================================
-- BEGIN 20260923_004_farm_rankings_friends.sql
-- ============================================================================
-- Stellar Diary V0.13.1 — Farm rankings + friends foundation
-- Run once in Supabase SQL Editor after 20260923_003_farm_cloud_save.sql.
-- Public reads are exposed only through SECURITY DEFINER RPCs; the private farm save remains RLS-protected.

begin;

create table if not exists public.farm_friendships (
  user_low uuid not null references auth.users(id) on delete cascade,
  user_high uuid not null references auth.users(id) on delete cascade,
  requested_by uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_low, user_high),
  constraint farm_friendships_distinct_users check (user_low <> user_high),
  constraint farm_friendships_requester_is_party check (requested_by = user_low or requested_by = user_high)
);

create index if not exists idx_farm_friendships_low_status on public.farm_friendships (user_low, status);
create index if not exists idx_farm_friendships_high_status on public.farm_friendships (user_high, status);

alter table public.farm_friendships enable row level security;
revoke all on table public.farm_friendships from public, anon, authenticated;
grant all privileges on table public.farm_friendships to service_role;

drop trigger if exists trg_farm_friendships_updated_at on public.farm_friendships;
create trigger trg_farm_friendships_updated_at
before update on public.farm_friendships
for each row execute function private.set_updated_at();

-- Read a real leaderboard from existing farm_saves + profiles.
-- Only a small public-safe subset is returned; private inventory/plots/history stay private.
create or replace function public.get_farm_rankings(
  p_sort text default 'level',
  p_limit integer default 50
)
returns table (
  rank_no bigint,
  user_id uuid,
  display_name text,
  sex text,
  farm_level integer,
  coins bigint,
  relation_state text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_sort text := case when p_sort = 'coins' then 'coins' else 'level' end;
  v_limit integer := greatest(1, least(coalesce(p_limit, 50), 100));
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  with base as (
    select
      fs.user_id,
      coalesce(nullif(trim(p.display_name), ''), '星辰农友') as display_name,
      case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
      least(999, greatest(1,
        case when coalesce(fs.state->>'level','') ~ '^[0-9]+$'
          then (fs.state->>'level')::integer else 1 end
      )) as farm_level,
      least(999999999999::bigint, greatest(0::bigint,
        case when coalesce(fs.state->>'coins','') ~ '^[0-9]+$'
          then (fs.state->>'coins')::bigint else 0::bigint end
      )) as coins,
      case
        when fs.user_id = v_uid then 'self'
        when ff.status = 'accepted' then 'friend'
        when ff.status = 'pending' and ff.requested_by = v_uid then 'pending_out'
        when ff.status = 'pending' then 'pending_in'
        else 'none'
      end as relation_state
    from public.farm_saves fs
    join public.profiles p on p.id = fs.user_id
    left join public.farm_friendships ff
      on ((ff.user_low = v_uid and ff.user_high = fs.user_id)
       or (ff.user_high = v_uid and ff.user_low = fs.user_id))
    where p.display_name is not null
  ), ranked as (
    select
      row_number() over (
        order by
          case when v_sort = 'coins' then base.coins end desc,
          case when v_sort = 'level' then base.farm_level end desc,
          case when v_sort = 'level' then base.coins end desc,
          case when v_sort = 'coins' then base.farm_level end desc,
          base.display_name asc,
          base.user_id asc
      ) as rank_no,
      base.*
    from base
  )
  select r.rank_no, r.user_id, r.display_name, r.sex, r.farm_level, r.coins, r.relation_state
  from ranked r
  order by r.rank_no
  limit v_limit;
end;
$$;

-- One friend request row represents a pair. If both sides request each other,
-- the second request automatically accepts the friendship.
create or replace function public.request_farm_friend(p_target uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_status text;
  v_requested_by uuid;
begin
  if v_uid is null then return 'not_authenticated'; end if;
  if p_target is null or p_target = v_uid then return 'invalid_target'; end if;

  if not exists (
    select 1
    from public.farm_saves fs
    join public.profiles p on p.id = fs.user_id
    where fs.user_id = p_target and p.display_name is not null
  ) then return 'not_found'; end if;

  if v_uid::text < p_target::text then v_low := v_uid; v_high := p_target;
  else v_low := p_target; v_high := v_uid; end if;

  select f.status, f.requested_by into v_status, v_requested_by
  from public.farm_friendships f
  where f.user_low = v_low and f.user_high = v_high;

  if found then
    if v_status = 'accepted' then return 'already_friend'; end if;
    if v_requested_by = v_uid then return 'pending'; end if;
    update public.farm_friendships
      set status = 'accepted'
      where user_low = v_low and user_high = v_high;
    return 'accepted';
  end if;

  insert into public.farm_friendships(user_low, user_high, requested_by, status)
  values(v_low, v_high, v_uid, 'pending');
  return 'requested';
end;
$$;

create or replace function public.respond_farm_friend(p_other uuid, p_accept boolean)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_status text;
  v_requested_by uuid;
begin
  if v_uid is null then return 'not_authenticated'; end if;
  if p_other is null or p_other = v_uid then return 'invalid_target'; end if;

  if v_uid::text < p_other::text then v_low := v_uid; v_high := p_other;
  else v_low := p_other; v_high := v_uid; end if;

  select f.status, f.requested_by into v_status, v_requested_by
  from public.farm_friendships f
  where f.user_low = v_low and f.user_high = v_high;

  if not found then return 'not_found'; end if;
  if v_status = 'accepted' then return 'already_friend'; end if;
  if v_requested_by = v_uid then return 'not_incoming'; end if;

  if coalesce(p_accept, false) then
    update public.farm_friendships set status = 'accepted'
      where user_low = v_low and user_high = v_high;
    return 'accepted';
  end if;

  delete from public.farm_friendships where user_low = v_low and user_high = v_high;
  return 'rejected';
end;
$$;

create or replace function public.remove_farm_friend(p_other uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
begin
  if v_uid is null then return 'not_authenticated'; end if;
  if p_other is null or p_other = v_uid then return 'invalid_target'; end if;

  if v_uid::text < p_other::text then v_low := v_uid; v_high := p_other;
  else v_low := p_other; v_high := v_uid; end if;

  delete from public.farm_friendships
  where user_low = v_low and user_high = v_high;
  if found then return 'removed'; end if;
  return 'not_found';
end;
$$;

create or replace function public.get_farm_friends()
returns table (
  user_id uuid,
  display_name text,
  sex text,
  farm_level integer,
  coins bigint,
  relation_state text,
  requested_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  with pairs as (
    select
      case when f.user_low = v_uid then f.user_high else f.user_low end as other_id,
      f.status,
      f.requested_by,
      f.created_at
    from public.farm_friendships f
    where f.user_low = v_uid or f.user_high = v_uid
  )
  select
    pairs.other_id as user_id,
    coalesce(nullif(trim(p.display_name), ''), '星辰农友') as display_name,
    case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
    least(999, greatest(1,
      case when coalesce(fs.state->>'level','') ~ '^[0-9]+$'
        then (fs.state->>'level')::integer else 1 end
    )) as farm_level,
    least(999999999999::bigint, greatest(0::bigint,
      case when coalesce(fs.state->>'coins','') ~ '^[0-9]+$'
        then (fs.state->>'coins')::bigint else 0::bigint end
    )) as coins,
    case
      when pairs.status = 'accepted' then 'friend'
      when pairs.requested_by = v_uid then 'pending_out'
      else 'pending_in'
    end as relation_state,
    pairs.created_at as requested_at
  from pairs
  join public.profiles p on p.id = pairs.other_id
  left join public.farm_saves fs on fs.user_id = pairs.other_id
  order by
    case
      when pairs.status = 'pending' and pairs.requested_by <> v_uid then 0
      when pairs.status = 'accepted' then 1
      else 2
    end,
    pairs.created_at desc,
    p.display_name asc;
end;
$$;

revoke all on function public.get_farm_rankings(text,integer) from public, anon;
revoke all on function public.request_farm_friend(uuid) from public, anon;
revoke all on function public.respond_farm_friend(uuid,boolean) from public, anon;
revoke all on function public.remove_farm_friend(uuid) from public, anon;
revoke all on function public.get_farm_friends() from public, anon;

grant execute on function public.get_farm_rankings(text,integer) to authenticated;
grant execute on function public.request_farm_friend(uuid) to authenticated;
grant execute on function public.respond_farm_friend(uuid,boolean) to authenticated;
grant execute on function public.remove_farm_friend(uuid) to authenticated;
grant execute on function public.get_farm_friends() to authenticated;

grant execute on function public.get_farm_rankings(text,integer) to service_role;
grant execute on function public.request_farm_friend(uuid) to service_role;
grant execute on function public.respond_farm_friend(uuid,boolean) to service_role;
grant execute on function public.remove_farm_friend(uuid) to service_role;
grant execute on function public.get_farm_friends() to service_role;

commit;

-- END 20260923_004_farm_rankings_friends.sql

-- ============================================================================
-- BEGIN 20260923_005_farm_friend_visits.sql
-- ============================================================================
-- Stellar Diary V0.13.2 — friend farm visit (read-only)
-- Run once in Supabase SQL Editor after migration 004.
-- Only accepted farm friends may read this sanitized visit payload.

begin;

create or replace function public.get_friend_farm(p_friend uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_state jsonb;
  v_updated_at timestamptz;
  v_display_name text;
  v_sex text;
  v_level integer := 1;
  v_coins bigint := 0;
  v_plots jsonb := '[]'::jsonb;
  v_low uuid;
  v_high uuid;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;
  if p_friend is null or p_friend = v_uid then
    return jsonb_build_object('ok', false, 'reason', 'invalid_target');
  end if;

  if v_uid::text < p_friend::text then
    v_low := v_uid;
    v_high := p_friend;
  else
    v_low := p_friend;
    v_high := v_uid;
  end if;

  if not exists (
    select 1
    from public.farm_friendships f
    where f.user_low = v_low
      and f.user_high = v_high
      and f.status = 'accepted'
  ) then
    return jsonb_build_object('ok', false, 'reason', 'not_friend');
  end if;

  select
    fs.state,
    fs.updated_at,
    coalesce(nullif(trim(p.display_name), ''), '星辰农友'),
    case when p.sex in ('male','female') then p.sex else 'unspecified' end
  into v_state, v_updated_at, v_display_name, v_sex
  from public.farm_saves fs
  join public.profiles p on p.id = fs.user_id
  where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  v_level := least(999, greatest(1,
    case when coalesce(v_state->>'level','') ~ '^[0-9]+$'
      then (v_state->>'level')::integer else 1 end
  ));
  v_coins := least(999999999999::bigint, greatest(0::bigint,
    case when coalesce(v_state->>'coins','') ~ '^[0-9]+$'
      then (v_state->>'coins')::bigint else 0::bigint end
  ));

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', (plot.ord - 1)::integer,
      'cropId', case
        when plot.elem->>'cropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
          then plot.elem->>'cropId'
        else null
      end,
      'plantedAt', case
        when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$'
          then (plot.elem->>'plantedAt')::bigint
        else null
      end
    ) order by plot.ord
  ), '[]'::jsonb)
  into v_plots
  from jsonb_array_elements(coalesce(v_state->'plots', '[]'::jsonb)) with ordinality as plot(elem, ord)
  where plot.ord <= 20;

  return jsonb_build_object(
    'ok', true,
    'user_id', p_friend,
    'display_name', v_display_name,
    'sex', v_sex,
    'level', v_level,
    'coins', v_coins,
    'plots', v_plots,
    'updated_at', v_updated_at
  );
end;
$$;

revoke all on function public.get_friend_farm(uuid) from public, anon;
grant execute on function public.get_friend_farm(uuid) to authenticated;
grant execute on function public.get_friend_farm(uuid) to service_role;

commit;

-- END 20260923_005_farm_friend_visits.sql

-- ============================================================================
-- BEGIN 20260924_006_farm_steal.sql
-- ============================================================================
-- Stellar Diary V0.13.4 — friend crop stealing + visit metadata
-- Run once after migration 005. Stealing is server-validated and atomic.
-- Rules: accepted friends only; mature crops only; same friend once per growth cycle;
-- steal 1–3 at random while the owner always keeps at least 1.

begin;

create table if not exists public.farm_steals (
  id bigint generated by default as identity primary key,
  thief_id uuid not null references auth.users(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  plot_id integer not null check (plot_id between 0 and 19),
  planted_at bigint not null check (planted_at > 0),
  crop_id text not null check (crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')),
  amount integer not null check (amount between 1 and 3),
  created_at timestamptz not null default now(),
  constraint farm_steals_distinct_users check (thief_id <> owner_id),
  constraint farm_steals_once_per_friend_cycle unique (thief_id, owner_id, plot_id, planted_at)
);

create index if not exists idx_farm_steals_owner_plot_cycle
  on public.farm_steals(owner_id, plot_id, planted_at);
create index if not exists idx_farm_steals_thief_created
  on public.farm_steals(thief_id, created_at desc);

alter table public.farm_steals enable row level security;
revoke all on table public.farm_steals from public, anon, authenticated;
grant all privileges on table public.farm_steals to service_role;

-- Replace the visit payload so the UI can show stealable mature plots without
-- exposing the owner's inventory, tasks or full private save.
create or replace function public.get_friend_farm(p_friend uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_state jsonb;
  v_updated_at timestamptz;
  v_display_name text;
  v_sex text;
  v_level integer := 1;
  v_coins bigint := 0;
  v_plots jsonb := '[]'::jsonb;
  v_low uuid;
  v_high uuid;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;
  if p_friend is null or p_friend = v_uid then
    return jsonb_build_object('ok', false, 'reason', 'invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low = v_low and f.user_high = v_high and f.status = 'accepted'
  ) then
    return jsonb_build_object('ok', false, 'reason', 'not_friend');
  end if;

  select fs.state, fs.updated_at,
         coalesce(nullif(trim(p.display_name), ''), '星辰农友'),
         case when p.sex in ('male','female') then p.sex else 'unspecified' end
  into v_state, v_updated_at, v_display_name, v_sex
  from public.farm_saves fs
  join public.profiles p on p.id = fs.user_id
  where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  v_level := least(999, greatest(1,
    case when coalesce(v_state->>'level','') ~ '^[0-9]+$'
      then (v_state->>'level')::integer else 1 end));
  v_coins := least(999999999999::bigint, greatest(0::bigint,
    case when coalesce(v_state->>'coins','') ~ '^[0-9]+$'
      then (v_state->>'coins')::bigint else 0::bigint end));

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', (plot.ord - 1)::integer,
      'cropId', case
        when plot.elem->>'cropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery')
          then plot.elem->>'cropId' else null end,
      'plantedAt', case
        when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$'
          then (plot.elem->>'plantedAt')::bigint else null end,
      'resultCropId', case
        when plot.elem->>'resultCropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
          then plot.elem->>'resultCropId' else null end,
      'harvestYield', case
        when coalesce(plot.elem->>'harvestYield','') ~ '^[0-9]+$'
          then least(5, greatest(1, (plot.elem->>'harvestYield')::integer)) else null end,
      'stolenCount', case
        when coalesce(plot.elem->>'stolenCount','') ~ '^[0-9]+$'
          then least(4, greatest(0, (plot.elem->>'stolenCount')::integer)) else 0 end,
      'stolenByMe', exists (
        select 1 from public.farm_steals st
        where st.thief_id = v_uid
          and st.owner_id = p_friend
          and st.plot_id = (plot.ord - 1)::integer
          and st.planted_at = case
            when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$'
              then (plot.elem->>'plantedAt')::bigint else -1 end
      )
    ) order by plot.ord
  ), '[]'::jsonb)
  into v_plots
  from jsonb_array_elements(coalesce(v_state->'plots', '[]'::jsonb)) with ordinality as plot(elem, ord)
  where plot.ord <= 20;

  return jsonb_build_object(
    'ok', true, 'user_id', p_friend, 'display_name', v_display_name, 'sex', v_sex,
    'level', v_level, 'coins', v_coins, 'plots', v_plots, 'updated_at', v_updated_at
  );
end;
$$;

create or replace function public.steal_friend_crop(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_thief_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_grow_minutes integer;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_total integer;
  v_stolen integer := 0;
  v_remaining integer;
  v_max_take integer;
  v_take integer;
  v_current_produce integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok', false, 'reason', 'not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low = v_low and f.user_high = v_high and f.status = 'accepted'
  ) then return jsonb_build_object('ok', false, 'reason', 'not_friend'); end if;

  -- Serialize steals against this owner's farm so concurrent visitors cannot
  -- take past the guaranteed final item.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_friend::text || ':' || p_plot::text, 0));

  select fs.state into v_owner_state
  from public.farm_saves fs where fs.user_id = p_friend for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_farm'); end if;

  select fs.state into v_thief_state
  from public.farm_saves fs where fs.user_id = v_uid for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  v_crop_id := v_plot->>'cropId';
  if v_crop_id is null or v_crop_id = '' then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  if v_crop_id = 'mystery' then return jsonb_build_object('ok', false, 'reason', 'protected'); end if;
  if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;

  if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;
  v_planted_at := (v_plot->>'plantedAt')::bigint;

  v_grow_minutes := case v_crop_id
    when 'carrot' then 20 when 'wheat' then 30 when 'corn' then 30 when 'tomato' then 50
    when 'strawberry' then 90 when 'pumpkin' then 150 when 'grape' then 240 when 'starfruit' then 480
    else 999999 end;
  if v_now_ms - v_planted_at < v_grow_minutes::bigint * 60000 then
    return jsonb_build_object('ok', false, 'reason', 'not_mature');
  end if;

  if exists (
    select 1 from public.farm_steals st
    where st.thief_id = v_uid and st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at
  ) then return jsonb_build_object('ok', false, 'reason', 'already_stolen'); end if;

  if coalesce(v_plot->>'harvestYield','') ~ '^[0-9]+$' then
    v_total := least(5, greatest(4, (v_plot->>'harvestYield')::integer));
  else
    v_total := 4 + floor(random() * 2)::integer;
  end if;

  select coalesce(sum(st.amount), 0)::integer into v_stolen
  from public.farm_steals st
  where st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at;

  v_remaining := v_total - v_stolen;
  if v_remaining <= 1 then return jsonb_build_object('ok', false, 'reason', 'protected', 'remaining', 1); end if;

  v_max_take := least(3, v_remaining - 1);
  v_take := 1 + floor(random() * v_max_take)::integer;

  insert into public.farm_steals(thief_id, owner_id, plot_id, planted_at, crop_id, amount)
  values(v_uid, p_friend, p_plot, v_planted_at, v_crop_id, v_take);
  v_stolen := v_stolen + v_take;
  v_remaining := v_total - v_stolen;

  -- Persist the authoritative yield/steal counters into the owner's sanitized
  -- plot state so their next cloud pull immediately reflects the loss.
  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'harvestYield'], to_jsonb(v_total), true);
  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'stolenCount'], to_jsonb(v_stolen), true);
  v_owner_state := jsonb_set(v_owner_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  v_thief_state := jsonb_set(v_thief_state, '{produce}', coalesce(v_thief_state->'produce', '{}'::jsonb), true);
  if coalesce(v_thief_state->'produce'->>v_crop_id,'') ~ '^[0-9]+$' then
    v_current_produce := (v_thief_state->'produce'->>v_crop_id)::integer;
  end if;
  v_thief_state := jsonb_set(v_thief_state, array['produce', v_crop_id], to_jsonb(v_current_produce + v_take), true);
  v_thief_state := jsonb_set(v_thief_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  update public.farm_saves
    set state = v_owner_state, client_updated_at = v_now_ms
    where user_id = p_friend;
  update public.farm_saves
    set state = v_thief_state, client_updated_at = v_now_ms
    where user_id = v_uid;

  return jsonb_build_object(
    'ok', true,
    'crop_id', v_crop_id,
    'amount', v_take,
    'owner_remaining', v_remaining,
    'thief_state', v_thief_state
  );
end;
$$;

revoke all on function public.get_friend_farm(uuid) from public, anon;
revoke all on function public.steal_friend_crop(uuid,integer) from public, anon;
grant execute on function public.get_friend_farm(uuid) to authenticated, service_role;
grant execute on function public.steal_friend_crop(uuid,integer) to authenticated, service_role;

commit;

-- END 20260924_006_farm_steal.sql

-- ============================================================================
-- BEGIN 20260924_007_farm_save_rpc.sql
-- ============================================================================
-- Stellar Diary V0.13.10 — authoritative farm save RPC
-- Run once in Supabase SQL Editor.
-- Purpose: make browser farm saves reliable by binding writes to auth.uid()
-- server-side instead of relying on a direct RLS table upsert.

begin;

create or replace function public.save_farm_state(
  p_state jsonb,
  p_client_updated_at bigint
)
returns table(
  state jsonb,
  client_updated_at bigint,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_stamp bigint := greatest(coalesce(p_client_updated_at, 0), 0);
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception 'invalid_farm_state' using errcode = '22023';
  end if;

  insert into public.farm_saves(user_id, state, client_updated_at)
  values(v_uid, p_state, v_stamp)
  on conflict (user_id) do update
    set state = excluded.state,
        client_updated_at = excluded.client_updated_at,
        updated_at = now()
    -- Do not allow an older browser request to overwrite a newer farm revision.
    where public.farm_saves.client_updated_at <= excluded.client_updated_at;

  return query
  select fs.state, fs.client_updated_at, fs.updated_at
  from public.farm_saves fs
  where fs.user_id = v_uid;
end;
$$;

revoke all on function public.save_farm_state(jsonb, bigint) from public, anon;
grant execute on function public.save_farm_state(jsonb, bigint) to authenticated;

commit;

-- END 20260924_007_farm_save_rpc.sql

-- ============================================================================
-- BEGIN 20260924_008_farm_revision_guard.sql
-- ============================================================================
-- Stellar Diary V0.13.10 — authoritative farm revision guard
-- Run once after 007.
-- Goals:
-- 1) stop old/cached clients from directly overwriting farm_saves;
-- 2) make every browser save use optimistic concurrency control;
-- 3) reject stale full-state writes instead of letting a later timestamp erase newer data.

begin;

alter table public.farm_saves
  add column if not exists revision bigint not null default 1 check (revision >= 1);


-- Every server-side mutation (including friend stealing from migration 006)
-- must advance the same revision. This trigger makes the revision universal,
-- not only something changed by the browser save RPC.
create or replace function private.bump_farm_revision()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.revision = old.revision + 1;
  return new;
end;
$$;

drop trigger if exists trg_farm_saves_revision on public.farm_saves;
create trigger trg_farm_saves_revision
before update on public.farm_saves
for each row execute function private.bump_farm_revision();

revoke all on function private.bump_farm_revision() from public, anon, authenticated;

-- The browser may read its own save, but must no longer write the table directly.
-- This blocks older site builds / stale tabs that still use .upsert() against farm_saves.
revoke insert, update, delete on table public.farm_saves from authenticated;
grant select on table public.farm_saves to authenticated;

-- Retire the V0.13.9 write RPC for browser clients. Old cached pages will fail closed
-- instead of silently overwriting a newer farm save.
revoke execute on function public.save_farm_state(jsonb, bigint) from authenticated;

create or replace function public.save_farm_state_v2(
  p_state jsonb,
  p_client_updated_at bigint,
  p_expected_revision bigint
)
returns table(
  state jsonb,
  client_updated_at bigint,
  updated_at timestamptz,
  revision bigint,
  applied boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_stamp bigint := greatest(coalesce(p_client_updated_at, 0), 0);
  v_expected bigint := greatest(coalesce(p_expected_revision, 0), 0);
  v_current_revision bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception 'invalid_farm_state' using errcode = '22023';
  end if;

  -- Serialize saves for this user's row while checking the revision.
  select fs.revision
    into v_current_revision
    from public.farm_saves fs
   where fs.user_id = v_uid
   for update;

  if not found then
    if v_expected <> 0 then
      return;
    end if;

    insert into public.farm_saves(user_id, state, client_updated_at, revision)
    values(v_uid, p_state, v_stamp, 1);

    return query
      select fs.state, fs.client_updated_at, fs.updated_at, fs.revision, true
        from public.farm_saves fs
       where fs.user_id = v_uid;
    return;
  end if;

  if v_expected <> v_current_revision then
    return query
      select fs.state, fs.client_updated_at, fs.updated_at, fs.revision, false
        from public.farm_saves fs
       where fs.user_id = v_uid;
    return;
  end if;

  update public.farm_saves fs
     set state = p_state,
         client_updated_at = v_stamp,
         updated_at = now()
   where fs.user_id = v_uid;

  return query
    select fs.state, fs.client_updated_at, fs.updated_at, fs.revision, true
      from public.farm_saves fs
     where fs.user_id = v_uid;
end;
$$;

revoke all on function public.save_farm_state_v2(jsonb, bigint, bigint) from public, anon;
grant execute on function public.save_farm_state_v2(jsonb, bigint, bigint) to authenticated;

commit;

-- END 20260924_008_farm_revision_guard.sql

-- ============================================================================
-- BEGIN 20260924_009_farm_traffic_optimization.sql
-- ============================================================================
-- Stellar Diary V0.13.13 — farm traffic optimization
-- Run once after 008.
-- Goals:
-- 1) successful browser saves return metadata only instead of the full farm JSON;
-- 2) revision conflicts still return the authoritative state so the client can rebase safely;
-- 3) retire the V2 browser RPC so stale builds fail closed instead of wasting bandwidth.

begin;

revoke execute on function public.save_farm_state_v2(jsonb, bigint, bigint) from authenticated;

create or replace function public.save_farm_state_v3(
  p_state jsonb,
  p_client_updated_at bigint,
  p_expected_revision bigint
)
returns table(
  revision bigint,
  client_updated_at bigint,
  updated_at timestamptz,
  applied boolean,
  conflict_state jsonb
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_stamp bigint := greatest(coalesce(p_client_updated_at, 0), 0);
  v_expected bigint := greatest(coalesce(p_expected_revision, 0), 0);
  v_current_revision bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception 'invalid_farm_state' using errcode = '22023';
  end if;

  select fs.revision
    into v_current_revision
    from public.farm_saves fs
   where fs.user_id = v_uid
   for update;

  if not found then
    if v_expected <> 0 then
      return;
    end if;

    insert into public.farm_saves(user_id, state, client_updated_at, revision)
    values(v_uid, p_state, v_stamp, 1);

    return query
      select fs.revision,
             fs.client_updated_at,
             fs.updated_at,
             true,
             null::jsonb
        from public.farm_saves fs
       where fs.user_id = v_uid;
    return;
  end if;

  if v_expected <> v_current_revision then
    return query
      select fs.revision,
             fs.client_updated_at,
             fs.updated_at,
             false,
             fs.state
        from public.farm_saves fs
       where fs.user_id = v_uid;
    return;
  end if;

  update public.farm_saves fs
     set state = p_state,
         client_updated_at = v_stamp,
         updated_at = now()
   where fs.user_id = v_uid;

  return query
    select fs.revision,
           fs.client_updated_at,
           fs.updated_at,
           true,
           null::jsonb
      from public.farm_saves fs
     where fs.user_id = v_uid;
end;
$$;

revoke all on function public.save_farm_state_v3(jsonb, bigint, bigint) from public, anon;
grant execute on function public.save_farm_state_v3(jsonb, bigint, bigint) to authenticated;

commit;

-- END 20260924_009_farm_traffic_optimization.sql

-- ============================================================================
-- BEGIN 20260924_010_farm_achievements_titles.sql
-- ============================================================================
-- Stellar Diary V0.13.14 — achievements + public equipped titles
-- Run once after migrations 004, 006, 008 and 009.
-- Existing farm saves remain intact. This adds v2 multiplayer RPCs that expose
-- only the currently equipped cosmetic title id, and a v2 steal RPC that also
-- increments the thief's long-term steal counter in the authoritative farm save.

begin;

create or replace function public.get_farm_rankings_v2(
  p_sort text default 'level',
  p_limit integer default 50
)
returns table (
  rank_no bigint,
  user_id uuid,
  display_name text,
  sex text,
  farm_level integer,
  coins bigint,
  title_id text,
  relation_state text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_sort text := case when p_sort = 'coins' then 'coins' else 'level' end;
  v_limit integer := greatest(1, least(coalesce(p_limit, 50), 100));
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  with base as (
    select
      fs.user_id,
      coalesce(nullif(trim(p.display_name), ''), '星辰农友') as display_name,
      case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
      least(999, greatest(1,
        case when coalesce(fs.state->>'level','') ~ '^[0-9]+$'
          then (fs.state->>'level')::integer else 1 end
      )) as farm_level,
      least(999999999999::bigint, greatest(0::bigint,
        case when coalesce(fs.state->>'coins','') ~ '^[0-9]+$'
          then (fs.state->>'coins')::bigint else 0::bigint end
      )) as coins,
      left(coalesce(nullif(fs.state->'titles'->>'equipped',''), 'newbie'), 64) as title_id,
      case
        when fs.user_id = v_uid then 'self'
        when ff.status = 'accepted' then 'friend'
        when ff.status = 'pending' and ff.requested_by = v_uid then 'pending_out'
        when ff.status = 'pending' then 'pending_in'
        else 'none'
      end as relation_state
    from public.farm_saves fs
    join public.profiles p on p.id = fs.user_id
    left join public.farm_friendships ff
      on ((ff.user_low = v_uid and ff.user_high = fs.user_id)
       or (ff.user_high = v_uid and ff.user_low = fs.user_id))
    where p.display_name is not null
  ), ranked as (
    select
      row_number() over (
        order by
          case when v_sort = 'coins' then base.coins end desc,
          case when v_sort = 'level' then base.farm_level end desc,
          case when v_sort = 'level' then base.coins end desc,
          case when v_sort = 'coins' then base.farm_level end desc,
          base.display_name asc,
          base.user_id asc
      ) as rank_no,
      base.*
    from base
  )
  select r.rank_no, r.user_id, r.display_name, r.sex, r.farm_level, r.coins, r.title_id, r.relation_state
  from ranked r
  order by r.rank_no
  limit v_limit;
end;
$$;

create or replace function public.get_farm_friends_v2()
returns table (
  user_id uuid,
  display_name text,
  sex text,
  farm_level integer,
  coins bigint,
  title_id text,
  relation_state text,
  requested_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  with pairs as (
    select
      case when f.user_low = v_uid then f.user_high else f.user_low end as other_id,
      f.status,
      f.requested_by,
      f.created_at
    from public.farm_friendships f
    where f.user_low = v_uid or f.user_high = v_uid
  )
  select
    pairs.other_id as user_id,
    coalesce(nullif(trim(p.display_name), ''), '星辰农友') as display_name,
    case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
    least(999, greatest(1,
      case when coalesce(fs.state->>'level','') ~ '^[0-9]+$'
        then (fs.state->>'level')::integer else 1 end
    )) as farm_level,
    least(999999999999::bigint, greatest(0::bigint,
      case when coalesce(fs.state->>'coins','') ~ '^[0-9]+$'
        then (fs.state->>'coins')::bigint else 0::bigint end
    )) as coins,
    left(coalesce(nullif(fs.state->'titles'->>'equipped',''), 'newbie'), 64) as title_id,
    case
      when pairs.status = 'accepted' then 'friend'
      when pairs.requested_by = v_uid then 'pending_out'
      else 'pending_in'
    end as relation_state,
    pairs.created_at as requested_at
  from pairs
  join public.profiles p on p.id = pairs.other_id
  left join public.farm_saves fs on fs.user_id = pairs.other_id
  order by
    case
      when pairs.status = 'pending' and pairs.requested_by <> v_uid then 0
      when pairs.status = 'accepted' then 1
      else 2
    end,
    pairs.created_at desc,
    p.display_name asc;
end;
$$;

create or replace function public.get_friend_farm_v2(p_friend uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_payload jsonb;
  v_title text := 'newbie';
begin
  v_payload := public.get_friend_farm(p_friend);
  if coalesce((v_payload->>'ok')::boolean, false) then
    select left(coalesce(nullif(fs.state->'titles'->>'equipped',''), 'newbie'), 64)
      into v_title
      from public.farm_saves fs
     where fs.user_id = p_friend;
    v_payload := v_payload || jsonb_build_object('title_id', coalesce(v_title, 'newbie'));
  end if;
  return v_payload;
end;
$$;

create or replace function public.steal_friend_crop_v2(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
  v_state jsonb;
  v_stats jsonb;
  v_steals integer := 0;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse the already-audited atomic steal implementation from migration 006.
  v_result := public.steal_friend_crop(p_friend, p_plot);
  if not coalesce((v_result->>'ok')::boolean, false) then
    return v_result;
  end if;

  -- The old RPC has already credited produce. Add the long-term successful
  -- steal counter to the thief's authoritative save in the same request.
  select fs.state into v_state
  from public.farm_saves fs
  where fs.user_id = v_uid
  for update;

  if found then
    v_stats := coalesce(v_state->'stats', '{}'::jsonb);
    if coalesce(v_stats->>'steals','') ~ '^[0-9]+$' then
      v_steals := (v_stats->>'steals')::integer;
    end if;
    v_stats := jsonb_set(v_stats, '{steals}', to_jsonb(v_steals + 1), true);
    v_state := jsonb_set(v_state, '{stats}', v_stats, true);
    v_state := jsonb_set(v_state, '{updatedAt}', to_jsonb(v_now_ms), true);

    update public.farm_saves
       set state = v_state,
           client_updated_at = v_now_ms
     where user_id = v_uid;

    v_result := v_result || jsonb_build_object('thief_state', v_state);
  end if;

  return v_result;
end;
$$;

revoke all on function public.get_farm_rankings_v2(text,integer) from public, anon;
revoke all on function public.get_farm_friends_v2() from public, anon;
revoke all on function public.get_friend_farm_v2(uuid) from public, anon;
revoke all on function public.steal_friend_crop_v2(uuid,integer) from public, anon;

grant execute on function public.get_farm_rankings_v2(text,integer) to authenticated, service_role;
grant execute on function public.get_farm_friends_v2() to authenticated, service_role;
grant execute on function public.get_friend_farm_v2(uuid) to authenticated, service_role;
grant execute on function public.steal_friend_crop_v2(uuid,integer) to authenticated, service_role;

commit;

-- END 20260924_010_farm_achievements_titles.sql

-- ============================================================================
-- BEGIN 20260926_011_farm_crop_sheet2_steal_activity.sql
-- ============================================================================
-- Stellar Diary V0.13.25 — fixed ×1 stealing + steal activity feed
-- Run once after migration 010.
-- Existing farm data and historical steal rows are preserved.

begin;

alter table public.farm_steals
  add column if not exists seen_at timestamptz;

create index if not exists idx_farm_steals_owner_created
  on public.farm_steals(owner_id, created_at desc);

-- Fixed rule: each friend can take exactly one item from a mature plot per
-- growth cycle. The existing unique(thief, owner, plot, planted_at) continues
-- to enforce "same friend, same plant, once per cycle", while the owner always
-- keeps at least one item.
create or replace function public.steal_friend_crop(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_thief_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_grow_minutes integer;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_total integer;
  v_stolen integer := 0;
  v_remaining integer;
  v_take integer := 1;
  v_current_produce integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok', false, 'reason', 'not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low = v_low and f.user_high = v_high and f.status = 'accepted'
  ) then return jsonb_build_object('ok', false, 'reason', 'not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_friend::text || ':' || p_plot::text, 0));

  select fs.state into v_owner_state
  from public.farm_saves fs where fs.user_id = p_friend for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_farm'); end if;

  select fs.state into v_thief_state
  from public.farm_saves fs where fs.user_id = v_uid for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  v_crop_id := v_plot->>'cropId';
  if v_crop_id is null or v_crop_id = '' then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  if v_crop_id = 'mystery' then return jsonb_build_object('ok', false, 'reason', 'protected'); end if;
  if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;

  if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;
  v_planted_at := (v_plot->>'plantedAt')::bigint;

  v_grow_minutes := case v_crop_id
    when 'carrot' then 20 when 'wheat' then 30 when 'corn' then 30 when 'tomato' then 50
    when 'strawberry' then 90 when 'pumpkin' then 150 when 'grape' then 240 when 'starfruit' then 480
    else 999999 end;
  if v_now_ms - v_planted_at < v_grow_minutes::bigint * 60000 then
    return jsonb_build_object('ok', false, 'reason', 'not_mature');
  end if;

  if exists (
    select 1 from public.farm_steals st
    where st.thief_id = v_uid and st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at
  ) then return jsonb_build_object('ok', false, 'reason', 'already_stolen'); end if;

  if coalesce(v_plot->>'harvestYield','') ~ '^[0-9]+$' then
    v_total := least(5, greatest(4, (v_plot->>'harvestYield')::integer));
  else
    v_total := 4 + floor(random() * 2)::integer;
  end if;

  select coalesce(sum(st.amount), 0)::integer into v_stolen
  from public.farm_steals st
  where st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at;

  v_remaining := v_total - v_stolen;
  if v_remaining <= 1 then return jsonb_build_object('ok', false, 'reason', 'protected', 'remaining', 1); end if;

  insert into public.farm_steals(thief_id, owner_id, plot_id, planted_at, crop_id, amount)
  values(v_uid, p_friend, p_plot, v_planted_at, v_crop_id, v_take);

  v_stolen := v_stolen + v_take;
  v_remaining := v_total - v_stolen;

  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'harvestYield'], to_jsonb(v_total), true);
  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'stolenCount'], to_jsonb(v_stolen), true);
  v_owner_state := jsonb_set(v_owner_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  v_thief_state := jsonb_set(v_thief_state, '{produce}', coalesce(v_thief_state->'produce', '{}'::jsonb), true);
  if coalesce(v_thief_state->'produce'->>v_crop_id,'') ~ '^[0-9]+$' then
    v_current_produce := (v_thief_state->'produce'->>v_crop_id)::integer;
  end if;
  v_thief_state := jsonb_set(v_thief_state, array['produce', v_crop_id], to_jsonb(v_current_produce + 1), true);
  v_thief_state := jsonb_set(v_thief_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  update public.farm_saves
     set state = v_owner_state,
         client_updated_at = v_now_ms
   where user_id = p_friend;

  update public.farm_saves
     set state = v_thief_state,
         client_updated_at = v_now_ms
   where user_id = v_uid;

  return jsonb_build_object(
    'ok', true,
    'crop_id', v_crop_id,
    'amount', 1,
    'owner_remaining', v_remaining,
    'thief_state', v_thief_state
  );
end;
$$;

-- V3 is the V0.13.25 public entry point. V2 still exists for older clients,
-- but because the audited base function above is replaced, both paths now use
-- the fixed ×1 rule. V2 also keeps the long-term steal achievement counter.
create or replace function public.steal_friend_crop_v3(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  return public.steal_friend_crop_v2(p_friend, p_plot);
end;
$$;

-- Owner-facing steal history. Only the authenticated farm owner can read their
-- own records. p_mark_seen lets the client mark the returned feed as read while
-- still receiving which rows were new before this call.
create or replace function public.get_farm_steal_activity_v1(
  p_limit integer default 30,
  p_mark_seen boolean default true
)
returns table (
  id bigint,
  thief_id uuid,
  display_name text,
  sex text,
  crop_id text,
  amount integer,
  plot_id integer,
  stolen_at timestamptz,
  is_unread boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_limit integer := greatest(1, least(coalesce(p_limit, 30), 100));
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  select
    st.id,
    st.thief_id,
    coalesce(nullif(trim(p.display_name), ''), '农场好友') as display_name,
    case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
    st.crop_id,
    st.amount,
    st.plot_id,
    st.created_at as stolen_at,
    (st.seen_at is null) as is_unread
  from public.farm_steals st
  left join public.profiles p on p.id = st.thief_id
  where st.owner_id = v_uid
  order by st.created_at desc, st.id desc
  limit v_limit;

  if coalesce(p_mark_seen, true) then
    update public.farm_steals st
       set seen_at = now()
     where st.id in (
       select s.id
       from public.farm_steals s
       where s.owner_id = v_uid
       order by s.created_at desc, s.id desc
       limit v_limit
     )
       and st.seen_at is null;
  end if;
end;
$$;

revoke all on function public.steal_friend_crop_v3(uuid,integer) from public, anon;
revoke all on function public.get_farm_steal_activity_v1(integer,boolean) from public, anon;
grant execute on function public.steal_friend_crop_v3(uuid,integer) to authenticated, service_role;
grant execute on function public.get_farm_steal_activity_v1(integer,boolean) to authenticated, service_role;

commit;

-- END 20260926_011_farm_crop_sheet2_steal_activity.sql

-- ============================================================================
-- BEGIN 20260926_012_farm_daily_tasks.sql
-- ============================================================================
-- Stellar Diary V0.13.26 — server day + daily-task steal counter
-- Run once after migration 011. Existing farm data is preserved.

begin;

-- Authoritative UTC+8 farm day used by the browser for daily resets.
create or replace function public.get_farm_day_v1()
returns text
language sql
volatile
security definer
set search_path = ''
as $$
  select ((clock_timestamp() at time zone 'Asia/Taipei')::date)::text;
$$;

-- V4 keeps the fixed ×1 steal rule from V3, then updates the thief's
-- daily-task counter using the server's UTC+8 date. This avoids relying on
-- the phone/computer clock for the daily steal mission.
create or replace function public.steal_friend_crop_v4(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
  v_state jsonb;
  v_daily jsonb;
  v_day text := ((clock_timestamp() at time zone 'Asia/Taipei')::date)::text;
  v_steal integer := 0;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  v_result := public.steal_friend_crop_v3(p_friend, p_plot);
  if not coalesce((v_result->>'ok')::boolean, false) then
    return v_result;
  end if;

  select fs.state into v_state
  from public.farm_saves fs
  where fs.user_id = v_uid
  for update;

  if found then
    v_daily := coalesce(v_state->'daily', '{}'::jsonb);

    if coalesce(v_daily->>'date', '') <> v_day then
      v_daily := jsonb_build_object(
        'date', v_day,
        'plant', 0,
        'harvest', 0,
        'sell', 0,
        'steal', 0,
        'visitedFriends', '[]'::jsonb,
        'claimed', '[]'::jsonb,
        'bonusClaimed', false
      );
    end if;

    if coalesce(v_daily->>'steal','') ~ '^[0-9]+$' then
      v_steal := (v_daily->>'steal')::integer;
    end if;

    v_daily := jsonb_set(v_daily, '{steal}', to_jsonb(v_steal + 1), true);
    v_state := jsonb_set(v_state, '{daily}', v_daily, true);
    v_state := jsonb_set(v_state, '{updatedAt}', to_jsonb(v_now_ms), true);

    update public.farm_saves
       set state = v_state,
           client_updated_at = v_now_ms
     where user_id = v_uid;

    v_result := v_result || jsonb_build_object('thief_state', v_state, 'farm_day', v_day);
  end if;

  return v_result;
end;
$$;

revoke all on function public.get_farm_day_v1() from public, anon;
revoke all on function public.steal_friend_crop_v4(uuid,integer) from public, anon;
grant execute on function public.get_farm_day_v1() to authenticated, service_role;
grant execute on function public.steal_friend_crop_v4(uuid,integer) to authenticated, service_role;

commit;

-- END 20260926_012_farm_daily_tasks.sql

-- ============================================================================
-- BEGIN 20260926_013_farm_care_tools.sql
-- ============================================================================
-- Stellar Diary V0.13.27 — watering + fertilizer care system
-- Run once after migration 012.
-- Existing farm saves remain valid; new plot keys are optional JSON fields.

begin;

-- Keep server-side steal maturity checks consistent with the client care rules.
-- Watering multiplies the base grow duration by 0.92. A single fertilizer can
-- multiply it again by 0.90 / 0.80 / 0.70. Mystery boxes remain protected.
create or replace function public.steal_friend_crop(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_thief_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_grow_minutes integer;
  v_factor numeric := 1.0;
  v_fertilizer text;
  v_effective_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_total integer;
  v_stolen integer := 0;
  v_remaining integer;
  v_take integer := 1;
  v_current_produce integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok', false, 'reason', 'not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low = v_low and f.user_high = v_high and f.status = 'accepted'
  ) then return jsonb_build_object('ok', false, 'reason', 'not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_friend::text || ':' || p_plot::text, 0));

  select fs.state into v_owner_state
  from public.farm_saves fs where fs.user_id = p_friend for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_farm'); end if;

  select fs.state into v_thief_state
  from public.farm_saves fs where fs.user_id = v_uid for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  v_crop_id := v_plot->>'cropId';
  if v_crop_id is null or v_crop_id = '' then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  if v_crop_id = 'mystery' then return jsonb_build_object('ok', false, 'reason', 'protected'); end if;
  if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;

  if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;
  v_planted_at := (v_plot->>'plantedAt')::bigint;

  v_grow_minutes := case v_crop_id
    when 'carrot' then 20 when 'wheat' then 30 when 'corn' then 30 when 'tomato' then 50
    when 'strawberry' then 90 when 'pumpkin' then 150 when 'grape' then 240 when 'starfruit' then 480
    else 999999 end;

  if coalesce(v_plot->>'watered', 'false') = 'true' then
    v_factor := v_factor * 0.92;
  end if;

  v_fertilizer := coalesce(v_plot->>'fertilizerId', '');
  v_factor := v_factor * case v_fertilizer
    when 'fertilizerLow' then 0.90
    when 'fertilizerMid' then 0.80
    when 'fertilizerHigh' then 0.70
    else 1.00 end;

  v_effective_ms := round(v_grow_minutes::numeric * 60000 * v_factor)::bigint;
  if v_now_ms - v_planted_at < v_effective_ms then
    return jsonb_build_object('ok', false, 'reason', 'not_mature');
  end if;

  if exists (
    select 1 from public.farm_steals st
    where st.thief_id = v_uid and st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at
  ) then return jsonb_build_object('ok', false, 'reason', 'already_stolen'); end if;

  if coalesce(v_plot->>'harvestYield','') ~ '^[0-9]+$' then
    v_total := least(5, greatest(4, (v_plot->>'harvestYield')::integer));
  else
    v_total := 4 + floor(random() * 2)::integer;
  end if;

  select coalesce(sum(st.amount), 0)::integer into v_stolen
  from public.farm_steals st
  where st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at;

  v_remaining := v_total - v_stolen;
  if v_remaining <= 1 then return jsonb_build_object('ok', false, 'reason', 'protected', 'remaining', 1); end if;

  insert into public.farm_steals(thief_id, owner_id, plot_id, planted_at, crop_id, amount)
  values(v_uid, p_friend, p_plot, v_planted_at, v_crop_id, v_take);

  v_stolen := v_stolen + v_take;
  v_remaining := v_total - v_stolen;

  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'harvestYield'], to_jsonb(v_total), true);
  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'stolenCount'], to_jsonb(v_stolen), true);
  v_owner_state := jsonb_set(v_owner_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  v_thief_state := jsonb_set(v_thief_state, '{produce}', coalesce(v_thief_state->'produce', '{}'::jsonb), true);
  if coalesce(v_thief_state->'produce'->>v_crop_id,'') ~ '^[0-9]+$' then
    v_current_produce := (v_thief_state->'produce'->>v_crop_id)::integer;
  end if;
  v_thief_state := jsonb_set(v_thief_state, array['produce', v_crop_id], to_jsonb(v_current_produce + 1), true);
  v_thief_state := jsonb_set(v_thief_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  update public.farm_saves
     set state = v_owner_state,
         client_updated_at = v_now_ms
   where user_id = p_friend;

  update public.farm_saves
     set state = v_thief_state,
         client_updated_at = v_now_ms
   where user_id = v_uid;

  return jsonb_build_object(
    'ok', true,
    'crop_id', v_crop_id,
    'amount', 1,
    'owner_remaining', v_remaining,
    'thief_state', v_thief_state
  );
end;
$$;

revoke all on function public.steal_friend_crop(uuid,integer) from public, anon;
grant execute on function public.steal_friend_crop(uuid,integer) to authenticated, service_role;

commit;

-- END 20260926_013_farm_care_tools.sql

-- ============================================================================
-- BEGIN 20260926_014_farm_activity_center.sql
-- ============================================================================
-- Stellar Diary V0.13.29 — farm activity center
-- Adds visit history and a unified, bounded activity feed for visits + steals.
-- Run once after migration 013. Existing farm/friend/steal data is preserved.

begin;

create table if not exists public.farm_activity (
  id bigint generated always as identity primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  actor_id uuid not null references auth.users(id) on delete cascade,
  activity_type text not null check (activity_type in ('visit','steal','help_bug','friend')),
  crop_id text,
  amount integer,
  plot_id integer,
  source_steal_id bigint unique,
  created_at timestamptz not null default now(),
  seen_at timestamptz,
  check (owner_id <> actor_id)
);

create index if not exists idx_farm_activity_owner_created
  on public.farm_activity(owner_id, created_at desc, id desc);
create index if not exists idx_farm_activity_owner_unread
  on public.farm_activity(owner_id, seen_at) where seen_at is null;
create index if not exists idx_farm_activity_actor_created
  on public.farm_activity(actor_id, created_at desc);

alter table public.farm_activity enable row level security;
revoke all on table public.farm_activity from public, anon, authenticated;

-- Backfill existing steal history into the unified feed. source_steal_id makes
-- the operation safe to rerun and keeps future trigger inserts idempotent.
insert into public.farm_activity(
  owner_id, actor_id, activity_type, crop_id, amount, plot_id,
  source_steal_id, created_at, seen_at
)
select
  st.owner_id,
  st.thief_id,
  'steal',
  st.crop_id,
  greatest(1, coalesce(st.amount, 1)),
  st.plot_id,
  st.id,
  st.created_at,
  st.seen_at
from public.farm_steals st
where st.owner_id <> st.thief_id
on conflict (source_steal_id) do nothing;

-- Keep only the newest 100 display activities per farm owner. farm_steals is
-- never pruned here because it remains the authoritative anti-repeat ledger.
delete from public.farm_activity a
where a.id in (
  select old.id
  from (
    select id, row_number() over (partition by owner_id order by created_at desc, id desc) as rn
    from public.farm_activity
  ) old
  where old.rn > 100
);

create or replace function public.farm_activity_from_steal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.farm_activity(
    owner_id, actor_id, activity_type, crop_id, amount, plot_id,
    source_steal_id, created_at
  ) values (
    new.owner_id, new.thief_id, 'steal', new.crop_id,
    greatest(1, coalesce(new.amount,1)), new.plot_id, new.id, new.created_at
  )
  on conflict (source_steal_id) do nothing;

  delete from public.farm_activity a
  where a.owner_id = new.owner_id
    and a.id in (
      select x.id
      from public.farm_activity x
      where x.owner_id = new.owner_id
      order by x.created_at desc, x.id desc
      offset 100
    );

  return new;
end;
$$;

drop trigger if exists trg_farm_steals_activity on public.farm_steals;
create trigger trg_farm_steals_activity
after insert on public.farm_steals
for each row execute function public.farm_activity_from_steal();

-- V3 returns the same sanitized friend-farm payload as V2 and, for genuine
-- user-initiated visits, writes a visit event. Repeat refreshes within ten
-- minutes are deduplicated so the owner's activity feed cannot be spammed.
create or replace function public.get_friend_farm_v3(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  v_payload := public.get_friend_farm_v2(p_friend);

  if coalesce((v_payload->>'ok')::boolean, false)
     and coalesce(p_log_visit, true)
     and p_friend is not null
     and p_friend <> v_uid then

    if not exists (
      select 1
      from public.farm_activity a
      where a.owner_id = p_friend
        and a.actor_id = v_uid
        and a.activity_type = 'visit'
        and a.created_at > v_now - interval '10 minutes'
    ) then
      insert into public.farm_activity(owner_id, actor_id, activity_type, created_at)
      values(p_friend, v_uid, 'visit', v_now);

      delete from public.farm_activity a
      where a.owner_id = p_friend
        and a.id in (
          select x.id
          from public.farm_activity x
          where x.owner_id = p_friend
          order by x.created_at desc, x.id desc
          offset 100
        );
    end if;
  end if;

  return v_payload;
end;
$$;

create or replace function public.get_farm_activity_v1(
  p_limit integer default 50,
  p_mark_seen boolean default false
)
returns table (
  id bigint,
  activity_type text,
  actor_id uuid,
  display_name text,
  sex text,
  crop_id text,
  amount integer,
  plot_id integer,
  activity_at timestamptz,
  is_unread boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_limit integer := greatest(1, least(coalesce(p_limit, 50), 100));
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  select
    a.id,
    a.activity_type,
    a.actor_id,
    coalesce(nullif(trim(p.display_name), ''), '农场好友') as display_name,
    case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
    a.crop_id,
    a.amount,
    a.plot_id,
    a.created_at as activity_at,
    (a.seen_at is null) as is_unread
  from public.farm_activity a
  left join public.profiles p on p.id = a.actor_id
  where a.owner_id = v_uid
  order by a.created_at desc, a.id desc
  limit v_limit;

  if coalesce(p_mark_seen, false) then
    update public.farm_activity a
       set seen_at = coalesce(a.seen_at, clock_timestamp())
     where a.owner_id = v_uid
       and a.seen_at is null
       and a.id in (
         select x.id
         from public.farm_activity x
         where x.owner_id = v_uid
         order by x.created_at desc, x.id desc
         limit v_limit
       );
  end if;
end;
$$;


create or replace function public.get_farm_activity_unread_v1()
returns integer
language sql
security definer
set search_path = ''
as $$
  select case
    when auth.uid() is null then 0
    else (
      select count(*)::integer
      from public.farm_activity a
      where a.owner_id = auth.uid()
        and a.seen_at is null
    )
  end;
$$;

revoke all on function public.get_friend_farm_v3(uuid,boolean) from public, anon;
revoke all on function public.get_farm_activity_v1(integer,boolean) from public, anon;
revoke all on function public.get_farm_activity_unread_v1() from public, anon;
grant execute on function public.get_friend_farm_v3(uuid,boolean) to authenticated, service_role;
grant execute on function public.get_farm_activity_v1(integer,boolean) to authenticated, service_role;
grant execute on function public.get_farm_activity_unread_v1() to authenticated, service_role;

commit;

-- END 20260926_014_farm_activity_center.sql

-- ============================================================================
-- BEGIN 20260926_015_farm_weather_merchant_pests.sql
-- ============================================================================
-- Stellar Diary V0.13.30 — daily events, traveling merchant, pests and friend pest-help
-- Run once after migration 014. Existing farm saves, friends and activity remain intact.

begin;

-- Friend visit payload V4 exposes only gameplay-safe plot fields needed for
-- crop rendering, stealing and pest assistance. The full private save remains hidden.
create or replace function public.get_friend_farm_v4(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_plots jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V3 for friendship validation, public identity/title and visit logging.
  v_payload := public.get_friend_farm_v3(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', (plot.ord - 1)::integer,
      'cropId', case when plot.elem->>'cropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then plot.elem->>'cropId' else null end,
      'plantedAt', case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else null end,
      'resultCropId', case when plot.elem->>'resultCropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then plot.elem->>'resultCropId' else null end,
      'harvestYield', case when coalesce(plot.elem->>'harvestYield','') ~ '^[0-9]+$' then (plot.elem->>'harvestYield')::integer else null end,
      'stolenCount', case when coalesce(plot.elem->>'stolenCount','') ~ '^[0-9]+$' then (plot.elem->>'stolenCount')::integer else 0 end,
      'stolenByMe', exists (
        select 1 from public.farm_steals st
         where st.thief_id = v_uid and st.owner_id = p_friend
           and st.plot_id = (plot.ord - 1)::integer
           and st.planted_at = case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else -1 end
      ),
      'watered', coalesce((plot.elem->>'watered')::boolean, false),
      'fertilizerId', case when plot.elem->>'fertilizerId' in ('fertilizerLow','fertilizerMid','fertilizerHigh') then plot.elem->>'fertilizerId' else null end,
      'hasPest', coalesce((plot.elem->>'hasPest')::boolean, false)
    ) order by plot.ord
  ), '[]'::jsonb)
  into v_plots
  from jsonb_array_elements(coalesce(v_state->'plots','[]'::jsonb)) with ordinality as plot(elem,ord)
  where plot.ord <= 20;

  return v_payload || jsonb_build_object('plots', v_plots);
end;
$$;

-- A confirmed friend may remove one active pest from one plot. The operation
-- is server-authoritative and atomically updates both farms. A small reward is
-- intentionally probabilistic so helping is fun without becoming a farm-money exploit.
create or replace function public.help_friend_bug_v1(
  p_friend uuid,
  p_plot integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_helper_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_roll double precision := random();
  v_reward_type text := 'none';
  v_reward_amount integer := 0;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_coins bigint := 0;
  v_exp integer := 0;
  v_max_coins bigint := 0;
  v_mystery integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok',false,'reason','invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
     where f.user_low = v_low and f.user_high = v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('bug:' || p_friend::text || ':' || p_plot::text,0));

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend for update;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null or coalesce(v_plot->>'cropId','') = '' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  if not coalesce((v_plot->>'hasPest')::boolean,false) then return jsonb_build_object('ok',false,'reason','no_pest'); end if;
  v_crop_id := v_plot->>'cropId';

  select fs.state into v_helper_state from public.farm_saves fs where fs.user_id=v_uid for update;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'hasPest'],'false'::jsonb,true);
  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;

  -- 45% coins, 35% EXP, 10% mystery box, 10% simple good deed.
  if v_roll < 0.45 then
    v_reward_type := 'coins';
    v_reward_amount := 2 + floor(random()*4)::integer;
    if coalesce(v_helper_state->>'coins','') ~ '^[0-9]+$' then v_coins := (v_helper_state->>'coins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{coins}',to_jsonb(v_coins + v_reward_amount),true);
    v_helper_state := jsonb_set(v_helper_state,'{stats}',coalesce(v_helper_state->'stats','{}'::jsonb),true);
    if coalesce(v_helper_state->'stats'->>'maxCoins','') ~ '^[0-9]+$' then v_max_coins := (v_helper_state->'stats'->>'maxCoins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{stats,maxCoins}',to_jsonb(greatest(v_max_coins,v_coins+v_reward_amount)),true);
  elsif v_roll < 0.80 then
    v_reward_type := 'exp';
    v_reward_amount := 3 + floor(random()*6)::integer;
    if coalesce(v_helper_state->>'exp','') ~ '^[0-9]+$' then v_exp := (v_helper_state->>'exp')::integer; end if;
    v_helper_state := jsonb_set(v_helper_state,'{exp}',to_jsonb(v_exp + v_reward_amount),true);
  elsif v_roll < 0.90 then
    v_reward_type := 'mystery';
    v_reward_amount := 1;
    v_helper_state := jsonb_set(v_helper_state,'{seeds}',coalesce(v_helper_state->'seeds','{}'::jsonb),true);
    if coalesce(v_helper_state->'seeds'->>'mystery','') ~ '^[0-9]+$' then v_mystery := (v_helper_state->'seeds'->>'mystery')::integer; end if;
    v_helper_state := jsonb_set(v_helper_state,'{seeds,mystery}',to_jsonb(v_mystery+1),true);
  end if;

  v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  update public.farm_saves set state=v_helper_state,client_updated_at=v_now_ms where user_id=v_uid;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(p_friend,v_uid,'help_bug',v_crop_id,case when v_reward_type='none' then null else v_reward_amount end,p_plot,clock_timestamp());

  delete from public.farm_activity a
   where a.owner_id=p_friend and a.id in (
    select x.id from public.farm_activity x where x.owner_id=p_friend order by x.created_at desc,x.id desc offset 100
   );

  return jsonb_build_object(
    'ok',true,'crop_id',v_crop_id,'plot_id',p_plot,
    'reward_type',v_reward_type,'reward_amount',v_reward_amount,
    'helper_state',v_helper_state
  );
end;
$$;

revoke all on function public.get_friend_farm_v4(uuid,boolean) from public,anon;
revoke all on function public.help_friend_bug_v1(uuid,integer) from public,anon;
grant execute on function public.get_friend_farm_v4(uuid,boolean) to authenticated,service_role;
grant execute on function public.help_friend_bug_v1(uuid,integer) to authenticated,service_role;

commit;

-- END 20260926_015_farm_weather_merchant_pests.sql

-- ============================================================================
-- BEGIN 20260926_016_farm_4h_weather_clock.sql
-- ============================================================================
-- Stellar Diary V0.13.32 — 4-hour farm weather clock + locked sunny growth factor
-- Run once after migration 015. Existing saves remain valid.

begin;

-- Authoritative UTC+8 farm clock. Daily tasks still reset once per calendar day,
-- while weather / merchant events use one of six 4-hour slots each day.
create or replace function public.get_farm_clock_v1()
returns jsonb
language sql
volatile
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'day', (q.ts::date)::text,
    'slot_index', floor(extract(hour from q.ts) / 4)::integer,
    'slot_key', (q.ts::date)::text || '-' || (floor(extract(hour from q.ts) / 4)::integer)::text,
    'slot_start_hour', (floor(extract(hour from q.ts) / 4)::integer * 4),
    'slot_end_hour', ((floor(extract(hour from q.ts) / 4)::integer + 1) * 4),
    'server_ms', floor(extract(epoch from clock_timestamp()) * 1000)::bigint
  )
  from (select clock_timestamp() at time zone 'Asia/Taipei' as ts) q;
$$;

-- Keep friend-farm rendering aware of the growth factor that was locked in at
-- planting time. Old plots simply behave as factor 1.0.
create or replace function public.get_friend_farm_v4(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_plots jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  v_payload := public.get_friend_farm_v3(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', (plot.ord - 1)::integer,
      'cropId', case when plot.elem->>'cropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then plot.elem->>'cropId' else null end,
      'plantedAt', case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else null end,
      'resultCropId', case when plot.elem->>'resultCropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then plot.elem->>'resultCropId' else null end,
      'harvestYield', case when coalesce(plot.elem->>'harvestYield','') ~ '^[0-9]+$' then (plot.elem->>'harvestYield')::integer else null end,
      'stolenCount', case when coalesce(plot.elem->>'stolenCount','') ~ '^[0-9]+$' then (plot.elem->>'stolenCount')::integer else 0 end,
      'stolenByMe', exists (
        select 1 from public.farm_steals st
         where st.thief_id = v_uid and st.owner_id = p_friend
           and st.plot_id = (plot.ord - 1)::integer
           and st.planted_at = case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else -1 end
      ),
      'watered', coalesce((plot.elem->>'watered')::boolean, false),
      'fertilizerId', case when plot.elem->>'fertilizerId' in ('fertilizerLow','fertilizerMid','fertilizerHigh') then plot.elem->>'fertilizerId' else null end,
      'hasPest', coalesce((plot.elem->>'hasPest')::boolean, false),
      'eventGrowFactor', case
        when coalesce(plot.elem->>'eventGrowFactor','') ~ '^[0-9]+([.][0-9]+)?$'
          then greatest(0.90, least(1.0, (plot.elem->>'eventGrowFactor')::numeric))
        else 1.0
      end
    ) order by plot.ord
  ), '[]'::jsonb)
  into v_plots
  from jsonb_array_elements(coalesce(v_state->'plots','[]'::jsonb)) with ordinality as plot(elem,ord)
  where plot.ord <= 20;

  return v_payload || jsonb_build_object('plots', v_plots);
end;
$$;

-- Replace the audited base steal function so maturity checks also include the
-- sunny growth factor captured when a crop was planted. The V2/V3/V4 wrappers
-- continue to call this function, so no client-facing steal RPC changes are needed.
create or replace function public.steal_friend_crop(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_thief_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_grow_minutes integer;
  v_factor numeric := 1.0;
  v_fertilizer text;
  v_event_factor numeric := 1.0;
  v_effective_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_total integer;
  v_stolen integer := 0;
  v_remaining integer;
  v_take integer := 1;
  v_current_produce integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok', false, 'reason', 'not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low = v_low and f.user_high = v_high and f.status = 'accepted'
  ) then return jsonb_build_object('ok', false, 'reason', 'not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_friend::text || ':' || p_plot::text, 0));

  select fs.state into v_owner_state
  from public.farm_saves fs where fs.user_id = p_friend for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_farm'); end if;

  select fs.state into v_thief_state
  from public.farm_saves fs where fs.user_id = v_uid for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  v_crop_id := v_plot->>'cropId';
  if v_crop_id is null or v_crop_id = '' then return jsonb_build_object('ok', false, 'reason', 'no_crop'); end if;
  if v_crop_id = 'mystery' then return jsonb_build_object('ok', false, 'reason', 'protected'); end if;
  if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;

  if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then
    return jsonb_build_object('ok', false, 'reason', 'no_crop');
  end if;
  v_planted_at := (v_plot->>'plantedAt')::bigint;

  v_grow_minutes := case v_crop_id
    when 'carrot' then 20 when 'wheat' then 30 when 'corn' then 30 when 'tomato' then 50
    when 'strawberry' then 90 when 'pumpkin' then 150 when 'grape' then 240 when 'starfruit' then 480
    else 999999 end;

  if coalesce(v_plot->>'watered', 'false') = 'true' then
    v_factor := v_factor * 0.92;
  end if;

  v_fertilizer := coalesce(v_plot->>'fertilizerId', '');
  v_factor := v_factor * case v_fertilizer
    when 'fertilizerLow' then 0.90
    when 'fertilizerMid' then 0.80
    when 'fertilizerHigh' then 0.70
    else 1.00 end;

  if coalesce(v_plot->>'eventGrowFactor','') ~ '^[0-9]+([.][0-9]+)?$' then
    v_event_factor := greatest(0.90, least(1.0, (v_plot->>'eventGrowFactor')::numeric));
  end if;
  v_factor := v_factor * v_event_factor;

  v_effective_ms := round(v_grow_minutes::numeric * 60000 * v_factor)::bigint;
  if v_now_ms - v_planted_at < v_effective_ms then
    return jsonb_build_object('ok', false, 'reason', 'not_mature');
  end if;

  if exists (
    select 1 from public.farm_steals st
    where st.thief_id = v_uid and st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at
  ) then return jsonb_build_object('ok', false, 'reason', 'already_stolen'); end if;

  if coalesce(v_plot->>'harvestYield','') ~ '^[0-9]+$' then
    v_total := least(5, greatest(4, (v_plot->>'harvestYield')::integer));
  else
    v_total := 4 + floor(random() * 2)::integer;
  end if;

  select coalesce(sum(st.amount), 0)::integer into v_stolen
  from public.farm_steals st
  where st.owner_id = p_friend and st.plot_id = p_plot and st.planted_at = v_planted_at;

  v_remaining := v_total - v_stolen;
  if v_remaining <= 1 then return jsonb_build_object('ok', false, 'reason', 'protected', 'remaining', 1); end if;

  insert into public.farm_steals(thief_id, owner_id, plot_id, planted_at, crop_id, amount)
  values(v_uid, p_friend, p_plot, v_planted_at, v_crop_id, v_take);

  v_stolen := v_stolen + v_take;
  v_remaining := v_total - v_stolen;

  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'harvestYield'], to_jsonb(v_total), true);
  v_owner_state := jsonb_set(v_owner_state, array['plots', p_plot::text, 'stolenCount'], to_jsonb(v_stolen), true);
  v_owner_state := jsonb_set(v_owner_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  v_thief_state := jsonb_set(v_thief_state, '{produce}', coalesce(v_thief_state->'produce', '{}'::jsonb), true);
  if coalesce(v_thief_state->'produce'->>v_crop_id,'') ~ '^[0-9]+$' then
    v_current_produce := (v_thief_state->'produce'->>v_crop_id)::integer;
  end if;
  v_thief_state := jsonb_set(v_thief_state, array['produce', v_crop_id], to_jsonb(v_current_produce + 1), true);
  v_thief_state := jsonb_set(v_thief_state, '{updatedAt}', to_jsonb(v_now_ms), true);

  update public.farm_saves
     set state = v_owner_state,
         client_updated_at = v_now_ms
   where user_id = p_friend;

  update public.farm_saves
     set state = v_thief_state,
         client_updated_at = v_now_ms
   where user_id = v_uid;

  return jsonb_build_object(
    'ok', true,
    'crop_id', v_crop_id,
    'amount', 1,
    'owner_remaining', v_remaining,
    'thief_state', v_thief_state
  );
end;
$$;

revoke all on function public.get_farm_clock_v1() from public, anon;
revoke all on function public.get_friend_farm_v4(uuid,boolean) from public, anon;
revoke all on function public.steal_friend_crop(uuid,integer) from public, anon;
grant execute on function public.get_farm_clock_v1() to authenticated, service_role;
grant execute on function public.get_friend_farm_v4(uuid,boolean) to authenticated, service_role;
grant execute on function public.steal_friend_crop(uuid,integer) to authenticated, service_role;

commit;

-- END 20260926_016_farm_4h_weather_clock.sql

-- ============================================================================
-- BEGIN 20260927_017_farm_decorations.sql
-- ============================================================================
-- Stellar Diary V0.14.0 — farm decorations and friend-visible layout
-- Run once after migration 016. Decoration ownership/layout lives inside the existing farm state JSON.
-- This migration only exposes a sanitized 8-slot layout to confirmed friends.

begin;

create or replace function public.get_friend_farm_v5(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_slots jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V4 for friendship validation, public profile, plots and visit logging.
  v_payload := public.get_friend_farm_v4(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  select coalesce(jsonb_agg(
    case
      when (v_state #>> array['decorations','slots',g.i::text]) in
        ('hay','barrels','flowerbed','wheel','birdhouse','bench','scarecrow','lamp','windmill','sign')
      then to_jsonb(v_state #>> array['decorations','slots',g.i::text])
      else 'null'::jsonb
    end order by g.i
  ), '[]'::jsonb)
  into v_slots
  from generate_series(0,7) as g(i);

  return v_payload || jsonb_build_object(
    'decorations', jsonb_build_object('slots', v_slots)
  );
end;
$$;

revoke all on function public.get_friend_farm_v5(uuid,boolean) from public, anon;
grant execute on function public.get_friend_farm_v5(uuid,boolean) to authenticated, service_role;

commit;

-- END 20260927_017_farm_decorations.sql

-- ============================================================================
-- BEGIN 20260927_018_system_mail_gm.sql
-- ============================================================================
-- Stellar Diary V0.16.1 — GM roles + system mailbox + atomic reward claiming
-- Run ONCE in Supabase SQL Editor after the existing farm migrations.
-- First GM is bootstrapped by immutable Auth UUID, not by email.

begin;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'gm' check (role in ('super_admin','gm','support')),
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.system_mail (
  id bigint generated by default as identity primary key,
  title text not null check (char_length(title) between 1 and 120),
  body text not null default '' check (char_length(body) <= 6000),
  mail_type text not null default 'announcement' check (mail_type in ('announcement','reward')),
  audience_type text not null default 'all' check (audience_type in ('all','user')),
  target_user_id uuid references auth.users(id) on delete cascade,
  rewards jsonb not null default '{}'::jsonb check (jsonb_typeof(rewards) = 'object'),
  starts_at timestamptz not null default now(),
  expires_at timestamptz,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint system_mail_target_check check (
    (audience_type = 'all' and target_user_id is null)
    or (audience_type = 'user' and target_user_id is not null)
  ),
  constraint system_mail_expiry_check check (expires_at is null or expires_at > starts_at)
);

create index if not exists system_mail_active_idx on public.system_mail(starts_at desc, expires_at);
create index if not exists system_mail_target_idx on public.system_mail(target_user_id, starts_at desc);

create table if not exists public.player_mail_state (
  user_id uuid not null references auth.users(id) on delete cascade,
  mail_id bigint not null references public.system_mail(id) on delete cascade,
  read_at timestamptz,
  claimed_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (user_id, mail_id)
);

create index if not exists player_mail_state_user_idx on public.player_mail_state(user_id, read_at, claimed_at);

create table if not exists public.gm_audit_log (
  id bigint generated by default as identity primary key,
  gm_user_id uuid not null references auth.users(id) on delete restrict,
  action text not null,
  subject_id text,
  detail jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists gm_audit_log_created_idx on public.gm_audit_log(created_at desc);

alter table public.admin_users enable row level security;
alter table public.system_mail enable row level security;
alter table public.player_mail_state enable row level security;
alter table public.gm_audit_log enable row level security;

revoke all on table public.admin_users from public, anon, authenticated;
revoke all on table public.system_mail from public, anon, authenticated;
revoke all on table public.player_mail_state from public, anon, authenticated;
revoke all on table public.gm_audit_log from public, anon, authenticated;

-- Fresh-install note: no initial GM is hard-coded here.
-- After creating/signing in with the site-owner account, run
-- supabase/SET_FIRST_GM.sql with that account's Auth user UUID.

create or replace function private.is_stellar_gm(p_uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists(
    select 1 from public.admin_users a
    where a.user_id = p_uid and a.role in ('super_admin','gm')
  );
$$;

create or replace function private.farm_exp_need(p_level integer)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case p_level
    when 1 then 100 when 2 then 140 when 3 then 190 when 4 then 250 when 5 then 320
    when 6 then 400 when 7 then 500 when 8 then 620 when 9 then 750 when 10 then 900
    when 11 then 1060 when 12 then 1230 when 13 then 1410 when 14 then 1600 when 15 then 1800
    when 16 then 2010 when 17 then 2230 when 18 then 2460 when 19 then 2700 when 20 then 2950
    when 21 then 3210 when 22 then 3480 when 23 then 3760 when 24 then 4050 when 25 then 4350
    else 4350 + greatest(0, p_level - 25) * 350
  end;
$$;

create or replace function private.validate_mail_rewards(p_rewards jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_key text;
  v_value jsonb;
  v_num numeric;
begin
  if p_rewards is null or jsonb_typeof(p_rewards) <> 'object' then
    raise exception 'invalid_rewards' using errcode='22023';
  end if;

  if (p_rewards - 'coins' - 'exp' - 'seeds' - 'supplies') <> '{}'::jsonb then
    raise exception 'unknown_reward_key' using errcode='22023';
  end if;

  foreach v_key in array array['coins','exp'] loop
    if p_rewards ? v_key then
      begin v_num := (p_rewards->>v_key)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 1000000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end if;
  end loop;

  if p_rewards ? 'seeds' then
    if jsonb_typeof(p_rewards->'seeds') <> 'object' then raise exception 'invalid_seed_rewards'; end if;
    for v_key, v_value in select key, value from jsonb_each(p_rewards->'seeds') loop
      if v_key not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then
        raise exception 'unknown_seed_reward';
      end if;
      begin v_num := trim(both '"' from v_value::text)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 100000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;

  if p_rewards ? 'supplies' then
    if jsonb_typeof(p_rewards->'supplies') <> 'object' then raise exception 'invalid_supply_rewards'; end if;
    for v_key, v_value in select key, value from jsonb_each(p_rewards->'supplies') loop
      if v_key not in ('fertilizerLow','fertilizerMid','fertilizerHigh') then raise exception 'unknown_supply_reward'; end if;
      begin v_num := trim(both '"' from v_value::text)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 100000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;
end;
$$;

create or replace function public.is_gm_v1()
returns table(is_gm boolean, role text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    return query select false, null::text;
    return;
  end if;
  return query
    select true, a.role from public.admin_users a where a.user_id = v_uid and a.role in ('super_admin','gm')
    union all
    select false, null::text where not exists(select 1 from public.admin_users a2 where a2.user_id = v_uid and a2.role in ('super_admin','gm'))
    limit 1;
end;
$$;

create or replace function public.get_mailbox_v1(p_limit integer default 60)
returns table(
  id bigint,
  title text,
  body text,
  mail_type text,
  rewards jsonb,
  starts_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz,
  read_at timestamptz,
  claimed_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  return query
    select m.id, m.title, m.body, m.mail_type, m.rewards, m.starts_at, m.expires_at, m.created_at,
           s.read_at, s.claimed_at
      from public.system_mail m
      left join public.player_mail_state s on s.user_id = v_uid and s.mail_id = m.id
     where m.starts_at <= now()
       and (m.expires_at is null or m.expires_at > now())
       and (m.audience_type = 'all' or (m.audience_type = 'user' and m.target_user_id = v_uid))
     order by m.created_at desc, m.id desc
     limit least(greatest(coalesce(p_limit,60),1),100);
end;
$$;

create or replace function public.get_mailbox_unread_v1()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select case when auth.uid() is null then 0 else (
    select count(*)::integer
    from public.system_mail m
    left join public.player_mail_state s on s.user_id = auth.uid() and s.mail_id = m.id
    where m.starts_at <= now()
      and (m.expires_at is null or m.expires_at > now())
      and (m.audience_type = 'all' or (m.audience_type = 'user' and m.target_user_id = auth.uid()))
      and s.read_at is null
  ) end;
$$;

create or replace function public.mark_system_mail_read_v1(p_mail_id bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(
    select 1 from public.system_mail m
    where m.id = p_mail_id and m.starts_at <= now() and (m.expires_at is null or m.expires_at > now())
      and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
  ) then return false; end if;

  insert into public.player_mail_state(user_id,mail_id,read_at)
  values(v_uid,p_mail_id,now())
  on conflict(user_id,mail_id) do update set read_at = coalesce(public.player_mail_state.read_at, excluded.read_at);
  return true;
end;
$$;

create or replace function public.claim_system_mail_v1(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_rewards jsonb;
  v_state jsonb;
  v_claimed timestamptz;
  v_key text;
  v_value jsonb;
  v_qty integer;
  v_current integer;
  v_coins integer;
  v_exp integer;
  v_level integer;
  v_need integer;
  v_revision bigint;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(select 1 from auth.users u where u.id=v_uid and nullif(u.email,'') is not null) then
    return query select false,'member_required','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  select m.rewards into v_rewards
  from public.system_mail m
  where m.id=p_mail_id and m.starts_at<=now() and (m.expires_at is null or m.expires_at>now())
    and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
  for share;
  if not found then return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint; return; end if;
  perform private.validate_mail_rewards(v_rewards);
  if v_rewards = '{}'::jsonb then return query select false,'no_attachments',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,claimed_at)
  values(v_uid,p_mail_id,now(),null)
  on conflict(user_id,mail_id) do nothing;

  select s.claimed_at into v_claimed
  from public.player_mail_state s where s.user_id=v_uid and s.mail_id=p_mail_id
  for update;
  if v_claimed is not null then return query select false,'already_claimed',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.farm_saves(user_id,state,client_updated_at)
  values(
    v_uid,
    jsonb_build_object(
      'version',1,'createdAt',floor(extract(epoch from now())*1000)::bigint,
      'coins',100,'level',1,'exp',0,'plots','[]'::jsonb,
      'seeds',jsonb_build_object('carrot',3,'wheat',2),'produce','{}'::jsonb,
      'supplies',jsonb_build_object('fertilizerLow',0,'fertilizerMid',0,'fertilizerHigh',0),
      'stats',jsonb_build_object('visit',1,'plant',0,'harvest',0,'sell',0,'friend',0,'blindBoxPlant',0,'steals',0,'maxCoins',100),
      'updatedAt',floor(extract(epoch from now())*1000)::bigint
    ),
    floor(extract(epoch from now())*1000)::bigint
  ) on conflict(user_id) do nothing;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=v_uid for update;
  v_state := coalesce(v_state,'{}'::jsonb);

  v_coins := greatest(0,coalesce(nullif(v_state->>'coins','')::integer,0)) + greatest(0,coalesce((v_rewards->>'coins')::integer,0));
  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins),true);
  v_state := jsonb_set(v_state,'{stats}',coalesce(v_state->'stats','{}'::jsonb),true);
  v_current := greatest(v_coins,coalesce(nullif(v_state->'stats'->>'maxCoins','')::integer,0));
  v_state := jsonb_set(v_state,'{stats,maxCoins}',to_jsonb(v_current),true);

  v_state := jsonb_set(v_state,'{seeds}',coalesce(v_state->'seeds','{}'::jsonb),true);
  if v_rewards ? 'seeds' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'seeds') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_state := jsonb_set(v_state,'{supplies}',coalesce(v_state->'supplies','{}'::jsonb),true);
  if v_rewards ? 'supplies' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'supplies') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_level := greatest(1,coalesce(nullif(v_state->>'level','')::integer,1));
  v_exp := greatest(0,coalesce(nullif(v_state->>'exp','')::integer,0)) + greatest(0,coalesce((v_rewards->>'exp')::integer,0));
  loop
    v_need := private.farm_exp_need(v_level);
    exit when v_exp < v_need;
    v_exp := v_exp - v_need;
    v_level := v_level + 1;
  end loop;
  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(floor(extract(epoch from now())*1000)::bigint),true);

  update public.farm_saves fs
     set state=v_state, client_updated_at=floor(extract(epoch from now())*1000)::bigint, updated_at=now()
   where fs.user_id=v_uid
   returning fs.revision into v_revision;

  update public.player_mail_state
     set read_at=coalesce(read_at,now()), claimed_at=now()
   where user_id=v_uid and mail_id=p_mail_id;

  return query select true,'claimed',v_rewards,v_state,v_revision;
end;
$$;

create or replace function public.gm_send_system_mail_v1(
  p_title text,
  p_body text default '',
  p_mail_type text default 'announcement',
  p_audience_type text default 'all',
  p_target_user_id uuid default null,
  p_rewards jsonb default '{}'::jsonb,
  p_starts_at timestamptz default now(),
  p_expires_at timestamptz default null
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_id bigint;
begin
  if v_uid is null or not private.is_stellar_gm(v_uid) then raise exception 'gm_forbidden' using errcode='42501'; end if;
  if char_length(trim(coalesce(p_title,''))) < 1 or char_length(trim(p_title)) > 120 then raise exception 'invalid_title'; end if;
  if char_length(coalesce(p_body,'')) > 6000 then raise exception 'body_too_long'; end if;
  if p_mail_type not in ('announcement','reward') then raise exception 'invalid_mail_type'; end if;
  if p_audience_type not in ('all','user') then raise exception 'invalid_audience_type'; end if;
  if p_audience_type='all' then p_target_user_id := null; end if;
  if p_audience_type='user' and (p_target_user_id is null or not exists(select 1 from auth.users u where u.id=p_target_user_id)) then raise exception 'invalid_target_user'; end if;
  if p_expires_at is not null and p_expires_at <= coalesce(p_starts_at,now()) then raise exception 'invalid_expiry'; end if;
  perform private.validate_mail_rewards(coalesce(p_rewards,'{}'::jsonb));

  insert into public.system_mail(title,body,mail_type,audience_type,target_user_id,rewards,starts_at,expires_at,created_by)
  values(trim(p_title),coalesce(p_body,''),p_mail_type,p_audience_type,p_target_user_id,coalesce(p_rewards,'{}'::jsonb),coalesce(p_starts_at,now()),p_expires_at,v_uid)
  returning id into v_id;

  insert into public.gm_audit_log(gm_user_id,action,subject_id,detail)
  values(v_uid,'send_system_mail',v_id::text,jsonb_build_object('title',trim(p_title),'mail_type',p_mail_type,'audience_type',p_audience_type,'target_user_id',p_target_user_id,'rewards',coalesce(p_rewards,'{}'::jsonb)));
  return v_id;
end;
$$;

create or replace function public.gm_list_system_mail_v1(p_limit integer default 30)
returns table(
  id bigint,title text,mail_type text,audience_type text,target_user_id uuid,rewards jsonb,
  starts_at timestamptz,expires_at timestamptz,created_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null or not private.is_stellar_gm(v_uid) then raise exception 'gm_forbidden' using errcode='42501'; end if;
  return query select m.id,m.title,m.mail_type,m.audience_type,m.target_user_id,m.rewards,m.starts_at,m.expires_at,m.created_at
    from public.system_mail m order by m.created_at desc,m.id desc limit least(greatest(coalesce(p_limit,30),1),100);
end;
$$;

revoke all on function private.is_stellar_gm(uuid) from public,anon,authenticated;
revoke all on function private.farm_exp_need(integer) from public,anon,authenticated;
revoke all on function private.validate_mail_rewards(jsonb) from public,anon,authenticated;

revoke all on function public.is_gm_v1() from public,anon;
revoke all on function public.get_mailbox_v1(integer) from public,anon;
revoke all on function public.get_mailbox_unread_v1() from public,anon;
revoke all on function public.mark_system_mail_read_v1(bigint) from public,anon;
revoke all on function public.claim_system_mail_v1(bigint) from public,anon;
revoke all on function public.gm_send_system_mail_v1(text,text,text,text,uuid,jsonb,timestamptz,timestamptz) from public,anon;
revoke all on function public.gm_list_system_mail_v1(integer) from public,anon;

grant execute on function public.is_gm_v1() to authenticated;
grant execute on function public.get_mailbox_v1(integer) to authenticated;
grant execute on function public.get_mailbox_unread_v1() to authenticated;
grant execute on function public.mark_system_mail_read_v1(bigint) to authenticated;
grant execute on function public.claim_system_mail_v1(bigint) to authenticated;
grant execute on function public.gm_send_system_mail_v1(text,text,text,text,uuid,jsonb,timestamptz,timestamptz) to authenticated;
grant execute on function public.gm_list_system_mail_v1(integer) to authenticated;

commit;

-- END 20260927_018_system_mail_gm.sql

-- ============================================================================
-- BEGIN 20260927_019_mail_item_catalog.sql
-- ============================================================================
-- Stellar Diary V0.16.1 — Mail item catalog + item-ID reward attachments
-- Run AFTER 20260927_018_system_mail_gm.sql.
-- Existing V0.16.0 mail remains claimable; new GM mail uses stable item_id values.

begin;

create table if not exists public.mail_item_catalog (
  item_id integer primary key,
  item_code text not null unique,
  category text not null check (category in ('currency','box','seed','supply')),
  reward_kind text not null check (reward_kind in ('coin','exp','seed','supply')),
  state_key text,
  name_zh_cn text not null,
  name_zh_tw text not null,
  name_en text not null,
  icon_source text not null default 'farm' check (icon_source in ('farm','farm_item','site')),
  icon_key text,
  icon_cell integer,
  max_quantity integer not null default 100000 check (max_quantity > 0),
  sort_order integer not null default 0,
  mail_enabled boolean not null default true,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mail_item_catalog_code_check check (item_code ~ '^[a-z0-9]+([._-][a-z0-9]+)*$'),
  constraint mail_item_catalog_state_key_check check (
    (reward_kind in ('coin','exp') and state_key is null)
    or (reward_kind in ('seed','supply') and nullif(state_key,'') is not null)
  )
);

alter table public.mail_item_catalog enable row level security;
revoke all on table public.mail_item_catalog from public, anon, authenticated;

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(1001,'currency.coin','currency','coin',null,'金币','金幣','Coins','farm','coin',null,1000000,10,true,true),
(1002,'currency.exp','currency','exp',null,'EXP','EXP','EXP','farm','exp',null,1000000,20,true,true),
(2001,'box.mystery','box','seed','mystery','蔬果盲盒','蔬果盲盒','Produce mystery box','farm','reward-box',null,100000,30,true,true),
(3001,'seed.carrot','seed','seed','carrot','红萝卜种子','紅蘿蔔種子','Carrot seeds','farm','seed-carrot',null,100000,101,true,true),
(3002,'seed.wheat','seed','seed','wheat','小麦种子','小麥種子','Wheat seeds','farm','seed-wheat',null,100000,102,true,true),
(3003,'seed.corn','seed','seed','corn','玉米种子','玉米種子','Corn seeds','farm','seed-corn',null,100000,103,true,true),
(3004,'seed.tomato','seed','seed','tomato','番茄种子','番茄種子','Tomato seeds','farm','seed-tomato',null,100000,104,true,true),
(3005,'seed.strawberry','seed','seed','strawberry','草莓种子','草莓種子','Strawberry seeds','farm','seed-strawberry',null,100000,105,true,true),
(3006,'seed.pumpkin','seed','seed','pumpkin','南瓜种子','南瓜種子','Pumpkin seeds','farm','seed-pumpkin',null,100000,106,true,true),
(3007,'seed.grape','seed','seed','grape','葡萄种子','葡萄種子','Grape seeds','farm','seed-grape',null,100000,107,true,true),
(3008,'seed.starfruit','seed','seed','starfruit','星辰果种子','星辰果種子','Starfruit seeds','farm','seed-starfruit',null,100000,108,true,true),
(4001,'supply.fertilizer_low','supply','supply','fertilizerLow','低级肥料','低級肥料','Basic fertilizer','farm_item',null,5,100000,201,true,true),
(4002,'supply.fertilizer_mid','supply','supply','fertilizerMid','中级肥料','中級肥料','Medium fertilizer','farm_item',null,6,100000,202,true,true),
(4003,'supply.fertilizer_high','supply','supply','fertilizerHigh','高级肥料','高級肥料','Advanced fertilizer','farm_item',null,7,100000,203,true,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

-- Authenticated players may retrieve the safe public item catalog only through RPC.
create or replace function public.get_mail_item_catalog_v1()
returns table(
  item_id integer,
  item_code text,
  category text,
  name_zh_cn text,
  name_zh_tw text,
  name_en text,
  icon_source text,
  icon_key text,
  icon_cell integer,
  max_quantity integer,
  sort_order integer
)
language sql
stable
security definer
set search_path = ''
as $$
  select c.item_id,c.item_code,c.category,c.name_zh_cn,c.name_zh_tw,c.name_en,
         c.icon_source,c.icon_key,c.icon_cell,c.max_quantity,c.sort_order
    from public.mail_item_catalog c
   where c.active and c.mail_enabled
   order by c.sort_order,c.item_id;
$$;

-- GM-only UID lookup so targeted mail can be verified before publishing.
create or replace function public.gm_lookup_player_v1(p_user_id uuid)
returns table(user_id uuid, display_name text, email text, farm_level integer)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null or not private.is_stellar_gm(v_uid) then
    raise exception 'gm_forbidden' using errcode='42501';
  end if;
  return query
    select u.id,
           coalesce(nullif(trim(p.display_name),''),'未设置名称')::text,
           coalesce(u.email,'')::text,
           greatest(1,coalesce(nullif(fs.state->>'level','')::integer,1))
      from auth.users u
      left join public.profiles p on p.id=u.id
      left join public.farm_saves fs on fs.user_id=u.id
     where u.id=p_user_id;
end;
$$;

-- V0.16.1 reward validator: accepts new {items:[{item_id,quantity}]} format,
-- while retaining V0.16.0 legacy fields so already-issued mail never breaks.
create or replace function private.validate_mail_rewards(p_rewards jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_key text;
  v_value jsonb;
  v_num numeric;
  v_item jsonb;
  v_item_id integer;
  v_qty integer;
  v_max integer;
begin
  if p_rewards is null or jsonb_typeof(p_rewards) <> 'object' then
    raise exception 'invalid_rewards' using errcode='22023';
  end if;

  if (p_rewards - 'items' - 'coins' - 'exp' - 'seeds' - 'supplies') <> '{}'::jsonb then
    raise exception 'unknown_reward_key' using errcode='22023';
  end if;

  if p_rewards ? 'items' then
    if jsonb_typeof(p_rewards->'items') <> 'array' then raise exception 'invalid_reward_items'; end if;
    if jsonb_array_length(p_rewards->'items') > 20 then raise exception 'too_many_reward_items'; end if;
    if (select count(*) from jsonb_array_elements(p_rewards->'items')) <>
       (select count(distinct (value->>'item_id')) from jsonb_array_elements(p_rewards->'items')) then
      raise exception 'duplicate_reward_item';
    end if;
    for v_item in select value from jsonb_array_elements(p_rewards->'items') loop
      if jsonb_typeof(v_item) <> 'object' or (v_item - 'item_id' - 'quantity') <> '{}'::jsonb then
        raise exception 'invalid_reward_item';
      end if;
      begin
        v_item_id := (v_item->>'item_id')::integer;
        v_qty := (v_item->>'quantity')::integer;
      exception when others then raise exception 'invalid_reward_item'; end;
      select c.max_quantity into v_max
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if not found then raise exception 'unknown_item_id:%',v_item_id; end if;
      if v_qty <= 0 or v_qty > v_max then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;

  foreach v_key in array array['coins','exp'] loop
    if p_rewards ? v_key then
      begin v_num := (p_rewards->>v_key)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 1000000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end if;
  end loop;

  if p_rewards ? 'seeds' then
    if jsonb_typeof(p_rewards->'seeds') <> 'object' then raise exception 'invalid_seed_rewards'; end if;
    for v_key,v_value in select key,value from jsonb_each(p_rewards->'seeds') loop
      if v_key not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then raise exception 'unknown_seed_reward'; end if;
      begin v_num := trim(both '"' from v_value::text)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 100000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;

  if p_rewards ? 'supplies' then
    if jsonb_typeof(p_rewards->'supplies') <> 'object' then raise exception 'invalid_supply_rewards'; end if;
    for v_key,v_value in select key,value from jsonb_each(p_rewards->'supplies') loop
      if v_key not in ('fertilizerLow','fertilizerMid','fertilizerHigh') then raise exception 'unknown_supply_reward'; end if;
      begin v_num := trim(both '"' from v_value::text)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 100000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;
end;
$$;

-- Replace claim RPC to understand both stable item IDs and legacy rewards.
create or replace function public.claim_system_mail_v1(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_rewards jsonb;
  v_state jsonb;
  v_claimed timestamptz;
  v_key text;
  v_value jsonb;
  v_qty integer;
  v_current integer;
  v_coins integer;
  v_exp integer;
  v_exp_bonus integer := 0;
  v_level integer;
  v_need integer;
  v_revision bigint;
  v_item jsonb;
  v_item_id integer;
  v_kind text;
  v_state_key text;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(select 1 from auth.users u where u.id=v_uid and nullif(u.email,'') is not null) then
    return query select false,'member_required','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  select m.rewards into v_rewards
    from public.system_mail m
   where m.id=p_mail_id and m.starts_at<=now() and (m.expires_at is null or m.expires_at>now())
     and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
   for share;
  if not found then return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint; return; end if;
  perform private.validate_mail_rewards(v_rewards);
  if v_rewards='{}'::jsonb or (v_rewards ? 'items' and jsonb_array_length(v_rewards->'items')=0 and (v_rewards-'items')='{}'::jsonb) then
    return query select false,'no_attachments',v_rewards,null::jsonb,null::bigint; return;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,claimed_at)
  values(v_uid,p_mail_id,now(),null)
  on conflict(user_id,mail_id) do nothing;

  select s.claimed_at into v_claimed
    from public.player_mail_state s where s.user_id=v_uid and s.mail_id=p_mail_id for update;
  if v_claimed is not null then return query select false,'already_claimed',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.farm_saves(user_id,state,client_updated_at)
  values(v_uid,jsonb_build_object(
      'version',1,'createdAt',floor(extract(epoch from now())*1000)::bigint,
      'coins',100,'level',1,'exp',0,'plots','[]'::jsonb,
      'seeds',jsonb_build_object('carrot',3,'wheat',2),'produce','{}'::jsonb,
      'supplies',jsonb_build_object('fertilizerLow',0,'fertilizerMid',0,'fertilizerHigh',0),
      'stats',jsonb_build_object('visit',1,'plant',0,'harvest',0,'sell',0,'friend',0,'blindBoxPlant',0,'steals',0,'maxCoins',100),
      'updatedAt',floor(extract(epoch from now())*1000)::bigint),
    floor(extract(epoch from now())*1000)::bigint)
  on conflict(user_id) do nothing;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=v_uid for update;
  v_state := coalesce(v_state,'{}'::jsonb);
  v_state := jsonb_set(v_state,'{seeds}',coalesce(v_state->'seeds','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{supplies}',coalesce(v_state->'supplies','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{stats}',coalesce(v_state->'stats','{}'::jsonb),true);

  v_coins := greatest(0,coalesce(nullif(v_state->>'coins','')::integer,0));
  v_exp_bonus := greatest(0,coalesce((v_rewards->>'exp')::integer,0));

  -- New item-ID attachment format.
  if v_rewards ? 'items' then
    for v_item in select value from jsonb_array_elements(v_rewards->'items') loop
      v_item_id := (v_item->>'item_id')::integer;
      v_qty := (v_item->>'quantity')::integer;
      select c.reward_kind,c.state_key into v_kind,v_state_key
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if v_kind='coin' then
        v_coins := v_coins + v_qty;
      elsif v_kind='exp' then
        v_exp_bonus := v_exp_bonus + v_qty;
      elsif v_kind='seed' then
        v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['seeds',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='supply' then
        v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['supplies',v_state_key],to_jsonb(v_current+v_qty),true);
      end if;
    end loop;
  end if;

  -- Legacy V0.16.0 attachments remain supported.
  v_coins := v_coins + greatest(0,coalesce((v_rewards->>'coins')::integer,0));
  if v_rewards ? 'seeds' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'seeds') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;
  if v_rewards ? 'supplies' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'supplies') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins),true);
  v_current := greatest(v_coins,coalesce(nullif(v_state->'stats'->>'maxCoins','')::integer,0));
  v_state := jsonb_set(v_state,'{stats,maxCoins}',to_jsonb(v_current),true);

  v_level := greatest(1,coalesce(nullif(v_state->>'level','')::integer,1));
  v_exp := greatest(0,coalesce(nullif(v_state->>'exp','')::integer,0)) + v_exp_bonus;
  loop
    v_need := private.farm_exp_need(v_level);
    exit when v_exp < v_need;
    v_exp := v_exp-v_need;
    v_level := v_level+1;
  end loop;
  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(floor(extract(epoch from now())*1000)::bigint),true);

  update public.farm_saves fs
     set state=v_state,client_updated_at=floor(extract(epoch from now())*1000)::bigint,updated_at=now()
   where fs.user_id=v_uid
   returning fs.revision into v_revision;

  update public.player_mail_state
     set read_at=coalesce(read_at,now()),claimed_at=now()
   where user_id=v_uid and mail_id=p_mail_id;

  return query select true,'claimed',v_rewards,v_state,v_revision;
end;
$$;

revoke all on function public.get_mail_item_catalog_v1() from public,anon;
revoke all on function public.gm_lookup_player_v1(uuid) from public,anon;
grant execute on function public.get_mail_item_catalog_v1() to authenticated;
grant execute on function public.gm_lookup_player_v1(uuid) to authenticated;

commit;

-- END 20260927_019_mail_item_catalog.sql

-- ============================================================================
-- BEGIN 20260927_020_mail_actions_expiry.sql
-- ============================================================================
-- Stellar Diary V0.16.2 — mailbox actions / soft delete / expiry UX support
-- Run AFTER 20260927_019_mail_item_catalog.sql.
-- Player deletion is per-account soft deletion; the GM/system mail record is retained.

begin;

alter table public.player_mail_state
  add column if not exists deleted_at timestamptz;

create index if not exists player_mail_state_deleted_idx
  on public.player_mail_state(user_id, deleted_at, read_at, claimed_at);

create or replace function public.get_mailbox_v1(p_limit integer default 60)
returns table(
  id bigint,
  title text,
  body text,
  mail_type text,
  rewards jsonb,
  starts_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz,
  read_at timestamptz,
  claimed_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  return query
    select m.id, m.title, m.body, m.mail_type, m.rewards, m.starts_at, m.expires_at, m.created_at,
           s.read_at, s.claimed_at
      from public.system_mail m
      left join public.player_mail_state s on s.user_id = v_uid and s.mail_id = m.id
     where m.starts_at <= now()
       and (m.expires_at is null or m.expires_at > now())
       and (m.audience_type = 'all' or (m.audience_type = 'user' and m.target_user_id = v_uid))
       and s.deleted_at is null
     order by (s.read_at is null) desc, m.created_at desc, m.id desc
     limit least(greatest(coalesce(p_limit,60),1),100);
end;
$$;

create or replace function public.get_mailbox_unread_v1()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select case when auth.uid() is null then 0 else (
    select count(*)::integer
    from public.system_mail m
    left join public.player_mail_state s on s.user_id = auth.uid() and s.mail_id = m.id
    where m.starts_at <= now()
      and (m.expires_at is null or m.expires_at > now())
      and (m.audience_type = 'all' or (m.audience_type = 'user' and m.target_user_id = auth.uid()))
      and s.deleted_at is null
      and s.read_at is null
  ) end;
$$;

create or replace function public.mark_system_mail_read_v1(p_mail_id bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if exists(
    select 1 from public.player_mail_state s
     where s.user_id=v_uid and s.mail_id=p_mail_id and s.deleted_at is not null
  ) then return false; end if;
  if not exists(
    select 1 from public.system_mail m
    where m.id = p_mail_id and m.starts_at <= now() and (m.expires_at is null or m.expires_at > now())
      and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
  ) then return false; end if;

  insert into public.player_mail_state(user_id,mail_id,read_at)
  values(v_uid,p_mail_id,now())
  on conflict(user_id,mail_id) do update
    set read_at = coalesce(public.player_mail_state.read_at, excluded.read_at)
    where public.player_mail_state.deleted_at is null;
  return true;
end;
$$;

create or replace function public.delete_system_mail_v1(p_mail_id bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(
    select 1 from public.system_mail m
     where m.id=p_mail_id
       and m.starts_at<=now()
       and (m.expires_at is null or m.expires_at>now())
       and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
  ) then return false; end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,deleted_at)
  values(v_uid,p_mail_id,now(),now())
  on conflict(user_id,mail_id) do update
    set read_at=coalesce(public.player_mail_state.read_at,excluded.read_at),
        deleted_at=coalesce(public.player_mail_state.deleted_at,excluded.deleted_at);
  return true;
end;
$$;

create or replace function public.claim_system_mail_v1(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_rewards jsonb;
  v_state jsonb;
  v_claimed timestamptz;
  v_key text;
  v_value jsonb;
  v_qty integer;
  v_current integer;
  v_coins integer;
  v_exp integer;
  v_exp_bonus integer := 0;
  v_level integer;
  v_need integer;
  v_revision bigint;
  v_item jsonb;
  v_item_id integer;
  v_kind text;
  v_state_key text;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(select 1 from auth.users u where u.id=v_uid and nullif(u.email,'') is not null) then
    return query select false,'member_required','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  if exists(
    select 1 from public.player_mail_state s
     where s.user_id=v_uid and s.mail_id=p_mail_id and s.deleted_at is not null
  ) then
    return query select false,'mail_deleted','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  select m.rewards into v_rewards
    from public.system_mail m
   where m.id=p_mail_id and m.starts_at<=now() and (m.expires_at is null or m.expires_at>now())
     and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
   for share;
  if not found then return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint; return; end if;
  perform private.validate_mail_rewards(v_rewards);
  if v_rewards='{}'::jsonb or (v_rewards ? 'items' and jsonb_array_length(v_rewards->'items')=0 and (v_rewards-'items')='{}'::jsonb) then
    return query select false,'no_attachments',v_rewards,null::jsonb,null::bigint; return;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,claimed_at)
  values(v_uid,p_mail_id,now(),null)
  on conflict(user_id,mail_id) do nothing;

  select s.claimed_at into v_claimed
    from public.player_mail_state s where s.user_id=v_uid and s.mail_id=p_mail_id for update;
  if v_claimed is not null then return query select false,'already_claimed',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.farm_saves(user_id,state,client_updated_at)
  values(v_uid,jsonb_build_object(
      'version',1,'createdAt',floor(extract(epoch from now())*1000)::bigint,
      'coins',100,'level',1,'exp',0,'plots','[]'::jsonb,
      'seeds',jsonb_build_object('carrot',3,'wheat',2),'produce','{}'::jsonb,
      'supplies',jsonb_build_object('fertilizerLow',0,'fertilizerMid',0,'fertilizerHigh',0),
      'stats',jsonb_build_object('visit',1,'plant',0,'harvest',0,'sell',0,'friend',0,'blindBoxPlant',0,'steals',0,'maxCoins',100),
      'updatedAt',floor(extract(epoch from now())*1000)::bigint),
    floor(extract(epoch from now())*1000)::bigint)
  on conflict(user_id) do nothing;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=v_uid for update;
  v_state := coalesce(v_state,'{}'::jsonb);
  v_state := jsonb_set(v_state,'{seeds}',coalesce(v_state->'seeds','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{supplies}',coalesce(v_state->'supplies','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{stats}',coalesce(v_state->'stats','{}'::jsonb),true);

  v_coins := greatest(0,coalesce(nullif(v_state->>'coins','')::integer,0));
  v_exp_bonus := greatest(0,coalesce((v_rewards->>'exp')::integer,0));

  -- New item-ID attachment format.
  if v_rewards ? 'items' then
    for v_item in select value from jsonb_array_elements(v_rewards->'items') loop
      v_item_id := (v_item->>'item_id')::integer;
      v_qty := (v_item->>'quantity')::integer;
      select c.reward_kind,c.state_key into v_kind,v_state_key
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if v_kind='coin' then
        v_coins := v_coins + v_qty;
      elsif v_kind='exp' then
        v_exp_bonus := v_exp_bonus + v_qty;
      elsif v_kind='seed' then
        v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['seeds',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='supply' then
        v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['supplies',v_state_key],to_jsonb(v_current+v_qty),true);
      end if;
    end loop;
  end if;

  -- Legacy V0.16.0 attachments remain supported.
  v_coins := v_coins + greatest(0,coalesce((v_rewards->>'coins')::integer,0));
  if v_rewards ? 'seeds' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'seeds') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;
  if v_rewards ? 'supplies' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'supplies') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins),true);
  v_current := greatest(v_coins,coalesce(nullif(v_state->'stats'->>'maxCoins','')::integer,0));
  v_state := jsonb_set(v_state,'{stats,maxCoins}',to_jsonb(v_current),true);

  v_level := greatest(1,coalesce(nullif(v_state->>'level','')::integer,1));
  v_exp := greatest(0,coalesce(nullif(v_state->>'exp','')::integer,0)) + v_exp_bonus;
  loop
    v_need := private.farm_exp_need(v_level);
    exit when v_exp < v_need;
    v_exp := v_exp-v_need;
    v_level := v_level+1;
  end loop;
  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(floor(extract(epoch from now())*1000)::bigint),true);

  update public.farm_saves fs
     set state=v_state,client_updated_at=floor(extract(epoch from now())*1000)::bigint,updated_at=now()
   where fs.user_id=v_uid
   returning fs.revision into v_revision;

  update public.player_mail_state
     set read_at=coalesce(read_at,now()),claimed_at=now()
   where user_id=v_uid and mail_id=p_mail_id;

  return query select true,'claimed',v_rewards,v_state,v_revision;
end;
$$;


revoke all on function public.delete_system_mail_v1(bigint) from public,anon;
grant execute on function public.delete_system_mail_v1(bigint) to authenticated;

commit;

-- END 20260927_020_mail_actions_expiry.sql

-- ============================================================================
-- BEGIN 20260927_021_mail_bulk_cleanup.sql
-- ============================================================================
-- Stellar Diary V0.16.3 — bulk cleanup of claimed player mail
begin;

create or replace function public.clear_claimed_system_mail_v1()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_count integer := 0;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  -- Player-local soft delete only. This never deletes the shared system_mail row,
  -- never touches unclaimed reward mail, and never removes plain announcements
  -- unless that mail actually has a claimed_at state.
  update public.player_mail_state s
     set deleted_at = coalesce(s.deleted_at, now()),
         read_at = coalesce(s.read_at, now())
   where s.user_id = v_uid
     and s.claimed_at is not null
     and s.deleted_at is null;

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.clear_claimed_system_mail_v1() from public, anon;
grant execute on function public.clear_claimed_system_mail_v1() to authenticated;

commit;

-- END 20260927_021_mail_bulk_cleanup.sql

-- ============================================================================
-- BEGIN 20260928_022_mailbox_v1_final.sql
-- ============================================================================
-- Stellar Diary V0.16.5 — System Mail V1 finalization
-- Run AFTER 20260927_021_mail_bulk_cleanup.sql.
-- Adds recipient scope (future/current players), GM withdrawal, and hardens
-- player visibility/claim eligibility around cutoff + withdrawal state.

begin;

alter table public.system_mail
  add column if not exists recipient_cutoff_at timestamptz,
  add column if not exists withdrawn_at timestamptz,
  add column if not exists withdrawn_by uuid references auth.users(id) on delete set null;

create index if not exists system_mail_recipient_cutoff_idx
  on public.system_mail(recipient_cutoff_at);
create index if not exists system_mail_withdrawn_idx
  on public.system_mail(withdrawn_at, created_at desc);

-- V0.16.4 emergency cutoff script used an Auth INSERT trigger. V0.16.5 no longer
-- needs per-new-user state writes: eligibility is checked directly against
-- auth.users.created_at, so future registrations cost zero mailbox writes.
drop trigger if exists stellar_hide_cutoff_mail_for_new_user on auth.users;
drop function if exists public.hide_cutoff_mail_for_new_user_v1();

create or replace function private.mail_is_visible_to_user_v2(
  p_mail_id bigint,
  p_uid uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists(
    select 1
      from public.system_mail m
      join auth.users u on u.id = p_uid
      left join public.player_mail_state s
        on s.user_id = p_uid and s.mail_id = m.id
     where m.id = p_mail_id
       and m.withdrawn_at is null
       and m.starts_at <= now()
       and (m.expires_at is null or m.expires_at > now())
       and s.deleted_at is null
       and (
         (m.audience_type = 'user' and m.target_user_id = p_uid)
         or
         (m.audience_type = 'all'
          and (m.recipient_cutoff_at is null or u.created_at <= m.recipient_cutoff_at))
       )
  );
$$;

create or replace function public.get_mailbox_v1(p_limit integer default 60)
returns table(
  id bigint,
  title text,
  body text,
  mail_type text,
  rewards jsonb,
  starts_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz,
  read_at timestamptz,
  claimed_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_user_created_at timestamptz;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  select u.created_at into v_user_created_at
    from auth.users u where u.id = v_uid;

  return query
    select m.id, m.title, m.body, m.mail_type, m.rewards,
           m.starts_at, m.expires_at, m.created_at,
           s.read_at, s.claimed_at
      from public.system_mail m
      left join public.player_mail_state s
        on s.user_id = v_uid and s.mail_id = m.id
     where m.withdrawn_at is null
       and m.starts_at <= now()
       and (m.expires_at is null or m.expires_at > now())
       and s.deleted_at is null
       and (
         (m.audience_type = 'user' and m.target_user_id = v_uid)
         or
         (m.audience_type = 'all'
          and (m.recipient_cutoff_at is null or v_user_created_at <= m.recipient_cutoff_at))
       )
     order by (s.read_at is null) desc, m.created_at desc, m.id desc
     limit least(greatest(coalesce(p_limit,60),1),100);
end;
$$;

create or replace function public.get_mailbox_unread_v1()
returns integer
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_user_created_at timestamptz;
  v_count integer := 0;
begin
  if v_uid is null then return 0; end if;

  select u.created_at into v_user_created_at
    from auth.users u where u.id = v_uid;

  select count(*)::integer into v_count
    from public.system_mail m
    left join public.player_mail_state s
      on s.user_id = v_uid and s.mail_id = m.id
   where m.withdrawn_at is null
     and m.starts_at <= now()
     and (m.expires_at is null or m.expires_at > now())
     and s.deleted_at is null
     and s.read_at is null
     and (
       (m.audience_type = 'user' and m.target_user_id = v_uid)
       or
       (m.audience_type = 'all'
        and (m.recipient_cutoff_at is null or v_user_created_at <= m.recipient_cutoff_at))
     );

  return coalesce(v_count,0);
end;
$$;

create or replace function public.mark_system_mail_read_v1(p_mail_id bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;
  if not private.mail_is_visible_to_user_v2(p_mail_id, v_uid) then
    return false;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at)
  values(v_uid,p_mail_id,now())
  on conflict(user_id,mail_id) do update
    set read_at = coalesce(public.player_mail_state.read_at, excluded.read_at)
    where public.player_mail_state.deleted_at is null;
  return true;
end;
$$;

create or replace function public.delete_system_mail_v1(p_mail_id bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;
  if not private.mail_is_visible_to_user_v2(p_mail_id, v_uid) then
    return false;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,deleted_at)
  values(v_uid,p_mail_id,now(),now())
  on conflict(user_id,mail_id) do update
    set read_at=coalesce(public.player_mail_state.read_at,excluded.read_at),
        deleted_at=coalesce(public.player_mail_state.deleted_at,excluded.deleted_at);
  return true;
end;
$$;

-- V2 is the hardened claim entrypoint. The legacy V1 implementation remains
-- as the atomic reward engine but is no longer executable by client roles.
create or replace function public.claim_system_mail_v2(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_allowed boolean := false;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  -- Row share lock prevents a GM withdrawal from racing past an in-flight claim.
  select true into v_allowed
    from public.system_mail m
    join auth.users u on u.id = v_uid
    left join public.player_mail_state s
      on s.user_id=v_uid and s.mail_id=m.id
   where m.id=p_mail_id
     and m.withdrawn_at is null
     and m.starts_at<=now()
     and (m.expires_at is null or m.expires_at>now())
     and s.deleted_at is null
     and (
       (m.audience_type='user' and m.target_user_id=v_uid)
       or
       (m.audience_type='all'
        and (m.recipient_cutoff_at is null or u.created_at<=m.recipient_cutoff_at))
     )
   for share of m;

  if not coalesce(v_allowed,false) then
    return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint;
    return;
  end if;

  return query
    select * from public.claim_system_mail_v1(p_mail_id);
end;
$$;

create or replace function public.gm_send_system_mail_v2(
  p_title text,
  p_body text default '',
  p_mail_type text default 'announcement',
  p_recipient_scope text default 'all_future',
  p_target_user_id uuid default null,
  p_rewards jsonb default '{}'::jsonb,
  p_starts_at timestamptz default now(),
  p_expires_at timestamptz default null
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_id bigint;
  v_audience_type text;
  v_cutoff timestamptz;
  v_start timestamptz := coalesce(p_starts_at,now());
begin
  if v_uid is null or not private.is_stellar_gm(v_uid) then
    raise exception 'gm_forbidden' using errcode='42501';
  end if;
  if char_length(trim(coalesce(p_title,''))) < 1 or char_length(trim(p_title)) > 120 then
    raise exception 'invalid_title';
  end if;
  if char_length(coalesce(p_body,'')) > 6000 then raise exception 'body_too_long'; end if;
  if p_mail_type not in ('announcement','reward') then raise exception 'invalid_mail_type'; end if;
  if p_recipient_scope not in ('all_future','current_all','user') then raise exception 'invalid_recipient_scope'; end if;

  v_audience_type := case when p_recipient_scope='user' then 'user' else 'all' end;
  v_cutoff := case when p_recipient_scope='current_all' then now() else null end;

  if v_audience_type='all' then p_target_user_id := null; end if;
  if v_audience_type='user' and (
    p_target_user_id is null
    or not exists(select 1 from auth.users u where u.id=p_target_user_id)
  ) then
    raise exception 'invalid_target_user';
  end if;
  if p_expires_at is not null and p_expires_at <= v_start then raise exception 'invalid_expiry'; end if;

  perform private.validate_mail_rewards(coalesce(p_rewards,'{}'::jsonb));

  insert into public.system_mail(
    title,body,mail_type,audience_type,target_user_id,rewards,
    starts_at,expires_at,recipient_cutoff_at,created_by
  ) values(
    trim(p_title),coalesce(p_body,''),p_mail_type,v_audience_type,p_target_user_id,
    coalesce(p_rewards,'{}'::jsonb),v_start,p_expires_at,v_cutoff,v_uid
  ) returning id into v_id;

  insert into public.gm_audit_log(gm_user_id,action,subject_id,detail)
  values(
    v_uid,'send_system_mail',v_id::text,
    jsonb_build_object(
      'title',trim(p_title),
      'mail_type',p_mail_type,
      'audience_type',v_audience_type,
      'recipient_scope',p_recipient_scope,
      'target_user_id',p_target_user_id,
      'recipient_cutoff_at',v_cutoff,
      'starts_at',v_start,
      'expires_at',p_expires_at,
      'rewards',coalesce(p_rewards,'{}'::jsonb)
    )
  );

  return v_id;
end;
$$;

create or replace function public.gm_list_system_mail_v2(p_limit integer default 30)
returns table(
  id bigint,
  title text,
  body text,
  mail_type text,
  audience_type text,
  recipient_scope text,
  target_user_id uuid,
  rewards jsonb,
  starts_at timestamptz,
  expires_at timestamptz,
  recipient_cutoff_at timestamptz,
  withdrawn_at timestamptz,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or not private.is_stellar_gm(v_uid) then
    raise exception 'gm_forbidden' using errcode='42501';
  end if;

  return query
    select m.id,m.title,m.body,m.mail_type,m.audience_type,
           case
             when m.audience_type='user' then 'user'::text
             when m.recipient_cutoff_at is not null then 'current_all'::text
             else 'all_future'::text
           end as recipient_scope,
           m.target_user_id,m.rewards,m.starts_at,m.expires_at,
           m.recipient_cutoff_at,m.withdrawn_at,m.created_at
      from public.system_mail m
     order by m.created_at desc,m.id desc
     limit least(greatest(coalesce(p_limit,30),1),100);
end;
$$;

create or replace function public.gm_withdraw_system_mail_v1(p_mail_id bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_title text;
begin
  if v_uid is null or not private.is_stellar_gm(v_uid) then
    raise exception 'gm_forbidden' using errcode='42501';
  end if;

  select m.title into v_title
    from public.system_mail m
   where m.id=p_mail_id and m.withdrawn_at is null
   for update;

  if not found then return false; end if;

  update public.system_mail
     set withdrawn_at=now(), withdrawn_by=v_uid
   where id=p_mail_id;

  insert into public.gm_audit_log(gm_user_id,action,subject_id,detail)
  values(v_uid,'withdraw_system_mail',p_mail_id::text,jsonb_build_object('title',v_title));

  return true;
end;
$$;

revoke all on function private.mail_is_visible_to_user_v2(bigint,uuid) from public,anon,authenticated;

-- Client must use V2 for claims so cutoff/withdrawal cannot be bypassed.
revoke execute on function public.claim_system_mail_v1(bigint) from authenticated;
revoke all on function public.claim_system_mail_v2(bigint) from public,anon;
revoke all on function public.gm_send_system_mail_v2(text,text,text,text,uuid,jsonb,timestamptz,timestamptz) from public,anon;
revoke all on function public.gm_list_system_mail_v2(integer) from public,anon;
revoke all on function public.gm_withdraw_system_mail_v1(bigint) from public,anon;

grant execute on function public.claim_system_mail_v2(bigint) to authenticated;
grant execute on function public.gm_send_system_mail_v2(text,text,text,text,uuid,jsonb,timestamptz,timestamptz) to authenticated;
grant execute on function public.gm_list_system_mail_v2(integer) to authenticated;
grant execute on function public.gm_withdraw_system_mail_v1(bigint) to authenticated;

commit;

-- END 20260928_022_mailbox_v1_final.sql

-- ============================================================================
-- BEGIN 20260928_023_farm_friend_interaction_v2.sql
-- ============================================================================
-- Stellar Diary V0.17.0 — Farm Friends Interaction 2.0
-- Run once after migration 022. Existing farms, friendships, steals and activity are preserved.
-- Adds friend overview counts, one-time friend watering (-5% growth time), batch care,
-- and a two-way activity feed (received interactions / my footsteps).

begin;

-- ---------------------------------------------------------------------------
-- 1) Activity feed: allow friend watering events.
-- ---------------------------------------------------------------------------
alter table public.farm_activity
  drop constraint if exists farm_activity_activity_type_check;

alter table public.farm_activity
  add constraint farm_activity_activity_type_check
  check (activity_type in ('visit','steal','help_bug','help_water','friend'));

-- ---------------------------------------------------------------------------
-- 2) Shared authoritative grow-duration helper.
--    friendWatered=true adds one extra 0.95 factor for the current crop cycle.
-- ---------------------------------------------------------------------------
create or replace function public.farm_plot_duration_ms_v1(p_plot jsonb)
returns bigint
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_crop text := coalesce(p_plot->>'cropId','');
  v_minutes integer;
  v_factor numeric := 1.0;
  v_fertilizer text := coalesce(p_plot->>'fertilizerId','');
  v_event_factor numeric := 1.0;
begin
  v_minutes := case v_crop
    when 'carrot' then 20
    when 'wheat' then 30
    when 'corn' then 30
    when 'tomato' then 50
    when 'strawberry' then 90
    when 'pumpkin' then 150
    when 'grape' then 240
    when 'starfruit' then 480
    when 'mystery' then 240
    else 0
  end;

  if v_minutes <= 0 then return 0; end if;
  if v_crop = 'mystery' then return (v_minutes::bigint * 60000); end if;

  if coalesce(p_plot->>'watered','false') = 'true' then
    v_factor := v_factor * 0.92;
  end if;

  v_factor := v_factor * case v_fertilizer
    when 'fertilizerLow' then 0.90
    when 'fertilizerMid' then 0.80
    when 'fertilizerHigh' then 0.70
    else 1.00
  end;

  if coalesce(p_plot->>'eventGrowFactor','') ~ '^[0-9]+([.][0-9]+)?$' then
    v_event_factor := greatest(0.90, least(1.0, (p_plot->>'eventGrowFactor')::numeric));
  end if;
  v_factor := v_factor * v_event_factor;

  if coalesce(p_plot->>'friendWatered','false') = 'true' then
    v_factor := v_factor * 0.95;
  end if;

  v_factor := greatest(0.45, least(1.0, v_factor));
  return round(v_minutes::numeric * 60000 * v_factor)::bigint;
end;
$$;

revoke all on function public.farm_plot_duration_ms_v1(jsonb) from public, anon, authenticated;
grant execute on function public.farm_plot_duration_ms_v1(jsonb) to service_role;

-- ---------------------------------------------------------------------------
-- 3) Friend farm payload V6: preserve V5 decorations and expose friend-help
--    watering metadata without exposing the full private save.
-- ---------------------------------------------------------------------------
create or replace function public.get_friend_farm_v6(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_plots jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  v_payload := public.get_friend_farm_v5(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  select coalesce(jsonb_agg(
    coalesce(base.elem, '{}'::jsonb) || jsonb_build_object(
      'friendWatered', coalesce((owner_plot.elem->>'friendWatered')::boolean, false),
      'friendWateredByName', left(coalesce(owner_plot.elem->>'friendWateredByName',''), 80),
      'friendWateredAt', case
        when coalesce(owner_plot.elem->>'friendWateredAt','') ~ '^[0-9]+$'
          then (owner_plot.elem->>'friendWateredAt')::bigint
        else null
      end
    ) order by base.ord
  ), '[]'::jsonb)
  into v_plots
  from jsonb_array_elements(coalesce(v_payload->'plots','[]'::jsonb)) with ordinality as base(elem,ord)
  left join lateral (
    select x.elem
    from jsonb_array_elements(coalesce(v_state->'plots','[]'::jsonb)) with ordinality as x(elem,ord)
    where x.ord = base.ord
    limit 1
  ) owner_plot on true;

  return v_payload || jsonb_build_object('plots', v_plots);
end;
$$;

-- ---------------------------------------------------------------------------
-- 4) Batch friend overview. One RPC returns all existing friendship rows plus
--    live interaction counts for accepted friends, avoiding one request/friend.
-- ---------------------------------------------------------------------------
create or replace function public.get_farm_friends_v3()
returns table (
  user_id uuid,
  display_name text,
  sex text,
  farm_level integer,
  coins bigint,
  title_id text,
  relation_state text,
  requested_at timestamptz,
  mature_count integer,
  stealable_count integer,
  pest_count integer,
  help_water_count integer,
  interaction_score integer
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  select
    f.user_id,
    f.display_name,
    f.sex,
    f.farm_level,
    f.coins,
    f.title_id,
    f.relation_state,
    f.requested_at,
    case when f.relation_state='friend' then coalesce(o.mature_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.stealable_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.pest_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.help_water_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.interaction_score,0) else 0 end
  from public.get_farm_friends_v2() f
  left join public.farm_saves fs on fs.user_id = f.user_id
  left join lateral (
    select
      count(*) filter (
        where p.crop_id <> ''
          and p.planted_at is not null
          and p.duration_ms > 0
          and v_now_ms - p.planted_at >= p.duration_ms
      )::integer as mature_count,
      count(*) filter (
        where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
          and p.planted_at is not null
          and p.duration_ms > 0
          and v_now_ms - p.planted_at >= p.duration_ms
          and greatest(1, p.total_yield - p.stolen_count) > 1
          and not p.stolen_by_me
      )::integer as stealable_count,
      count(*) filter (
        where p.crop_id <> '' and p.has_pest
      )::integer as pest_count,
      count(*) filter (
        where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
          and p.planted_at is not null
          and p.duration_ms > 0
          and v_now_ms - p.planted_at < p.duration_ms
          and not p.friend_watered
      )::integer as help_water_count,
      (
        count(*) filter (
          where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
            and p.planted_at is not null
            and p.duration_ms > 0
            and v_now_ms - p.planted_at >= p.duration_ms
            and greatest(1, p.total_yield - p.stolen_count) > 1
            and not p.stolen_by_me
        ) * 100
        + count(*) filter (where p.crop_id <> '' and p.has_pest) * 40
        + count(*) filter (
          where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
            and p.planted_at is not null
            and p.duration_ms > 0
            and v_now_ms - p.planted_at < p.duration_ms
            and not p.friend_watered
        ) * 10
      )::integer as interaction_score
    from (
      select
        (plot.ord - 1)::integer as plot_id,
        case when plot.elem->>'cropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then plot.elem->>'cropId' else '' end as crop_id,
        case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else null end as planted_at,
        public.farm_plot_duration_ms_v1(plot.elem) as duration_ms,
        case when coalesce(plot.elem->>'harvestYield','') ~ '^[0-9]+$' then greatest(1,(plot.elem->>'harvestYield')::integer) else 4 end as total_yield,
        case when coalesce(plot.elem->>'stolenCount','') ~ '^[0-9]+$' then greatest(0,(plot.elem->>'stolenCount')::integer) else 0 end as stolen_count,
        coalesce((plot.elem->>'hasPest')::boolean,false) as has_pest,
        coalesce((plot.elem->>'friendWatered')::boolean,false) as friend_watered,
        exists (
          select 1 from public.farm_steals st
          where st.thief_id = v_uid
            and st.owner_id = f.user_id
            and st.plot_id = (plot.ord - 1)::integer
            and st.planted_at = case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else -1 end
        ) as stolen_by_me
      from jsonb_array_elements(coalesce(fs.state->'plots','[]'::jsonb)) with ordinality as plot(elem,ord)
      where plot.ord <= 20
    ) p
  ) o on f.relation_state='friend'
  order by
    case
      when f.relation_state='pending_in' then 0
      when f.relation_state='friend' then 1
      else 2
    end,
    case when f.relation_state='friend' then coalesce(o.interaction_score,0) else 0 end desc,
    f.requested_at desc,
    f.display_name asc;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5) One-time friend watering. p_plot=NULL means one-click water all eligible
--    growing normal crops. Each crop cycle can receive this bonus only once.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_water_v1(
  p_friend uuid,
  p_plot integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_duration_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_helper_name text := '农场好友';
  v_count integer := 0;
  v_ids jsonb := '[]'::jsonb;
  i integer;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid then return jsonb_build_object('ok',false,'reason','invalid_target'); end if;
  if p_plot is not null and (p_plot < 0 or p_plot > 19) then return jsonb_build_object('ok',false,'reason','invalid_plot'); end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  select coalesce(nullif(trim(p.display_name),''),'农场好友')
    into v_helper_name
    from public.profiles p
   where p.id=v_uid;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('water:' || p_friend::text,0));
  select fs.state into v_owner_state
    from public.farm_saves fs
   where fs.user_id=p_friend
   for update;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;

  for i in 0..19 loop
    if p_plot is not null and i <> p_plot then continue; end if;

    v_plot := v_owner_state->'plots'->i;
    if v_plot is null then continue; end if;
    v_crop_id := coalesce(v_plot->>'cropId','');
    if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then continue; end if;
    if coalesce(v_plot->>'friendWatered','false') = 'true' then continue; end if;
    if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then continue; end if;

    v_planted_at := (v_plot->>'plantedAt')::bigint;
    v_duration_ms := public.farm_plot_duration_ms_v1(v_plot);
    if v_duration_ms <= 0 or v_now_ms - v_planted_at >= v_duration_ms then continue; end if;

    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWatered'],'true'::jsonb,true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredBy'],to_jsonb(v_uid::text),true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredByName'],to_jsonb(left(v_helper_name,80)),true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredAt'],to_jsonb(v_now_ms),true);
    v_count := v_count + 1;
    v_ids := v_ids || jsonb_build_array(i);

    insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
    values(p_friend,v_uid,'help_water',v_crop_id,5,i,clock_timestamp());
  end loop;

  if v_count <= 0 then
    return jsonb_build_object('ok',false,'reason','no_eligible','count',0,'plot_ids',v_ids);
  end if;

  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  update public.farm_saves
     set state=v_owner_state,
         client_updated_at=v_now_ms
   where user_id=p_friend;

  delete from public.farm_activity a
   where a.owner_id=p_friend and a.id in (
     select x.id from public.farm_activity x
     where x.owner_id=p_friend
     order by x.created_at desc,x.id desc
     offset 100
   );

  return jsonb_build_object('ok',true,'count',v_count,'plot_ids',v_ids,'bonus_percent',5);
end;
$$;

-- ---------------------------------------------------------------------------
-- 6) One-click friend pest help. Reuses the audited single-plot function so
--    rewards and helper-state updates stay identical to manual clicking.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_bug_all_v1(p_friend uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_state jsonb;
  v_result jsonb;
  v_helper_state jsonb := null;
  v_count integer := 0;
  v_ids jsonb := '[]'::jsonb;
  rec record;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid then return jsonb_build_object('ok',false,'reason','invalid_target'); end if;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;

  for rec in
    select (plot.ord - 1)::integer as plot_id
    from jsonb_array_elements(coalesce(v_state->'plots','[]'::jsonb)) with ordinality as plot(elem,ord)
    where plot.ord <= 20
      and coalesce(plot.elem->>'cropId','') <> ''
      and coalesce((plot.elem->>'hasPest')::boolean,false)
    order by plot.ord
  loop
    v_result := public.help_friend_bug_v1(p_friend, rec.plot_id);
    if coalesce((v_result->>'ok')::boolean,false) then
      v_count := v_count + 1;
      v_ids := v_ids || jsonb_build_array(rec.plot_id);
      if v_result ? 'helper_state' then v_helper_state := v_result->'helper_state'; end if;
    end if;
  end loop;

  if v_count <= 0 then
    return jsonb_build_object('ok',false,'reason','no_pest','count',0,'plot_ids',v_ids);
  end if;

  return jsonb_build_object('ok',true,'count',v_count,'plot_ids',v_ids,'helper_state',v_helper_state);
end;
$$;

-- ---------------------------------------------------------------------------
-- 7) Two-way activity feed. One request returns both directions.
-- ---------------------------------------------------------------------------
create or replace function public.get_farm_activity_v2(
  p_limit integer default 50,
  p_mark_seen boolean default false
)
returns table (
  direction text,
  id bigint,
  activity_type text,
  peer_id uuid,
  display_name text,
  sex text,
  crop_id text,
  amount integer,
  plot_id integer,
  activity_at timestamptz,
  is_unread boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_limit integer := greatest(1, least(coalesce(p_limit,50),100));
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  return query
  with received as (
    select
      'received'::text as direction,
      a.id,
      a.activity_type,
      a.actor_id as peer_id,
      coalesce(nullif(trim(p.display_name),''),'农场好友') as display_name,
      case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
      a.crop_id,
      a.amount,
      a.plot_id,
      a.created_at as activity_at,
      (a.seen_at is null) as is_unread
    from public.farm_activity a
    left join public.profiles p on p.id=a.actor_id
    where a.owner_id=v_uid
    order by a.created_at desc,a.id desc
    limit v_limit
  ), sent as (
    select
      'sent'::text as direction,
      a.id,
      a.activity_type,
      a.owner_id as peer_id,
      coalesce(nullif(trim(p.display_name),''),'农场好友') as display_name,
      case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
      a.crop_id,
      a.amount,
      a.plot_id,
      a.created_at as activity_at,
      false as is_unread
    from public.farm_activity a
    left join public.profiles p on p.id=a.owner_id
    where a.actor_id=v_uid
    order by a.created_at desc,a.id desc
    limit v_limit
  )
  select * from received
  union all
  select * from sent
  order by activity_at desc,id desc;

  if coalesce(p_mark_seen,false) then
    update public.farm_activity a
       set seen_at=coalesce(a.seen_at,clock_timestamp())
     where a.owner_id=v_uid
       and a.seen_at is null
       and a.id in (
         select x.id from public.farm_activity x
         where x.owner_id=v_uid
         order by x.created_at desc,x.id desc
         limit v_limit
       );
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 8) Keep stealing maturity checks aligned with friendWatered (-5%).
--    Existing v2/v3/v4 steal wrappers still call this base function.
-- ---------------------------------------------------------------------------
create or replace function public.steal_friend_crop(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_thief_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_effective_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_total integer;
  v_stolen integer := 0;
  v_remaining integer;
  v_take integer := 1;
  v_current_produce integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend=v_uid or p_plot is null or p_plot<0 or p_plot>19 then
    return jsonb_build_object('ok',false,'reason','invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low:=v_uid; v_high:=p_friend;
  else v_low:=p_friend; v_high:=v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_friend::text || ':' || p_plot::text,0));

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend for update;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_thief_state from public.farm_saves fs where fs.user_id=v_uid for update;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  v_crop_id := coalesce(v_plot->>'cropId','');
  if v_crop_id='' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  if v_crop_id='mystery' then return jsonb_build_object('ok',false,'reason','protected'); end if;
  if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then
    return jsonb_build_object('ok',false,'reason','no_crop');
  end if;
  if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;

  v_planted_at := (v_plot->>'plantedAt')::bigint;
  v_effective_ms := public.farm_plot_duration_ms_v1(v_plot);
  if v_effective_ms <= 0 or v_now_ms - v_planted_at < v_effective_ms then
    return jsonb_build_object('ok',false,'reason','not_mature');
  end if;

  if exists (
    select 1 from public.farm_steals st
    where st.thief_id=v_uid and st.owner_id=p_friend and st.plot_id=p_plot and st.planted_at=v_planted_at
  ) then return jsonb_build_object('ok',false,'reason','already_stolen'); end if;

  if coalesce(v_plot->>'harvestYield','') ~ '^[0-9]+$' then
    v_total := least(5,greatest(4,(v_plot->>'harvestYield')::integer));
  else
    v_total := 4 + floor(random()*2)::integer;
  end if;

  select coalesce(sum(st.amount),0)::integer into v_stolen
  from public.farm_steals st
  where st.owner_id=p_friend and st.plot_id=p_plot and st.planted_at=v_planted_at;

  v_remaining := v_total - v_stolen;
  if v_remaining <= 1 then return jsonb_build_object('ok',false,'reason','protected','remaining',1); end if;

  insert into public.farm_steals(thief_id,owner_id,plot_id,planted_at,crop_id,amount)
  values(v_uid,p_friend,p_plot,v_planted_at,v_crop_id,v_take);

  v_stolen := v_stolen + v_take;
  v_remaining := v_total - v_stolen;

  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'harvestYield'],to_jsonb(v_total),true);
  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'stolenCount'],to_jsonb(v_stolen),true);
  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  v_thief_state := jsonb_set(v_thief_state,'{produce}',coalesce(v_thief_state->'produce','{}'::jsonb),true);
  if coalesce(v_thief_state->'produce'->>v_crop_id,'') ~ '^[0-9]+$' then
    v_current_produce := (v_thief_state->'produce'->>v_crop_id)::integer;
  end if;
  v_thief_state := jsonb_set(v_thief_state,array['produce',v_crop_id],to_jsonb(v_current_produce+1),true);
  v_thief_state := jsonb_set(v_thief_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_thief_state,client_updated_at=v_now_ms where user_id=v_uid;

  return jsonb_build_object('ok',true,'crop_id',v_crop_id,'amount',1,'owner_remaining',v_remaining,'thief_state',v_thief_state);
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
revoke all on function public.get_friend_farm_v6(uuid,boolean) from public, anon;
revoke all on function public.get_farm_friends_v3() from public, anon;
revoke all on function public.help_friend_water_v1(uuid,integer) from public, anon;
revoke all on function public.help_friend_bug_all_v1(uuid) from public, anon;
revoke all on function public.get_farm_activity_v2(integer,boolean) from public, anon;
revoke all on function public.steal_friend_crop(uuid,integer) from public, anon;

grant execute on function public.get_friend_farm_v6(uuid,boolean) to authenticated, service_role;
grant execute on function public.get_farm_friends_v3() to authenticated, service_role;
grant execute on function public.help_friend_water_v1(uuid,integer) to authenticated, service_role;
grant execute on function public.help_friend_bug_all_v1(uuid) to authenticated, service_role;
grant execute on function public.get_farm_activity_v2(integer,boolean) to authenticated, service_role;
grant execute on function public.steal_friend_crop(uuid,integer) to authenticated, service_role;

commit;

-- END 20260928_023_farm_friend_interaction_v2.sql

-- ============================================================================
-- BEGIN 20260928_024_farm_stability_traffic.sql
-- ============================================================================
-- Stellar Diary V0.17.0.1 — Farm stability + traffic optimization
-- Run once after migration 023.
-- Goals:
--   * batch friend care into one farm update / one activity row
--   * fix helper EXP level conversion
--   * harden JSON boolean/array parsing
--   * verify friendship before batch reads
--   * use deterministic pair locking for two-player economic mutations
--   * mark all received activity seen when the feed is opened

begin;

-- ---------------------------------------------------------------------------
-- 1) Shared server-side EXP application helper.
--    Keeps friend-care rewards aligned with the same level curve used by mail.
-- ---------------------------------------------------------------------------
create or replace function private.farm_apply_exp_v1(p_state jsonb, p_delta integer)
returns jsonb
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_state jsonb := coalesce(p_state, '{}'::jsonb);
  v_level integer := 1;
  v_exp integer := 0;
  v_need integer;
begin
  if coalesce(v_state->>'level','') ~ '^[0-9]+$' then
    v_level := greatest(1, least(999, (v_state->>'level')::integer));
  end if;
  if coalesce(v_state->>'exp','') ~ '^[0-9]+$' then
    v_exp := greatest(0, (v_state->>'exp')::integer);
  end if;

  v_exp := v_exp + greatest(0, coalesce(p_delta,0));

  while v_level < 999 loop
    v_need := case v_level
      when 1 then 100 when 2 then 140 when 3 then 190 when 4 then 250 when 5 then 320
      when 6 then 400 when 7 then 500 when 8 then 620 when 9 then 750 when 10 then 900
      when 11 then 1060 when 12 then 1230 when 13 then 1410 when 14 then 1600 when 15 then 1800
      when 16 then 2010 when 17 then 2230 when 18 then 2460 when 19 then 2700 when 20 then 2950
      when 21 then 3210 when 22 then 3480 when 23 then 3760 when 24 then 4050 when 25 then 4350
      else 4350 + greatest(0, v_level - 25) * 350
    end;
    exit when v_exp < v_need;
    v_exp := v_exp - v_need;
    v_level := v_level + 1;
  end loop;

  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  return v_state;
end;
$$;

revoke all on function private.farm_apply_exp_v1(jsonb,integer) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2) Friend payload V6 — same public payload, but tolerate malformed booleans
--    and malformed plots containers instead of throwing for every friend.
-- ---------------------------------------------------------------------------
create or replace function public.get_friend_farm_v6(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_plots jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  v_payload := public.get_friend_farm_v5(p_friend, p_log_visit);
  if coalesce(v_payload->>'ok','false') <> 'true' then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  select coalesce(jsonb_agg(
    coalesce(base.elem, '{}'::jsonb) || jsonb_build_object(
      'friendWatered', coalesce(owner_plot.elem->>'friendWatered','false') = 'true',
      'friendWateredByName', left(coalesce(owner_plot.elem->>'friendWateredByName',''), 80),
      'friendWateredAt', case
        when coalesce(owner_plot.elem->>'friendWateredAt','') ~ '^[0-9]+$'
          then (owner_plot.elem->>'friendWateredAt')::bigint
        else null
      end
    ) order by base.ord
  ), '[]'::jsonb)
  into v_plots
  from jsonb_array_elements(
    case when jsonb_typeof(v_payload->'plots')='array' then v_payload->'plots' else '[]'::jsonb end
  ) with ordinality as base(elem,ord)
  left join lateral (
    select x.elem
    from jsonb_array_elements(
      case when jsonb_typeof(v_state->'plots')='array' then v_state->'plots' else '[]'::jsonb end
    ) with ordinality as x(elem,ord)
    where x.ord = base.ord
    limit 1
  ) owner_plot on true;

  return v_payload || jsonb_build_object('plots', v_plots);
end;
$$;

-- ---------------------------------------------------------------------------
-- 3) Batch friend overview — safe booleans/arrays. Still one RPC for the whole
--    friend list, with no request-per-friend fan-out from the browser.
-- ---------------------------------------------------------------------------
create or replace function public.get_farm_friends_v3()
returns table (
  user_id uuid,
  display_name text,
  sex text,
  farm_level integer,
  coins bigint,
  title_id text,
  relation_state text,
  requested_at timestamptz,
  mature_count integer,
  stealable_count integer,
  pest_count integer,
  help_water_count integer,
  interaction_score integer
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  return query
  select
    f.user_id,
    f.display_name,
    f.sex,
    f.farm_level,
    f.coins,
    f.title_id,
    f.relation_state,
    f.requested_at,
    case when f.relation_state='friend' then coalesce(o.mature_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.stealable_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.pest_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.help_water_count,0) else 0 end,
    case when f.relation_state='friend' then coalesce(o.interaction_score,0) else 0 end
  from public.get_farm_friends_v2() f
  left join public.farm_saves fs on fs.user_id = f.user_id
  left join lateral (
    select
      count(*) filter (
        where p.crop_id <> ''
          and p.planted_at is not null
          and p.duration_ms > 0
          and v_now_ms - p.planted_at >= p.duration_ms
      )::integer as mature_count,
      count(*) filter (
        where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
          and p.planted_at is not null
          and p.duration_ms > 0
          and v_now_ms - p.planted_at >= p.duration_ms
          and greatest(1, p.total_yield - p.stolen_count) > 1
          and not p.stolen_by_me
      )::integer as stealable_count,
      count(*) filter (where p.crop_id <> '' and p.has_pest)::integer as pest_count,
      count(*) filter (
        where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
          and p.planted_at is not null
          and p.duration_ms > 0
          and v_now_ms - p.planted_at < p.duration_ms
          and not p.friend_watered
      )::integer as help_water_count,
      (
        count(*) filter (
          where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
            and p.planted_at is not null
            and p.duration_ms > 0
            and v_now_ms - p.planted_at >= p.duration_ms
            and greatest(1, p.total_yield - p.stolen_count) > 1
            and not p.stolen_by_me
        ) * 100
        + count(*) filter (where p.crop_id <> '' and p.has_pest) * 40
        + count(*) filter (
          where p.crop_id in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit')
            and p.planted_at is not null
            and p.duration_ms > 0
            and v_now_ms - p.planted_at < p.duration_ms
            and not p.friend_watered
        ) * 10
      )::integer as interaction_score
    from (
      select
        (plot.ord - 1)::integer as plot_id,
        case when plot.elem->>'cropId' in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then plot.elem->>'cropId' else '' end as crop_id,
        case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else null end as planted_at,
        public.farm_plot_duration_ms_v1(plot.elem) as duration_ms,
        case when coalesce(plot.elem->>'harvestYield','') ~ '^[0-9]+$' then greatest(1,(plot.elem->>'harvestYield')::integer) else 4 end as total_yield,
        case when coalesce(plot.elem->>'stolenCount','') ~ '^[0-9]+$' then greatest(0,(plot.elem->>'stolenCount')::integer) else 0 end as stolen_count,
        coalesce(plot.elem->>'hasPest','false') = 'true' as has_pest,
        coalesce(plot.elem->>'friendWatered','false') = 'true' as friend_watered,
        exists (
          select 1 from public.farm_steals st
          where st.thief_id = v_uid
            and st.owner_id = f.user_id
            and st.plot_id = (plot.ord - 1)::integer
            and st.planted_at = case when coalesce(plot.elem->>'plantedAt','') ~ '^[0-9]+$' then (plot.elem->>'plantedAt')::bigint else -1 end
        ) as stolen_by_me
      from jsonb_array_elements(
        case when jsonb_typeof(fs.state->'plots')='array' then fs.state->'plots' else '[]'::jsonb end
      ) with ordinality as plot(elem,ord)
      where plot.ord <= 20
    ) p
  ) o on f.relation_state='friend'
  order by
    case
      when f.relation_state='pending_in' then 0
      when f.relation_state='friend' then 1
      else 2
    end,
    case when f.relation_state='friend' then coalesce(o.interaction_score,0) else 0 end desc,
    f.requested_at desc,
    f.display_name asc;
end;
$$;

-- ---------------------------------------------------------------------------
-- 4) One-time friend watering. p_plot=NULL is a true batch operation:
--    one owner save UPDATE and one aggregated activity row.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_water_v1(
  p_friend uuid,
  p_plot integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_owner_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_first_crop text := null;
  v_first_plot integer := null;
  v_planted_at bigint;
  v_duration_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_helper_name text := '农场好友';
  v_count integer := 0;
  v_ids jsonb := '[]'::jsonb;
  i integer;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid then return jsonb_build_object('ok',false,'reason','invalid_target'); end if;
  if p_plot is not null and (p_plot < 0 or p_plot > 19) then return jsonb_build_object('ok',false,'reason','invalid_plot'); end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  select coalesce(nullif(trim(p.display_name),''),'农场好友')
    into v_helper_name
    from public.profiles p
   where p.id=v_uid;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('water:' || p_friend::text,0));
  select fs.state into v_owner_state
    from public.farm_saves fs
   where fs.user_id=p_friend
   for update;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;

  for i in 0..19 loop
    if p_plot is not null and i <> p_plot then continue; end if;

    v_plot := v_owner_state->'plots'->i;
    if v_plot is null then continue; end if;
    v_crop_id := coalesce(v_plot->>'cropId','');
    if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then continue; end if;
    if coalesce(v_plot->>'friendWatered','false') = 'true' then continue; end if;
    if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then continue; end if;

    v_planted_at := (v_plot->>'plantedAt')::bigint;
    v_duration_ms := public.farm_plot_duration_ms_v1(v_plot);
    if v_duration_ms <= 0 or v_now_ms - v_planted_at >= v_duration_ms then continue; end if;

    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWatered'],'true'::jsonb,true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredBy'],to_jsonb(v_uid::text),true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredByName'],to_jsonb(left(v_helper_name,80)),true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredAt'],to_jsonb(v_now_ms),true);
    v_count := v_count + 1;
    v_ids := v_ids || jsonb_build_array(i);
    if v_first_plot is null then v_first_plot := i; v_first_crop := v_crop_id; end if;
  end loop;

  if v_count <= 0 then
    return jsonb_build_object('ok',false,'reason','no_eligible','count',0,'plot_ids',v_ids);
  end if;

  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  update public.farm_saves
     set state=v_owner_state,
         client_updated_at=v_now_ms
   where user_id=p_friend;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(
    p_friend,
    v_uid,
    'help_water',
    case when v_count=1 then v_first_crop else null end,
    v_count,
    case when v_count=1 then v_first_plot else null end,
    clock_timestamp()
  );

  delete from public.farm_activity a
   where a.owner_id=p_friend and a.id in (
     select x.id from public.farm_activity x
     where x.owner_id=p_friend
     order by x.created_at desc,x.id desc
     offset 100
   );

  return jsonb_build_object('ok',true,'count',v_count,'plot_ids',v_ids,'bonus_percent',5);
end;
$$;

-- ---------------------------------------------------------------------------
-- 5) Single-plot pest help — deterministic pair lock + immediate EXP leveling.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_bug_v1(
  p_friend uuid,
  p_plot integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_lock_id uuid;
  v_owner_state jsonb;
  v_helper_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_roll double precision := random();
  v_reward_type text := 'none';
  v_reward_amount integer := 0;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_coins bigint := 0;
  v_max_coins bigint := 0;
  v_mystery integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok',false,'reason','invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
     where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  -- One pair-wide lock order covers A->B and B->A concurrent care.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('farm-pair:' || v_low::text || ':' || v_high::text,0));
  for v_lock_id in
    select fs.user_id from public.farm_saves fs
     where fs.user_id in (v_low,v_high)
     order by fs.user_id
     for update
  loop
    null;
  end loop;

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_helper_state from public.farm_saves fs where fs.user_id=v_uid;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null or coalesce(v_plot->>'cropId','') = '' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  if coalesce(v_plot->>'hasPest','false') <> 'true' then return jsonb_build_object('ok',false,'reason','no_pest'); end if;
  v_crop_id := v_plot->>'cropId';

  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'hasPest'],'false'::jsonb,true);

  -- 45% coins, 35% EXP, 10% mystery box, 10% simple good deed.
  if v_roll < 0.45 then
    v_reward_type := 'coins';
    v_reward_amount := 2 + floor(random()*4)::integer;
    if coalesce(v_helper_state->>'coins','') ~ '^[0-9]+$' then v_coins := (v_helper_state->>'coins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{coins}',to_jsonb(v_coins + v_reward_amount),true);
    v_helper_state := jsonb_set(v_helper_state,'{stats}',coalesce(v_helper_state->'stats','{}'::jsonb),true);
    if coalesce(v_helper_state->'stats'->>'maxCoins','') ~ '^[0-9]+$' then v_max_coins := (v_helper_state->'stats'->>'maxCoins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{stats,maxCoins}',to_jsonb(greatest(v_max_coins,v_coins+v_reward_amount)),true);
  elsif v_roll < 0.80 then
    v_reward_type := 'exp';
    v_reward_amount := 3 + floor(random()*6)::integer;
    v_helper_state := private.farm_apply_exp_v1(v_helper_state,v_reward_amount);
  elsif v_roll < 0.90 then
    v_reward_type := 'mystery';
    v_reward_amount := 1;
    v_helper_state := jsonb_set(v_helper_state,'{seeds}',coalesce(v_helper_state->'seeds','{}'::jsonb),true);
    if coalesce(v_helper_state->'seeds'->>'mystery','') ~ '^[0-9]+$' then v_mystery := (v_helper_state->'seeds'->>'mystery')::integer; end if;
    v_helper_state := jsonb_set(v_helper_state,'{seeds,mystery}',to_jsonb(v_mystery+1),true);
  end if;

  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_helper_state,client_updated_at=v_now_ms where user_id=v_uid;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(p_friend,v_uid,'help_bug',v_crop_id,1,p_plot,clock_timestamp());

  delete from public.farm_activity a
   where a.owner_id=p_friend and a.id in (
    select x.id from public.farm_activity x where x.owner_id=p_friend order by x.created_at desc,x.id desc offset 100
   );

  return jsonb_build_object(
    'ok',true,'crop_id',v_crop_id,'plot_id',p_plot,
    'reward_type',v_reward_type,'reward_amount',v_reward_amount,
    'helper_state',v_helper_state
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 6) One-click pest help — true batch implementation.
--    One pair lock, one owner UPDATE, one helper UPDATE, one activity row.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_bug_all_v1(p_friend uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_lock_id uuid;
  v_owner_state jsonb;
  v_helper_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_first_crop text := null;
  v_first_plot integer := null;
  v_count integer := 0;
  v_ids jsonb := '[]'::jsonb;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_roll double precision;
  v_coin_reward integer := 0;
  v_exp_reward integer := 0;
  v_mystery_reward integer := 0;
  v_coins bigint := 0;
  v_max_coins bigint := 0;
  v_mystery integer := 0;
  i integer;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid then return jsonb_build_object('ok',false,'reason','invalid_target'); end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  -- Check friendship before reading any target farm state.
  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('farm-pair:' || v_low::text || ':' || v_high::text,0));
  for v_lock_id in
    select fs.user_id from public.farm_saves fs
     where fs.user_id in (v_low,v_high)
     order by fs.user_id
     for update
  loop
    null;
  end loop;

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_helper_state from public.farm_saves fs where fs.user_id=v_uid;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  for i in 0..19 loop
    v_plot := v_owner_state->'plots'->i;
    if v_plot is null then continue; end if;
    v_crop_id := coalesce(v_plot->>'cropId','');
    if v_crop_id = '' or coalesce(v_plot->>'hasPest','false') <> 'true' then continue; end if;

    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'hasPest'],'false'::jsonb,true);
    v_count := v_count + 1;
    v_ids := v_ids || jsonb_build_array(i);
    if v_first_plot is null then v_first_plot := i; v_first_crop := v_crop_id; end if;

    -- Preserve the old per-plot reward odds, but aggregate the resulting writes.
    v_roll := random();
    if v_roll < 0.45 then
      v_coin_reward := v_coin_reward + 2 + floor(random()*4)::integer;
    elsif v_roll < 0.80 then
      v_exp_reward := v_exp_reward + 3 + floor(random()*6)::integer;
    elsif v_roll < 0.90 then
      v_mystery_reward := v_mystery_reward + 1;
    end if;
  end loop;

  if v_count <= 0 then
    return jsonb_build_object('ok',false,'reason','no_pest','count',0,'plot_ids',v_ids);
  end if;

  if v_coin_reward > 0 then
    if coalesce(v_helper_state->>'coins','') ~ '^[0-9]+$' then v_coins := (v_helper_state->>'coins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{coins}',to_jsonb(v_coins + v_coin_reward),true);
    v_helper_state := jsonb_set(v_helper_state,'{stats}',coalesce(v_helper_state->'stats','{}'::jsonb),true);
    if coalesce(v_helper_state->'stats'->>'maxCoins','') ~ '^[0-9]+$' then v_max_coins := (v_helper_state->'stats'->>'maxCoins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{stats,maxCoins}',to_jsonb(greatest(v_max_coins,v_coins+v_coin_reward)),true);
  end if;

  if v_exp_reward > 0 then
    v_helper_state := private.farm_apply_exp_v1(v_helper_state,v_exp_reward);
  end if;

  if v_mystery_reward > 0 then
    v_helper_state := jsonb_set(v_helper_state,'{seeds}',coalesce(v_helper_state->'seeds','{}'::jsonb),true);
    if coalesce(v_helper_state->'seeds'->>'mystery','') ~ '^[0-9]+$' then v_mystery := (v_helper_state->'seeds'->>'mystery')::integer; end if;
    v_helper_state := jsonb_set(v_helper_state,'{seeds,mystery}',to_jsonb(v_mystery+v_mystery_reward),true);
  end if;

  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_helper_state,client_updated_at=v_now_ms where user_id=v_uid;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(
    p_friend,
    v_uid,
    'help_bug',
    case when v_count=1 then v_first_crop else null end,
    v_count,
    case when v_count=1 then v_first_plot else null end,
    clock_timestamp()
  );

  delete from public.farm_activity a
   where a.owner_id=p_friend and a.id in (
     select x.id from public.farm_activity x
     where x.owner_id=p_friend
     order by x.created_at desc,x.id desc
     offset 100
   );

  return jsonb_build_object(
    'ok',true,
    'count',v_count,
    'plot_ids',v_ids,
    'helper_state',v_helper_state,
    'rewards',jsonb_build_object(
      'coins',v_coin_reward,
      'exp',v_exp_reward,
      'mystery',v_mystery_reward
    )
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 7) Two-way activity feed. Opening received activity marks ALL unread rows,
--    not only the latest p_limit rows, so the unread badge cannot jump back.
-- ---------------------------------------------------------------------------
create or replace function public.get_farm_activity_v2(
  p_limit integer default 50,
  p_mark_seen boolean default false
)
returns table (
  direction text,
  id bigint,
  activity_type text,
  peer_id uuid,
  display_name text,
  sex text,
  crop_id text,
  amount integer,
  plot_id integer,
  activity_at timestamptz,
  is_unread boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_limit integer := greatest(1, least(coalesce(p_limit,50),100));
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  return query
  with received as (
    select
      'received'::text as direction,
      a.id,
      a.activity_type,
      a.actor_id as peer_id,
      coalesce(nullif(trim(p.display_name),''),'农场好友') as display_name,
      case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
      a.crop_id,
      a.amount,
      a.plot_id,
      a.created_at as activity_at,
      (a.seen_at is null) as is_unread
    from public.farm_activity a
    left join public.profiles p on p.id=a.actor_id
    where a.owner_id=v_uid
    order by a.created_at desc,a.id desc
    limit v_limit
  ), sent as (
    select
      'sent'::text as direction,
      a.id,
      a.activity_type,
      a.owner_id as peer_id,
      coalesce(nullif(trim(p.display_name),''),'农场好友') as display_name,
      case when p.sex in ('male','female') then p.sex else 'unspecified' end as sex,
      a.crop_id,
      a.amount,
      a.plot_id,
      a.created_at as activity_at,
      false as is_unread
    from public.farm_activity a
    left join public.profiles p on p.id=a.owner_id
    where a.actor_id=v_uid
    order by a.created_at desc,a.id desc
    limit v_limit
  )
  select * from received
  union all
  select * from sent
  order by activity_at desc,id desc;

  if coalesce(p_mark_seen,false) then
    update public.farm_activity a
       set seen_at=coalesce(a.seen_at,clock_timestamp())
     where a.owner_id=v_uid
       and a.seen_at is null;
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 8) Atomic steal base — preserve V0.17 friend-water maturity, but lock both
--    player farm rows in one deterministic pair order to reduce deadlocks.
-- ---------------------------------------------------------------------------
create or replace function public.steal_friend_crop(p_friend uuid, p_plot integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_lock_id uuid;
  v_owner_state jsonb;
  v_thief_state jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_planted_at bigint;
  v_effective_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_total integer;
  v_stolen integer := 0;
  v_remaining integer;
  v_take integer := 1;
  v_current_produce integer := 0;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend=v_uid or p_plot is null or p_plot<0 or p_plot>19 then
    return jsonb_build_object('ok',false,'reason','invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low:=v_uid; v_high:=p_friend;
  else v_low:=p_friend; v_high:=v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('farm-pair:' || v_low::text || ':' || v_high::text,0));
  for v_lock_id in
    select fs.user_id from public.farm_saves fs
     where fs.user_id in (v_low,v_high)
     order by fs.user_id
     for update
  loop
    null;
  end loop;

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_thief_state from public.farm_saves fs where fs.user_id=v_uid;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  v_crop_id := coalesce(v_plot->>'cropId','');
  if v_crop_id='' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  if v_crop_id='mystery' then return jsonb_build_object('ok',false,'reason','protected'); end if;
  if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then
    return jsonb_build_object('ok',false,'reason','no_crop');
  end if;
  if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;

  v_planted_at := (v_plot->>'plantedAt')::bigint;
  v_effective_ms := public.farm_plot_duration_ms_v1(v_plot);
  if v_effective_ms <= 0 or v_now_ms - v_planted_at < v_effective_ms then
    return jsonb_build_object('ok',false,'reason','not_mature');
  end if;

  if exists (
    select 1 from public.farm_steals st
    where st.thief_id=v_uid and st.owner_id=p_friend and st.plot_id=p_plot and st.planted_at=v_planted_at
  ) then return jsonb_build_object('ok',false,'reason','already_stolen'); end if;

  if coalesce(v_plot->>'harvestYield','') ~ '^[0-9]+$' then
    v_total := least(5,greatest(4,(v_plot->>'harvestYield')::integer));
  else
    v_total := 4 + floor(random()*2)::integer;
  end if;

  select coalesce(sum(st.amount),0)::integer into v_stolen
  from public.farm_steals st
  where st.owner_id=p_friend and st.plot_id=p_plot and st.planted_at=v_planted_at;

  v_remaining := v_total - v_stolen;
  if v_remaining <= 1 then return jsonb_build_object('ok',false,'reason','protected','remaining',1); end if;

  insert into public.farm_steals(thief_id,owner_id,plot_id,planted_at,crop_id,amount)
  values(v_uid,p_friend,p_plot,v_planted_at,v_crop_id,v_take);

  v_stolen := v_stolen + v_take;
  v_remaining := v_total - v_stolen;

  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'harvestYield'],to_jsonb(v_total),true);
  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'stolenCount'],to_jsonb(v_stolen),true);
  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  v_thief_state := jsonb_set(v_thief_state,'{produce}',coalesce(v_thief_state->'produce','{}'::jsonb),true);
  if coalesce(v_thief_state->'produce'->>v_crop_id,'') ~ '^[0-9]+$' then
    v_current_produce := (v_thief_state->'produce'->>v_crop_id)::integer;
  end if;
  v_thief_state := jsonb_set(v_thief_state,array['produce',v_crop_id],to_jsonb(v_current_produce+1),true);
  v_thief_state := jsonb_set(v_thief_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_thief_state,client_updated_at=v_now_ms where user_id=v_uid;

  return jsonb_build_object('ok',true,'crop_id',v_crop_id,'amount',1,'owner_remaining',v_remaining,'thief_state',v_thief_state);
end;
$$;

-- ---------------------------------------------------------------------------
-- Permissions: keep all game-mutating RPCs authenticated-only.
-- ---------------------------------------------------------------------------
revoke all on function public.get_friend_farm_v6(uuid,boolean) from public, anon;
revoke all on function public.get_farm_friends_v3() from public, anon;
revoke all on function public.help_friend_water_v1(uuid,integer) from public, anon;
revoke all on function public.help_friend_bug_v1(uuid,integer) from public, anon;
revoke all on function public.help_friend_bug_all_v1(uuid) from public, anon;
revoke all on function public.get_farm_activity_v2(integer,boolean) from public, anon;
revoke all on function public.steal_friend_crop(uuid,integer) from public, anon;

grant execute on function public.get_friend_farm_v6(uuid,boolean) to authenticated, service_role;
grant execute on function public.get_farm_friends_v3() to authenticated, service_role;
grant execute on function public.help_friend_water_v1(uuid,integer) to authenticated, service_role;
grant execute on function public.help_friend_bug_v1(uuid,integer) to authenticated, service_role;
grant execute on function public.help_friend_bug_all_v1(uuid) to authenticated, service_role;
grant execute on function public.get_farm_activity_v2(integer,boolean) to authenticated, service_role;
grant execute on function public.steal_friend_crop(uuid,integer) to authenticated, service_role;

commit;

-- END 20260928_024_farm_stability_traffic.sql

-- ============================================================================
-- BEGIN 20260928_025_farm_friend_task_final.sql
-- ============================================================================
begin;

-- Stellar Diary V0.17.1
-- Friend / task / achievement / title final pass.
--
-- Goals:
--   * daily social EXP pool: 50 EXP max per UTC+8 farm day
--   * first visit to each real friend per day: +2 EXP
--   * friend watering: +5 EXP per successfully helped plot
--   * cumulative friend-visit / watering / pest-help statistics
--   * keep pest-help's existing random rewards outside the 50 EXP social cap
--   * return authoritative helper farm state so the browser can sync immediately

-- ---------------------------------------------------------------------------
-- 1) Central helper for daily social EXP and cumulative social statistics.
--    Returned JSON: {state, awarded, social_exp_today, new_visit}
-- ---------------------------------------------------------------------------
create or replace function private.farm_social_progress_v1(
  p_state jsonb,
  p_day text,
  p_exp_requested integer default 0,
  p_visit_key text default null,
  p_friend_visit_delta integer default 0,
  p_help_water_delta integer default 0,
  p_help_bug_delta integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_state jsonb := coalesce(p_state, '{}'::jsonb);
  v_daily jsonb;
  v_stats jsonb;
  v_visited jsonb := '[]'::jsonb;
  v_day text := coalesce(nullif(p_day,''), to_char(clock_timestamp() at time zone 'Asia/Taipei','YYYY-MM-DD'));
  v_current integer := 0;
  v_awarded integer := 0;
  v_new_visit boolean := false;
  v_friend_visits bigint := 0;
  v_help_water bigint := 0;
  v_help_bug bigint := 0;
  v_requested integer := greatest(0, coalesce(p_exp_requested,0));
  v_visit_delta integer := greatest(0, coalesce(p_friend_visit_delta,0));
begin
  v_stats := case when jsonb_typeof(v_state->'stats')='object' then v_state->'stats' else '{}'::jsonb end;
  v_daily := case when jsonb_typeof(v_state->'daily')='object' then v_state->'daily' else '{}'::jsonb end;

  -- A server-side interaction can be the first farm action after midnight.
  -- Reset the same daily fields used by the browser so stale yesterday values
  -- are never mixed into today's social cap.
  if coalesce(v_daily->>'date','') <> v_day then
    v_daily := jsonb_build_object(
      'date', v_day,
      'plant', 0,
      'harvest', 0,
      'sell', 0,
      'steal', 0,
      'visitedFriends', '[]'::jsonb,
      'socialExp', 0,
      'claimed', '[]'::jsonb,
      'bonusClaimed', false
    );
  end if;

  if coalesce(v_daily->>'socialExp','') ~ '^[0-9]+$' then
    v_current := least(50, greatest(0, (v_daily->>'socialExp')::integer));
  end if;

  if jsonb_typeof(v_daily->'visitedFriends')='array' then
    v_visited := v_daily->'visitedFriends';
  end if;

  if p_visit_key is not null and btrim(p_visit_key) <> '' then
    if not exists (
      select 1
      from jsonb_array_elements_text(v_visited) as x(value)
      where x.value = left(btrim(p_visit_key),100)
    ) then
      v_new_visit := true;
      v_visited := v_visited || jsonb_build_array(left(btrim(p_visit_key),100));
    else
      v_requested := 0;
      v_visit_delta := 0;
    end if;
  end if;

  v_awarded := least(v_requested, greatest(0, 50 - v_current));
  if v_awarded > 0 then
    v_state := private.farm_apply_exp_v1(v_state, v_awarded);
    v_current := v_current + v_awarded;
  end if;

  if coalesce(v_stats->>'friendVisits','') ~ '^[0-9]+$' then v_friend_visits := (v_stats->>'friendVisits')::bigint; end if;
  if coalesce(v_stats->>'helpWater','') ~ '^[0-9]+$' then v_help_water := (v_stats->>'helpWater')::bigint; end if;
  if coalesce(v_stats->>'helpBug','') ~ '^[0-9]+$' then v_help_bug := (v_stats->>'helpBug')::bigint; end if;

  v_stats := jsonb_set(v_stats,'{friendVisits}',to_jsonb(v_friend_visits + v_visit_delta),true);
  v_stats := jsonb_set(v_stats,'{helpWater}',to_jsonb(v_help_water + greatest(0,coalesce(p_help_water_delta,0))),true);
  v_stats := jsonb_set(v_stats,'{helpBug}',to_jsonb(v_help_bug + greatest(0,coalesce(p_help_bug_delta,0))),true);

  v_daily := jsonb_set(v_daily,'{date}',to_jsonb(v_day),true);
  v_daily := jsonb_set(v_daily,'{visitedFriends}',v_visited,true);
  v_daily := jsonb_set(v_daily,'{socialExp}',to_jsonb(v_current),true);
  v_state := jsonb_set(v_state,'{stats}',v_stats,true);
  v_state := jsonb_set(v_state,'{daily}',v_daily,true);

  return jsonb_build_object(
    'state', v_state,
    'awarded', v_awarded,
    'social_exp_today', v_current,
    'new_visit', v_new_visit
  );
end;
$$;

revoke all on function private.farm_social_progress_v1(jsonb,text,integer,text,integer,integer,integer)
from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2) Friend farm payload V7.
--    V6 remains available for older clients. V7 keeps the existing public farm
--    payload but makes the first visit to a different friend each UTC+8 day
--    server-authoritative (+2 EXP, shared 50 EXP cap).
-- ---------------------------------------------------------------------------
create or replace function public.get_friend_farm_v7(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_helper_state jsonb;
  v_social jsonb;
  v_day text := to_char(clock_timestamp() at time zone 'Asia/Taipei','YYYY-MM-DD');
  v_now timestamptz := clock_timestamp();
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_revision bigint := null;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;

  -- V6 already performs friendship validation and returns only safe friend data.
  -- Disable its visit logging so V7 can handle activity + reward in one place.
  v_payload := public.get_friend_farm_v6(p_friend, false);
  if coalesce(v_payload->>'ok','false') <> 'true' then return v_payload; end if;

  if coalesce(p_log_visit,true) and p_friend is not null and p_friend <> v_uid then
    -- Keep the existing anti-spam activity rule: at most one visible visit row
    -- to the same friend every 10 minutes.
    if not exists (
      select 1 from public.farm_activity a
      where a.owner_id=p_friend
        and a.actor_id=v_uid
        and a.activity_type='visit'
        and a.created_at > v_now - interval '10 minutes'
    ) then
      insert into public.farm_activity(owner_id,actor_id,activity_type,created_at)
      values(p_friend,v_uid,'visit',v_now);

      delete from public.farm_activity a
      where a.owner_id=p_friend and a.id in (
        select x.id from public.farm_activity x
        where x.owner_id=p_friend
        order by x.created_at desc,x.id desc
        offset 100
      );
    end if;

    select fs.state into v_helper_state
      from public.farm_saves fs
      where fs.user_id=v_uid
      for update;

    if found then
      v_social := private.farm_social_progress_v1(
        v_helper_state,
        v_day,
        2,
        p_friend::text,
        1,
        0,
        0
      );
      v_helper_state := v_social->'state';

      if coalesce((v_social->>'new_visit')::boolean,false) then
        v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);
        update public.farm_saves
           set state=v_helper_state,
               client_updated_at=v_now_ms
         where user_id=v_uid;
        select fs.revision into v_revision from public.farm_saves fs where fs.user_id=v_uid;

        v_payload := v_payload || jsonb_build_object(
          'helper_state', v_helper_state,
          'helper_revision', v_revision
        );
      end if;

      v_payload := v_payload || jsonb_build_object(
        'social_exp_awarded', coalesce((v_social->>'awarded')::integer,0),
        'social_exp_today', coalesce((v_social->>'social_exp_today')::integer,0),
        'new_daily_visit', coalesce((v_social->>'new_visit')::boolean,false),
        'farm_day', v_day
      );
    end if;
  end if;

  return v_payload;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3) Friend watering: true batch + helper reward/stat update.
--    Every successfully watered plot requests +5 social EXP, capped at 50/day.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_water_v1(
  p_friend uuid,
  p_plot integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_lock_id uuid;
  v_owner_state jsonb;
  v_helper_state jsonb;
  v_social jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_first_crop text := null;
  v_first_plot integer := null;
  v_planted_at bigint;
  v_duration_ms bigint;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_helper_name text := '农场好友';
  v_count integer := 0;
  v_ids jsonb := '[]'::jsonb;
  v_day text := to_char(clock_timestamp() at time zone 'Asia/Taipei','YYYY-MM-DD');
  v_revision bigint := null;
  i integer;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid then return jsonb_build_object('ok',false,'reason','invalid_target'); end if;
  if p_plot is not null and (p_plot < 0 or p_plot > 19) then return jsonb_build_object('ok',false,'reason','invalid_plot'); end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  select coalesce(nullif(trim(p.display_name),''),'农场好友')
    into v_helper_name
    from public.profiles p
   where p.id=v_uid;
  v_helper_name := coalesce(nullif(trim(v_helper_name),''),'农场好友');

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('farm-pair:' || v_low::text || ':' || v_high::text,0));
  for v_lock_id in
    select fs.user_id from public.farm_saves fs
    where fs.user_id in (v_low,v_high)
    order by fs.user_id
    for update
  loop null; end loop;

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_helper_state from public.farm_saves fs where fs.user_id=v_uid;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  for i in 0..19 loop
    if p_plot is not null and i <> p_plot then continue; end if;
    v_plot := v_owner_state->'plots'->i;
    if v_plot is null then continue; end if;
    v_crop_id := coalesce(v_plot->>'cropId','');
    if v_crop_id not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit') then continue; end if;
    if coalesce(v_plot->>'friendWatered','false') = 'true' then continue; end if;
    if coalesce(v_plot->>'plantedAt','') !~ '^[0-9]+$' then continue; end if;

    v_planted_at := (v_plot->>'plantedAt')::bigint;
    v_duration_ms := public.farm_plot_duration_ms_v1(v_plot);
    if v_duration_ms <= 0 or v_now_ms - v_planted_at >= v_duration_ms then continue; end if;

    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWatered'],'true'::jsonb,true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredBy'],to_jsonb(v_uid::text),true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredByName'],to_jsonb(left(v_helper_name,80)),true);
    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'friendWateredAt'],to_jsonb(v_now_ms),true);
    v_count := v_count + 1;
    v_ids := v_ids || jsonb_build_array(i);
    if v_first_plot is null then v_first_plot := i; v_first_crop := v_crop_id; end if;
  end loop;

  if v_count <= 0 then
    return jsonb_build_object('ok',false,'reason','no_eligible','count',0,'plot_ids',v_ids);
  end if;

  v_social := private.farm_social_progress_v1(v_helper_state,v_day,v_count*5,null,0,v_count,0);
  v_helper_state := v_social->'state';

  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_helper_state,client_updated_at=v_now_ms where user_id=v_uid;
  select fs.revision into v_revision from public.farm_saves fs where fs.user_id=v_uid;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(
    p_friend,v_uid,'help_water',
    case when v_count=1 then v_first_crop else null end,
    v_count,
    case when v_count=1 then v_first_plot else null end,
    clock_timestamp()
  );

  delete from public.farm_activity a
  where a.owner_id=p_friend and a.id in (
    select x.id from public.farm_activity x
    where x.owner_id=p_friend
    order by x.created_at desc,x.id desc
    offset 100
  );

  return jsonb_build_object(
    'ok',true,
    'count',v_count,
    'plot_ids',v_ids,
    'bonus_percent',5,
    'social_exp_awarded',coalesce((v_social->>'awarded')::integer,0),
    'social_exp_today',coalesce((v_social->>'social_exp_today')::integer,0),
    'helper_state',v_helper_state,
    'helper_revision',v_revision,
    'farm_day',v_day
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 4) Pest help keeps the existing random reward table. The cumulative helpBug
--    statistic is added, but random EXP does NOT consume the social 50 EXP cap.
-- ---------------------------------------------------------------------------
create or replace function public.help_friend_bug_v1(
  p_friend uuid,
  p_plot integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_lock_id uuid;
  v_owner_state jsonb;
  v_helper_state jsonb;
  v_social jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_roll double precision := random();
  v_reward_type text := 'none';
  v_reward_amount integer := 0;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_coins bigint := 0;
  v_max_coins bigint := 0;
  v_mystery integer := 0;
  v_day text := to_char(clock_timestamp() at time zone 'Asia/Taipei','YYYY-MM-DD');
  v_revision bigint := null;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid or p_plot is null or p_plot < 0 or p_plot > 19 then
    return jsonb_build_object('ok',false,'reason','invalid_target');
  end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('farm-pair:' || v_low::text || ':' || v_high::text,0));
  for v_lock_id in
    select fs.user_id from public.farm_saves fs
    where fs.user_id in (v_low,v_high)
    order by fs.user_id
    for update
  loop null; end loop;

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_helper_state from public.farm_saves fs where fs.user_id=v_uid;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  v_plot := v_owner_state->'plots'->p_plot;
  if v_plot is null or coalesce(v_plot->>'cropId','') = '' then return jsonb_build_object('ok',false,'reason','no_crop'); end if;
  if coalesce(v_plot->>'hasPest','false') <> 'true' then return jsonb_build_object('ok',false,'reason','no_pest'); end if;
  v_crop_id := v_plot->>'cropId';
  v_owner_state := jsonb_set(v_owner_state,array['plots',p_plot::text,'hasPest'],'false'::jsonb,true);

  if v_roll < 0.45 then
    v_reward_type := 'coins';
    v_reward_amount := 2 + floor(random()*4)::integer;
    if coalesce(v_helper_state->>'coins','') ~ '^[0-9]+$' then v_coins := (v_helper_state->>'coins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{coins}',to_jsonb(v_coins + v_reward_amount),true);
    v_helper_state := jsonb_set(v_helper_state,'{stats}',coalesce(v_helper_state->'stats','{}'::jsonb),true);
    if coalesce(v_helper_state->'stats'->>'maxCoins','') ~ '^[0-9]+$' then v_max_coins := (v_helper_state->'stats'->>'maxCoins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{stats,maxCoins}',to_jsonb(greatest(v_max_coins,v_coins+v_reward_amount)),true);
  elsif v_roll < 0.80 then
    v_reward_type := 'exp';
    v_reward_amount := 3 + floor(random()*6)::integer;
    v_helper_state := private.farm_apply_exp_v1(v_helper_state,v_reward_amount);
  elsif v_roll < 0.90 then
    v_reward_type := 'mystery';
    v_reward_amount := 1;
    v_helper_state := jsonb_set(v_helper_state,'{seeds}',coalesce(v_helper_state->'seeds','{}'::jsonb),true);
    if coalesce(v_helper_state->'seeds'->>'mystery','') ~ '^[0-9]+$' then v_mystery := (v_helper_state->'seeds'->>'mystery')::integer; end if;
    v_helper_state := jsonb_set(v_helper_state,'{seeds,mystery}',to_jsonb(v_mystery+1),true);
  end if;

  v_social := private.farm_social_progress_v1(v_helper_state,v_day,0,null,0,0,1);
  v_helper_state := v_social->'state';
  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_helper_state,client_updated_at=v_now_ms where user_id=v_uid;
  select fs.revision into v_revision from public.farm_saves fs where fs.user_id=v_uid;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(p_friend,v_uid,'help_bug',v_crop_id,1,p_plot,clock_timestamp());

  delete from public.farm_activity a
  where a.owner_id=p_friend and a.id in (
    select x.id from public.farm_activity x where x.owner_id=p_friend order by x.created_at desc,x.id desc offset 100
  );

  return jsonb_build_object(
    'ok',true,'crop_id',v_crop_id,'plot_id',p_plot,
    'reward_type',v_reward_type,'reward_amount',v_reward_amount,
    'helper_state',v_helper_state,'helper_revision',v_revision,'farm_day',v_day
  );
end;
$$;

create or replace function public.help_friend_bug_all_v1(p_friend uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_lock_id uuid;
  v_owner_state jsonb;
  v_helper_state jsonb;
  v_social jsonb;
  v_plot jsonb;
  v_crop_id text;
  v_first_crop text := null;
  v_first_plot integer := null;
  v_count integer := 0;
  v_ids jsonb := '[]'::jsonb;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_roll double precision;
  v_coin_reward integer := 0;
  v_exp_reward integer := 0;
  v_mystery_reward integer := 0;
  v_coins bigint := 0;
  v_max_coins bigint := 0;
  v_mystery integer := 0;
  v_day text := to_char(clock_timestamp() at time zone 'Asia/Taipei','YYYY-MM-DD');
  v_revision bigint := null;
  i integer;
begin
  if v_uid is null then return jsonb_build_object('ok',false,'reason','not_authenticated'); end if;
  if p_friend is null or p_friend = v_uid then return jsonb_build_object('ok',false,'reason','invalid_target'); end if;

  if v_uid::text < p_friend::text then v_low := v_uid; v_high := p_friend;
  else v_low := p_friend; v_high := v_uid; end if;

  if not exists (
    select 1 from public.farm_friendships f
    where f.user_low=v_low and f.user_high=v_high and f.status='accepted'
  ) then return jsonb_build_object('ok',false,'reason','not_friend'); end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('farm-pair:' || v_low::text || ':' || v_high::text,0));
  for v_lock_id in
    select fs.user_id from public.farm_saves fs
    where fs.user_id in (v_low,v_high)
    order by fs.user_id
    for update
  loop null; end loop;

  select fs.state into v_owner_state from public.farm_saves fs where fs.user_id=p_friend;
  if not found then return jsonb_build_object('ok',false,'reason','no_farm'); end if;
  select fs.state into v_helper_state from public.farm_saves fs where fs.user_id=v_uid;
  if not found then return jsonb_build_object('ok',false,'reason','no_own_farm'); end if;

  for i in 0..19 loop
    v_plot := v_owner_state->'plots'->i;
    if v_plot is null then continue; end if;
    v_crop_id := coalesce(v_plot->>'cropId','');
    if v_crop_id = '' or coalesce(v_plot->>'hasPest','false') <> 'true' then continue; end if;

    v_owner_state := jsonb_set(v_owner_state,array['plots',i::text,'hasPest'],'false'::jsonb,true);
    v_count := v_count + 1;
    v_ids := v_ids || jsonb_build_array(i);
    if v_first_plot is null then v_first_plot := i; v_first_crop := v_crop_id; end if;

    v_roll := random();
    if v_roll < 0.45 then
      v_coin_reward := v_coin_reward + 2 + floor(random()*4)::integer;
    elsif v_roll < 0.80 then
      v_exp_reward := v_exp_reward + 3 + floor(random()*6)::integer;
    elsif v_roll < 0.90 then
      v_mystery_reward := v_mystery_reward + 1;
    end if;
  end loop;

  if v_count <= 0 then return jsonb_build_object('ok',false,'reason','no_pest','count',0,'plot_ids',v_ids); end if;

  if v_coin_reward > 0 then
    if coalesce(v_helper_state->>'coins','') ~ '^[0-9]+$' then v_coins := (v_helper_state->>'coins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{coins}',to_jsonb(v_coins + v_coin_reward),true);
    v_helper_state := jsonb_set(v_helper_state,'{stats}',coalesce(v_helper_state->'stats','{}'::jsonb),true);
    if coalesce(v_helper_state->'stats'->>'maxCoins','') ~ '^[0-9]+$' then v_max_coins := (v_helper_state->'stats'->>'maxCoins')::bigint; end if;
    v_helper_state := jsonb_set(v_helper_state,'{stats,maxCoins}',to_jsonb(greatest(v_max_coins,v_coins+v_coin_reward)),true);
  end if;
  if v_exp_reward > 0 then v_helper_state := private.farm_apply_exp_v1(v_helper_state,v_exp_reward); end if;
  if v_mystery_reward > 0 then
    v_helper_state := jsonb_set(v_helper_state,'{seeds}',coalesce(v_helper_state->'seeds','{}'::jsonb),true);
    if coalesce(v_helper_state->'seeds'->>'mystery','') ~ '^[0-9]+$' then v_mystery := (v_helper_state->'seeds'->>'mystery')::integer; end if;
    v_helper_state := jsonb_set(v_helper_state,'{seeds,mystery}',to_jsonb(v_mystery+v_mystery_reward),true);
  end if;

  v_social := private.farm_social_progress_v1(v_helper_state,v_day,0,null,0,0,v_count);
  v_helper_state := v_social->'state';
  v_owner_state := jsonb_set(v_owner_state,'{updatedAt}',to_jsonb(v_now_ms),true);
  v_helper_state := jsonb_set(v_helper_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves set state=v_owner_state,client_updated_at=v_now_ms where user_id=p_friend;
  update public.farm_saves set state=v_helper_state,client_updated_at=v_now_ms where user_id=v_uid;
  select fs.revision into v_revision from public.farm_saves fs where fs.user_id=v_uid;

  insert into public.farm_activity(owner_id,actor_id,activity_type,crop_id,amount,plot_id,created_at)
  values(
    p_friend,v_uid,'help_bug',
    case when v_count=1 then v_first_crop else null end,
    v_count,
    case when v_count=1 then v_first_plot else null end,
    clock_timestamp()
  );

  delete from public.farm_activity a
  where a.owner_id=p_friend and a.id in (
    select x.id from public.farm_activity x
    where x.owner_id=p_friend
    order by x.created_at desc,x.id desc
    offset 100
  );

  return jsonb_build_object(
    'ok',true,
    'count',v_count,
    'plot_ids',v_ids,
    'helper_state',v_helper_state,
    'helper_revision',v_revision,
    'farm_day',v_day,
    'rewards',jsonb_build_object('coins',v_coin_reward,'exp',v_exp_reward,'mystery',v_mystery_reward)
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 5) Permissions.
-- ---------------------------------------------------------------------------
revoke all on function public.get_friend_farm_v7(uuid,boolean) from public, anon;
revoke all on function public.help_friend_water_v1(uuid,integer) from public, anon;
revoke all on function public.help_friend_bug_v1(uuid,integer) from public, anon;
revoke all on function public.help_friend_bug_all_v1(uuid) from public, anon;

grant execute on function public.get_friend_farm_v7(uuid,boolean) to authenticated, service_role;
grant execute on function public.help_friend_water_v1(uuid,integer) to authenticated, service_role;
grant execute on function public.help_friend_bug_v1(uuid,integer) to authenticated, service_role;
grant execute on function public.help_friend_bug_all_v1(uuid) to authenticated, service_role;

commit;

-- END 20260928_025_farm_friend_task_final.sql

-- ============================================================================
-- BEGIN 20260928_026_farm_daily_quest_v2.sql
-- ============================================================================
begin;

-- Stellar Diary V0.17.2
-- Daily Quest 2.0 compatibility layer.
--
-- No new tables are required. Daily quest selection / mastery / the train reset
-- ticket live inside the existing farm_saves.state JSON. This migration only
-- upgrades the server-authoritative social helper so a friend interaction that
-- happens just after UTC+8 midnight cannot reset the new daily fields back to
-- the older V0.17.1 shape.
--
-- It also records today's helpWater / helpBug counters on the server. Those
-- counters feed the new random daily quest pool while the existing cumulative
-- stats and 50 EXP social cap keep their V0.17.1 behaviour.

create or replace function private.farm_social_progress_v1(
  p_state jsonb,
  p_day text,
  p_exp_requested integer default 0,
  p_visit_key text default null,
  p_friend_visit_delta integer default 0,
  p_help_water_delta integer default 0,
  p_help_bug_delta integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_state jsonb := coalesce(p_state, '{}'::jsonb);
  v_daily jsonb;
  v_stats jsonb;
  v_visited jsonb := '[]'::jsonb;
  v_day text := coalesce(nullif(p_day,''), to_char(clock_timestamp() at time zone 'Asia/Taipei','YYYY-MM-DD'));
  v_current integer := 0;
  v_awarded integer := 0;
  v_new_visit boolean := false;
  v_friend_visits bigint := 0;
  v_help_water bigint := 0;
  v_help_bug bigint := 0;
  v_daily_help_water bigint := 0;
  v_daily_help_bug bigint := 0;
  v_requested integer := greatest(0, coalesce(p_exp_requested,0));
  v_visit_delta integer := greatest(0, coalesce(p_friend_visit_delta,0));
  v_water_delta integer := greatest(0, coalesce(p_help_water_delta,0));
  v_bug_delta integer := greatest(0, coalesce(p_help_bug_delta,0));
begin
  v_stats := case when jsonb_typeof(v_state->'stats')='object' then v_state->'stats' else '{}'::jsonb end;
  v_daily := case when jsonb_typeof(v_state->'daily')='object' then v_state->'daily' else '{}'::jsonb end;

  -- A server-side friend interaction can be the first action after midnight.
  -- Build the full V0.17.2 daily shape so the browser can safely generate its
  -- deterministic five-task plan after receiving this authoritative state.
  if coalesce(v_daily->>'date','') <> v_day then
    v_daily := jsonb_build_object(
      'date', v_day,
      'plant', 0,
      'harvest', 0,
      'sell', 0,
      'steal', 0,
      'helpWater', 0,
      'helpBug', 0,
      'trainCars', 0,
      'trainDepart', 0,
      'fertilize', 0,
      'mysteryPlant', 0,
      'plantByCrop', '{}'::jsonb,
      'harvestByCrop', '{}'::jsonb,
      'visitedFriends', '[]'::jsonb,
      'socialExp', 0,
      'taskIds', '[]'::jsonb,
      'levelSnapshot', 0,
      'rerollUsed', false,
      'rerollSlot', null,
      'claimed', '[]'::jsonb,
      'masteryClaimed', '[]'::jsonb,
      'bonusClaimed', false
    );
  end if;

  if coalesce(v_daily->>'socialExp','') ~ '^[0-9]+$' then
    v_current := least(50, greatest(0, (v_daily->>'socialExp')::integer));
  end if;
  if coalesce(v_daily->>'helpWater','') ~ '^[0-9]+$' then
    v_daily_help_water := (v_daily->>'helpWater')::bigint;
  end if;
  if coalesce(v_daily->>'helpBug','') ~ '^[0-9]+$' then
    v_daily_help_bug := (v_daily->>'helpBug')::bigint;
  end if;

  if jsonb_typeof(v_daily->'visitedFriends')='array' then
    v_visited := v_daily->'visitedFriends';
  end if;

  if p_visit_key is not null and btrim(p_visit_key) <> '' then
    if not exists (
      select 1
      from jsonb_array_elements_text(v_visited) as x(value)
      where x.value = left(btrim(p_visit_key),100)
    ) then
      v_new_visit := true;
      v_visited := v_visited || jsonb_build_array(left(btrim(p_visit_key),100));
    else
      v_requested := 0;
      v_visit_delta := 0;
    end if;
  end if;

  v_awarded := least(v_requested, greatest(0, 50 - v_current));
  if v_awarded > 0 then
    v_state := private.farm_apply_exp_v1(v_state, v_awarded);
    v_current := v_current + v_awarded;
  end if;

  if coalesce(v_stats->>'friendVisits','') ~ '^[0-9]+$' then v_friend_visits := (v_stats->>'friendVisits')::bigint; end if;
  if coalesce(v_stats->>'helpWater','') ~ '^[0-9]+$' then v_help_water := (v_stats->>'helpWater')::bigint; end if;
  if coalesce(v_stats->>'helpBug','') ~ '^[0-9]+$' then v_help_bug := (v_stats->>'helpBug')::bigint; end if;

  v_stats := jsonb_set(v_stats,'{friendVisits}',to_jsonb(v_friend_visits + v_visit_delta),true);
  v_stats := jsonb_set(v_stats,'{helpWater}',to_jsonb(v_help_water + v_water_delta),true);
  v_stats := jsonb_set(v_stats,'{helpBug}',to_jsonb(v_help_bug + v_bug_delta),true);

  v_daily := jsonb_set(v_daily,'{date}',to_jsonb(v_day),true);
  v_daily := jsonb_set(v_daily,'{visitedFriends}',v_visited,true);
  v_daily := jsonb_set(v_daily,'{socialExp}',to_jsonb(v_current),true);
  v_daily := jsonb_set(v_daily,'{helpWater}',to_jsonb(v_daily_help_water + v_water_delta),true);
  v_daily := jsonb_set(v_daily,'{helpBug}',to_jsonb(v_daily_help_bug + v_bug_delta),true);

  -- Backfill keys for same-day V0.17.1 state without replacing any V0.17.2
  -- task plan / reroll / claimed mastery data that may already exist.
  if coalesce(jsonb_typeof(v_daily->'plantByCrop'),'') <> 'object' then v_daily := jsonb_set(v_daily,'{plantByCrop}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_daily->'harvestByCrop'),'') <> 'object' then v_daily := jsonb_set(v_daily,'{harvestByCrop}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_daily->'taskIds'),'') <> 'array' then v_daily := jsonb_set(v_daily,'{taskIds}','[]'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_daily->'claimed'),'') <> 'array' then v_daily := jsonb_set(v_daily,'{claimed}','[]'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_daily->'masteryClaimed'),'') <> 'array' then v_daily := jsonb_set(v_daily,'{masteryClaimed}','[]'::jsonb,true); end if;
  if not (v_daily ? 'trainCars') then v_daily := jsonb_set(v_daily,'{trainCars}','0'::jsonb,true); end if;
  if not (v_daily ? 'trainDepart') then v_daily := jsonb_set(v_daily,'{trainDepart}','0'::jsonb,true); end if;
  if not (v_daily ? 'fertilize') then v_daily := jsonb_set(v_daily,'{fertilize}','0'::jsonb,true); end if;
  if not (v_daily ? 'mysteryPlant') then v_daily := jsonb_set(v_daily,'{mysteryPlant}','0'::jsonb,true); end if;
  if not (v_daily ? 'levelSnapshot') then v_daily := jsonb_set(v_daily,'{levelSnapshot}','0'::jsonb,true); end if;
  if not (v_daily ? 'rerollUsed') then v_daily := jsonb_set(v_daily,'{rerollUsed}','false'::jsonb,true); end if;
  if not (v_daily ? 'bonusClaimed') then v_daily := jsonb_set(v_daily,'{bonusClaimed}','false'::jsonb,true); end if;

  v_state := jsonb_set(v_state,'{stats}',v_stats,true);
  v_state := jsonb_set(v_state,'{daily}',v_daily,true);

  return jsonb_build_object(
    'state', v_state,
    'awarded', v_awarded,
    'social_exp_today', v_current,
    'new_visit', v_new_visit
  );
end;
$$;

revoke all on function private.farm_social_progress_v1(jsonb,text,integer,text,integer,integer,integer)
from public, anon, authenticated;

commit;

-- END 20260928_026_farm_daily_quest_v2.sql

-- ============================================================================
-- BEGIN 20260928_027_farm_item_wardrobe.sql
-- ============================================================================
-- Stellar Diary V0.18.1 — Stable farm item IDs + wardrobe ownership
-- Run AFTER 20260928_026_farm_daily_quest_v2.sql.
--
-- Adds:
--   #4004 supply.train_reset_ticket
--   #5001 outfit.default          (built-in / not mail-sendable)
--   #5002 outfit.mid_autumn       (reserved until art is released)
--   #5003 outfit.halloween        (reserved until art is released)
--   #5004 outfit.christmas        (reserved until art is released)
--
-- Outfit rewards are permanent booleans under state.wardrobe.outfits.
-- avatar.outfit remains the currently equipped cosmetic only.

begin;

-- Expand the stable item catalog so permanent cosmetics can use the same item-ID
-- attachment/reward pipeline as coins, seeds and farm supplies.
alter table public.mail_item_catalog
  drop constraint if exists mail_item_catalog_category_check,
  drop constraint if exists mail_item_catalog_reward_kind_check,
  drop constraint if exists mail_item_catalog_state_key_check;

alter table public.mail_item_catalog
  add constraint mail_item_catalog_category_check
    check (category in ('currency','box','seed','supply','outfit')),
  add constraint mail_item_catalog_reward_kind_check
    check (reward_kind in ('coin','exp','seed','supply','outfit')),
  add constraint mail_item_catalog_state_key_check check (
    (reward_kind in ('coin','exp') and state_key is null)
    or (reward_kind in ('seed','supply','outfit') and nullif(state_key,'') is not null)
  );

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(4004,'supply.train_reset_ticket','supply','supply','trainResetTicket','火车重置券','火車重置券','Train reset ticket','farm','refresh',null,100000,204,true,true),
(5001,'outfit.default','outfit','outfit','default','星辰农夫','星辰農夫','Stellar Farmer','farm','outfit',null,1,301,false,true),
(5002,'outfit.mid_autumn','outfit','outfit','mid_autumn','中秋节造型','中秋節造型','Mid-Autumn Outfit','farm','outfit',null,1,302,false,true),
(5003,'outfit.halloween','outfit','outfit','halloween','万圣节造型','萬聖節造型','Halloween Outfit','farm','outfit',null,1,303,false,true),
(5004,'outfit.christmas','outfit','outfit','christmas','圣诞造型','聖誕造型','Christmas Outfit','farm','outfit',null,1,304,false,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

-- Keep the existing item-ID format and legacy payload compatibility.  The train
-- ticket is also accepted in the legacy supplies object so older admin payloads
-- do not fail validation.
create or replace function private.validate_mail_rewards(p_rewards jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_key text;
  v_value jsonb;
  v_num numeric;
  v_item jsonb;
  v_item_id integer;
  v_qty integer;
  v_max integer;
begin
  if p_rewards is null or jsonb_typeof(p_rewards) <> 'object' then
    raise exception 'invalid_rewards' using errcode='22023';
  end if;

  if (p_rewards - 'items' - 'coins' - 'exp' - 'seeds' - 'supplies') <> '{}'::jsonb then
    raise exception 'unknown_reward_key' using errcode='22023';
  end if;

  if p_rewards ? 'items' then
    if jsonb_typeof(p_rewards->'items') <> 'array' then raise exception 'invalid_reward_items'; end if;
    if jsonb_array_length(p_rewards->'items') > 20 then raise exception 'too_many_reward_items'; end if;
    if (select count(*) from jsonb_array_elements(p_rewards->'items')) <>
       (select count(distinct (value->>'item_id')) from jsonb_array_elements(p_rewards->'items')) then
      raise exception 'duplicate_reward_item';
    end if;
    for v_item in select value from jsonb_array_elements(p_rewards->'items') loop
      if jsonb_typeof(v_item) <> 'object' or (v_item - 'item_id' - 'quantity') <> '{}'::jsonb then
        raise exception 'invalid_reward_item';
      end if;
      begin
        v_item_id := (v_item->>'item_id')::integer;
        v_qty := (v_item->>'quantity')::integer;
      exception when others then raise exception 'invalid_reward_item'; end;
      select c.max_quantity into v_max
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if not found then raise exception 'unknown_item_id:%',v_item_id; end if;
      if v_qty <= 0 or v_qty > v_max then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;

  foreach v_key in array array['coins','exp'] loop
    if p_rewards ? v_key then
      begin v_num := (p_rewards->>v_key)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 1000000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end if;
  end loop;

  if p_rewards ? 'seeds' then
    if jsonb_typeof(p_rewards->'seeds') <> 'object' then raise exception 'invalid_seed_rewards'; end if;
    for v_key,v_value in select key,value from jsonb_each(p_rewards->'seeds') loop
      if v_key not in ('carrot','wheat','corn','tomato','strawberry','pumpkin','grape','starfruit','mystery') then raise exception 'unknown_seed_reward'; end if;
      begin v_num := trim(both '"' from v_value::text)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 100000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;

  if p_rewards ? 'supplies' then
    if jsonb_typeof(p_rewards->'supplies') <> 'object' then raise exception 'invalid_supply_rewards'; end if;
    for v_key,v_value in select key,value from jsonb_each(p_rewards->'supplies') loop
      if v_key not in ('fertilizerLow','fertilizerMid','fertilizerHigh','trainResetTicket') then raise exception 'unknown_supply_reward'; end if;
      begin v_num := trim(both '"' from v_value::text)::numeric; exception when others then raise exception 'invalid_reward_quantity'; end;
      if v_num < 0 or v_num > 100000 or trunc(v_num) <> v_num then raise exception 'invalid_reward_quantity'; end if;
    end loop;
  end if;
end;
$$;

-- Replace the atomic reward engine used by claim_system_mail_v2.  Outfit items
-- set permanent ownership; they do NOT auto-equip, so the player explicitly taps
-- the wardrobe Apply button after claiming the mail.
create or replace function public.claim_system_mail_v1(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_rewards jsonb;
  v_state jsonb;
  v_claimed timestamptz;
  v_key text;
  v_value jsonb;
  v_qty integer;
  v_current integer;
  v_coins integer;
  v_exp integer;
  v_exp_bonus integer := 0;
  v_level integer;
  v_need integer;
  v_revision bigint;
  v_item jsonb;
  v_item_id integer;
  v_kind text;
  v_state_key text;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(select 1 from auth.users u where u.id=v_uid and nullif(u.email,'') is not null) then
    return query select false,'member_required','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  if exists(
    select 1 from public.player_mail_state s
     where s.user_id=v_uid and s.mail_id=p_mail_id and s.deleted_at is not null
  ) then
    return query select false,'mail_deleted','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  select m.rewards into v_rewards
    from public.system_mail m
   where m.id=p_mail_id and m.starts_at<=now() and (m.expires_at is null or m.expires_at>now())
     and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
   for share;
  if not found then return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint; return; end if;
  perform private.validate_mail_rewards(v_rewards);
  if v_rewards='{}'::jsonb or (v_rewards ? 'items' and jsonb_array_length(v_rewards->'items')=0 and (v_rewards-'items')='{}'::jsonb) then
    return query select false,'no_attachments',v_rewards,null::jsonb,null::bigint; return;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,claimed_at)
  values(v_uid,p_mail_id,now(),null)
  on conflict(user_id,mail_id) do nothing;

  select s.claimed_at into v_claimed
    from public.player_mail_state s where s.user_id=v_uid and s.mail_id=p_mail_id for update;
  if v_claimed is not null then return query select false,'already_claimed',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.farm_saves(user_id,state,client_updated_at)
  values(v_uid,jsonb_build_object(
      'version',1,'createdAt',floor(extract(epoch from now())*1000)::bigint,
      'coins',100,'level',1,'exp',0,'plots','[]'::jsonb,
      'seeds',jsonb_build_object('carrot',3,'wheat',2),'produce','{}'::jsonb,
      'supplies',jsonb_build_object('fertilizerLow',0,'fertilizerMid',0,'fertilizerHigh',0,'trainResetTicket',0),
      'wardrobe',jsonb_build_object('outfits',jsonb_build_object('default',true)),
      'avatar',jsonb_build_object('gender','male','outfit','default'),
      'stats',jsonb_build_object('visit',1,'plant',0,'harvest',0,'sell',0,'friend',0,'blindBoxPlant',0,'steals',0,'maxCoins',100),
      'updatedAt',floor(extract(epoch from now())*1000)::bigint),
    floor(extract(epoch from now())*1000)::bigint)
  on conflict(user_id) do nothing;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=v_uid for update;
  v_state := coalesce(v_state,'{}'::jsonb);
  v_state := jsonb_set(v_state,'{seeds}',coalesce(v_state->'seeds','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{supplies}',coalesce(v_state->'supplies','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{stats}',coalesce(v_state->'stats','{}'::jsonb),true);
  if coalesce(jsonb_typeof(v_state->'wardrobe'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{wardrobe}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'->'outfits'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{wardrobe,outfits}','{}'::jsonb,true);
  end if;
  v_state := jsonb_set(v_state,'{wardrobe,outfits,default}','true'::jsonb,true);

  v_coins := greatest(0,coalesce(nullif(v_state->>'coins','')::integer,0));
  v_exp_bonus := greatest(0,coalesce((v_rewards->>'exp')::integer,0));

  if v_rewards ? 'items' then
    for v_item in select value from jsonb_array_elements(v_rewards->'items') loop
      v_item_id := (v_item->>'item_id')::integer;
      v_qty := (v_item->>'quantity')::integer;
      select c.reward_kind,c.state_key into v_kind,v_state_key
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if v_kind='coin' then
        v_coins := v_coins + v_qty;
      elsif v_kind='exp' then
        v_exp_bonus := v_exp_bonus + v_qty;
      elsif v_kind='seed' then
        v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['seeds',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='supply' then
        v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['supplies',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='outfit' then
        v_state := jsonb_set(v_state,array['wardrobe','outfits',v_state_key],'true'::jsonb,true);
      end if;
    end loop;
  end if;

  -- Legacy V0.16 attachments remain supported.
  v_coins := v_coins + greatest(0,coalesce((v_rewards->>'coins')::integer,0));
  if v_rewards ? 'seeds' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'seeds') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;
  if v_rewards ? 'supplies' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'supplies') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins),true);
  v_current := greatest(v_coins,coalesce(nullif(v_state->'stats'->>'maxCoins','')::integer,0));
  v_state := jsonb_set(v_state,'{stats,maxCoins}',to_jsonb(v_current),true);

  v_level := greatest(1,coalesce(nullif(v_state->>'level','')::integer,1));
  v_exp := greatest(0,coalesce(nullif(v_state->>'exp','')::integer,0)) + v_exp_bonus;
  loop
    v_need := private.farm_exp_need(v_level);
    exit when v_exp < v_need;
    v_exp := v_exp-v_need;
    v_level := v_level+1;
  end loop;
  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(floor(extract(epoch from now())*1000)::bigint),true);

  update public.farm_saves fs
     set state=v_state,client_updated_at=floor(extract(epoch from now())*1000)::bigint,updated_at=now()
   where fs.user_id=v_uid
   returning fs.revision into v_revision;

  update public.player_mail_state
     set read_at=coalesce(read_at,now()),claimed_at=now()
   where user_id=v_uid and mail_id=p_mail_id;

  return query select true,'claimed',v_rewards,v_state,v_revision;
end;
$$;

-- Keep V1 private to the hardened V2 wrapper introduced by migration 022.
revoke execute on function public.claim_system_mail_v1(bigint) from public,anon,authenticated;

commit;

-- END 20260928_027_farm_item_wardrobe.sql

-- ============================================================================
-- BEGIN 20260928_028_mid_autumn_outfit.sql
-- ============================================================================
-- Stellar Diary V0.18.2 — Release Mid-Autumn outfit #5002
-- Run AFTER 20260928_027_farm_item_wardrobe.sql.
--
-- Both male/female Sprite Sheets now ship with the client, so the previously
-- reserved permanent outfit can be safely distributed through GM/system mail.

begin;

update public.mail_item_catalog
   set mail_enabled = true,
       active = true,
       max_quantity = 1,
       name_zh_cn = '中秋节造型',
       name_zh_tw = '中秋節造型',
       name_en = 'Mid-Autumn Outfit',
       updated_at = now()
 where item_id = 5002
   and item_code = 'outfit.mid_autumn'
   and category = 'outfit'
   and reward_kind = 'outfit'
   and state_key = 'mid_autumn';

do $$
begin
  if not exists (
    select 1
      from public.mail_item_catalog
     where item_id = 5002
       and item_code = 'outfit.mid_autumn'
       and category = 'outfit'
       and reward_kind = 'outfit'
       and state_key = 'mid_autumn'
       and active
       and mail_enabled
       and max_quantity = 1
  ) then
    raise exception 'mid_autumn_outfit_5002_not_ready';
  end if;
end $$;

commit;

-- END 20260928_028_mid_autumn_outfit.sql

-- ============================================================================
-- BEGIN 20260928_029_halloween_christmas_outfits.sql
-- ============================================================================
-- Stellar Diary V0.18.3 — Release Halloween #5003 + Christmas #5004 outfits
-- Run AFTER 20260928_027_farm_item_wardrobe.sql and 20260928_028_mid_autumn_outfit.sql.
--
-- Both male/female Sprite Sheets now ship with the client. These two permanent
-- Item IDs are therefore enabled for GM/system-mail distribution. Receiving an
-- outfit only unlocks wardrobe ownership; it never auto-equips the cosmetic.

begin;

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(5003,'outfit.halloween','outfit','outfit','halloween','万圣节造型','萬聖節造型','Halloween Outfit','farm','outfit',null,1,303,true,true),
(5004,'outfit.christmas','outfit','outfit','christmas','圣诞造型','聖誕造型','Christmas Outfit','farm','outfit',null,1,304,true,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

do $$
begin
  if not exists (
    select 1 from public.mail_item_catalog
     where item_id = 5003
       and item_code = 'outfit.halloween'
       and category = 'outfit'
       and reward_kind = 'outfit'
       and state_key = 'halloween'
       and active and mail_enabled and max_quantity = 1
  ) then
    raise exception 'halloween_outfit_5003_not_ready';
  end if;

  if not exists (
    select 1 from public.mail_item_catalog
     where item_id = 5004
       and item_code = 'outfit.christmas'
       and category = 'outfit'
       and reward_kind = 'outfit'
       and state_key = 'christmas'
       and active and mail_enabled and max_quantity = 1
  ) then
    raise exception 'christmas_outfit_5004_not_ready';
  end if;
end $$;

commit;

-- END 20260928_029_halloween_christmas_outfits.sql

-- ============================================================================
-- BEGIN 20260928_030_seasonal_decorations.sql
-- ============================================================================
-- Stellar Diary V0.19.0 — Seasonal decoration items + GM test delivery
-- Run AFTER 20260928_029_halloween_christmas_outfits.sql.
--
-- Public shop release:
--   #6001-#6004 Mid-Autumn decorations are visible in the farm decoration shop.
-- GM-only pre-release testing:
--   #6005-#6007 Halloween and #6009-#6012 Christmas are mail-sendable, but the
--   client deliberately hides them from the normal decoration shop until release.
-- #6008 is intentionally reserved.

begin;

alter table public.mail_item_catalog
  drop constraint if exists mail_item_catalog_category_check,
  drop constraint if exists mail_item_catalog_reward_kind_check,
  drop constraint if exists mail_item_catalog_state_key_check,
  drop constraint if exists mail_item_catalog_icon_source_check;

-- The original inline CHECK can have an autogenerated name in older projects.
-- Drop any remaining icon_source CHECK before recreating the supported list.
do $$
declare r record;
begin
  for r in
    select conname
      from pg_constraint
     where conrelid='public.mail_item_catalog'::regclass
       and contype='c'
       and pg_get_constraintdef(oid) ilike '%icon_source%'
  loop
    execute format('alter table public.mail_item_catalog drop constraint %I', r.conname);
  end loop;
end $$;

alter table public.mail_item_catalog
  add constraint mail_item_catalog_category_check
    check (category in ('currency','box','seed','supply','outfit','decoration')),
  add constraint mail_item_catalog_reward_kind_check
    check (reward_kind in ('coin','exp','seed','supply','outfit','decoration')),
  add constraint mail_item_catalog_state_key_check check (
    (reward_kind in ('coin','exp') and state_key is null)
    or (reward_kind in ('seed','supply','outfit','decoration') and nullif(state_key,'') is not null)
  ),
  add constraint mail_item_catalog_icon_source_check
    check (icon_source in ('farm','farm_item','farm_catalog','site'));

-- Upgrade the ticket/outfit catalog rows to the new 16-cell Item Icon Atlas.
update public.mail_item_catalog set icon_source='farm_catalog',icon_key='catalog',icon_cell=1,updated_at=now() where item_id=4004;
update public.mail_item_catalog set icon_source='farm_catalog',icon_key='catalog',icon_cell=2,updated_at=now() where item_id=5001;
update public.mail_item_catalog set icon_source='farm_catalog',icon_key='catalog',icon_cell=3,updated_at=now() where item_id=5002;
update public.mail_item_catalog set icon_source='farm_catalog',icon_key='catalog',icon_cell=4,updated_at=now() where item_id=5003;
update public.mail_item_catalog set icon_source='farm_catalog',icon_key='catalog',icon_cell=5,updated_at=now() where item_id=5004;

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(6001,'decoration.mid_lantern','decoration','decoration','mid_lantern','中秋宫灯','中秋宮燈','Mid-Autumn Palace Lantern','farm_catalog','catalog',6,99,401,true,true),
(6002,'decoration.mid_rabbit','decoration','decoration','mid_rabbit','玉兔摆饰','玉兔擺飾','Jade Rabbit Decoration','farm_catalog','catalog',7,99,402,true,true),
(6003,'decoration.mid_osmanthus','decoration','decoration','mid_osmanthus','桂花盆栽','桂花盆栽','Osmanthus Bonsai','farm_catalog','catalog',8,99,403,true,true),
(6004,'decoration.mid_moon_lamp','decoration','decoration','mid_moon_lamp','月亮景观灯','月亮景觀燈','Moon Landscape Lamp','farm_catalog','catalog',9,99,404,true,true),
(6005,'decoration.halloween_pumpkin','decoration','decoration','halloween_pumpkin','万圣南瓜灯','萬聖南瓜燈','Halloween Pumpkin Lantern','farm_catalog','catalog',10,99,405,true,true),
(6006,'decoration.halloween_ghost','decoration','decoration','halloween_ghost','幽灵墓碑','幽靈墓碑','Ghost Tombstone','farm_catalog','catalog',11,99,406,true,true),
(6007,'decoration.halloween_candle','decoration','decoration','halloween_candle','万圣烛台','萬聖燭台','Halloween Candelabrum','farm_catalog','catalog',12,99,407,true,true),
(6009,'decoration.christmas_tree','decoration','decoration','christmas_tree','圣诞树','聖誕樹','Christmas Tree','farm_catalog','catalog',13,99,409,true,true),
(6010,'decoration.christmas_gifts','decoration','decoration','christmas_gifts','圣诞礼物堆','聖誕禮物堆','Christmas Gift Pile','farm_catalog','catalog',14,99,410,true,true),
(6011,'decoration.christmas_snowman','decoration','decoration','christmas_snowman','雪人','雪人','Snowman','farm_catalog','catalog',15,99,411,true,true),
(6012,'decoration.christmas_lamp','decoration','decoration','christmas_lamp','圣诞路灯','聖誕路燈','Christmas Street Lamp','farm_catalog','catalog',16,99,412,true,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

-- Claim engine: decorations increase state.decorations.owned.<state_key>.
create or replace function public.claim_system_mail_v1(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_rewards jsonb;
  v_state jsonb;
  v_claimed timestamptz;
  v_key text;
  v_value jsonb;
  v_qty integer;
  v_current integer;
  v_coins integer;
  v_exp integer;
  v_exp_bonus integer := 0;
  v_level integer;
  v_need integer;
  v_revision bigint;
  v_item jsonb;
  v_item_id integer;
  v_kind text;
  v_state_key text;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(select 1 from auth.users u where u.id=v_uid and nullif(u.email,'') is not null) then
    return query select false,'member_required','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  if exists(
    select 1 from public.player_mail_state s
     where s.user_id=v_uid and s.mail_id=p_mail_id and s.deleted_at is not null
  ) then
    return query select false,'mail_deleted','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  select m.rewards into v_rewards
    from public.system_mail m
   where m.id=p_mail_id and m.starts_at<=now() and (m.expires_at is null or m.expires_at>now())
     and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
   for share;
  if not found then return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint; return; end if;
  perform private.validate_mail_rewards(v_rewards);
  if v_rewards='{}'::jsonb or (v_rewards ? 'items' and jsonb_array_length(v_rewards->'items')=0 and (v_rewards-'items')='{}'::jsonb) then
    return query select false,'no_attachments',v_rewards,null::jsonb,null::bigint; return;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,claimed_at)
  values(v_uid,p_mail_id,now(),null)
  on conflict(user_id,mail_id) do nothing;

  select s.claimed_at into v_claimed
    from public.player_mail_state s where s.user_id=v_uid and s.mail_id=p_mail_id for update;
  if v_claimed is not null then return query select false,'already_claimed',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.farm_saves(user_id,state,client_updated_at)
  values(v_uid,jsonb_build_object(
      'version',1,'createdAt',floor(extract(epoch from now())*1000)::bigint,
      'coins',100,'level',1,'exp',0,'plots','[]'::jsonb,
      'seeds',jsonb_build_object('carrot',3,'wheat',2),'produce','{}'::jsonb,
      'supplies',jsonb_build_object('fertilizerLow',0,'fertilizerMid',0,'fertilizerHigh',0,'trainResetTicket',0),
      'decorations',jsonb_build_object('owned','{}'::jsonb,'slots',jsonb_build_array(null,null,null,null,null,null,null,null)),
      'wardrobe',jsonb_build_object('outfits',jsonb_build_object('default',true)),
      'avatar',jsonb_build_object('gender','male','outfit','default'),
      'stats',jsonb_build_object('visit',1,'plant',0,'harvest',0,'sell',0,'friend',0,'blindBoxPlant',0,'steals',0,'maxCoins',100),
      'updatedAt',floor(extract(epoch from now())*1000)::bigint),
    floor(extract(epoch from now())*1000)::bigint)
  on conflict(user_id) do nothing;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=v_uid for update;
  v_state := coalesce(v_state,'{}'::jsonb);
  v_state := jsonb_set(v_state,'{seeds}',coalesce(v_state->'seeds','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{supplies}',coalesce(v_state->'supplies','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{stats}',coalesce(v_state->'stats','{}'::jsonb),true);
  if coalesce(jsonb_typeof(v_state->'decorations'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{decorations}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'decorations'->'owned'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{decorations,owned}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'decorations'->'slots'),'') <> 'array' then
    v_state := jsonb_set(v_state,'{decorations,slots}',jsonb_build_array(null,null,null,null,null,null,null,null),true);
  end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{wardrobe}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'->'outfits'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{wardrobe,outfits}','{}'::jsonb,true);
  end if;
  v_state := jsonb_set(v_state,'{wardrobe,outfits,default}','true'::jsonb,true);

  v_coins := greatest(0,coalesce(nullif(v_state->>'coins','')::integer,0));
  v_exp_bonus := greatest(0,coalesce((v_rewards->>'exp')::integer,0));

  if v_rewards ? 'items' then
    for v_item in select value from jsonb_array_elements(v_rewards->'items') loop
      v_item_id := (v_item->>'item_id')::integer;
      v_qty := (v_item->>'quantity')::integer;
      select c.reward_kind,c.state_key into v_kind,v_state_key
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if v_kind='coin' then
        v_coins := v_coins + v_qty;
      elsif v_kind='exp' then
        v_exp_bonus := v_exp_bonus + v_qty;
      elsif v_kind='seed' then
        v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['seeds',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='supply' then
        v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['supplies',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='outfit' then
        v_state := jsonb_set(v_state,array['wardrobe','outfits',v_state_key],'true'::jsonb,true);
      elsif v_kind='decoration' then
        v_current := greatest(0,coalesce(nullif(v_state->'decorations'->'owned'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['decorations','owned',v_state_key],to_jsonb(v_current+v_qty),true);
      end if;
    end loop;
  end if;

  -- Legacy V0.16 attachments remain supported.
  v_coins := v_coins + greatest(0,coalesce((v_rewards->>'coins')::integer,0));
  if v_rewards ? 'seeds' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'seeds') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;
  if v_rewards ? 'supplies' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'supplies') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins),true);
  v_current := greatest(v_coins,coalesce(nullif(v_state->'stats'->>'maxCoins','')::integer,0));
  v_state := jsonb_set(v_state,'{stats,maxCoins}',to_jsonb(v_current),true);

  v_level := greatest(1,coalesce(nullif(v_state->>'level','')::integer,1));
  v_exp := greatest(0,coalesce(nullif(v_state->>'exp','')::integer,0)) + v_exp_bonus;
  loop
    v_need := private.farm_exp_need(v_level);
    exit when v_exp < v_need;
    v_exp := v_exp-v_need;
    v_level := v_level+1;
  end loop;
  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(floor(extract(epoch from now())*1000)::bigint),true);

  update public.farm_saves fs
     set state=v_state,client_updated_at=floor(extract(epoch from now())*1000)::bigint,updated_at=now()
   where fs.user_id=v_uid
   returning fs.revision into v_revision;

  update public.player_mail_state
     set read_at=coalesce(read_at,now()),claimed_at=now()
   where user_id=v_uid and mail_id=p_mail_id;

  return query select true,'claimed',v_rewards,v_state,v_revision;
end;
$$;

revoke execute on function public.claim_system_mail_v1(bigint) from public,anon,authenticated;

-- Friend farm payload must allow the new seasonal IDs through the existing
-- sanitized decoration layout used by V6/V7.
create or replace function public.get_friend_farm_v5(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_slots jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V4 for friendship validation, public profile, plots and visit logging.
  v_payload := public.get_friend_farm_v4(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  select coalesce(jsonb_agg(
    case
      when (v_state #>> array['decorations','slots',g.i::text]) in
        ('hay','barrels','flowerbed','wheel','birdhouse','bench','scarecrow','lamp','windmill','sign',
         'mid_lantern','mid_rabbit','mid_osmanthus','mid_moon_lamp',
         'halloween_pumpkin','halloween_ghost','halloween_candle',
         'christmas_tree','christmas_gifts','christmas_snowman','christmas_lamp')
      then to_jsonb(v_state #>> array['decorations','slots',g.i::text])
      else 'null'::jsonb
    end order by g.i
  ), '[]'::jsonb)
  into v_slots
  from generate_series(0,7) as g(i);

  return v_payload || jsonb_build_object(
    'decorations', jsonb_build_object('slots', v_slots)
  );
end;
$$;

revoke all on function public.get_friend_farm_v5(uuid,boolean) from public, anon;
grant execute on function public.get_friend_farm_v5(uuid,boolean) to authenticated, service_role;

-- Smoke tests for all newly registered IDs and the reserved #6008 gap.
do $$
begin
  if (select count(*) from public.mail_item_catalog where item_id in (6001,6002,6003,6004,6005,6006,6007,6009,6010,6011,6012) and active and mail_enabled and reward_kind='decoration') <> 11 then
    raise exception 'seasonal_decoration_catalog_incomplete';
  end if;
  if exists(select 1 from public.mail_item_catalog where item_id=6008) then
    raise exception 'item_6008_must_remain_reserved';
  end if;
end $$;

commit;

-- END 20260928_030_seasonal_decorations.sql

-- ============================================================================
-- BEGIN 20260928_031_friend_avatar_visuals.sql
-- ============================================================================
-- V0.19.0.2 — public friend-farm visuals
-- Expose only the currently equipped outfit id (whitelisted) alongside the
-- already-public decoration slots. Wardrobe ownership and other private save
-- fields remain hidden. get_friend_farm_v6/v7 call v5, so no client RPC name
-- changes are required.

begin;

create or replace function public.get_friend_farm_v5(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_slots jsonb := '[]'::jsonb;
  v_outfit text := 'default';
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V4 for friendship validation, public profile, plots and visit logging.
  v_payload := public.get_friend_farm_v4(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  -- Keep the public farm view strictly whitelisted. Only valid scene decoration
  -- ids are returned; inventory counts and unpublished save fields stay private.
  select coalesce(jsonb_agg(
    case
      when (v_state #>> array['decorations','slots',g.i::text]) in
        ('hay','barrels','flowerbed','wheel','birdhouse','bench','scarecrow','lamp','windmill','sign',
         'mid_lantern','mid_rabbit','mid_osmanthus','mid_moon_lamp',
         'halloween_pumpkin','halloween_ghost','halloween_candle',
         'christmas_tree','christmas_gifts','christmas_snowman','christmas_lamp')
      then to_jsonb(v_state #>> array['decorations','slots',g.i::text])
      else 'null'::jsonb
    end order by g.i
  ), '[]'::jsonb)
  into v_slots
  from generate_series(0,7) as g(i);

  v_outfit := case
    when coalesce(v_state #>> '{avatar,outfit}','default') in ('default','mid_autumn','halloween','christmas')
      then coalesce(v_state #>> '{avatar,outfit}','default')
    else 'default'
  end;

  return v_payload || jsonb_build_object(
    'avatar', jsonb_build_object('outfit', v_outfit),
    'decorations', jsonb_build_object('slots', v_slots)
  );
end;
$$;

revoke all on function public.get_friend_farm_v5(uuid,boolean) from public, anon;
grant execute on function public.get_friend_farm_v5(uuid,boolean) to authenticated, service_role;

commit;

-- END 20260928_031_friend_avatar_visuals.sql

-- ============================================================================
-- BEGIN 20260930_032_pet_system_v1.sql
-- ============================================================================
-- Stellar Diary V0.19.1 — Pet system 1.0 / #7001 牙牙
-- Run AFTER 20260928_031_friend_avatar_visuals.sql.
-- Adds a permanent pet inventory, active follower state, GM mail delivery,
-- and a strictly whitelisted public active-pet field for friend farm visits.

begin;

alter table public.mail_item_catalog
  drop constraint if exists mail_item_catalog_category_check,
  drop constraint if exists mail_item_catalog_reward_kind_check,
  drop constraint if exists mail_item_catalog_state_key_check,
  drop constraint if exists mail_item_catalog_icon_source_check;

-- Older databases can carry an autogenerated icon_source CHECK name.
do $$
declare r record;
begin
  for r in
    select conname from pg_constraint
     where conrelid='public.mail_item_catalog'::regclass
       and contype='c'
       and pg_get_constraintdef(oid) ilike '%icon_source%'
  loop
    execute format('alter table public.mail_item_catalog drop constraint %I', r.conname);
  end loop;
end $$;

alter table public.mail_item_catalog
  add constraint mail_item_catalog_category_check
    check (category in ('currency','box','seed','supply','outfit','decoration','pet')),
  add constraint mail_item_catalog_reward_kind_check
    check (reward_kind in ('coin','exp','seed','supply','outfit','decoration','pet')),
  add constraint mail_item_catalog_state_key_check check (
    (reward_kind in ('coin','exp') and state_key is null)
    or (reward_kind in ('seed','supply','outfit','decoration','pet') and nullif(state_key,'') is not null)
  ),
  add constraint mail_item_catalog_icon_source_check
    check (icon_source in ('farm','farm_item','farm_catalog','farm_pet','site'));

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(7001,'pet.ya_ya','pet','pet','ya_ya','牙牙','牙牙','Yaya','farm_pet','ya_ya',null,1,501,true,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

create or replace function public.claim_system_mail_v1(p_mail_id bigint)
returns table(ok boolean, reason text, rewards jsonb, farm_state jsonb, revision bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_rewards jsonb;
  v_state jsonb;
  v_claimed timestamptz;
  v_key text;
  v_value jsonb;
  v_qty integer;
  v_current integer;
  v_coins integer;
  v_exp integer;
  v_exp_bonus integer := 0;
  v_level integer;
  v_need integer;
  v_revision bigint;
  v_item jsonb;
  v_item_id integer;
  v_kind text;
  v_state_key text;
begin
  if v_uid is null then raise exception 'not_authenticated' using errcode='28000'; end if;
  if not exists(select 1 from auth.users u where u.id=v_uid and nullif(u.email,'') is not null) then
    return query select false,'member_required','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  if exists(
    select 1 from public.player_mail_state s
     where s.user_id=v_uid and s.mail_id=p_mail_id and s.deleted_at is not null
  ) then
    return query select false,'mail_deleted','{}'::jsonb,null::jsonb,null::bigint; return;
  end if;

  select m.rewards into v_rewards
    from public.system_mail m
   where m.id=p_mail_id and m.starts_at<=now() and (m.expires_at is null or m.expires_at>now())
     and (m.audience_type='all' or (m.audience_type='user' and m.target_user_id=v_uid))
   for share;
  if not found then return query select false,'mail_unavailable','{}'::jsonb,null::jsonb,null::bigint; return; end if;
  perform private.validate_mail_rewards(v_rewards);
  if v_rewards='{}'::jsonb or (v_rewards ? 'items' and jsonb_array_length(v_rewards->'items')=0 and (v_rewards-'items')='{}'::jsonb) then
    return query select false,'no_attachments',v_rewards,null::jsonb,null::bigint; return;
  end if;

  insert into public.player_mail_state(user_id,mail_id,read_at,claimed_at)
  values(v_uid,p_mail_id,now(),null)
  on conflict(user_id,mail_id) do nothing;

  select s.claimed_at into v_claimed
    from public.player_mail_state s where s.user_id=v_uid and s.mail_id=p_mail_id for update;
  if v_claimed is not null then return query select false,'already_claimed',v_rewards,null::jsonb,null::bigint; return; end if;

  insert into public.farm_saves(user_id,state,client_updated_at)
  values(v_uid,jsonb_build_object(
      'version',1,'createdAt',floor(extract(epoch from now())*1000)::bigint,
      'coins',100,'level',1,'exp',0,'plots','[]'::jsonb,
      'seeds',jsonb_build_object('carrot',3,'wheat',2),'produce','{}'::jsonb,
      'supplies',jsonb_build_object('fertilizerLow',0,'fertilizerMid',0,'fertilizerHigh',0,'trainResetTicket',0),
      'decorations',jsonb_build_object('owned','{}'::jsonb,'slots',jsonb_build_array(null,null,null,null,null,null,null,null)),
      'wardrobe',jsonb_build_object('outfits',jsonb_build_object('default',true)),
      'avatar',jsonb_build_object('gender','male','outfit','default'),
      'pets',jsonb_build_object('owned','{}'::jsonb,'active',null),
      'stats',jsonb_build_object('visit',1,'plant',0,'harvest',0,'sell',0,'friend',0,'blindBoxPlant',0,'steals',0,'maxCoins',100),
      'updatedAt',floor(extract(epoch from now())*1000)::bigint),
    floor(extract(epoch from now())*1000)::bigint)
  on conflict(user_id) do nothing;

  select fs.state into v_state from public.farm_saves fs where fs.user_id=v_uid for update;
  v_state := coalesce(v_state,'{}'::jsonb);
  v_state := jsonb_set(v_state,'{seeds}',coalesce(v_state->'seeds','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{supplies}',coalesce(v_state->'supplies','{}'::jsonb),true);
  v_state := jsonb_set(v_state,'{stats}',coalesce(v_state->'stats','{}'::jsonb),true);
  if coalesce(jsonb_typeof(v_state->'decorations'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{decorations}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'decorations'->'owned'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{decorations,owned}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'decorations'->'slots'),'') <> 'array' then
    v_state := jsonb_set(v_state,'{decorations,slots}',jsonb_build_array(null,null,null,null,null,null,null,null),true);
  end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{wardrobe}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'->'outfits'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{wardrobe,outfits}','{}'::jsonb,true);
  end if;
  v_state := jsonb_set(v_state,'{wardrobe,outfits,default}','true'::jsonb,true);
  if coalesce(jsonb_typeof(v_state->'pets'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{pets}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'pets'->'owned'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{pets,owned}','{}'::jsonb,true);
  end if;
  if not (v_state->'pets' ? 'active') then
    v_state := jsonb_set(v_state,'{pets,active}','null'::jsonb,true);
  end if;

  v_coins := greatest(0,coalesce(nullif(v_state->>'coins','')::integer,0));
  v_exp_bonus := greatest(0,coalesce((v_rewards->>'exp')::integer,0));

  if v_rewards ? 'items' then
    for v_item in select value from jsonb_array_elements(v_rewards->'items') loop
      v_item_id := (v_item->>'item_id')::integer;
      v_qty := (v_item->>'quantity')::integer;
      select c.reward_kind,c.state_key into v_kind,v_state_key
        from public.mail_item_catalog c
       where c.item_id=v_item_id and c.active and c.mail_enabled;
      if v_kind='coin' then
        v_coins := v_coins + v_qty;
      elsif v_kind='exp' then
        v_exp_bonus := v_exp_bonus + v_qty;
      elsif v_kind='seed' then
        v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['seeds',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='supply' then
        v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['supplies',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='outfit' then
        v_state := jsonb_set(v_state,array['wardrobe','outfits',v_state_key],'true'::jsonb,true);
      elsif v_kind='decoration' then
        v_current := greatest(0,coalesce(nullif(v_state->'decorations'->'owned'->>v_state_key,'')::integer,0));
        v_state := jsonb_set(v_state,array['decorations','owned',v_state_key],to_jsonb(v_current+v_qty),true);
      elsif v_kind='pet' then
        v_state := jsonb_set(v_state,array['pets','owned',v_state_key],'true'::jsonb,true);
      end if;
    end loop;
  end if;

  -- Legacy V0.16 attachments remain supported.
  v_coins := v_coins + greatest(0,coalesce((v_rewards->>'coins')::integer,0));
  if v_rewards ? 'seeds' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'seeds') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'seeds'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;
  if v_rewards ? 'supplies' then
    for v_key,v_value in select key,value from jsonb_each(v_rewards->'supplies') loop
      v_qty := greatest(0,trim(both '"' from v_value::text)::integer);
      v_current := greatest(0,coalesce(nullif(v_state->'supplies'->>v_key,'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_key],to_jsonb(v_current+v_qty),true);
    end loop;
  end if;

  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins),true);
  v_current := greatest(v_coins,coalesce(nullif(v_state->'stats'->>'maxCoins','')::integer,0));
  v_state := jsonb_set(v_state,'{stats,maxCoins}',to_jsonb(v_current),true);

  v_level := greatest(1,coalesce(nullif(v_state->>'level','')::integer,1));
  v_exp := greatest(0,coalesce(nullif(v_state->>'exp','')::integer,0)) + v_exp_bonus;
  loop
    v_need := private.farm_exp_need(v_level);
    exit when v_exp < v_need;
    v_exp := v_exp-v_need;
    v_level := v_level+1;
  end loop;
  v_state := jsonb_set(v_state,'{level}',to_jsonb(v_level),true);
  v_state := jsonb_set(v_state,'{exp}',to_jsonb(v_exp),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(floor(extract(epoch from now())*1000)::bigint),true);

  update public.farm_saves fs
     set state=v_state,client_updated_at=floor(extract(epoch from now())*1000)::bigint,updated_at=now()
   where fs.user_id=v_uid
   returning fs.revision into v_revision;

  update public.player_mail_state
     set read_at=coalesce(read_at,now()),claimed_at=now()
   where user_id=v_uid and mail_id=p_mail_id;

  return query select true,'claimed',v_rewards,v_state,v_revision;
end;
$$;

revoke execute on function public.claim_system_mail_v1(bigint) from public,anon,authenticated;

create or replace function public.get_friend_farm_v5(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_slots jsonb := '[]'::jsonb;
  v_outfit text := 'default';
  v_pet text := null;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V4 for friendship validation, public profile, plots and visit logging.
  v_payload := public.get_friend_farm_v4(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  -- Keep the public farm view strictly whitelisted. Only valid scene decoration
  -- ids are returned; inventory counts and unpublished save fields stay private.
  select coalesce(jsonb_agg(
    case
      when (v_state #>> array['decorations','slots',g.i::text]) in
        ('hay','barrels','flowerbed','wheel','birdhouse','bench','scarecrow','lamp','windmill','sign',
         'mid_lantern','mid_rabbit','mid_osmanthus','mid_moon_lamp',
         'halloween_pumpkin','halloween_ghost','halloween_candle',
         'christmas_tree','christmas_gifts','christmas_snowman','christmas_lamp')
      then to_jsonb(v_state #>> array['decorations','slots',g.i::text])
      else 'null'::jsonb
    end order by g.i
  ), '[]'::jsonb)
  into v_slots
  from generate_series(0,7) as g(i);

  v_outfit := case
    when coalesce(v_state #>> '{avatar,outfit}','default') in ('default','mid_autumn','halloween','christmas')
      then coalesce(v_state #>> '{avatar,outfit}','default')
    else 'default'
  end;

  v_pet := case
    when coalesce(v_state #>> '{pets,active}','') in ('ya_ya')
      and coalesce((v_state #>> '{pets,owned,ya_ya}')::boolean,false)
      then v_state #>> '{pets,active}'
    else null
  end;

  return v_payload || jsonb_build_object(
    'avatar', jsonb_build_object('outfit', v_outfit),
    'pet', jsonb_build_object('active', v_pet),
    'decorations', jsonb_build_object('slots', v_slots)
  );
end;
$$;

revoke all on function public.get_friend_farm_v5(uuid,boolean) from public, anon;
grant execute on function public.get_friend_farm_v5(uuid,boolean) to authenticated, service_role;

commit;

-- END 20260930_032_pet_system_v1.sql

-- ============================================================================
-- BEGIN 20260930_033_pet_collection_v2.sql
-- ============================================================================
-- Stellar Diary V0.19.2 — Pet collection 2.0 / #7002–#7004
-- Run AFTER 20260930_032_pet_system_v1.sql.
-- Adds three directly-unlocked pets and extends the public friend-farm pet whitelist.

begin;

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(7002,'pet.shiba','pet','pet','shiba','小柴犬','小柴犬','Little Shiba','farm_pet','shiba',null,1,502,true,true),
(7003,'pet.orange_cat','pet','pet','orange_cat','橘猫','橘貓','Orange Cat','farm_pet','orange_cat',null,1,503,true,true),
(7004,'pet.moon_rabbit','pet','pet','moon_rabbit','月桂兔','月桂兔','Moon Rabbit','farm_pet','moon_rabbit',null,1,504,true,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

create or replace function public.get_friend_farm_v5(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_slots jsonb := '[]'::jsonb;
  v_outfit text := 'default';
  v_pet text := null;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V4 for friendship validation, public profile, plots and visit logging.
  v_payload := public.get_friend_farm_v4(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  -- Keep the public farm view strictly whitelisted. Only valid scene decoration
  -- ids are returned; inventory counts and unpublished save fields stay private.
  select coalesce(jsonb_agg(
    case
      when (v_state #>> array['decorations','slots',g.i::text]) in
        ('hay','barrels','flowerbed','wheel','birdhouse','bench','scarecrow','lamp','windmill','sign',
         'mid_lantern','mid_rabbit','mid_osmanthus','mid_moon_lamp',
         'halloween_pumpkin','halloween_ghost','halloween_candle',
         'christmas_tree','christmas_gifts','christmas_snowman','christmas_lamp')
      then to_jsonb(v_state #>> array['decorations','slots',g.i::text])
      else 'null'::jsonb
    end order by g.i
  ), '[]'::jsonb)
  into v_slots
  from generate_series(0,7) as g(i);

  v_outfit := case
    when coalesce(v_state #>> '{avatar,outfit}','default') in ('default','mid_autumn','halloween','christmas')
      then coalesce(v_state #>> '{avatar,outfit}','default')
    else 'default'
  end;

  v_pet := case
    when coalesce(v_state #>> '{pets,active}','') in ('ya_ya','shiba','orange_cat','moon_rabbit')
      and coalesce((v_state #>> array['pets','owned',coalesce(v_state #>> '{pets,active}','')])::boolean,false)
      then v_state #>> '{pets,active}'
    else null
  end;

  return v_payload || jsonb_build_object(
    'avatar', jsonb_build_object('outfit', v_outfit),
    'pet', jsonb_build_object('active', v_pet),
    'decorations', jsonb_build_object('slots', v_slots)
  );
end;
$$;

revoke all on function public.get_friend_farm_v5(uuid,boolean) from public, anon;
grant execute on function public.get_friend_farm_v5(uuid,boolean) to authenticated, service_role;


commit;

-- END 20260930_033_pet_collection_v2.sql

-- BEGIN 20261004_034_pet_roster_refresh.sql
-- Stellar Diary V0.19.3.2 — Pet roster refresh / #7001–#7005
-- Run AFTER 20260930_033_pet_collection_v2.sql.
-- Replaces #7001 牙牙 with 奶兔兔, replaces #7002 小柴犬 with 哈士奇,
-- keeps #7003 橘猫 / #7004 月桂兔, and adds #7005 奶油小羊.
-- Existing #7001/#7002 ownership and active follower state are migrated in place.

begin;

insert into public.mail_item_catalog
(item_id,item_code,category,reward_kind,state_key,name_zh_cn,name_zh_tw,name_en,icon_source,icon_key,icon_cell,max_quantity,sort_order,mail_enabled,active)
values
(7001,'pet.milk_bunny','pet','pet','milk_bunny','奶兔兔','奶兔兔','Milk Bunny','farm_pet','milk_bunny',null,1,501,true,true),
(7002,'pet.husky','pet','pet','husky','哈士奇','哈士奇','Husky','farm_pet','husky',null,1,502,true,true),
(7003,'pet.orange_cat','pet','pet','orange_cat','橘猫','橘貓','Orange Cat','farm_pet','orange_cat',null,1,503,true,true),
(7004,'pet.moon_rabbit','pet','pet','moon_rabbit','月桂兔','月桂兔','Moon Rabbit','farm_pet','moon_rabbit',null,1,504,true,true),
(7005,'pet.cream_sheep','pet','pet','cream_sheep','奶油小羊','奶油小羊','Cream Lamb','farm_pet','cream_sheep',null,1,505,true,true)
on conflict (item_id) do update set
  item_code=excluded.item_code,
  category=excluded.category,
  reward_kind=excluded.reward_kind,
  state_key=excluded.state_key,
  name_zh_cn=excluded.name_zh_cn,
  name_zh_tw=excluded.name_zh_tw,
  name_en=excluded.name_en,
  icon_source=excluded.icon_source,
  icon_key=excluded.icon_key,
  icon_cell=excluded.icon_cell,
  max_quantity=excluded.max_quantity,
  sort_order=excluded.sort_order,
  mail_enabled=excluded.mail_enabled,
  active=excluded.active,
  updated_at=now();

-- Preserve already-granted #7001 / #7002 ownership while changing the internal
-- state keys. This is intentionally item-ID preserving so existing system mail
-- attachments and GM grants remain valid.
update public.farm_saves fs
set state =
  jsonb_set(
    jsonb_set(
      fs.state,
      '{pets,owned}',
      (
        (coalesce(fs.state #> '{pets,owned}', '{}'::jsonb) - 'ya_ya' - 'shiba')
        || case
             when coalesce((fs.state #>> '{pets,owned,ya_ya}')::boolean,false)
               then jsonb_build_object('milk_bunny', true)
             else '{}'::jsonb
           end
        || case
             when coalesce((fs.state #>> '{pets,owned,shiba}')::boolean,false)
               then jsonb_build_object('husky', true)
             else '{}'::jsonb
           end
      ),
      true
    ),
    '{pets,active}',
    case
      when fs.state #>> '{pets,active}' = 'ya_ya' then to_jsonb('milk_bunny'::text)
      when fs.state #>> '{pets,active}' = 'shiba' then to_jsonb('husky'::text)
      when nullif(fs.state #>> '{pets,active}','') is null then 'null'::jsonb
      else to_jsonb(fs.state #>> '{pets,active}')
    end,
    true
  )
where coalesce(jsonb_typeof(fs.state->'pets'),'') = 'object';

create or replace function public.get_friend_farm_v5(
  p_friend uuid,
  p_log_visit boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_payload jsonb;
  v_state jsonb;
  v_slots jsonb := '[]'::jsonb;
  v_outfit text := 'default';
  v_pet text := null;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  end if;

  -- Reuse V4 for friendship validation, public profile, plots and visit logging.
  v_payload := public.get_friend_farm_v4(p_friend, p_log_visit);
  if not coalesce((v_payload->>'ok')::boolean, false) then
    return v_payload;
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id = p_friend;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_farm');
  end if;

  -- Keep the public farm view strictly whitelisted. Only valid scene decoration
  -- ids are returned; inventory counts and unpublished save fields stay private.
  select coalesce(jsonb_agg(
    case
      when (v_state #>> array['decorations','slots',g.i::text]) in
        ('hay','barrels','flowerbed','wheel','birdhouse','bench','scarecrow','lamp','windmill','sign',
         'mid_lantern','mid_rabbit','mid_osmanthus','mid_moon_lamp',
         'halloween_pumpkin','halloween_ghost','halloween_candle',
         'christmas_tree','christmas_gifts','christmas_snowman','christmas_lamp')
      then to_jsonb(v_state #>> array['decorations','slots',g.i::text])
      else 'null'::jsonb
    end order by g.i
  ), '[]'::jsonb)
  into v_slots
  from generate_series(0,7) as g(i);

  v_outfit := case
    when coalesce(v_state #>> '{avatar,outfit}','default') in ('default','mid_autumn','halloween','christmas')
      then coalesce(v_state #>> '{avatar,outfit}','default')
    else 'default'
  end;

  v_pet := case
    when coalesce(v_state #>> '{pets,active}','') in ('milk_bunny','husky','orange_cat','moon_rabbit','cream_sheep')
      and coalesce((v_state #>> array['pets','owned',coalesce(v_state #>> '{pets,active}','')])::boolean,false)
      then v_state #>> '{pets,active}'
    else null
  end;

  return v_payload || jsonb_build_object(
    'avatar', jsonb_build_object('outfit', v_outfit),
    'pet', jsonb_build_object('active', v_pet),
    'decorations', jsonb_build_object('slots', v_slots)
  );
end;
$$;

revoke all on function public.get_friend_farm_v5(uuid,boolean) from public, anon;
grant execute on function public.get_friend_farm_v5(uuid,boolean) to authenticated, service_role;

commit;
-- END 20261004_034_pet_roster_refresh.sql

-- BEGIN 20261005_035_seasonal_blind_box.sql
-- Stellar Diary V0.19.4.0 — Seasonal blind box system
-- Halloween / Christmas blind boxes, 49 coins each.
-- Purchase and opening are authoritative server-side operations.
-- Rare outfit (1%) and pet (1%) rewards are permanent and never duplicate.

begin;

create or replace function private.farm_blind_box_available_v1(p_box_code text)
returns boolean
language plpgsql
stable
set search_path = ''
as $$
declare
  v_md integer := to_char(timezone('Asia/Taipei', now()), 'MMDD')::integer;
begin
  if p_box_code = 'halloween' then
    return v_md between 1001 and 1130;
  elsif p_box_code = 'christmas' then
    return v_md >= 1201 or v_md <= 115;
  end if;
  return false;
end;
$$;

revoke all on function private.farm_blind_box_available_v1(text) from public, anon, authenticated;

create or replace function public.buy_farm_blind_box_v1(
  p_box_code text,
  p_quantity integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_state jsonb;
  v_qty integer := coalesce(p_quantity, 0);
  v_price integer := 49;
  v_cost integer;
  v_coins integer;
  v_owned integer;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_revision bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  if p_box_code is null or p_box_code not in ('halloween','christmas') then
    return jsonb_build_object('ok',false,'reason','invalid_box');
  end if;
  if v_qty not in (1,10) then
    return jsonb_build_object('ok',false,'reason','invalid_quantity');
  end if;
  if not private.farm_blind_box_available_v1(p_box_code) then
    return jsonb_build_object('ok',false,'reason','season_closed');
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id=v_uid
   for update;
  if not found or v_state is null or jsonb_typeof(v_state) <> 'object' then
    return jsonb_build_object('ok',false,'reason','farm_not_ready');
  end if;

  if coalesce(jsonb_typeof(v_state->'blindBoxes'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{blindBoxes}','{}'::jsonb,true);
  end if;
  if coalesce(jsonb_typeof(v_state->'stats'),'') <> 'object' then
    v_state := jsonb_set(v_state,'{stats}','{}'::jsonb,true);
  end if;

  v_coins := greatest(0, coalesce(nullif(v_state->>'coins','')::integer,0));
  v_cost := v_price * v_qty;
  if v_coins < v_cost then
    return jsonb_build_object('ok',false,'reason','not_enough_coins','need',v_cost,'coins',v_coins);
  end if;

  v_owned := greatest(0, coalesce(nullif(v_state #>> array['blindBoxes',p_box_code],'')::integer,0));
  v_state := jsonb_set(v_state,'{coins}',to_jsonb(v_coins-v_cost),true);
  v_state := jsonb_set(v_state,array['blindBoxes',p_box_code],to_jsonb(v_owned+v_qty),true);
  v_state := jsonb_set(v_state,'{stats,blindBoxBought}',to_jsonb(greatest(0,coalesce(nullif(v_state #>> '{stats,blindBoxBought}','')::integer,0))+v_qty),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves fs
     set state=v_state,
         client_updated_at=v_now_ms,
         updated_at=now()
   where fs.user_id=v_uid;

  select fs.revision into v_revision from public.farm_saves fs where fs.user_id=v_uid;

  return jsonb_build_object(
    'ok',true,
    'box_code',p_box_code,
    'quantity',v_qty,
    'cost',v_cost,
    'remaining_coins',v_coins-v_cost,
    'box_count',v_owned+v_qty,
    'revision',v_revision,
    'state',v_state
  );
end;
$$;

revoke all on function public.buy_farm_blind_box_v1(text,integer) from public, anon;
grant execute on function public.buy_farm_blind_box_v1(text,integer) to authenticated;

create or replace function public.open_farm_blind_box_v1(
  p_box_code text,
  p_count integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_state jsonb;
  v_count integer := coalesce(p_count,0);
  v_owned integer;
  v_now_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_revision bigint;
  v_results jsonb := '[]'::jsonb;
  v_i integer;
  v_roll numeric;
  v_outfit_id text;
  v_outfit_name text;
  v_outfit_available boolean;
  v_pet_ids text[];
  v_pet_id text;
  v_pet_name text;
  v_decor_ids text[];
  v_decor_id text;
  v_decor_name text;
  v_seed_id text;
  v_seed_name text;
  v_seed_qty integer;
  v_supply_id text;
  v_supply_name text;
  v_current integer;
  v_rare_count integer := 0;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode='28000';
  end if;

  if p_box_code is null or p_box_code not in ('halloween','christmas') then
    return jsonb_build_object('ok',false,'reason','invalid_box');
  end if;
  if v_count not in (1,10) then
    return jsonb_build_object('ok',false,'reason','invalid_count');
  end if;

  select fs.state into v_state
    from public.farm_saves fs
   where fs.user_id=v_uid
   for update;
  if not found or v_state is null or jsonb_typeof(v_state) <> 'object' then
    return jsonb_build_object('ok',false,'reason','farm_not_ready');
  end if;

  -- Normalize the state containers touched by the reward engine.
  if coalesce(jsonb_typeof(v_state->'blindBoxes'),'') <> 'object' then v_state := jsonb_set(v_state,'{blindBoxes}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'),'') <> 'object' then v_state := jsonb_set(v_state,'{wardrobe}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'wardrobe'->'outfits'),'') <> 'object' then v_state := jsonb_set(v_state,'{wardrobe,outfits}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'pets'),'') <> 'object' then v_state := jsonb_set(v_state,'{pets}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'pets'->'owned'),'') <> 'object' then v_state := jsonb_set(v_state,'{pets,owned}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'decorations'),'') <> 'object' then v_state := jsonb_set(v_state,'{decorations}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'decorations'->'owned'),'') <> 'object' then v_state := jsonb_set(v_state,'{decorations,owned}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'seeds'),'') <> 'object' then v_state := jsonb_set(v_state,'{seeds}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'supplies'),'') <> 'object' then v_state := jsonb_set(v_state,'{supplies}','{}'::jsonb,true); end if;
  if coalesce(jsonb_typeof(v_state->'stats'),'') <> 'object' then v_state := jsonb_set(v_state,'{stats}','{}'::jsonb,true); end if;

  v_owned := greatest(0, coalesce(nullif(v_state #>> array['blindBoxes',p_box_code],'')::integer,0));
  if v_owned < v_count then
    return jsonb_build_object('ok',false,'reason','not_enough_boxes','have',v_owned,'need',v_count);
  end if;

  -- Consume first. Any "another box" reward below adds one back atomically.
  v_state := jsonb_set(v_state,array['blindBoxes',p_box_code],to_jsonb(v_owned-v_count),true);

  if p_box_code='halloween' then
    v_outfit_id := 'halloween';
    v_outfit_name := '万圣节造型';
    v_decor_ids := array['halloween_pumpkin','halloween_ghost','halloween_candle'];
  else
    v_outfit_id := 'christmas';
    v_outfit_name := '圣诞造型';
    v_decor_ids := array['christmas_tree','christmas_gifts','christmas_snowman','christmas_lamp'];
  end if;

  for v_i in 1..v_count loop
    -- Outfit has a 1% category chance while the seasonal outfit is still missing.
    v_outfit_available := coalesce(v_state #>> array['wardrobe','outfits',v_outfit_id],'false') <> 'true';

    -- Pet has a 1% category chance while at least one released pet is still missing.
    select array_agg(x order by x) into v_pet_ids
      from unnest(array['milk_bunny','husky','orange_cat','moon_rabbit','cream_sheep']) as x
     where coalesce(v_state #>> array['pets','owned',x],'false') <> 'true';

    -- Exact rare-category rates: 0–1 = outfit 1%, 1–2 = pet 1%.
    -- If that permanent reward is already exhausted, that 1% draw is rerouted
    -- into the common pool instead of increasing the other rare category.
    v_roll := random() * 100;

    if v_roll < 1 then
      if v_outfit_available then
        v_state := jsonb_set(v_state,array['wardrobe','outfits',v_outfit_id],'true'::jsonb,true);
        v_results := v_results || jsonb_build_array(jsonb_build_object('kind','outfit','id',v_outfit_id,'name',v_outfit_name,'qty',1,'rarity','rare','effect','gold'));
        v_rare_count := v_rare_count + 1;
        continue;
      end if;
    elsif v_roll < 2 then
      if coalesce(cardinality(v_pet_ids),0)>0 then
        v_pet_id := v_pet_ids[1 + floor(random()*cardinality(v_pet_ids))::integer];
        v_pet_name := case v_pet_id
          when 'milk_bunny' then '奶兔兔'
          when 'husky' then '哈士奇'
          when 'orange_cat' then '橘猫'
          when 'moon_rabbit' then '月桂兔'
          when 'cream_sheep' then '奶油小羊'
          else '宠物' end;
        v_state := jsonb_set(v_state,array['pets','owned',v_pet_id],'true'::jsonb,true);
        v_results := v_results || jsonb_build_array(jsonb_build_object('kind','pet','id',v_pet_id,'name',v_pet_name,'qty',1,'rarity','rare','effect','purple'));
        v_rare_count := v_rare_count + 1;
        continue;
      end if;
    end if;

    -- Common pool = seed 55 + seasonal decor 18 + fertilizer 15 + same box 10.
    -- A missing rare reward lands here and is redistributed proportionally.
    v_roll := random() * 98;
    if v_roll < 55 then
      -- Weighted seed sub-pool. Quantity scales down as seed rarity rises.
      v_roll := random()*100;
      if v_roll < 26 then v_seed_id:='carrot'; v_seed_name:='红萝卜种子'; v_seed_qty:=5;
      elsif v_roll < 48 then v_seed_id:='wheat'; v_seed_name:='小麦种子'; v_seed_qty:=4;
      elsif v_roll < 66 then v_seed_id:='corn'; v_seed_name:='玉米种子'; v_seed_qty:=4;
      elsif v_roll < 80 then v_seed_id:='tomato'; v_seed_name:='番茄种子'; v_seed_qty:=3;
      elsif v_roll < 89 then v_seed_id:='strawberry'; v_seed_name:='草莓种子'; v_seed_qty:=3;
      elsif v_roll < 95 then v_seed_id:='pumpkin'; v_seed_name:='南瓜种子'; v_seed_qty:=2;
      elsif v_roll < 99 then v_seed_id:='grape'; v_seed_name:='葡萄种子'; v_seed_qty:=2;
      else v_seed_id:='starfruit'; v_seed_name:='星辰果种子'; v_seed_qty:=1;
      end if;
      v_current := greatest(0,coalesce(nullif(v_state #>> array['seeds',v_seed_id],'')::integer,0));
      v_state := jsonb_set(v_state,array['seeds',v_seed_id],to_jsonb(v_current+v_seed_qty),true);
      v_results := v_results || jsonb_build_array(jsonb_build_object('kind','seed','id',v_seed_id,'name',v_seed_name,'qty',v_seed_qty,'rarity','normal'));
      continue;
    end if;
    v_roll := v_roll - 55;

    if v_roll < 18 then
      v_decor_id := v_decor_ids[1 + floor(random()*cardinality(v_decor_ids))::integer];
      v_decor_name := case v_decor_id
        when 'halloween_pumpkin' then '万圣南瓜灯'
        when 'halloween_ghost' then '幽灵墓碑'
        when 'halloween_candle' then '万圣烛台'
        when 'christmas_tree' then '圣诞树'
        when 'christmas_gifts' then '圣诞礼物堆'
        when 'christmas_snowman' then '雪人'
        when 'christmas_lamp' then '圣诞路灯'
        else '季节装饰' end;
      v_current := greatest(0,coalesce(nullif(v_state #>> array['decorations','owned',v_decor_id],'')::integer,0));
      v_state := jsonb_set(v_state,array['decorations','owned',v_decor_id],to_jsonb(v_current+1),true);
      v_results := v_results || jsonb_build_array(jsonb_build_object('kind','decoration','id',v_decor_id,'name',v_decor_name,'qty',1,'rarity','seasonal'));
      continue;
    end if;
    v_roll := v_roll - 18;

    if v_roll < 15 then
      v_roll := random()*100;
      if v_roll < 60 then v_supply_id:='fertilizerLow'; v_supply_name:='低级肥料';
      elsif v_roll < 90 then v_supply_id:='fertilizerMid'; v_supply_name:='中级肥料';
      else v_supply_id:='fertilizerHigh'; v_supply_name:='高级肥料';
      end if;
      v_current := greatest(0,coalesce(nullif(v_state #>> array['supplies',v_supply_id],'')::integer,0));
      v_state := jsonb_set(v_state,array['supplies',v_supply_id],to_jsonb(v_current+1),true);
      v_results := v_results || jsonb_build_array(jsonb_build_object('kind','supply','id',v_supply_id,'name',v_supply_name,'qty',1,'rarity','normal'));
      continue;
    end if;

    -- Remaining 10%: another blind box of the same seasonal type.
    v_current := greatest(0,coalesce(nullif(v_state #>> array['blindBoxes',p_box_code],'')::integer,0));
    v_state := jsonb_set(v_state,array['blindBoxes',p_box_code],to_jsonb(v_current+1),true);
    v_results := v_results || jsonb_build_array(jsonb_build_object('kind','blindbox','id',p_box_code,'name',case when p_box_code='halloween' then '万圣节盲盒' else '圣诞节盲盒' end,'qty',1,'rarity','bonus'));
  end loop;

  v_state := jsonb_set(v_state,'{stats,blindBoxOpened}',to_jsonb(greatest(0,coalesce(nullif(v_state #>> '{stats,blindBoxOpened}','')::integer,0))+v_count),true);
  v_state := jsonb_set(v_state,'{stats,blindBoxRare}',to_jsonb(greatest(0,coalesce(nullif(v_state #>> '{stats,blindBoxRare}','')::integer,0))+v_rare_count),true);
  v_state := jsonb_set(v_state,'{updatedAt}',to_jsonb(v_now_ms),true);

  update public.farm_saves fs
     set state=v_state,
         client_updated_at=v_now_ms,
         updated_at=now()
   where fs.user_id=v_uid;

  select fs.revision into v_revision from public.farm_saves fs where fs.user_id=v_uid;

  return jsonb_build_object(
    'ok',true,
    'box_code',p_box_code,
    'count',v_count,
    'results',v_results,
    'remaining',greatest(0,coalesce(nullif(v_state #>> array['blindBoxes',p_box_code],'')::integer,0)),
    'rare_count',v_rare_count,
    'revision',v_revision,
    'state',v_state
  );
end;
$$;

revoke all on function public.open_farm_blind_box_v1(text,integer) from public, anon;
grant execute on function public.open_farm_blind_box_v1(text,integer) to authenticated;

commit;

-- END 20261005_035_seasonal_blind_box.sql
