# 10 — Build Order & Class Gating

> **Read this if:** you are unsure whether you are allowed to build something yet.  
> **Skip if:** Nobody. This is the doc that stops you wasting days.  
> **~9 min.** Long code and setup blocks are collapsed — expand what you need.

The capstone started while backend classes are still running. You are at
**Class 37 (Auth.js v5)**; Classes 38–45 have not happened yet.

That is intentional, not a mistake. This document says exactly what you can
build today, what to leave alone, and in what order — so nobody sits idle
waiting for a class, and nobody wastes three days building something badly that
Class 38 would have taught them properly.

---

## What you can build right now

Everything through Class 37 is yours. That is far more than most teams realise.

| Area | **Build now** (Classes 1–37) | **Wait for** |
|---|---|---|
| **Frontend** | All screens, routing, layouts, shared components, design tokens, RHF + Zod forms, TanStack Query against mocks, Context, Vercel deploy | — nothing. The frontend is fully unblocked. |
| **Backend core** | Schema design, Prisma models + migrations, full CRUD endpoints, controllers/services layering, Zod validation, global error handler, Winston logging, seed script | — |
| **Auth** | Auth.js v5: Google OAuth, session, protected routes/middleware (Class 37) | Manual JWT, bcrypt password hashing, refresh-token rotation -> **Class 38** |
| **Security** | `.env` hygiene, basic CORS config, helmet, ownership checks on mutations | Rate limiting, injection-hardening pass, full security review -> **Class 39** |
| **Mutations** | Route handlers + the typed API client | Refactor to Server Actions -> **Class 40** |
| **Testing** | Postman/Thunder collection, a written manual test pass | Vitest unit tests, Playwright E2E -> **Class 41** |
| **Deployment** | Vercel (frontend), git-deploy the API to Railway/Render, hosted Postgres | Dockerfile + containerised deploy -> **Class 42** |
| **Realtime** | — | WebSockets / Socket.io -> **Class 43**. **Stretch only. Never MVP.** |
| **Caching / jobs** | — | Redis, BullMQ -> **Class 44**. **Stretch only. Never MVP.** |

### The rule for anything in the right-hand column

**Build the seam now, fill it in after the class.**

Auth is the clearest example. You need protected endpoints today, but manual JWT
is Class 38. So:

```ts
// today — every protected route already uses this
export const requireAuth: RequestHandler = (req, _res, next) => {
  const userId = getUserIdFromSession(req);   // Auth.js session, Class 37
  if (!userId) return next(ApiError.unauthorized());
  req.user = { id: userId };
  next();
};
```

Every protected route gets `requireAuth` from day one. When Class 38 lands you
change the body of **one function** and the whole API is upgraded. Meanwhile
ownership checks, 401s, and 403s all work correctly right now.

Same pattern for testing (write testable services now, add the test files at 41)
and deployment (deploy from git now, add the Dockerfile at 42).

### Things teams get wrong here

- **Do not hand-roll auth before Class 38.** Every cohort has a team that
  invents its own token scheme in week 1, builds something insecure, and
  rewrites it after Class 38 anyway. Use Auth.js, which you have been taught.
- **Do not put WebSockets or Redis in your MVP.** They are Classes 43–44 and may
  land after your feature freeze. A realtime feature that half-works costs you
  more marks than not having one. Stretch goals are **bonus only** — you are
  never marked down for a missing stretch goal when the MVP is solid.
- **Do not wait for Class 40 to build mutations.** Route handlers + the API
  client work fine. Server Actions are a refactor, not a prerequisite.
- **Do not skip deploying because Docker is Class 42.** Git-deploy now. An API
  only on localhost blocks your whole frontend.

---

## Build order

Follow this sequence. Each phase unblocks the next, and the early phases are
the ones teams skip and regret.

### Phase 0 — Set up (days 1–2)

Nothing else starts until this is done.

- Roles assigned and written in the README ([04](../rules/roles.md))
- Both repos created and configured ([02](../ops/repo-setup.md))
- **Hook installed by every developer** on every clone
- Hosted dev Postgres provisioned; everyone can connect
- Board created, columns set, labels added
- Standup channel live; first standup posted

### Phase 1 — Decide what you are building (days 2–4)

PM leads. **Do not skip this to start coding** — it is 10% of the rubric and the
single biggest differentiator between teams at Demo Day.

- Problem statement written: who the user is, what they do today, why it is bad
- **Talk to at least 3 real potential users.** Write down what they actually
  said, including where it contradicted your plan
- MVP defined as 4–6 user stories, in priority order. Everything else is a
  stretch list
- MVP, stretch, and explicitly-cut lists written into the README

A team that can say "we thought X, we asked five landlords, they actually cared
about Y, so we built Y" presents far better than a team with a longer feature
list.

### Phase 2 — Design the data and the interface (days 4–6)

Runs in parallel. This is the phase that makes the rest go fast.

| Who | Does |
|---|---|
| Backend | Prisma schema for the whole MVP — all models, relations, enums. Migrate. Seed. |
| FE + BE together | Contract entries for every MVP endpoint ([08](api-contract.md)) |
| UI/UX | Tokens agreed and in `tailwind.config.ts`; wireframes for auth + the core flow, all states |
| Frontend | Shared components: Button, Input, Card, Skeleton, EmptyState, Toast, Navbar |
| DevOps | Staging API + staging frontend live. CI green. |

Design the **whole** schema now, even for features you build in week 2. Adding a
column later is easy; discovering your relations are wrong in week 2 is not.

### Phase 3 — Vertical slices (days 6–12) — the bulk of the work

Each dev takes a complete user story end to end and ships it: contract ->
endpoint -> screen -> wired -> deployed to staging.

Order your slices so **auth lands first** (everything else sits behind it), then
the single flow that proves the product, then the rest.

Per slice, in order:

1. Contract entry merged
2. Endpoint built, tested with Postman, deployed to staging
3. Screen built against the mock
4. Mock swapped for the real endpoint
5. PR reviewed, merged to `dev`
6. Demoed at the weekly internal demo

**Integrate continuously.** Merge to `dev` at least every two days. A team that
merges everything in the last three days discovers all its integration bugs with
no time left — this is the most reliable way to fail this capstone.

### Phase 4 — Integration and hardening (days 12–15)

- Every slice working together on **staging**, not just individually
- QA pass against every acceptance criterion
- Class 39 security pass once taught: rate limiting, CORS tightened, no leaked
  internal errors, ownership checks audited on every mutation
- Error and empty states reviewed on every screen
- Mobile pass at 375px
- Lighthouse run; obvious reds fixed
- `.env.example` accurate; README written

### Phase 5 — Freeze, polish, rehearse (final days)

- **Feature freeze.** No new features. Bugs and polish only.
- Deploy to production from `main`, tagged
- Seed production with presentable demo data
- Slide deck built
- **Rehearse the live demo end to end at least twice**, on the production URL,
  on the actual laptop and network you will present with
- Demo runbook written ([09](../ops/environments.md#demo-day-runbook--write-this-before-the-day-not-on-it))
- Individual contribution write-ups submitted

---

## Milestones

**Dates come from your project's own timeline — not from this handbook.** Follow
the schedule your programme gives you, and pin it in your team channel at
kickoff so everyone is working to the same dates.

What this handbook fixes is the **order**, not the calendar. Whatever your dates
are, hit these in this sequence:

| | Milestone | Done when |
|---|---|---|
| **Setup** | Repos configured | Both repos private and scaffolded, hooks installed by everyone, board live, staging up |
| **Checkpoint 1** | Problem validated | Talked to 3+ real users, MVP written down, board populated with named owners |
| **Checkpoint 2** | MVP works end to end | Every core user story working on staging — rough UI is fine, logic first |
| **Checkpoint 3** | Hardened and polished | QA pass done, security pass done, responsive, error and empty states everywhere |
| **Freeze** | Ready to present | Deployed to production and tagged, deck built, demo rehearsed twice |
| **Demo Day** | — | Live presentation + individual Q&A |

The phase-by-phase detail for each of these is in the
[Build order](#build-order) section above.

Checkpoints are not separate grades. They exist so a stalled project is caught
early by a mentor watching the board — not on Demo Day.

---

## If you are behind

You will be, at some point. Handle it like a professional:

1. **Cut scope, do not cut quality.** Four polished user stories beat eight
   half-working ones. The rubric rewards MVP completeness, not feature count.
2. **The PM makes the cut, the mentor is informed.** Do not quietly drop a
   feature and hope nobody notices on Demo Day.
3. **Write down what you cut and why**, in the README and on a slide. "We cut
   in-app messaging after Checkpoint 2 because the booking flow needed the time,
   and messaging without notifications tested badly" is a *strong* answer. It
   shows judgement.
4. **Never cut:** auth, the core flow, error handling, deployment. Those are what
   makes it a real application.
