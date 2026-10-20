# Capstone Handbook

Everything you need to run the full-stack capstone like an engineering team.
**Most questions already have an answer in the [FAQ](faq.md)** — check there
before asking.

!!! danger "Your team has a fix-it list, with a deadline"
    Every team has gaps against the standards below.
    **[Open Fix This Now →](fix-now.md)**

---

## The 12 non-negotiables

Break these and the project is marked down however good the app looks.

1. **Two repos per team, never one** — named after the **product**, not the team. `<product>-frontend` + `<product>-backend`. No monorepos. · [why](rules/ground-rules.md#ruling-1--no-monorepos)
2. **Everything lives in the `iotb-tech` org.** Don't create your own. · [why](rules/ground-rules.md#ruling-2--no-new-github-organisations)
3. **Repos are private.** · [setup](ops/repo-setup.md)
4. **Developers create and configure the repos** — not the mentor. · [setup](ops/repo-setup.md)
5. **Nobody pushes directly to `main`, `staging`, or `dev`.** Ever. · [workflow](rules/git-workflow.md#hard-rules)
6. **Every PR needs one teammate's approval.** · [workflow](rules/git-workflow.md#pull-requests)
7. **Contract first** — agreed and merged before the code that depends on it. · [contract](building/api-contract.md)
8. **No secrets in git. Not once.** · [secrets](ops/environments.md#secrets-policy)
9. **The stack is fixed.** Next.js 15 + TS + Tailwind · Express + TS + Prisma + Postgres. · [why](rules/ground-rules.md#ruling-4--the-stack-is-fixed)
10. **Every ticket has one named owner**, and you own a user story end to end. · [roles](rules/roles.md#how-work-is-split-vertical-slices-not-layers)
11. **Async standup every other day minimum.** Three lines, written down. · [how](rules/communication.md#async-standup)
12. **Ask before you act** on anything above your level. · [matrix](rules/ground-rules.md#decision-authority-matrix)

---

## Read this even if you read nothing else

!!! warning "Branch protection does not work here, and GitHub will lie to you about it"
    `iotb-tech` is on the **GitHub Free** plan, where branch protection and
    rulesets are enforced on **public** repos only.

    On a private repo, GitHub still lets you create a ruleset, still shows it as
    **"Active"** — and enforces **nothing**. You can push straight to `main`.
    `CODEOWNERS` is inert too.

    So we use a **local `pre-push` hook**, CI, a reviewer map, and audits.
    **Every developer installs the hook on every clone.**
    [Set it up →](ops/repo-setup.md#step-7--install-the-templates-and-the-hook)

---

## Who are you?

Nobody reads all fourteen documents. Read **your** four or five, in this order.

| You are | Read, in order |
|---|---|
| **Frontend dev** | [Ground rules](rules/ground-rules.md) → [Git workflow](rules/git-workflow.md) → [Frontend](building/frontend.md) → [API contract](building/api-contract.md) → [Done & rubric](standards/definition-of-done.md) |
| **Backend dev** | [Ground rules](rules/ground-rules.md) → [Git workflow](rules/git-workflow.md) → [Backend](building/backend.md) → [API contract](building/api-contract.md) → [Done & rubric](standards/definition-of-done.md) |
| **Product Manager** | [Ground rules](rules/ground-rules.md) → [Roles](rules/roles.md) → [Communication](rules/communication.md) → [Build order](building/build-order.md) → [Done & rubric](standards/definition-of-done.md) |
| **UI/UX Designer** | [Roles](rules/roles.md) → [Handoffs](rules/communication.md#handoffs) → [Frontend: design](building/frontend.md#design-shared-tokens) |
| **Cloud / DevOps** | [Repo setup](ops/repo-setup.md) → [Environments & secrets](ops/environments.md) → [Git workflow](rules/git-workflow.md) |
| **QA** | [Done & rubric](standards/definition-of-done.md) → [Handoffs](rules/communication.md#handoffs) → [Git workflow](rules/git-workflow.md) |
| **Tech Lead** | All of **Rules & Process**, then skim the rest |

Everyone reads the 12 above and the warning. Everything else is reference —
**use the search box** rather than reading cover to cover.

---

## Not sure you're allowed to build it yet?

Backend classes are still running. You're at **Class 37 (Auth.js v5)**; 38–45
haven't happened. That's planned for:
**[what you can build now, and what to leave alone →](building/build-order.md)**

Short version: the frontend is fully unblocked; the backend can do schema,
Prisma, and all CRUD; use Auth.js v5 and **don't hand-roll auth before Class
38**; WebSockets and Redis are stretch goals, never MVP.

---

## How you're assessed

A working app is table stakes. What's being assessed is whether you can operate
on a team: branch discipline, real code review, honouring a contract,
communicating a blocker, shipping something deployed.

**Collaboration and process is worth as much as the frontend or the backend.** A
team can ship a beautiful app and score badly. An individual can be on a winning
team and not progress, with no evidence they did the work.
[Rubric and the six participation checks →](standards/definition-of-done.md)

---

*One page to print and pin: [the non-negotiables](one-pager.md).*
