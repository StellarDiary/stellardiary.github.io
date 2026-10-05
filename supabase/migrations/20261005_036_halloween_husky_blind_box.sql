-- Stellar Diary V0.19.4.2 — Halloween blind box Husky jackpot
-- Halloween pet jackpot (1%) is now fixed to #7002 Husky.
-- Husky uses the existing purple 4-frame rare-pet effect.
-- If Husky is already owned, the pet 1% slot reroutes into the common pool; no duplicate pet is granted.

begin;

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

    -- V0.19.4.2: Halloween's 1% pet jackpot is specifically Husky.
    -- Once Husky is owned, that permanent 1% slot reroutes into the common pool.
    -- Christmas keeps the existing released-pet pool until its seasonal pet is assigned.
    if p_box_code='halloween' then
      if coalesce(v_state #>> array['pets','owned','husky'],'false') <> 'true' then
        v_pet_ids := array['husky'];
      else
        v_pet_ids := array[]::text[];
      end if;
    else
      select array_agg(x order by x) into v_pet_ids
        from unnest(array['milk_bunny','husky','orange_cat','moon_rabbit','cream_sheep']) as x
       where coalesce(v_state #>> array['pets','owned',x],'false') <> 'true';
    end if;

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
