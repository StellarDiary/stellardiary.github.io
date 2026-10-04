# StellarDiary new Supabase project setup (V0.19.3)

1. Authentication -> URL Configuration
   - Site URL: `https://stellardiary.github.io/`
   - Redirect URL: `https://stellardiary.github.io/**`
2. SQL Editor -> run `FRESH_INSTALL_V0193.sql` once on the empty project.
3. Deploy Edge Function `bark-push` only if Bark push is needed on the new site.
4. Store `BARK_DEVICE_KEY` only in Supabase Edge Function Secrets; never put it in GitHub Pages.
5. Open `https://stellardiary.github.io/`, create/sign in to the site-owner account once.
6. Authentication -> Users -> copy that account UUID.
7. Edit/run `SET_FIRST_GM.sql` with that UUID.
8. The browser frontend uses only the Project URL and Publishable Key. Never add a Secret Key to the website files.
