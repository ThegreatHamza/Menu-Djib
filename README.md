# Menu Djib

Mobile-first multilingual QR menu and WhatsApp ordering for restaurants in Djibouti. Built with Next.js 14 App Router, TypeScript, Tailwind CSS and Supabase.

## Features
- Restaurant owner authentication and setup
- French, Arabic (RTL) and English menu content
- Categories and menu item management
- Public restaurant menu at `/r/[slug]`, search, cart, table/delivery/pickup selection
- Orders saved to Supabase and WhatsApp handoff
- Realtime staff order board, sales summaries, QR download and print-friendly table cards
- DJF currency with no decimals

## Deploy free
1. Create a Supabase project at https://supabase.com and open SQL Editor.
2. Run `supabase/schema.sql`, then `supabase/seed.sql` if you want sample data. Enable Realtime for `orders` in Database > Replication if it is not already enabled.
3. In Supabase Storage, create a **public** bucket named `menu-photos` (max file size 5 MB). Configure upload policies so authenticated restaurant owners can upload only under their own restaurant UUID folder. The menu editor uses this bucket for dish photos.\n4. Copy `.env.example` to `.env.local` and fill in the Supabase project URL, anon key, and server-only service role key.\n5. In Supabase Authentication > URL Configuration, set your local URL and later your Vercel URL as Site URL / allowed redirect URLs.\n6. Install Node.js 18.17+ and run `npm install`, `npm run dev`.\n7. Push this repository to GitHub, import it at https://vercel.com, add the same environment variables, and deploy.\n8. Sign up in the app, create a restaurant, manage categories and dishes at `/dashboard/menu`, and print a QR card at `/dashboard/qr`. Set your WhatsApp number in international `+253` format.
4. In Supabase Authentication > URL Configuration, set your local URL and later your Vercel URL as Site URL / allowed redirect URLs.
5. Install Node.js 18.17+ and run `npm install`, `npm run dev`.
6. Push this repository to GitHub, import it at https://vercel.com, add the same environment variables, and deploy.
7. Sign up in the app, create a restaurant, and publish it. Set your WhatsApp number in international `+253...` format.

## Notes
- Orders are inserted through a server-side route using the Supabase service-role key. Never expose `SUPABASE_SERVICE_ROLE_KEY` in a `NEXT_PUBLIC_` variable.
- The browser WhatsApp link is a customer handoff, not an official WhatsApp Business API integration. Customers must tap Send in WhatsApp.
- Public menu reads are limited to published restaurants and available items. Owner writes are protected by RLS.
- For production, add rate limiting / bot protection to order creation and validate operational details with your restaurant.
