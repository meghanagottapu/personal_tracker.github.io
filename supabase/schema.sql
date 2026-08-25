create extension if not exists pgcrypto;

create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0), hourly_rate numeric(12,2) not null check (hourly_rate > 0),
  active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.income (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  pay_start_date date not null, pay_end_date date not null, job_id uuid references public.jobs(id) on delete set null,
  hours numeric(10,2) not null check (hours > 0), hourly_rate numeric(12,2) not null check (hourly_rate > 0),
  gross_pay numeric(12,2) not null check (gross_pay >= 0), deductions numeric(12,2) not null default 0 check (deductions >= 0),
  net_pay numeric(12,2) not null, notes text, created_at timestamptz not null default now(),
  constraint income_dates_valid check (pay_end_date >= pay_start_date), constraint income_net_valid check (net_pay = gross_pay - deductions)
);
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  expense_date date not null, category text not null check (char_length(trim(category)) > 0), amount numeric(12,2) not null check (amount > 0),
  remarks text, created_at timestamptz not null default now()
);
create index if not exists jobs_user_id_idx on public.jobs(user_id);
create index if not exists income_user_end_date_idx on public.income(user_id, pay_end_date desc);
create index if not exists expenses_user_date_idx on public.expenses(user_id, expense_date desc);

alter table public.jobs enable row level security;
alter table public.income enable row level security;
alter table public.expenses enable row level security;

create policy "Users manage their jobs" on public.jobs for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users manage their income" on public.income for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users manage their expenses" on public.expenses for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- The frontend omits user_id deliberately; this trigger supplies the authenticated user safely.
create or replace function public.set_user_id() returns trigger language plpgsql security definer set search_path = public as $$
begin new.user_id := auth.uid(); return new; end; $$;
create trigger jobs_set_user_id before insert on public.jobs for each row execute function public.set_user_id();
create trigger income_set_user_id before insert on public.income for each row execute function public.set_user_id();
create trigger expenses_set_user_id before insert on public.expenses for each row execute function public.set_user_id();
