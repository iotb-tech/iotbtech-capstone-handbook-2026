# 12 — Remediation: Fix By Saturday 24 October 2026

> **Read this if:** you are on any capstone team. Your team is named below.  
> **Skip if:** never — this one has a deadline.  
> **~9 min**, then a couple of hours of actual work.

> **Deadline: Saturday 24 October 2026, 11:59 PM WAT.**
> *(Mentors: this is the only place the date appears — change it here.)*

Every team has gaps. This is not a telling-off — the capstone started before
these standards were written down, and most of the drift is from teams taking
initiative with no reference to follow. Now there is one.

Find your team, do the list, confirm in the capstone channel when it is done.

**Nothing below requires a mentor** except repo visibility changes, transfers,
and team creation — ask for those early rather than on the deadline.

---

## Where each team stands

Audited directly against the `iotb-tech` organisation.

!!! note "These are repository names, not confirmed product names"
    The rows below are labelled with whatever each repo is currently called.
    We have not verified whether that is your **product** name or your **team**
    name — and the rule is that repos are named after the **product**
    ([why](rules/ground-rules.md#ruling-1--no-monorepos)).

    **Check your row.** If the name is your product, nothing to do. If it is
    your team name, it needs a rename — see
    [If your repos are named after your team](#if-your-repos-are-named-after-your-team).

| Repo name | Repos | Visibility | Branches | What exists today |
|---|---|---|---|---|
| **SchoolPulse** | `schoolpulse-frontend` / `-backend` | public | `main`, `dev`, `staging` + rulesets, `feature/<name>/<task>` | Furthest along. Next.js app; Express + Prisma + config/middleware; own workflow guide and `.env.example` |
| **LocalLink** | `locallink-frontend` / `-backend` | private | `main`, `dev` | Strong hygiene: `CONTRIBUTING.md`, issue/PR templates, `pre-push` hook, shared `contract/` package, docker-compose |
| **Fixit** | `Fixit-frontend` / `-backend` | private | `main`, `dev`, `staging` | README only — no code, no scaffolding |
| **RentTrack** | `RentTrack-frontend` / `-backend` | public | `main` only | LICENSE only — no code, no `dev` branch |
| **SabiQ** | `sabiQ-frontend` / `-backend` | private | none | Both repos completely empty |

Two teams deserve credit, because the rest of you should copy from them rather
than invent from scratch:

- **SchoolPulse** built the branch model and workflow discipline this handbook
  standardises on.
- **LocalLink** worked out the Free-plan protection problem independently and
  solved it with a `pre-push` hook — now the organisation-wide standard, and the
  basis of [`templates/CONTRIBUTING.md`](templates/CONTRIBUTING.md).

---

## Everyone, regardless of team

- [ ] Every member has **read the [front page](index.md), [Ground
      Rules](rules/ground-rules.md) and the [Git
      Workflow](rules/git-workflow.md)** and confirmed it in the team channel
- [ ] Both repos are **private**, in `iotb-tech`, named
      `<product>-frontend` / `<product>-backend` — after the **product**, not
      the team ([rename procedure](#if-your-repos-are-named-after-your-team))
- [ ] `main`, `dev`, `staging` all exist; default branch is `dev`
- [ ] **Every developer has installed the `pre-push` hook on every clone**, and
      verified that `git checkout main && git push` is refused
- [ ] `.github/` templates + both CI workflows committed
- [ ] `CONTRIBUTING.md`, `README.md`, `REVIEWERS.md`, `.env.example` committed
      and filled in (no `<PRODUCT>` placeholders left)
- [ ] `.env` is in `.gitignore`, and `git log --all --oneline -- .env` returns
      nothing
- [ ] Roles written into the README — who is Tech Lead, PM, UI/UX, DevOps, QA
- [ ] Board exists with the six columns, every in-flight ticket has a named owner
- [ ] Standups running, posted in writing
- [ ] Squash-merge only; auto-delete branches on merge

---

## SchoolPulse

You are the furthest along and your branch model is what this handbook
standardised on. Two things to fix.

- [ ] **Flip both repos to private** (ask the mentor — visibility is an L4
      decision)
- [ ] **Understand what that costs you, and replace it.** Your three rulesets
      (`protect main`, `Protect dev`, `protect staging`) are working *because
      the repos are public*. On a private repo in a Free org they will show as
      "Active" and enforce **nothing**. The `pre-push` hook is the replacement
      and it is mandatory — **every member, every clone, verified.** You are the
      team most exposed to this change, because you are the team currently
      relying on real protection.
- [ ] Clean up `sp-git-workflow-guide.md` — it currently opens mid-AI-chat
      ("You're right — we are NOT going back to Decision 29 yet…"). Fold the
      genuinely good parts into `CONTRIBUTING.md` from the template and delete
      the transcript. It is a public artifact of your team's engineering; make it
      read like one.
- [ ] Merge `quick-start.md` into the README's "Local setup" section
- [ ] Add CI workflows to both repos
- [ ] Add a `contract/` directory and write entries for your existing endpoints
      ([08](building/api-contract.md))

---

## LocalLink

The best repo hygiene of the five. Two of your controls are inert, though, and
you should know which.

- [ ] **`CODEOWNERS` does nothing on your repos.** Code owners are a paid
      feature for private repositories — on a Free org private repo the file is
      inert and never requests a reviewer. Replace it with
      [templates/REVIEWERS.md](templates/REVIEWERS.md) plus
      `assign-reviewers.yml`, which does work. Keep `CODEOWNERS` only if you
      intend to go public after Demo Day, and add a comment in the file saying
      it is currently inactive.
- [ ] **Create `staging`.** You have `main` and `dev` only.
- [ ] Add both CI workflows (`.github/workflows/`)
- [ ] Your `CONTRIBUTING.md` says server-side enforcement "is not yet active on
      our organization plan" — correct, and it will not become active. Update
      the wording to state the hook is the permanent control, not a stopgap.
- [ ] Promote your `contract/` package into proper written entries per
      [08](building/api-contract.md) — you have the types, add the endpoint docs,
      status codes, and `agreed / built / deployed` status
- [ ] Confirm every member has the hook installed (you wrote it — make sure it
      is actually installed on every clone)
- [ ] `docker/dockercompose.yaml` — rename to `docker-compose.yaml` for tooling
      conventions, and confirm it runs

**Credit where due:** your `pre-push` hook is now the org-wide standard and your
`CONTRIBUTING.md` is the basis of the shared template.

---

## Fixit

Private, correct branches, but both repos contain only a README. You are two
weeks from Demo Day with no code committed.

- [ ] **Scaffold the frontend** ([06, Step 1](building/frontend.md)) and push
- [ ] **Scaffold the backend** ([07, Step 1](building/backend.md)) and push
- [ ] Set default branch to `dev` on both
- [ ] Copy in `.github/`, `scripts/`, `CONTRIBUTING.md`, `REVIEWERS.md`,
      `.env.example`
- [ ] Install the hook — everyone
- [ ] Provision the shared hosted dev Postgres; confirm every dev can connect
- [ ] Prisma schema for the full MVP, migrated
- [ ] First contract entries written and merged
- [ ] Staging deployed — frontend and API

If local code exists that is not pushed, push it **today**. Work only on a
laptop is work nobody can see, review, or grade.

---

## RentTrack

Both repos are **public and effectively empty** — a LICENSE file and nothing
else. No `dev`, no `staging`, no protection.

- [ ] **Flip both repos to private** (mentor — L4)
- [ ] Create `dev` and `staging`; set default branch to `dev`
- [ ] **Scaffold both projects** ([06](building/frontend.md),
      [07](building/backend.md)) and push
- [ ] Copy in all templates; install the hook on every clone
- [ ] Your org team `renttrack-dev-and-cloud` has **no repository access
      granted** — add it to both repos with `Write`
      ([02, Step 6](ops/repo-setup.md#step-6--team-access))
- [ ] Confirm who holds PM, UI/UX, and DevOps, and write it in the README
- [ ] Provision the shared dev database
- [ ] Schema, first contract entries, staging deploy

---

## SabiQ

Both repos are **completely empty** — no commits at all since 12 October.

- [ ] Run the whole of [ops/repo-setup.md](ops/repo-setup.md), top to bottom,
      on both repos
- [ ] Scaffold both projects and push
- [ ] Install the hook on every clone
- [ ] Ask the mentor to create your org team, then grant it `Write` on both repos
- [ ] Assign roles and write them in the README
- [ ] Post your first standup
- [ ] **Talk to the mentor this week** — two empty repos a week after creation
      suggests a blocker that is not technical. Raise it now while there is
      still time to recover, not at Checkpoint 2.

---

## If your team built a monorepo

Split it into two repos before the deadline.

**Option A — preserve history** (preferred if the backend has real history):

```bash
# from the monorepo, with everything committed
git subtree split --prefix=backend -b backend-only

# create the new repo (ops/repo-setup.md Step 1), then:
cd .. && mkdir <product>-backend && cd <product>-backend
git init -b main
git pull ../<monorepo> backend-only
git remote add origin https://github.com/iotb-tech/<product>-backend.git
git push -u origin main
```

Then remove `backend/` from the monorepo, rename the monorepo to
`<product>-frontend`, and move the frontend files from `frontend/` up to the
repo root.

**Option B — clean start** (fine if there is little history to lose):

1. Tag the monorepo `git tag archive/monorepo && git push --tags` so nothing is
   lost.
2. Create both repos per [02](ops/repo-setup.md).
3. Copy the frontend files into one, the backend files into the other.
4. Commit as `chore: split monorepo into frontend and backend`.
5. Ask the mentor to archive the monorepo.

Either way, afterwards:

- [ ] Both repos scaffolded, building, and pushed
- [ ] Separate `.env.example` per repo — **no `DATABASE_URL` in the frontend**
- [ ] CI workflows re-pointed at the new repo roots
- [ ] Vercel/Railway projects re-pointed
- [ ] Every member re-clones; old clones deleted so nobody keeps pushing to the
      monorepo
- [ ] Monorepo archived (mentor)

---

## If your repos are named after your team

The convention is `<product>-frontend` / `<product>-backend` — named for what
you are building, not who built it.

A rename is an **L4 decision** and it breaks everyone's remotes, so do it once,
deliberately, and tell the whole team the moment it is done.

1. Agree the product name as a team. Lowercase, one word if you can.
2. **Ask the mentor** to rename both repos (Settings → Repository name).
3. Everyone updates their remote — this is the step people forget, and the
   symptom is a push that silently goes nowhere:

```bash
git remote set-url origin https://github.com/iotb-tech/<product>-frontend.git
git remote -v        # confirm both fetch and push point at the new name
```

4. Re-point Vercel and Railway at the renamed repos.
5. Update the name in `README.md`, `CONTRIBUTING.md` and `.env.example`.

GitHub redirects the old URL for a while, which is a trap: pushes appear to work
from stale clones long enough for you to forget to fix them. Do step 3 the same
day.

---

## If your team created its own GitHub organisation

Full procedure in
[01, Ruling 2](rules/ground-rules.md#if-your-team-created-its-own-organisation).

- [ ] Message the mentor **now** so they are ready to accept the transfer
- [ ] Transfer both repos into `iotb-tech` (Settings -> Danger Zone -> Transfer
      ownership), or create fresh repos and push if there is nothing worth
      keeping
- [ ] Rename to `<product>-frontend` / `<product>-backend`
- [ ] Set private, create branches, apply all templates
- [ ] Confirm with the mentor that both repos are visible in `iotb-tech`
- [ ] Re-point Vercel/Railway at the new repo locations
- [ ] Everyone updates their remote:
      `git remote set-url origin https://github.com/iotb-tech/<repo>.git`
- [ ] **Delete the organisation** so nobody pushes to it by accident

The same applies if your primary repo is on a **personal account**.

---

## How this is verified

After the deadline, mentors check each repo:

```bash
# visibility, default branch, org
gh api repos/iotb-tech/<repo> --jq '{visibility, default_branch, owner: .owner.login}'

# all three long-lived branches exist
gh api repos/iotb-tech/<repo>/branches --jq '[.[].name]'

# required files present
gh api repos/iotb-tech/<repo>/contents --jq '[.[].name]'
gh api repos/iotb-tech/<repo>/contents/.github --jq '[.[].name]'
gh api repos/iotb-tech/<repo>/contents/scripts/git-hooks --jq '[.[].name]'

# work is going through PRs, and by more than one person
gh pr list --repo iotb-tech/<repo> --state merged --limit 50 \
  --json number,author,mergedAt --jq '[.[].author.login] | group_by(.) | map({user: .[0], prs: length})'

# nothing landed on main outside a PR
git log --first-parent origin/main --pretty='%h %an %s'

# no secret was ever committed
git log --all --oneline -- .env        # must be empty
```

A team that has done the list passes in two minutes. A team that has not will be
asked for a plan with dates at the next checkpoint, and the collaboration score
([11](standards/definition-of-done.md#rubric--100-points-per-team)) reflects
it.

---

## Why this is worth your Saturday

Every item here is something you would be asked to fix in a real code review on
your first job. Private repos, no secrets in git, a PR-based workflow, one
project per deployable unit, a reviewer who is not you, a documented setup
someone else can follow.

Doing it now costs a few hours. Doing it in week two, with four people's
in-flight branches to rebase and two deploy targets to re-point, costs days you
will not have.
