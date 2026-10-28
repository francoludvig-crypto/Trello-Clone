-- Fluxo Kanban — banco de dados Supabase
-- Modelo inicial: um workspace JSONB por usuário autenticado.
-- Execute este script inteiro no Supabase Dashboard > SQL Editor.

create table if not exists public.fluxo_workspaces (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{"boards": [], "activeBoardId": null}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Não deixe o conteúdo acessível sem autenticação.
alter table public.fluxo_workspaces enable row level security;

-- Reaplica permissões explícitas para evitar acesso anônimo.
grant usage on schema public to authenticated;
revoke all on table public.fluxo_workspaces from anon, authenticated;
grant select, insert, update, delete on table public.fluxo_workspaces to authenticated;

-- Remove políticas com estes nomes se o script for executado novamente.
drop policy if exists "Fluxo: usuário lê seu workspace" on public.fluxo_workspaces;
drop policy if exists "Fluxo: usuário cria seu workspace" on public.fluxo_workspaces;
drop policy if exists "Fluxo: usuário atualiza seu workspace" on public.fluxo_workspaces;
drop policy if exists "Fluxo: usuário exclui seu workspace" on public.fluxo_workspaces;

create policy "Fluxo: usuário lê seu workspace"
on public.fluxo_workspaces
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Fluxo: usuário cria seu workspace"
on public.fluxo_workspaces
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Fluxo: usuário atualiza seu workspace"
on public.fluxo_workspaces
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Fluxo: usuário exclui seu workspace"
on public.fluxo_workspaces
for delete
to authenticated
using ((select auth.uid()) = user_id);

create index if not exists fluxo_workspaces_updated_at_idx
on public.fluxo_workspaces (updated_at desc);
