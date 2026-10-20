import { createClient } from '@supabase/supabase-js';
export function supabasePublic() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) throw new Error('Missing Supabase public environment variables. Copy .env.example to .env.local.');
  return createClient(url, key);
}
export function supabaseAdmin() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) throw new Error('Missing Supabase server environment variables.');
  return createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
}
