# Ice Cream POS — Maalem

Mobile-first point-of-sale web app. Sells per piece, tracks inventory and profit.

## Products

| Product | Cost/pc | Sell/pc | Profit/pc | Pcs/carton | Starting stock |
|---|---|---|---|---|---|
| Platsch | 3.31 DH | 6 DH | 2.69 DH | 32 | 96 |
| Scooby Doo | 2.50 DH | 6 DH | 3.50 DH | 40 | 80 |
| Cornion | 2.50 DH | 5 DH | 2.50 DH | 40 | 120 |
| Bay Bino | 5.00 DH | 10 DH | 5.00 DH | 24 | 48 |
| Leone | 10.00 DH | 15 DH | 5.00 DH | 25 | 75 |
| Classico | 12.00 DH | 17 DH | 5.00 DH | 22 | 22 |
| Yosse | 4.17 DH | 10 DH | 5.83 DH | 24 | 72 |
| Solero | 12.00 DH | 20 DH | 8.00 DH | 25 | 50 |
| Magnum | 17.50 DH | 23 DH | 5.50 DH | 20 | 80 |

## Features

- Per-piece sales with tap-to-add product grid and search
- Live inventory: stock shown on each card, decremented on every sale, blocks overselling
- Low-stock and out-of-stock indicators
- Stock panel: edit quantities, see stock value and carton equivalents
- Profit shown per sale (cart, receipt)
- Numbered receipts
- Data persists on the device (localStorage) — works offline
- Installable as a phone app (add to home screen)

## Deploy

Import the repo at [vercel.com/new](https://vercel.com/new) — no build config needed. Pushes to `main` auto-deploy once connected.

## Multi-device sync (Supabase)

1. Create a free project at [supabase.com](https://supabase.com).
2. In the project, open **SQL Editor**, paste the contents of `schema.sql`, and click **Run**.
3. In **Project Settings → API**, copy the **Project URL** and the **anon public key**.
4. Put them in `index.html`:
   ```js
   const SUPABASE_URL = 'https://xxxx.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJ...';
   ```
5. Push — done. All phones now share the same stock and sales in realtime.

Sync behavior:
- Header chip shows the state: **Sync** (green), **N en attente** (offline sales queued), **Hors ligne**, or **Local** (not configured).
- Sales made offline are queued on the device and pushed automatically when the connection returns.
- Stock changes and sales from other phones appear live via Supabase Realtime.
- The first device to connect seeds the database with the built-in product list.
