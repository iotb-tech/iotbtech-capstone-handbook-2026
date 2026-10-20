# Reviewers — who reviews what

**Why this file exists instead of `CODEOWNERS`:** `CODEOWNERS` does not work on
private repositories in a GitHub Free organisation. The file is accepted, looks
correct, and never requests a reviewer. This file plus
`.github/workflows/assign-reviewers.yml` does the same job and actually works,
because Actions do run on private Free repos.

Keep this table and `.github/reviewers.json` in sync. The JSON is what the
workflow reads; this file is what humans read.

---

## The team

| Role | GitHub | Reviews |
|---|---|---|
| Tech Lead (week of ____) | @ | anything, and everything unowned |
| Frontend Dev | @ | frontend features, shared components |
| Frontend Dev | @ | frontend features |
| Backend Dev | @ | endpoints, services, schema |
| Backend Dev | @ | endpoints, services |
| Cloud / DevOps | @ | CI, hooks, Docker, deploy config |
| UI/UX Designer | @ | visual review on UI PRs (not approval of code) |
| QA | @ | release PRs into `main` |

## Ownership map

| Area | Paths | Reviewers | Why |
|---|---|---|---|
| **API contract** | `src/contract/**`, `docs/api.md` | **1 frontend + 1 backend** | It binds both repos — both sides must agree |
| **Database schema** | `prisma/**` | Backend owner + Tech Lead | A migration affects everyone's data |
| **Auth** | `src/middlewares/auth.middleware.ts`, `src/lib/auth.ts`, `src/app/api/auth/**` | Tech Lead + Backend | Security-critical — two pairs of eyes |
| **CI / tooling / deploy** | `.github/**`, `scripts/**`, `docker/**`, `Dockerfile` | Cloud/DevOps | They own the pipeline |
| **Shared UI + tokens** | `src/components/ui/**`, `tailwind.config.ts` | Frontend owner | Used by every screen |
| **Everything else** | — | Tech Lead (default) | Nothing merges unreviewed |

## Rules

1. **One approval minimum. Two** for anything touching auth, the schema, or the
   contract.
2. **You never approve your own PR.** If nobody else is around, it waits or the
   Tech Lead reviews it.
3. **Review within 12 hours** of being requested. Reviewing is a deliverable,
   not a favour — it is part of your grade.
4. **Do not approve a red build.** CI cannot be enforced here, so reviewers
   hold this line.
5. If the workflow requests the wrong person, fix `.github/reviewers.json` —
   do not just work around it.

## Updating this

Changing ownership is a PR, like anything else: update both this file and
`.github/reviewers.json`, and tell the team.

Reminder: **the Tech Lead rotates weekly.** Update the "week of" row at handover.
