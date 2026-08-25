# Ledgerly

A small, private income and expense tracker built with HTML, CSS, vanilla JavaScript, Supabase, and Chart.js. It is a static site: there is no build step, Node server, or paid service.

## Setup

1. Create a free GitHub repository and a free Supabase project.
2. In Supabase SQL Editor, run [`supabase/schema.sql`](supabase/schema.sql).
3. In Supabase Dashboard, open **Project Settings > API** and copy the **Project URL** and **anon public key**.
4. Put them in [`js/config.js`](js/config.js). Only use the anon key, never a `service_role` key.
5. Open `index.html` locally for a quick visual check. For auth and CDN modules, use a simple static server if your browser blocks local module imports (for example VS Code Live Server). No npm is required.
6. Create an account, confirm the email if confirmation is enabled, then sign in.
7. Add a job, income, and expense. Verify the dashboard totals.
8. Commit and push the files to GitHub.
9. In the repository, open **Settings > Pages**, choose **Deploy from a branch**, select your main branch and `/ (root)`, and save.
10. Open the generated `https://<username>.github.io/<repository>/` URL and test signup/login and data entry.

## Supabase free tier and security

This uses free-tier PostgreSQL tables, Supabase Auth email/password, Row Level Security, and the hosted REST API. It is sized comfortably for one personal tracker, but free projects have quotas, including database/storage limits and monthly bandwidth/usage limits that Supabase may change. This app stores only small text and numeric records, so it does not need storage buckets or edge functions.

The repository contains frontend code only. Financial records live in Supabase. The anon public key is expected in browser code, but RLS is what protects the data: every row has `user_id`, and policies allow access only when it matches `auth.uid()`. A database trigger fills `user_id` on inserts. Never commit passwords, database credentials, or the `service_role` key. If the project is used by multiple people, each authenticated user sees only their own rows.

## Behavior notes

- Income belongs to the month of `pay_end_date`.
- Expenses belong to the month of `expense_date`.
- A paycheck stores a snapshot of the selected job's current hourly rate, so later rate changes do not rewrite history.
- Net pay is gross pay minus the actual deductions entered; no tax estimate is made.
- Available dashboard months are generated from saved records. The current month is shown even when empty.
- Date values are stored as ISO dates and displayed as localized `MM/DD/YYYY` dates by the browser.

## Files

- `index.html`: semantic app shell and auth screen
- `css/styles.css`: responsive visual system
- `js/app.js`: views, forms, charts, auth, and event handling
- `js/{supabase,jobs,income,expenses,summary}.js`: small data and calculation modules
- `supabase/schema.sql`: copy/paste-ready tables, indexes, constraints, trigger, and RLS
