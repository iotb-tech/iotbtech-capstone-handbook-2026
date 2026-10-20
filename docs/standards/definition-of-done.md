# 11 — Definition of Done, Rubric & Demo Day

> **Read this if:** Before you call anything done, and before Demo Day.  
> **Skip if:** Nobody. This is what you are graded against.  
> **~9 min.** Long code and setup blocks are collapsed — expand what you need.

"Done" has a definition. If you cannot tick the list, the ticket is not done,
and moving it to `Done` on the board anyway is the fastest way to lose a team's
trust.

---

## Definition of Done — a ticket

- [ ] Every acceptance criterion in the ticket is met
- [ ] Code is on `dev` via an **approved** PR
- [ ] CI green
- [ ] Types are real — no `any` added
- [ ] Loading, error, and empty states handled (UI) / all error paths return the
      contract's error shape (API)
- [ ] Tested by the author with real input, and the evidence is in the PR
      (screenshot for UI, request/response for API)
- [ ] `.env.example` updated if a variable was added
- [ ] Deployed to **staging**
- [ ] No secret, no `console.log`, no commented-out dead code
- [ ] Reviewed by a teammate who is not the author

## Definition of Done — a feature (a whole vertical slice)

- [ ] Contract entry merged and marked `deployed`
- [ ] Endpoint live on staging, matching the contract exactly
- [ ] Screen live on staging, wired to the real endpoint (mock deleted)
- [ ] Permission/ownership enforced — another user cannot touch your data
- [ ] Works at 375px
- [ ] QA has tested it against the acceptance criteria and said so in writing
- [ ] Demoed at a weekly internal demo

## Definition of Done — the project

- [ ] All MVP user stories work end to end in **production**
- [ ] Auth works: sign up, sign in, sign out, protected routes
- [ ] No console errors on any screen
- [ ] Production seeded with presentable demo data
- [ ] README complete (template in [templates/README_TEMPLATE.md](../templates/README_TEMPLATE.md))
- [ ] `.env.example` accurate in both repos
- [ ] A release tagged on `main`
- [ ] Deploy + rollback documented
- [ ] Lighthouse run, obvious issues fixed
- [ ] Demo rehearsed end to end at least twice on the production URL

---

## Rubric — 100 points per team

| # | Category | Pts | What is assessed |
|---|---|---|---|
| 1 | **Problem & validation** | 10 | Real problem, talked to 3+ actual users, findings written up honestly, MVP reflects what you learned — including where it contradicted your original plan |
| 2 | **MVP functionality** | 20 | Every core user story works end to end in production and genuinely removes the pain named in the problem statement |
| 3 | **API & data design** | 15 | Sensible schema and relations, correct normalisation, indexes, a contract that is actually honoured, correct status codes, pagination, consistent error envelope |
| 4 | **Backend engineering** | 15 | Route/controller/service layering respected, Zod validation at the boundary, global error handling, logging, ownership checks on every mutation, no leaked internal errors |
| 5 | **Frontend engineering** | 15 | Real TypeScript, component structure, TanStack Query used properly (keys, invalidation, loading/error states), RHF + Zod on every form, responsive, accessible basics |
| 6 | **Collaboration & process** | 15 | PRs with real reviews, commit history distributed across named members, board used, standups kept, contract respected, roles actually functioning |
| 7 | **DevOps & deployment** | 10 | Live on Vercel + a hosted API, staging **and** production, CI green, no secrets in git, documented deploy and rollback |

Note that **collaboration and process is worth 15** — as much as the frontend or
the backend. This is deliberate. A team that ships a working app with one person
committing everything scores badly here, and should.

### Automatic deductions

| Issue | Cost |
|---|---|
| A secret committed to git and not rotated | −10 |
| Direct commits to `main` outside PRs | −5 to −10 depending on how systemic |
| One person authored most commits | −10 on collaboration |
| Monorepo, or repos outside `iotb-tech`, after the remediation deadline | −10 |
| No deployment — localhost only | −10 |
| `any` used widely to silence TypeScript | −5 |
| No error or empty states anywhere | −5 |

---

## Individual progression

The rubric scores the **team**. Whether *you* progress is the team score
adjusted by your own evidence. A strong team does not carry a member with
nothing to show, and someone who carried a weak team is not punished for it.

Six checks, which together are very hard to fake:

1. **Commit history** — your own commits, over the whole period, not one dump at
   the end
2. **Board ownership** — tickets assigned to you, moved by you, closed by you
3. **Standup trail** — a written record of what you said you were doing, and
   whether it matched what shipped
4. **PRs authored and PRs reviewed** — reviewing is counted. A member who never
   reviewed anyone's code did not fully participate
5. **Contribution write-up** — 3–5 lines: what you personally built, and the
   hardest problem you solved
6. **Demo Day defence** — a direct question about the part you claim to own

### Evidence for non-coding roles

Commit count is the wrong measure for a PM, designer, or DevOps engineer. Their
evidence is their artifacts:

| Role | What counts as evidence |
|---|---|
| **PM** | Written problem statement + validation notes, the board's history, tickets with real acceptance criteria, standup record, the demo narrative |
| **UI/UX** | Figma file with named frames and all states, the agreed tokens, visual reviews left on UI PRs |
| **Cloud/DevOps** | CI workflows, staging + production environments, the deploy/rollback doc, `.env.example` accuracy, commits to `.github/` and `scripts/` |
| **QA** | Test passes written up, bug reports with reproduction steps, release sign-offs in `staging`->`main` PRs |

All of these live in the repo or the board, which is the point — do your work
where it can be seen.

### Peer evaluation

Private, mentor-only, one per person.

```
Your name: __________        Team: __________

Rate each teammate 1 (never) – 5 (always):

Teammate | Showed up consistently | Did real work | Communicated status | Helped others
---------|------------------------|---------------|---------------------|---------------
         |                        |               |                     |

Who contributed most, and why?
Anything a mentor should know that is not captured above? (optional)
```

Template: [templates/PEER_EVAL_TEMPLATE.md](../templates/PEER_EVAL_TEMPLATE.md).

---

## Submission checklist

Due before Demo Day:

- [ ] **Both repos** in `iotb-tech`, mentors have access
- [ ] **Live production URLs** — frontend and API
- [ ] **README** in both repos: problem, validation findings, stack, local setup,
      env vars, MVP vs stretch vs cut, known issues, team + roles
- [ ] **Slide deck**, 6–8 slides:
      1. The problem — who, what they do today, why it is broken
      2. Who you validated with and what you actually heard
      3. The solution — core screens and flow
      4. Architecture — two repos, the contract, the stack
      5. One interesting technical decision and its trade-off
      6. MVP vs stretch vs cut, and why
      7. **Individual contributions — who built what** (mandatory)
- [ ] **Individual contribution write-ups** — one per member
- [ ] **Peer evaluations** — submitted privately
- [ ] **Demo runbook** — URLs, demo account, rollback plan

---

## Demo Day

~15 minutes per team: **7 minutes live demo, 5 minutes individual Q&A,
3 minutes buffer**.

Rules:

- **The demo is live.** Not a recording, not localhost — the production URL.
  (Keep a recording as a wifi-failure backup only.)
- **Everyone speaks**, about their own part.
- **Each member gets a direct question** about the part they claim to own. This
  is the point of the format, and it is why the contribution slide must be
  accurate.
- Judged against the rubric; scores and feedback shared after all teams present.

### What makes a good demo

Show the **user's journey**, not a tour of your screens. Sign in, do the one
thing the product exists for, see the result. Narrate the problem as you go:
"this is the step that used to take a landlord three phone calls."

Then do **one** technical deep-dive — the contract, the schema decision, the
caching approach. One, done well, beats five mentioned in passing.

### What ruins a demo

| Avoid | Instead |
|---|---|
| Signing up live from scratch | Pre-seeded account, already in the browser |
| An empty database | Seed presentable data beforehand |
| A cold-start free tier timing out | Warm every endpoint 10 minutes before |
| Discovering a bug on stage | Rehearse the exact script twice |
| "It works on my machine" | It works on the production URL |
| One person talking for 7 minutes | Each owner demos their own slice |
| Apologising for what you did not build | State the cut and the reason, confidently |

### Expect these questions

- "Walk me through what happens when a user submits this form — browser to
  database and back."
- "Why two repos instead of one?"
- "Show me where you check that this user is allowed to delete this record."
- "What happens if the API is down when this screen loads?"
- "What was the hardest bug and how did you find it?"
- "What would you do differently with another two weeks?"
- "Which part of this did *you* write?"

If you built your slice, these are easy. That is the design.
