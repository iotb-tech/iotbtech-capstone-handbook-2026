# 01 — Ground Rules & Decision Authority

> **Read this if:** Everyone, before you create, rename, or change anything.  
> **Skip if:** Nobody. This is the shortest path to not derailing your team.  
> **~9 min.** Long code and setup blocks are collapsed — expand what you need.

The single biggest cause of chaos on a student project is someone making a
structural decision alone, in good faith, that the rest of the team then has to
unpick. Two teams have already done this: one built a monorepo, another created
a brand-new GitHub organisation when `iotb-tech` already existed.

Neither was laziness. Both were someone taking initiative without checking what
level the decision belonged to. This document fixes that by naming, for every
common decision, **who decides and who must be asked first**.

---

## The rule, in one sentence

**The further a decision reaches, the more people must agree to it before it
happens.** Changing a CSS class affects you. Changing the database schema
affects everyone. Creating an organisation affects the whole cohort.

Four levels:

| Level | Scope | Example |
|---|---|---|
| **L1 — Yourself** | Inside the file or branch you own | Rename a local variable, pick a loop style |
| **L2 — Your team** | Other people's work depends on it | Add a dependency, change a shared component, change the DB schema |
| **L3 — Both repos** | Crosses the frontend/backend boundary | Change the API contract, change an env var name, change auth flow |
| **L4 — Organisation** | Affects the cohort or costs money | Create a repo/org/team, change visibility, pick a hosting provider, change the stack |

L1 — just do it. L2 — post in the team channel and get a thumbs up. L3 — needs
one frontend and one backend approval, in writing, on a PR. L4 — **ask the
mentor first, always.**

---

## Decision Authority Matrix

"Decides" = has the final say. "Must consult" = must be asked *before* the
action, and can block it. "Inform after" = tell them, no permission needed.

| Decision | Decides | Must consult first | Inform after |
|---|---|---|---|
| Rename a local variable, refactor inside your own file | You | — | — |
| Styling choices inside a screen you own | You | UI/UX designer if it deviates from the design | — |
| **Add an npm dependency** | Tech Lead | The other devs in that repo | PM |
| **Remove / replace a dependency** | Tech Lead | Whole dev team | Mentor |
| Create a feature branch | You | — | — |
| **Merge into `dev`** | PR reviewer | 1 teammate approval (required) | — |
| **Merge into `staging`** | Tech Lead | QA / PM (is it tested?) | Team |
| **Merge into `main`** | Tech Lead | Whole team | Mentor |
| **Change the Prisma schema** | Backend Dev who owns it | Tech Lead + the FE owner of affected screens | Whole team |
| **Run a destructive migration (reset / drop)** | Tech Lead | Whole team — it wipes the shared dev DB | Mentor |
| **Change the API contract** | — | **1 FE + 1 BE approval on the contract PR** | Whole team, PM |
| **Add or rename an environment variable** | Dev who needs it | Cloud/DevOps owner | Whole team (update `.env.example` in the same PR) |
| **Deploy to staging** | Cloud/DevOps owner | — | Team |
| **Deploy to production (`main`)** | Cloud/DevOps owner | Tech Lead + PM | Mentor |
| **Change a design that is already merged** | UI/UX Designer | FE dev who built it + PM (it's rework) | Team |
| **Change MVP scope — add or drop a feature** | PM | Tech Lead | **Mentor** |
| **Create a repository** | Tech Lead (devs create their own repos) | Team, on naming | **Mentor** |
| **Rename / archive / delete a repository** | — | — | **Never without mentor** |
| **Change repo visibility (private <-> public)** | — | — | **Never without mentor** |
| **Add or remove an org member or collaborator** | — | — | **Never without mentor** |
| **Create a GitHub organisation** | — | — | **Never. See Ruling 2.** |
| **Change the tech stack** (swap Express, swap Postgres, swap Next.js) | — | — | **Never without mentor** |
| **Pick a hosting provider / anything that costs money** | — | — | **Never without mentor** |
| **Make the repo a monorepo** | — | — | **Never. See Ruling 1.** |

**Anything not on this list:** if you cannot tell which level it is, treat it as
one level higher than your instinct says and ask. Asking costs five minutes.
Unpicking costs a week.

---

## Ruling 1 — No monorepos

**Two repositories per team.** `<project>-frontend` and `<project>-backend`.

This is not a style preference, and it is not us being arbitrary. Here is the
actual reasoning, because you should be able to defend it on Demo Day:

1. **They deploy to different places.** The frontend goes to Vercel. The API
   goes to Railway/Render with a managed Postgres. Two deploy targets, two build
   commands, two sets of environment variables.
2. **Class 42 containerises the backend alone.** You will write a Dockerfile for
   the API. Docker expects a build context, and a monorepo makes that lesson
   harder than it needs to be.
3. **Different CI.** The frontend pipeline builds a Next.js app. The backend
   pipeline runs migrations and tests against a database. Separate workflows are
   simpler and faster.
4. **Different secrets.** A frontend never needs `DATABASE_URL`. Keeping both in
   one repo makes it far too easy to leak a database credential into a client
   bundle.
5. **It is already the convention here.** All five teams' repos were created as
   `<project>-frontend` / `<project>-backend`. The org has 20+ repos following
   it.

Monorepos are a legitimate professional pattern — with tooling (Turborepo, Nx,
pnpm workspaces) you have not been taught yet, and which would consume capstone
time you do not have. Learn them after the cohort.

**If you have already built a monorepo:** the split procedure is in
[fix-now.md](../fix-now.md).

---

## Ruling 2 — No new GitHub organisations

**All capstone work lives in `github.com/iotb-tech`.** One team has already
created a separate organisation. It has to come back.

Why this matters:

- Mentors grade from the `iotb-tech` org. Work outside it is invisible, which
  means it is ungraded.
- Your commit history is your evidence of contribution. Split across two orgs,
  it cannot be audited as one record.
- Org-level teams, permissions, and settings are already configured here.
- `iotb-tech` is the permanent record of the cohort. A student-created org
  disappears the moment whoever made it loses interest.

**Also not allowed as the primary home:** a personal account repo, a fork used
as the main repo, or a Drive folder of zipped code.

### If your team created its own organisation

Do this before the remediation deadline:

1. In the rogue org: **Settings -> Danger Zone -> Transfer ownership**, transfer
   each repo to `iotb-tech`. (You need admin on the source org, and the mentor
   must accept it into `iotb-tech` — message them first so they are ready.)
2. If the repos hold nothing worth keeping, do not transfer — just create fresh
   repos per [ops/repo-setup.md](../ops/repo-setup.md) and push your local code.
3. Rename the transferred repos to `<project>-frontend` / `<project>-backend` if
   they do not match.
4. Confirm with the mentor that both repos are visible in `iotb-tech`.
5. **Then delete the organisation** so nobody keeps pushing to it by accident.

---

## Ruling 3 — The developers own the repository

The mentor does not create your repo, add your branches, or configure your
settings. **You do**, following [ops/repo-setup.md](../ops/repo-setup.md).

This is deliberate. Repo setup is a skill being assessed. On a real team, "the
senior set it up for us" is not available, and the person who can bootstrap a
project correctly is the person who gets trusted with the next one.

What the mentor does: creates org teams if you need one, accepts repo transfers,
approves L4 decisions, and audits.

---

## Ruling 4 — The stack is fixed

| Layer | What you use | Not negotiable because |
|---|---|---|
| Frontend | Next.js 15 (App Router) + TypeScript + Tailwind | Classes 22–30 |
| Forms | React Hook Form + Zod | Class 27 |
| Data fetching | TanStack Query | Class 29 |
| Backend | Express + TypeScript | Classes 32–33 |
| Database | PostgreSQL + Prisma | Classes 34–36 |
| Auth | Auth.js v5 | Class 37 |

shadcn/ui is allowed and encouraged. A component library on top of Tailwind is
fine. Changing a **layer** is not.

**Specifically: do not use Supabase as your backend.** That was the shortcut for
the *frontend* capstone, where there was no backend phase yet. In this capstone,
building the API *is* the thing being assessed — replacing it with Supabase's
generated API removes most of what you are being marked on. Supabase is
acceptable purely as a **hosted Postgres instance** that Prisma connects to.

---

## Ruling 5 — Ask properly, then act

Three rules that save everyone time:

1. **Do not sit on a blocker for more than 2 hours.** Post it. Being stuck
   silently for a day is a process failure, not a personal one.
2. **Ask in the channel, not in DMs.** A DM answer helps one person. The same
   answer in the channel helps four and becomes a record.
3. **Ask a complete question.** What you are trying to do, what you tried, the
   exact error, what you think is wrong. The format and worked examples are in
   [rules/communication.md](communication.md#how-to-ask-a-question-that-gets-answered).

Escalate to the mentor **after** the team has tried — and when you do, bring
what you tried.
