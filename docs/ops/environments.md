# 09 — Environments, Secrets & DevOps

> **Read this if:** you own deploys or environments.  
> **Skip if:** Nobody — **everyone** reads [Secrets policy](#secrets-policy). The rest is for Cloud/DevOps.  
> **~8 min.** Long code and setup blocks are collapsed — expand what you need.

Owned by the **Cloud/DevOps engineer**. Everyone else reads the
[Secrets policy](#secrets-policy) section — it applies to you and it is the one
mistake with consequences beyond your grade.

---

## Three environments

| | Local | Staging | Production |
|---|---|---|---|
| **Branch** | your feature branch | `staging` | `main` |
| **Frontend** | `localhost:3000` | Vercel preview/staging | Vercel production |
| **API** | `localhost:4000` | Railway/Render staging | Railway/Render production |
| **Database** | shared hosted **dev** DB | staging DB | production DB |
| **Who deploys** | you (`npm run dev`) | DevOps, automatically on merge | DevOps, on a release PR |
| **Data** | seeded, disposable | seeded, disposable | real demo data |
| **Who tests here** | you | QA | nobody — it is the demo |

**Staging is where QA tests and where the frontend integrates against the real
API.** It must exist by the end of week 1 — the whole team moves slower until
it does. This is the Cloud/DevOps engineer's first and most important
deliverable.

**Production is what you demo.** It is not a test environment. Nobody
experiments there.

---

## Week 1 DevOps checklist

Get these done before anyone needs them:

- [ ] Hosted **dev** Postgres provisioned, `DATABASE_URL` shared securely
- [ ] API deployed to **staging** with a working `/health`
- [ ] Frontend deployed to **staging** on Vercel, pointing at the staging API
- [ ] CI green on both repos (`ci-frontend.yml`, `ci-backend.yml`)
- [ ] `assign-reviewers.yml` working
- [ ] `.env.example` accurate in both repos
- [ ] Deploy + rollback steps written in the repo README
- [ ] Every dev confirmed able to run both apps locally from a clean clone

---

## Secrets policy

**This section applies to everyone.**

### The rules

1. **`.env` is never committed.** Confirm it is in `.gitignore` *before* your
   first commit.
2. **`.env.example` is always committed**, with every key present and a
   placeholder value — never a real one.
3. **Add a variable, update `.env.example` in the same PR.** A teammate pulling
   your branch should not have to guess why the app crashes.
4. **Never paste a secret into group chat.** Not "just this once". Chat history
   is searchable, screenshots get forwarded, and group members change.
5. **Never put a secret in a `NEXT_PUBLIC_` variable.** That prefix compiles the
   value into the browser bundle, where anyone can read it.
6. **One owner per credential.** The DevOps engineer holds production. Written
   down who holds what, so the team is not stuck when one person is unreachable.

### How to share a secret

| Use | Do not use |
|---|---|
| The hosting platform's env var UI (Vercel/Railway) — the real answer, nobody needs a copy | WhatsApp/Telegram group |
| GitHub Actions secrets, for CI | A committed file |
| A password manager shared vault | A screenshot |
| 1:1, for a dev who genuinely needs local DB access | A "temporary" pastebin that is never deleted |

### Which variables exist

Frontend (`<project>-frontend/.env.local`):

```bash
NEXT_PUBLIC_API_URL=http://localhost:4000/api/v1    # public: it's just a URL
NEXT_PUBLIC_USE_MOCKS=false                          # public: dev flag
AUTH_SECRET=                                         # SECRET — server only
AUTH_GOOGLE_ID=                                      # SECRET
AUTH_GOOGLE_SECRET=                                  # SECRET
NEXTAUTH_URL=http://localhost:3000
```

Backend (`<project>-backend/.env`):

```bash
NODE_ENV=development
PORT=4000
DATABASE_URL=                                        # SECRET — DB password inside
CORS_ORIGIN=http://localhost:3000
AUTH_SECRET=                                         # SECRET — must match the frontend
```

`AUTH_SECRET` must be **identical** on both sides for session verification, and
different per environment. Generate with:

```bash
openssl rand -base64 32
```

### If you commit a secret

Assume it is compromised the moment it is pushed. Order matters:

1. **Rotate it first.** New database password, new OAuth secret, new API key.
   Do this before anything else — scrubbing history while the live credential
   still works protects nothing.
2. **Tell the Tech Lead and the DevOps owner.** Immediately. This is not a
   telling-off; it is an incident and the team needs to know.
3. **Update the live value** in Vercel/Railway and in everyone's local `.env`.
4. **Remove it from the code**, add the file to `.gitignore`, add the key to
   `.env.example` with a placeholder.
5. **Then** deal with history. Deleting the file in a later commit does *not*
   remove it from git history. On a private repo with a rotated credential this
   is lower priority, but before you ever make the repo public:

```bash
# scrub a file from all history — coordinate with the whole team first,
# everyone must re-clone afterwards
pip install git-filter-repo
git filter-repo --invert-paths --path .env
```

**Do not hide it and hope.** A leaked `DATABASE_URL` means someone can read and
delete your project's data.

---

## Deploying the frontend (Vercel)

Vercel's Hobby tier deploys **private** GitHub repos — no upgrade needed.

1. vercel.com -> Add New Project -> import `iotb-tech/<project>-frontend`
   (authorise the `iotb-tech` org when prompted).
2. Framework: Next.js (auto-detected). Root directory: repo root.
3. Add env vars per environment:
   - **Production** <- `main`
   - **Preview** <- `staging` and every PR branch
4. Set `NEXT_PUBLIC_API_URL` to the **staging** API for Preview and the
   **production** API for Production. Mixing these up is the classic bug: the
   demo silently reads staging data.

Every PR gets a preview URL automatically. Put it in the PR description — it is
the easiest way for a designer or QA to review without cloning anything.

---

## Deploying the API (Railway / Render)

**Before Class 42, deploy straight from git.** You do not need Docker to have a
live API, and the frontend needs one in week 1. Docker is Class 42; it formalises
what you already have.

Railway:

1. New Project -> Deploy from GitHub -> `iotb-tech/<project>-backend`.
2. Add a **PostgreSQL** service -> it provides `DATABASE_URL` (reference it, do
   not copy-paste it).
3. Build: `npm install && npm run build`. Start: `npm run start`.
4. Set every other env var from `.env.example`.
5. Health check path: `/health`.
6. Two services (or two projects): staging from `staging`, production from
   `main`.

### Migrations on deploy

```json
{ "scripts": { "start": "prisma migrate deploy && node dist/server.js" } }
```

`migrate deploy` applies committed migrations without prompting. **Never**
`migrate dev` or `migrate reset` in a deploy — `reset` drops the database.

### After Class 42 — Docker

```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate && npm run build

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
EXPOSE 4000
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/server.js"]
```

Multi-stage keeps the image small. A `docker-compose.yml` with Postgres for
local development is a good optional extra — **LocalLink already has one**.

---

## CI

Two workflows per repo — see the [templates overview](../templates/README.md).

What they run: install -> typecheck -> lint -> build. The test step is present
but commented out with `# enable after Class 41`.

**Important and worth understanding:** CI cannot be a *required* check here.
Required status checks are part of branch protection, which does not work on
private repos on a Free org ([02, Step 8](repo-setup.md#step-8--read-this-before-you-touch-rules-in-settings)).
The workflow still runs on every PR and still shows a red X.

So the rule is held by people: **do not merge a red PR.** A reviewer who
approves a failing build has not reviewed it. This shows up in the audit — a
merge commit whose CI run failed is visible in the Actions history forever.

GitHub Actions on a Free org: 2,000 minutes/month across all private repos.
Plenty for this, but do not add a workflow that runs on every push to every
branch — PRs and the long-lived branches only.

---

## Monitoring and the demo

- `/health` returns 200 — check it the morning of the demo
- Free tiers **sleep when idle**. Railway/Render free services can cold-start in
  10–30 seconds. Hit every endpoint 10 minutes before you present.
- Know your rollback: `git revert` the release PR, or redeploy the previous tag
- Have a screen recording of the full working flow as a backup. The demo must be
  live, but if the venue's wifi dies you still have something to show.

### Demo-day runbook — write this before the day, not on it

```
Production FE:   https://...
Production API:  https://...
Health:          https://.../health
Demo account:    demo@... / <in the team vault>
Last deploy:     <tag>, <date>, deployed by @...
Rollback:        revert PR #__ , or redeploy tag v0.1.0
Known issues:    ...
```

---

## Going public after Demo Day

Allowed with mentor approval — and it re-enables real rulesets, which is a nice
bonus. Before you flip it:

1. **Scan the full history** for secrets, not just the current files:
   ```bash
   git log -p --all | grep -iE "(password|secret|api[_-]?key|postgres://|DATABASE_URL=)" | head -50
   ```
2. Rotate anything you find, then scrub history (above).
3. Confirm `.env` was never committed:
   ```bash
   git log --all --oneline -- .env    # must return nothing
   ```
4. Write a real README — it is now a portfolio piece someone will judge you by.
5. Then ask the mentor to approve the visibility change
   ([01](../rules/ground-rules.md#decision-authority-matrix)).
