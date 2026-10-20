---
hide:
  - navigation
  - toc
---

![IOTBTECH](assets/iotbtech-wordmark.svg){.iotb-wordmark}

# Capstone — The Rules That Matter {.print-title}

*IOTBTECH 2026 Full-Stack Capstone. Print this. Pin it. Full handbook:
`iotb-tech.github.io/iotbtech-capstone-handbook-2026`*

## The 12 non-negotiables

| # | Rule |
|---|---|
| 1 | **Two repos per team.** `<project>-frontend` + `<project>-backend`. **No monorepos.** |
| 2 | **Everything in the `iotb-tech` org.** Don't create your own org. Don't use a personal account. |
| 3 | **Repos are private.** |
| 4 | **Developers create and configure the repos** — not the mentor. |
| 5 | **Never push directly to `main`, `staging`, or `dev`.** All changes by pull request. |
| 6 | **Every PR needs one teammate's approval.** You never approve your own. |
| 7 | **Contract first.** Agree and merge the API contract *before* the code using it. |
| 8 | **No secrets in git. Not once.** `.env` ignored, `.env.example` committed. |
| 9 | **Stack is fixed.** Next.js 15 + TS + Tailwind · Express + TS + Prisma + Postgres. |
| 10 | **Every ticket has one named owner.** You own a user story end to end. |
| 11 | **Async standup every other day.** Three lines, written down. |
| 12 | **Ask before you act** on anything above your level. |

## ⚠ Branch protection does not work here

`iotb-tech` is on **GitHub Free**: rulesets work on **public** repos only. On a
private repo GitHub shows a ruleset as **"Active"** and enforces **nothing** —
you can push straight to `main`. `CODEOWNERS` is inert too.
**So every developer installs the `pre-push` hook, on every clone:**

```bash
bash scripts/setup-hooks.sh        # or .\scripts\setup-hooks.ps1 on Windows
git checkout main && git push      # must be REFUSED. If it pushed, you're not protected.
```

## Daily workflow

```bash
git checkout dev && git pull origin dev        # always start from dev, never main
git checkout -b feature/yourname/short-task
git commit -m "feat(scope): what and why"      # not "update", not "fixed stuff"
git pull origin dev --rebase
git push -u origin feature/yourname/short-task
gh pr create --base dev --fill                 # screenshots for any UI change
```

`main` ← `staging` ← `dev` ← `feature/<name>/<task>`. One direction only.
Tech Lead alone merges into `staging` and `main`.

## When you're stuck

**2-hour rule — never sit on a blocker longer than that.** Label the ticket
`blocked`, post in the team channel, tag the one person who can help, switch
tickets while you wait. Ask with four lines: **Trying to / Tried / Error /
My guess.** Escalate to the mentor only after the team has tried — expect 24h
on working days.

## Before you call anything done

CI green · one approval · types real, no `any` · loading + error + **empty**
states · matches the contract · ownership checked on mutations · `.env.example`
updated · deployed to staging · no secrets, no `console.log`.

> **Your team has a fix-it list with a deadline — see "Fix This Now" in the handbook.**
