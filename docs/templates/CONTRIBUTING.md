# Contributing to <PRODUCT>

This is the team handbook for this repository. **Read it in full before your
first push.**

It is the project-specific companion to the capstone handbook. Where this file
and the handbook disagree, the handbook wins — tell the Tech Lead so this gets
fixed.

If anything here is unclear, say so. Confusing documentation is a bug.

---

## Contents

1. [One-time setup](#one-time-setup)
2. [The daily workflow](#the-daily-workflow)
3. [Branches](#branches)
4. [Commits](#commits)
5. [Pull requests](#pull-requests)
6. [Reviewing](#reviewing)
7. [Cross-repo changes](#cross-repo-changes)
8. [Environment variables](#environment-variables)
9. [When something goes wrong](#when-something-goes-wrong)

---

## One-time setup

Do this **once per clone**, on **every machine** you work from.

```bash
git clone https://github.com/iotb-tech/<REPO>.git
cd <REPO>

bash scripts/setup-hooks.sh        # macOS / Linux / Git Bash
# .\scripts\setup-hooks.ps1        # Windows PowerShell

npm install
cp .env.example .env               # frontend: .env.local
# fill in the values — ask the Cloud/DevOps owner for shared ones
npm run dev
```

### Verify the hook, by trying to break the rules

```bash
git checkout main
git push
# -> BLOCKED: direct push to 'main' is not allowed.
git checkout dev
```

**If that push succeeded, you are not protected.** Run the setup script again
and tell the Tech Lead.

### Why a hook and not GitHub branch protection

`iotb-tech` is on the GitHub **Free** plan, where branch protection and
rulesets are enforced on **public** repositories only. On a private repo
GitHub will let you create a ruleset, show it as **"Active"**, and enforce
nothing at all.

So this is **permanent**, not a stopgap:

| Control | Works here? |
|---|---|
| `pre-push` hook | yes — client-side |
| GitHub Actions CI | yes |
| `REVIEWERS.md` + `assign-reviewers.yml` | yes |
| Branch protection / rulesets | **no** — shows "Active", does nothing |
| `CODEOWNERS` | **no** — inert |

The hook runs on your machine, so it cannot protect the repo from someone who
never installed it. **The real control is the team.**

---

## The daily workflow

```bash
git checkout dev && git pull origin dev          # always start here
git checkout -b feature/yourname/short-task
# ... work, commit in small steps ...
git pull origin dev --rebase                     # before pushing
git push -u origin feature/yourname/short-task
gh pr create --base dev --fill
```

Push **at least once a day**, even unfinished — open it as a draft PR. Code
only on your laptop is invisible to your team, is not evidence of your
contribution, and is one dead laptop away from gone.

---

## Branches

```
main      production, always deployable   — Tech Lead merges only
staging   release candidate, QA tests here — Tech Lead merges only
dev       integration, everyone's work     — any dev, via approved PR
feature/<name>/<task>                      — you
```

Naming: `feature/` `fix/` `chore/` `docs/` + `/<yourname>/` + `<short-task>`.

```
feature/adeshina/listing-create-form
fix/abibat/login-redirect-loop
```

Rules:

- **Never push directly to `main`, `staging`, or `dev`.**
- **Always branch from the latest `dev`**, never from `main`.
- One branch per ticket.
- Never force-push a shared branch. Your own feature branch is fine
  (`--force-with-lease`).

---

## Commits

```
<type>(<scope>): <what changed>
```

`feat` `fix` `chore` `docs` `refactor` `test` `style`

```
feat(auth): add Google sign-in via Auth.js v5
fix(bookings): prevent double booking on the same slot
```

Not acceptable: `update`, `fixed stuff`, `final`, `asdasd`.

Add a body when the *why* is not obvious from the subject.

---

## Pull requests

- Targets `dev`
- Under ~400 changed lines
- Template filled in, issue linked (`Closes #42`)
- **Screenshots for any UI change**
- CI green — **do not merge a red PR**
- **One approval minimum**, two for auth / schema / contract
- Squash merge; branch deleted after
- **You never approve your own PR**

---

## Reviewing

Review within **12 hours** of being requested. It is part of your grade.

Look for: does it do what the ticket says; are the types real; are loading,
error, and empty states handled; any secret or hardcoded URL; does it match the
contract; could you debug this in three weeks.

Be specific. "The `price` field is a string here but the contract says number —
the form will send `"1500"` and Prisma will reject it" is useful. "this is
wrong" is not.

---

## Cross-repo changes

Frontend and backend are separate repos. Order is fixed:

1. **Contract PR** (1 frontend + 1 backend approval) — merges first
2. **Backend PR** — implement, deploy to staging
3. **Frontend PR** — wire it up, delete the mock

Cross-link all of them in the PR descriptions.

The frontend never waits on the backend — build against the mock once the
contract is merged.

---

## Environment variables

- `.env` / `.env.local` are **never** committed
- `.env.example` **is** committed, with placeholders, and updated in the **same
  PR** as the code that needs the new variable
- **Never paste a secret into group chat** — use the platform's env var UI
- Frontend: `NEXT_PUBLIC_` values are visible in the browser. Never a secret.

**If you commit a secret: rotate it first**, then tell the Tech Lead and the
Cloud/DevOps owner. Deleting the file in a later commit does not remove it from
history.

---

## When something goes wrong

| Problem | Do this |
|---|---|
| Committed to `dev` locally, not pushed | `git branch feature/you/work && git reset --hard origin/dev` |
| Pushed to a protected branch | **Tell the Tech Lead now.** Nobody is in trouble for the mistake. |
| PR has conflicts | `git pull origin dev --rebase`, resolve, `git push --force-with-lease` |
| Lost in a rebase | `git rebase --abort` — nothing is broken |
| Committed a secret | Rotate it, then tell the Tech Lead |
| Stuck over 2 hours | Post in the channel with the four-line format, switch tickets |

Full recipes: `rules/git-workflow.md` in the handbook.

---

## Project specifics

<!-- Fill these in for this repo. -->

**Local setup gotchas:**

**Shared dev database:** ask @

**Staging URL:**

**Who to ask:** Tech Lead @ · Frontend @ · Backend @ · DevOps @ · PM @ · Design @
