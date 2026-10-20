# 05 — Communication & Handoffs

> **Read this if:** Everyone, at kickoff and every time you are blocked.  
> **Skip if:** Nobody — but the **Handoffs** checklists are the part you will reuse weekly.  
> **~9 min.** Long code and setup blocks are collapsed — expand what you need.

Projects of this size rarely fail on the code. They fail where two people have
to pass work between them — a designer to a frontend dev, a backend dev to a
frontend dev, a dev to whoever deploys it.

This document is the protocol for those boundaries, plus how to be blocked
productively.

---

## Channels

Your team has its own channels. **Write your real channel names into this
table at kickoff** (replace `<team>` with your project name) and pin the list
where everyone can find it — what matters is that each kind of conversation has
one agreed home, not what they are called.

| Channel | Used for | Not for |
|---|---|---|
| `<team>-general` | Standups, decisions, announcements | Long debugging threads |
| `<team>-dev` | Technical discussion, PR requests, debugging | Scope arguments |
| `<team>-design` | Design reviews, Figma links, visual feedback | Ticket assignment |
| `<cohort>-capstone` | Cross-team questions, mentor announcements | Team-internal chatter |
| Mentor escalation | Escalations only, in the format below | "Is this right?" before trying |

Three rules:

1. **No technical decisions in DMs.** If it changes how the project works, it
   goes in a channel where the team can find it later. A decision nobody can
   find gets re-litigated in week 3.
2. **Write the decision down where the work lives.** Chat scrolls away. Decisions
   go in the PR, the ticket, or the README.
3. **Thread your replies.** Five parallel conversations in one flat channel is
   how a blocker goes unnoticed for two days.

---

## Async standup

**Every other day minimum. Daily is better.** Posted in writing, by every
member — including PM, designer, and DevOps.

```
Yesterday: finished the create-listing form, PR #23 open for review
Today:     wiring POST /listings now the contract is merged
Blocked:   nothing
```

```
Yesterday: drew the booking detail screen, all 4 states
Today:     mobile breakpoints for browse + detail
Blocked:   need confirmation from @PM whether cancelled bookings show in history
```

Three lines. Two minutes. Not a status report to management — it is how the
person who can unblock you finds out that you are stuck.

It is also the **written record of who was working**, which feeds directly into
individual assessment ([11](../standards/definition-of-done.md)). A member with
no standup trail and no commits has nothing to point at.

If you did nothing yesterday, write that. "Yesterday: nothing, exams" is honest
and fine. A fabricated standup is not.

---

## Meeting cadence

Keep it light — you have very little time and meetings are the easiest thing to
waste it on.

| Meeting | When | Length | Who | Output |
|---|---|---|---|---|
| **Kickoff** | Once | 90 min | Everyone | Roles assigned, MVP agreed, board populated, repos created |
| **Sync** | 2× / week | 30 min **hard stop** | Everyone | Decisions made, blockers cleared |
| **Internal demo** | Weekly | 30 min | Everyone | Each person shows their slice *working*, on staging |
| **Design review** | As needed | 20 min | Designer + FE + PM | Approved or revised designs |
| **Checkpoint** | Per schedule | 30 min | Team + mentor | Mentor feedback |
| **Retro** | End of each week | 20 min | Everyone | 2 things to keep, 1 to change |

Rules: an agenda posted beforehand or the meeting does not happen; whoever calls
it takes notes and posts decisions afterwards; no meeting to share information
that could have been a message.

The **weekly internal demo** is the highest-value one. Showing your work running
every week is what stops a team from discovering on the last day that two slices
do not fit together.

---

## When you are blocked

**The 2-hour rule: never sit on a blocker for more than 2 hours.**

Stuck on the same error for two hours means you need a second pair of eyes, not
more determination. You have very few days — an afternoon lost in silence is
expensive.

What to do:

1. Add the `blocked` label to the ticket and write what is blocking it.
2. Post in `<team>-dev` using the question format below.
3. Tag the specific person who can unblock you — not `@everyone`.
4. **Switch to something else** while you wait. Being blocked on one ticket is
   not being blocked on the project.
5. Still blocked after a full day and the team cannot help -> escalate to the
   mentor.

The Tech Lead owns unblocking. If someone has been `blocked` for more than a
day, that is the lead's problem to solve.

---

## How to ask a question that gets answered

Four lines. Every time.

```
Trying to:   POST a new listing from the create form
Tried:       checked the payload in Network tab, matches the contract;
             restarted the dev server; re-ran prisma generate
Error:       400 { "code": "VALIDATION_ERROR", "field": "price" }
My guess:    price is going as a string "1500" and Zod expects a number
```

Why this works: it usually answers itself by the time you finish writing it, and
when it does not, whoever reads it can respond immediately instead of asking
three clarifying questions across two hours.

**Not acceptable:**

```
it's not working
anyone awake?
help pls
my code is giving error
```

Also: **paste the error text, not a photo of your screen.** Nobody can search a
screenshot. Fence it in a code block.

### Escalating to the mentor

Only after the team has genuinely tried. Use this:

```
Team:        LocalLink
Blocker:     Prisma migrate fails against the shared dev DB
Impact:      3 of 5 devs cannot run the API locally — 2 days lost if unresolved
Tried:       (1) prisma migrate reset locally — works on local DB, fails on hosted
             (2) checked DATABASE_URL, confirmed correct
             (3) asked in team channel, nobody has seen this error
Error:       <pasted error, in a code block>
Ask:         Is our connection string missing a pooling parameter, or should we
             move the dev DB somewhere else?
Decision needed by: Thursday
```

That gets a useful answer in one round trip. "Sir, our backend is not working"
gets a request for exactly the information above, a day later.

Mentor response expectation: **within 24 hours on working days**, West Africa
Time. Plan around that — do not leave an L4 decision until the night before a
checkpoint.

---

## Handoffs

Each handoff is a checklist both sides can point at. The receiving side is
entitled to refuse an incomplete handoff — that is not rudeness, it is how you
avoid building the wrong thing twice.

### Handoff 1 — UI/UX -> Frontend

The designer has not handed off until **all** of these exist:

- [ ] Figma link, with the **frame named after the screen** (`Browse Listings`,
      not `Frame 47`)
- [ ] Desktop **and** mobile layouts
- [ ] **Every state drawn**: default, loading, error, empty, success. The empty
      state is the one that always gets forgotten and always comes up in review
- [ ] Interactive elements marked: what is a button, what is a link, what is
      disabled
- [ ] Spacing and type matching the agreed tokens — no new one-off values
- [ ] Any copy (real text, not lorem ipsum)

Rules:

- **FE does not start a screen with no design.** Label the ticket `needs-design`
  and pick up something else.
- **The designer does not silently change a merged design.** Once it is built,
  a change is a new ticket, priced by the PM.
- The designer gives each UI PR a visual review before merge.

### Handoff 2 — Backend -> Frontend

Not handed off until:

- [ ] The **contract entry is merged** ([08](../building/api-contract.md))
- [ ] The endpoint is **deployed to staging**, not just working locally
- [ ] A sample request and response pasted into the ticket or PR
- [ ] Error codes listed — what does a 400 look like, what does a 403 look like
- [ ] Auth requirement stated: public, or requires a session?

```
GET /api/v1/listings?status=active&page=1 is live on staging.

200:
{ "data": [ { "id": "clz...", "title": "Room in Yaba", "price": 150000,
              "status": "active" } ],
  "meta": { "page": 1, "pageSize": 20, "total": 37 } }

401 if no session. 400 { "code": "VALIDATION_ERROR", "field": "page" }.
```

### Handoff 3 — Developer -> Cloud/DevOps

Before asking for a deploy:

- [ ] Every new env var **named**, with an example value and whether it is secret
- [ ] `.env.example` updated **in the same PR** as the code that needs it
- [ ] Build command confirmed working from a clean clone
- [ ] Migration command, if the schema changed
- [ ] Health endpoint path (`GET /health`)
- [ ] What should happen on failure — fail the deploy, or degrade?

"It works on my machine" is the start of this conversation, not the end of it.

### Handoff 4 — Frontend -> Backend (asking for an endpoint)

Do not just say "I need an endpoint for bookings." Bring:

- [ ] The screen and the user action that needs it
- [ ] The shape you need back, as JSON, with the fields you will actually render
- [ ] Filtering / sorting / pagination needs
- [ ] What should happen on error
- [ ] Whether it is on a p0 screen

Then it becomes a contract PR, not a two-day back-and-forth.

### Handoff 5 — PM -> Developer

A ticket is not handed off until it has the full format in
[rules/roles.md](roles.md#product-manager): user story,
acceptance criteria including error and empty cases, design link, contract link,
named owner, size, priority.

### Handoff 6 — Developer -> QA

- [ ] Deployed to **staging**, with the URL
- [ ] The acceptance criteria it should now satisfy
- [ ] Test credentials, if auth is needed
- [ ] Anything knowingly not finished

---

## One last thing

Most of this reduces to a single habit: **say what you are doing, where other
people can see it.** Teams that over-communicate finish. Teams where everyone
works quietly and hopes it fits together on the last weekend do not.
