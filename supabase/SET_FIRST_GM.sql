-- Stellar Diary fresh project: promote the first site-owner account to super_admin.
-- 1) First create/sign in to the website account once.
-- 2) Supabase Dashboard -> Authentication -> Users -> copy that user's UUID.
-- 3) Replace YOUR_AUTH_USER_UUID below and run this file once in SQL Editor.

insert into public.admin_users(user_id, role, display_name)
values ('YOUR_AUTH_USER_UUID'::uuid, 'super_admin', 'Stellar Diary GM')
on conflict (user_id) do update
set role = excluded.role, display_name = excluded.display_name;
