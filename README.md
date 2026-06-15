# SAVOR POS

Flutter restaurant POS with tables, POS ordering, KDS, billing, inventory,
staff, reports, settings, and Supabase-ready data services.

## Local Mock Data

The app can run fully with built-in mock data while the real backend is not
ready. Keep this in `.env`:

```env
APP_DATA_SOURCE=mock
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Mock login accepts any password for seeded staff emails, for example:

```text
admin@savor.pos
cashier@savor.pos
waiter@savor.pos
kitchen@savor.pos
```

## Supabase Setup

When the software is ready for real data:

1. Create a Supabase project.
2. Open `supabase/setup.sql`.
3. Paste it into Supabase Dashboard > SQL Editor.
4. Run the SQL.
5. Create users in Supabase Dashboard > Authentication > Users.
6. Add user metadata such as `{"name":"Aditya Sen","role":"admin"}`.
7. Update `.env`:

```env
APP_DATA_SOURCE=live
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

To change a user role later in SQL Editor:

```sql
update public.profiles
set role = 'admin'
where email = 'admin@example.com';
```

Use one of these roles: `admin`, `cashier`, `waiter`, `kitchen`.
