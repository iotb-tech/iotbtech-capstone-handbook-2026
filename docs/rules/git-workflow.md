# 03 — Git Workflow

> **Read this if:** you write code, or you merge other people's.  
> **Skip if:** Nobody on the dev team. PM/designer: read **Branches** and **Pull requests** only.  
> **~11 min.** Long code and setup blocks are collapsed — expand what you need.

The same workflow in both repos, for every team. It is modelled on what
**SchoolPulse** already built (`main`/`dev`/`staging` with
`feature/<name>/<task>` branches) and the `pre-push` hook **LocalLink** wrote.
Both already work in this org.

Read this once, fully. Then keep the [Daily loop](#the-daily-loop) open until it
is muscle memory.

---

## Branch model

```
main      ← production. tagged releases. always deployable.
  ↑
staging   ← release candidate. QA tests here.
  ↑
dev       ← integration. everyone's approved work lands here.
  ↑
feature/<yourname>/<short-task>   ← you work here
```

Flow is one direction only: **feature -> dev -> staging -> main.**

### Branch naming

```
feature/adeshina/listing-create-form
fix/abibat/login-redirect-loop
chore/rufai/add-ci-workflow
docs/zariyatu/api-contract-bookings
```

`<type>/<your-name>/<short-task>` — lowercase, hyphens, no spaces, no issue
numbers in the branch name (the PR links the issue).

Your name is in there deliberately: with several people in a repo, `git branch -a`
should tell you instantly who is working on what.

### Hard rules

1. **Never push directly to `main`, `staging`, or `dev`.** The hook blocks it;
   if the hook is missing, the rule still stands.
2. **Always branch from the latest `dev`**, never from `main`. `main` lags
   behind, so branching off it guarantees a conflict later.
3. **One branch per ticket.** Not one branch per day, not one branch for three
   features.
4. **Never force-push a shared branch.** `main`, `staging`, `dev` — never. Your
   own feature branch nobody else has pulled, fine.
5. **Delete your feature branch after merge.** The repo is configured to do it
   automatically.

---

## The daily loop

```bash
# 1. Start from the latest dev — every single time
git checkout dev
git pull origin dev

# 2. Branch for your ticket
git checkout -b feature/yourname/short-task

# 3. Work. Commit in small, meaningful steps.
git add src/features/listings/CreateListingForm.tsx
git commit -m "feat(listings): add create-listing form with Zod validation"

# 4. Before pushing, bring in whatever landed on dev while you worked
git pull origin dev --rebase

# 5. Push and open the PR
git push -u origin feature/yourname/short-task
gh pr create --base dev --fill
```

Push **at least once a day**, even if the work is unfinished — open it as a
draft PR. Code that only exists on your laptop is invisible to your team, is
not evidence of your contribution, and is one dead laptop away from gone.

---

## Commit messages

Conventional Commits:

```
<type>(<scope>): <what changed, imperative, lowercase>
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`.

```bash
# Good
feat(auth): add Google sign-in via Auth.js v5
fix(bookings): prevent double booking on the same slot
refactor(api-client): centralise error envelope parsing
chore(ci): add typecheck step to frontend workflow

# Not acceptable
update
fixed stuff
final
asdasd
work in progress
```

If the *why* is not obvious from the subject line, add a body:

```
fix(listings): filter sold items from the browse query

Sold listings were still appearing in search results because the
status filter was applied client-side, after pagination. Moved it
into the Prisma where clause.
```

Why we care: the commit log is read by your reviewer, by whoever debugs this in
week 4, and by the mentor auditing your contribution. "update" tells all three
of them nothing.

---

## Pull requests

### Opening one

- **Target `dev`.** (Default branch is `dev`, so this should already be right.)
- **Keep it small.** Under ~400 changed lines. A 2,000-line PR does not get
  reviewed, it gets rubber-stamped — which defeats the point.
- **Fill in the template.** It is there to make you state what changed and how
  you tested it.
- **Link the issue** — `Closes #42`. GitHub closes it on merge.
- **Screenshots or a screen recording for any UI change.** Non-negotiable: your
  reviewer should not have to run your branch to see what you built.
- **Label it** (`area:frontend`, `type:feature`, ...).
- **Draft PR if it is not ready.** Visible progress, nobody wastes a review.

### Getting it merged

| Requirement | Why |
|---|---|
| **1 approval from a teammate** | Minimum. Two for anything touching auth, the schema, or the contract. |
| **CI green** | CI cannot be *enforced* as a required check here (Free plan, private repo) — so this is a rule reviewers hold. **Do not merge a red PR.** |
| **All review comments resolved** | Reply or fix. Do not silently dismiss. |
| **No merge conflicts** | Yours to fix, not the reviewer's. |
| **Squash merge** | One commit per PR on `dev`. Readable history. |

**You do not approve your own PR.** If you are the only person awake, it waits,
or you ask the Tech Lead. A self-merged PR shows up in the audit and reads as a
collaboration failure.

### Reviewing someone else's PR — this is part of your grade

Reviewing is a deliverable, not a favour. Aim to review within **12 hours** of
being requested.

What to actually look at:

1. Does it do what the ticket says, and only that?
2. Are the types real, or is it `any` with a hat on?
3. Loading, error, and empty states handled? (Every list view needs all three.)
4. Any secret, API key, or hardcoded URL that should be an env var?
5. Does it match the contract in [08](../building/api-contract.md)?
6. Would you be able to debug this in three weeks?

How to say it:

```
# Useful
The `price` field is a string here but the contract says number — the
form will send "1500" and Prisma will reject it. Worth a `z.coerce.number()`.

# Useless
this is wrong
```

Use GitHub's review states properly: **Approve**, **Request changes**, or
**Comment**. "LGTM" with no reading is how a broken `main` happens.

---

## Promotion: dev -> staging -> main

Only the **Tech Lead** opens these PRs.

```bash
# dev -> staging, when a batch of work is ready for QA
gh pr create --base staging --head dev --title "release: staging <date>" --body "Includes: #12 #15 #18"

# staging -> main, after QA signs off
gh pr create --base main --head staging --title "release: production <date>" --body "QA signed off by @username"
git tag -a v0.1.0 -m "MVP: auth + listings CRUD"
git push origin v0.1.0
```

Rules:

- `staging` -> `main` needs **QA or PM sign-off in the PR description**, by name.
- Tag every `main` release. `v0.1.0`, `v0.2.0`. It gives you something to roll
  back to.
- **Never commit a hotfix straight to `main`.** Branch `fix/...` from `main`,
  PR into `main`, then merge `main` back down into `dev` so the fix is not lost.

---

## Cross-repo changes (frontend + backend together)

The most common way a team loses a day: FE and BE both build against different
assumptions about the same endpoint.

**Order is fixed:**

1. **Contract PR first** — in `<project>-backend`, update the contract
   ([08](../building/api-contract.md)). Needs **1 FE + 1 BE approval**. Merge it.
2. **Backend PR** — implement the endpoint to match. Deploy to staging.
3. **Frontend PR** — wire it up, swapping the mock for the real call.

Cross-link the PRs in both descriptions:

```
Backend side: iotb-tech/locallink-backend#34
Contract: iotb-tech/locallink-backend#31
```

**The frontend never waits on the backend.** Once the contract is merged, the FE
builds against a mock and the real endpoint drops in later — see
[building/frontend.md](../building/frontend.md#working-before-the-backend-exists).

---

## The hook, and what happens when it is missing

Install (once per clone, per person):

```bash
bash scripts/setup-hooks.sh        # macOS / Linux / Git Bash
.\scripts\setup-hooks.ps1          # Windows PowerShell
```

It blocks pushes to `main`, `staging`, and `dev` from your machine.

**It is not a security control — it is a seatbelt.** Specifically:

- **A fresh clone has no hook until you run the script again.** The script sets
  `core.hooksPath` for that clone; the setting does not travel with the code.
- `git push --no-verify` skips it entirely.
- It runs on *your* machine, so it cannot protect the repo from a teammate who
  never installed it.
- Server-side enforcement is unavailable to us
  ([02, Step 8](../ops/repo-setup.md#step-8--read-this-before-you-touch-rules-in-settings)).

> **Check this if you use Husky or have ever set up global git hooks:** a global
> `core.hooksPath` silently overrides `.git/hooks/`, so hooks copied there never
> run. Our setup script works around it by setting the path repo-locally, which
> always wins — another reason to run the script rather than copying the file
> yourself. Confirm with `git config --get core.hooksPath`; it should print
> `scripts/git-hooks`.

So the real control is you. **If you push to a protected branch anyway — tell
the Tech Lead immediately.** Nobody is in trouble for the mistake. People get
in trouble for hiding it, because the next person pulls a broken `dev` and loses
an afternoon.

### How this gets audited

Mentors check whether work actually went through PRs. Every commit on `main`
should trace back to a merged pull request:

```bash
# commits that landed on main
git log --first-parent origin/main --pretty='%h %an %s'

# merged PRs, for comparison
gh pr list --state merged --base main --limit 100 --json number,title,mergedAt

# anything on main with no matching PR was a direct push
```

A clean history of reviewed PRs is strong evidence for every member. A `main`
full of direct commits from one account is strong evidence against the whole
team.

---

## When something goes wrong

### I committed to `dev` by accident (not pushed yet)

```bash
git branch feature/yourname/my-work   # save the work
git reset --hard origin/dev           # clean dev back to the remote
git checkout feature/yourname/my-work # carry on, correctly
```

### I committed to the wrong branch and already pushed

Tell the Tech Lead, then:

```bash
git checkout -b feature/yourname/my-work   # branch from where you are
git push -u origin feature/yourname/my-work
# open the PR from here; Tech Lead reverts the bad commit on the shared branch
```

### My PR has conflicts

```bash
git checkout feature/yourname/my-work
git pull origin dev --rebase
# Git stops at each conflict. Open the file, look for:
#   <<<<<<< HEAD / ======= / >>>>>>>
# Keep the correct result, delete the markers.
git add <resolved-file>
git rebase --continue
git push --force-with-lease     # safe on YOUR OWN feature branch only
```

Lost? `git rebase --abort` returns you to where you started. Nothing is broken.

### I need to undo a merge on `dev`

Tech Lead only:

```bash
git checkout dev && git pull origin dev
git revert -m 1 <merge-commit-sha>     # revert, do NOT reset a shared branch
# push via a PR, or if the hook blocks you, open a revert PR from the GitHub UI
```

### I committed a secret

**Order matters. Rotate first.**

1. **Rotate the credential immediately** — new DB password, new API key. Assume
   the old one is compromised the moment it was pushed.
2. Tell the Tech Lead and the Cloud/DevOps owner.
3. Remove it from the working tree, add the file to `.gitignore`, move the value
   into `.env`, and add the key to `.env.example` with a placeholder.
4. Only then worry about history. Full procedure:
   [ops/environments.md](../ops/environments.md#if-you-commit-a-secret).

Deleting the file in a later commit does **not** remove it from history.

### `main` is broken and the demo is tomorrow

```bash
git checkout main
git log --oneline -10          # find the last good tag
git checkout -b fix/urgent-rollback v0.1.0
```

Open a PR into `main`, get the Tech Lead to review, deploy. Then fix forward
properly on `dev`. Panicking and force-pushing `main` is how a team loses the
whole project the night before Demo Day.

---

## Cheat sheet

```bash
git checkout dev && git pull origin dev       # always start here
git checkout -b feature/me/thing              # branch
git add -p                                    # stage deliberately
git commit -m "feat(scope): what and why"     # commit
git pull origin dev --rebase                  # stay current
git push -u origin feature/me/thing           # push
gh pr create --base dev --fill                # PR
gh pr checkout 42                             # review someone's PR locally
git branch -a                                 # who is working on what
git log --oneline --graph --all -20           # see the shape of the repo
```
