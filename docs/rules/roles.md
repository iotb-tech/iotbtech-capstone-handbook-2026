# 04 — Roles & RACI

> **Read this if:** Everyone, at kickoff — know your job and everyone else's.  
> **Skip if:** Nobody. Role confusion is the most common way a cross-functional team stalls.  
> **~12 min.** Long code and setup blocks are collapsed — expand what you need.

Your team is **cross-functional**: developers plus a PM, a UI/UX designer, and a
Cloud/DevOps engineer. That is how real product teams are built, and it is why
this capstone is worth more than a solo project — but it only works if everyone
knows the edges of their own job.

Most friction on a cross-functional team is not laziness. It is two people
believing the same task belongs to the other one, for four days.

---

## The roles at a glance

| Role | One-line job |
|---|---|
| **Tech Lead** | Keeps the team unblocked and the branches clean — **rotates weekly** |
| **Frontend Dev** | Builds screens against the contract |
| **Backend Dev** | Builds the API, schema, and auth |
| **Product Manager** | Owns scope, the board, and the "why" |
| **UI/UX Designer** | Owns the designs and the design system |
| **Cloud / DevOps** | Owns environments, CI, secrets, deploys |
| **QA** | Owns "does it actually work" before `main` |
| **Mentor** | L4 decisions, escalations, assessment |

**How many people hold each role is up to your team.** One person may wear two
hats; two people may share one. What matters is that every role has a **named
owner** written in your README, and that the minimum bar below is met — see
[If a role is unfilled](#if-a-role-is-unfilled).

---

## Tech Lead (rotates weekly)

**The lead rotates every week.** The Week 1 lead is not the Week 2 lead. This is
deliberate: it stops one person becoming the permanent decision-maker *or* the
permanent workhorse, and gives everyone real leadership practice.

Pick the first lead in the first 15 minutes of kickoff. Self-nominate; a show of
hands settles a tie. Hand over with a 10-minute call and a written note of
what's in flight.

| | |
|---|---|
| **Owns** | Branch hygiene, promotion PRs (`dev`->`staging`->`main`), unblocking people, breaking technical ties |
| **Delivers** | A current board, a clean `dev`, release PRs with a changelog, the standup summary |
| **Does NOT** | Write most of the code. If the lead is writing everything "because it's faster", that is a task-assignment failure — fix it with vertical slices below |
| **Hands off** | Escalations to the mentor; scope questions to the PM; deploys to Cloud/DevOps |
| **Reach them** | Team channel, tagged. They are the single point of contact for mentor status questions |

The lead still owns a feature, just a smaller one.

---

## Frontend Developer

| | |
|---|---|
| **Owns** | Screens, components, client state, forms, data fetching, accessibility, responsiveness |
| **Delivers** | Working screens wired to the API, with loading / error / **empty** states; typed props; Zod-validated forms; a PR with screenshots |
| **Does NOT** | Invent API shapes (that's the contract), change the Prisma schema, redesign a screen without the designer, deploy to production |
| **Needs before starting a screen** | A design from UI/UX **and** a merged contract entry. Missing either -> label the ticket `needs-design` / `needs-contract` and say so in standup |
| **Hands off** | To QA with a staging URL + what to test; to the designer for a visual review before merge |
| **Never blocked by** | The backend. Build against the mock — [06](../building/frontend.md#working-before-the-backend-exists) |

---

## Backend Developer

| | |
|---|---|
| **Owns** | Prisma schema, migrations, endpoints, validation, auth, error handling, logging, seed data |
| **Delivers** | Endpoints that match the contract exactly, deployed to staging, with a sample request/response and the error codes documented |
| **Does NOT** | Change the contract unilaterally, change the schema without telling the FE owner of affected screens, run destructive migrations on the shared dev DB without team agreement, build their own auth before Class 38 |
| **Hands off** | To FE: "endpoint X is live on staging, here is a sample response". To DevOps: env var names + migration command |
| **Golden rule** | The contract changes **before** your code does |

---

## Product Manager

The PM is not a note-taker. The PM is why the team builds the right thing.

| | |
|---|---|
| **Owns** | Problem definition, user validation, MVP scope, the backlog, the board, the demo narrative |
| **Delivers** | Validated problem statement (talked to 3+ real users, written up); user stories with acceptance criteria; a prioritised board; the standup record; the Demo Day story |
| **Does NOT** | Assign technical approaches, estimate for the devs, promise features to the mentor without the Tech Lead, add scope mid-week without escalating |
| **Hands off** | Tickets to devs in the format below; the demo narrative to whoever presents |
| **Hardest and most valuable job** | Saying "that's a stretch goal, not MVP" and making it stick |

**A ticket from the PM is not done until it has all of:**

```
Title:        verb + object  (e.g. "Landlord can mark rent as received")
User story:   As a <role>, I want <capability>, so that <benefit>
Acceptance criteria:
  - [ ] Given ... when ... then ...
  - [ ] Error case: ...
  - [ ] Empty state: ...
Design:       <Figma frame link>   (or "not needed")
Contract:     <contract entry / PR link>  (or "not needed")
Owner:        @username
Size:         S / M / L
Priority:     p0 / p1 / p2
```

A ticket without acceptance criteria is a conversation, not a ticket. Devs are
entitled to push it back.

---

## UI/UX Designer

| | |
|---|---|
| **Owns** | User flows, wireframes, the design system (tokens, spacing, type scale), all screen states, visual review |
| **Delivers** | A Figma file with **named frames per screen**, every state drawn (default, loading, error, empty, success), mobile + desktop, and exported tokens the devs can paste into `tailwind.config.ts` |
| **Does NOT** | Change a design that is already built without raising a ticket — that is rework and the PM has to price it; design screens nobody asked for; block a dev for days on a polish detail |
| **Hands off** | Via the [design handoff checklist](communication.md#handoff-1--uiux---frontend) |
| **Reviews** | Every UI PR, visually. Approve or request changes with a screenshot annotation |

**Design in priority order**, not screen-by-screen prettiness: auth -> the one
core flow that proves the product -> list/detail -> everything else. If the devs
are idle waiting on designs, the design order is wrong.

---

## Cloud / DevOps Engineer

The role that gets forgotten until the night before the demo. Do not be that
team.

| | |
|---|---|
| **Owns** | Environments (local/staging/production), CI workflows, secret custody, deploys, the hosted dev database, rollback, uptime on demo day |
| **Delivers** | A working staging URL in week 1; green CI on both repos; `.env.example` always accurate; documented deploy + rollback steps; a health endpoint that is monitored |
| **Does NOT** | Write feature code (you'll be the bottleneck), hold secrets only in your own head, deploy to production without the Tech Lead + PM, paste secrets into group chat |
| **Needs from devs** | Env var names, build command, migration command, health endpoint path — [handoff 3](communication.md#handoff-3--developer---clouddevops) |
| **Week 1 priority** | Hosted Postgres + staging API URL. The whole team is slower until these exist |

Good first tasks that are genuinely yours: the `assign-reviewers.yml` workflow,
both CI workflows, the shared dev database, and the staging deploy.

---

## QA

If nobody is assigned this role, the **PM** holds it, and the bar below still applies.

| | |
|---|---|
| **Owns** | Testing on staging before anything reaches `main`; the test checklist; filing reproducible bugs |
| **Delivers** | A per-feature test pass against the ticket's acceptance criteria; bug reports with steps/expected/actual/screenshot; written sign-off in the `staging`->`main` PR |
| **Does NOT** | Approve a release they did not test; fix the bugs themselves (file them) |
| **Tests on** | Staging, not a dev's laptop. Mobile viewport included |

A bug report without reproduction steps gets closed. Format is in the issue
template.

---

## Mentor

| | |
|---|---|
| **Owns** | L4 approvals, org/team administration, repo transfers, assessment |
| **Delivers** | Decisions on escalations, unblocking what the team genuinely cannot, audits, grades |
| **Does NOT** | Set up your repo, write your tickets, chase your standups, debug code you have not tried to debug yourself |
| **Reach them** | After the team has tried, using the [escalation template](communication.md#escalating-to-the-mentor). Expect a response within 24h on working days |

---

## RACI

**R**esponsible (does it) · **A**ccountable (answers for it, one person) ·
**C**onsulted (asked first) · **I**nformed (told after)

| Workstream | Tech Lead | FE Dev | BE Dev | PM | UI/UX | DevOps | QA | Mentor |
|---|---|---|---|---|---|---|---|---|
| Problem validation | C | C | C | **A/R** | C | I | I | C |
| MVP scope | C | I | I | **A/R** | C | I | I | **C** |
| User stories & board | C | C | C | **A/R** | C | I | C | I |
| Design system & screens | I | C | I | C | **A/R** | I | I | I |
| Database schema | C | C | **A/R** | I | I | C | I | I |
| API contract | **A** | **R** | **R** | C | I | I | C | I |
| Frontend build | C | **A/R** | I | I | C | I | C | I |
| Backend build | C | I | **A/R** | I | I | C | C | I |
| Code review | **A** | R | R | I | C (visual) | C (CI) | I | I |
| Environments & secrets | C | I | C | I | I | **A/R** | I | I |
| CI pipelines | C | C | C | I | I | **A/R** | I | I |
| Deploy to staging | I | I | I | I | I | **A/R** | C | I |
| Deploy to production | **C** | I | I | **C** | I | **A/R** | C | I |
| QA & release sign-off | C | C | C | C | I | C | **A/R** | I |
| Demo Day presentation | R | R | R | **A/R** | R | R | R | I |
| Individual progression | I | I | I | I | I | I | I | **A/R** |

Two things to notice:

- **The API contract has an A with two Rs.** It is the one artifact FE and BE own
  jointly, and it is why contract PRs need an approval from each side.
- **Demo Day is R for everyone.** Every member presents the part they own.

---

## If a role is unfilled

Small teams will not have all seven. A missing role must never become a missing
deliverable, so:

| Missing | Who absorbs it | Minimum bar that still must be met |
|---|---|---|
| PM | Tech Lead | Written problem statement, a board with acceptance criteria, standups happening |
| UI/UX | The FE devs, together | Agreed tokens in `tailwind.config.ts`, one wireframe per screen (paper or Figma), all states defined before build |
| Cloud/DevOps | Tech Lead | Hosted dev DB, staging URL, CI green, `.env.example` current, documented deploy |
| QA | PM, else Tech Lead | A written test pass against acceptance criteria before every `staging`->`main` |

Write down who is absorbing what at kickoff, in the README. "We assumed someone
was doing it" is not a defence on Demo Day.

---

## How work is split: vertical slices, not layers

**Wrong** — split by layer:

> One person does all the UI. Another does all the Prisma queries. A third does
> all the forms.

Everyone blocks on everyone, one person touches all the hard logic, and the rest
style buttons. It also makes individual assessment impossible.

**Right** — split by user story, end to end:

| Owner | Slice | Touches |
|---|---|---|
| Dev 1 | Sign up / sign in / profile | Auth.js config, protected routes, profile form + endpoint |
| Dev 2 | Create a listing | Form + Zod, `POST /listings`, `listings` table, validation |
| Dev 3 | Browse / search / filter | List UI, TanStack Query, `GET /listings` with filters, empty state |
| Dev 4 | Listing detail + edit + delete | Detail page, `PATCH`/`DELETE`, ownership checks |

**This is a shape, not a headcount.** One slice per dev, however many devs you
have — with two devs each takes two slices; with five, split the slices finer.
The point is that each person owns a slice *end to end*, not that there are four
of them.

Everyone touches the full stack at least once. Nobody is "just the CSS person."
Every person has something concrete to defend in their Demo Day question.

**The designer and the DevOps engineer are shared services, not a layer to throw
work over.** The designer supports all four slices; DevOps makes all four
deployable. They are not the people a dev hands an unfinished slice to.

> Note for teams where the same person is a dev *and* the designer or DevOps
> owner: separate the two hats explicitly in standup ("as DevOps I did X; as a
> dev I did Y"). It keeps your contribution legible at assessment time.
