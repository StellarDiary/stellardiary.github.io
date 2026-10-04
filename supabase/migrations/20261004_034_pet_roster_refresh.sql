-- Stellar Diary V0.19.3.1 — Pet roster refresh / #7001–#7005
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
