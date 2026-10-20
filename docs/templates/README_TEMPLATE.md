# <PROJECT>

> One sentence: what this does and who for.

| | |
|---|---|
| **Live** | <production URL> |
| **Staging** | <staging URL> |
| **API** | <api URL> · contract: `docs/api.md` |
| **Companion repo** | [`<project>-backend`](https://github.com/iotb-tech/<project>-backend) |
| **Board** | <project board link> |

IOTBTECH 2026 Full-Stack Capstone.

---

## The problem

<!-- Who the user is, what they do today, and why that is bad. Write this
     before any feature list. Two or three paragraphs. -->

## What we learned from talking to users

<!-- Who you spoke to (how many, what kind of user) and what they actually
     said — including where it contradicted your original plan. This is 10% of
     the rubric and the biggest differentiator between teams. Be honest: "we
     assumed X, five landlords told us Y, so we built Y" is a strong answer. -->

## What it does

<!-- The core flow, in the user's words. Screenshots help. -->

---

## Scope

### Built (MVP)

- [ ]

### Stretch — built if time allowed

- [ ]

### Cut, and why

<!-- Naming what you cut and why is a strength, not an admission. -->

---

## Stack

| Layer | Tech |
|---|---|
| Framework | Next.js 15 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS <!-- + shadcn/ui --> |
| Forms | React Hook Form + Zod |
| Data | TanStack Query |
| Auth | Auth.js v5 |
| Hosting | Vercel |

<!-- Backend repo: Express + TypeScript + Prisma + PostgreSQL, on Railway. -->

## Architecture

<!-- Why two repos; how the contract joins them; one diagram or short
     paragraph. Be ready to defend this on Demo Day. -->

---

## Local setup

```bash
git clone https://github.com/iotb-tech/<repo>.git
cd <repo>

bash scripts/setup-hooks.sh     # required — see CONTRIBUTING.md
npm install
cp .env.example .env.local      # backend: .env
npm run dev
```

Then open http://localhost:3000.

**New to the repo? Read [CONTRIBUTING.md](CONTRIBUTING.md) before your first
push.**

### Environment variables

Every key is in `.env.example`. Ask the Cloud/DevOps owner for
shared values — never share secrets in group chat.

### Useful scripts

| Command | Does |
|---|---|
| `npm run dev` | Start the dev server |
| `npm run build` | Production build — run before opening a PR |
| `npm run lint` | Lint |
| `npx tsc --noEmit` | Typecheck |
<!-- backend: npm run prisma:migrate · npm run seed · npm run prisma:studio -->

---

## Team

| Name | Role | GitHub | Owned |
|---|---|---|---|
| | Tech Lead (rotates) | @ | |
| | Frontend | @ | |
| | Backend | @ | |
| | Product Manager | @ | |
| | UI/UX | @ | |
| | Cloud/DevOps | @ | |
| | QA | @ | |

<!-- If a role is unfilled, say who absorbed it. -->

## Deploy

| | |
|---|---|
| **Production** | merge `staging` -> `main`; auto-deploys. Tag the release. |
| **Staging** | merge `dev` -> `staging`; auto-deploys |
| **Rollback** | revert the release PR, or redeploy the previous tag |
| **Health** | `<api>/health` |

## Known issues

<!-- Be honest. A known, documented issue costs far less than one a mentor
     finds live on Demo Day. -->

---

## Handbook

Workflow, roles, and standards: the capstone handbook. Start with its README,
then `rules/ground-rules.md` and `rules/git-workflow.md`.
