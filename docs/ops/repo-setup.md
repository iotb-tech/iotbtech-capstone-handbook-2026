# 02 — Repository Setup

> **Read this if:** you are setting up a repo — Tech Lead and Cloud/DevOps. Once per repo.  
> **Skip if:** Your repo is already configured and the hook is installed. Jump to **Step 7** to check.  
> **~10 min.** Long code and setup blocks are collapsed — expand what you need.

Zero to a correctly configured repository. **You do this, not the mentor.** Run
it once per repo (so twice per team: frontend and backend).

Budget 45 minutes for your first repo. Do it with the whole dev team on a call
so everyone sees it happen once.

---

## Before you start

| Need | Detail |
|---|---|
| Org access | You must be a member of `iotb-tech`. If you cannot create a repo there, ask the mentor — do not create it elsewhere. |
| Project name | Lowercase, one word if possible. `schoolpulse`, `locallink`, `renttrack`. Agree it as a team **first** — renaming later breaks everyone's remotes. |
| Who runs this | The Tech Lead, with the other devs watching. |

---

## Step 1 — Create the two repositories

Names are fixed by convention:

```
<project>-frontend
<project>-backend
```

Both **private**. Both inside `iotb-tech` — check the owner dropdown says
`iotb-tech`, not your username. This is the single most common mistake.

**Via the web UI:** github.com/iotb-tech -> New repository -> Owner: `iotb-tech`
-> name -> **Private** -> *do not* add a README, .gitignore, or licence (you are
about to scaffold a real project; the wizard files just cause a conflict on your
first push) -> Create.

**Via the CLI** (faster, and worth learning):

```bash
gh repo create iotb-tech/<project>-frontend --private --description "<project> web app — Next.js 15 (IOTBTECH 2026 capstone)"
gh repo create iotb-tech/<project>-backend  --private --description "<project> API — Express + Prisma + PostgreSQL (IOTBTECH 2026 capstone)"
```

Write a real description. An empty description on five repos makes the org
unreadable for whoever grades it.

---

## Step 2 — Scaffold the project locally, then push

Do **not** click around in GitHub to add files. Scaffold locally and push.

- Frontend: follow [building/frontend.md](../building/frontend.md) Step 1
- Backend: follow [building/backend.md](../building/backend.md) Step 1

**Before you commit anything**, confirm `.gitignore` contains `.env` and
`node_modules`. A secret committed once is in the history forever — see
[ops/environments.md](environments.md#if-you-commit-a-secret).

Then push. **The two repos differ here**, because `create-next-app` already
creates a git repo and makes its own first commit, while the backend scaffold
does not.

**Frontend** — git already exists, so just name the branch and push:

```bash
cd <project>-frontend
git branch -M main                 # create-next-app may have used another name
git remote add origin https://github.com/iotb-tech/<project>-frontend.git
git push -u origin main
```

**Backend** — no git yet, so initialise it:

```bash
cd <project>-backend
git init -b main
git add .
git commit -m "chore: scaffold project"
git remote add origin https://github.com/iotb-tech/<project>-backend.git
git push -u origin main
```

If `git add . && git commit` reports *"nothing to commit, working tree clean"*,
that is the scaffolder's commit already in place — not an error. Carry on to the
push.

---

## Step 3 — Create the long-lived branches

Three permanent branches. Never deleted, never force-pushed.

```bash
git checkout main
git checkout -b dev
git push -u origin dev
git checkout -b staging
git push -u origin staging
git checkout dev
```

What each is for — full workflow in [rules/git-workflow.md](../rules/git-workflow.md):

| Branch | Holds | Who merges into it |
|---|---|---|
| `main` | Production. Always deployable. | Tech Lead only |
| `staging` | Release candidate, QA tests here | Tech Lead only |
| `dev` | Integration — everyone's merged work | Any dev, via approved PR |

---

## Step 4 — Make `dev` the default branch

```bash
gh repo edit iotb-tech/<project>-frontend --default-branch dev
```

Or: Settings -> General -> Default branch -> `dev`.

Why: a new clone lands on `dev`, and a PR opened without thinking targets `dev`
instead of `main`. It removes a whole class of accident.

---

## Step 5 — Repository settings

Settings -> General:

- **Pull Requests**: tick **Allow squash merging**. Untick *Allow merge commits*
  and *Allow rebase merging*. One merge style means a readable history.
- Tick **Automatically delete head branches** — stale feature branches pile up
  fast.
- Tick **Always suggest updating pull request branches**.
- Features: **Issues** on, **Projects** on. Wikis off (use the README).

Or via CLI:

```bash
gh repo edit iotb-tech/<project>-frontend \
  --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false \
  --delete-branch-on-merge --enable-issues --enable-projects --enable-wiki=false
```

---

## Step 6 — Team access

The org default is `no permission`, so teammates cannot see a new private repo
until access is granted.

- Reuse your existing org team if you have one (`locallink-devs`,
  `renttrack-dev-and-cloud`, ...). Settings -> Collaborators and teams -> Add
  team -> role **Write**.
- No team yet? **Ask the mentor to create one** — `<project>-team`. Do not add
  people one by one as individual collaborators; a team is one place to manage
  access for both repos.

**Role is `Write`, not `Admin`.** Write lets you push branches and open PRs,
which is all you need. Admin lets you turn off every safeguard in this handbook,
usually at 2am before a deadline. Tech Lead gets `Admin` on their own team's
repos only.

Everyone who needs read access: PM, UI/UX designer, QA. They are reviewers and
testers — give them `Read` (or `Write` if they file issues and edit docs).

---

## Step 7 — Install the templates and the hook

Copy from this handbook's [templates](../templates/README.md) into each repo:

/// details | Copy the templates in
    type: example

```bash
# from the repo root
mkdir -p .github/ISSUE_TEMPLATE .github/workflows scripts/git-hooks

cp <handbook>/templates/github/pull_request_template.md   .github/
cp <handbook>/templates/github/ISSUE_TEMPLATE/*.md        .github/ISSUE_TEMPLATE/
cp <handbook>/templates/github/workflows/ci-frontend.yml  .github/workflows/   # backend: ci-backend.yml
cp <handbook>/templates/github/workflows/assign-reviewers.yml .github/workflows/
cp <handbook>/templates/scripts/git-hooks/pre-push        scripts/git-hooks/
cp <handbook>/templates/scripts/setup-hooks.sh           scripts/
cp <handbook>/templates/scripts/setup-hooks.ps1          scripts/
cp <handbook>/templates/CONTRIBUTING.md                  .
cp <handbook>/templates/REVIEWERS.md                     .
cp <handbook>/templates/README_TEMPLATE.md               README.md
```
///

Fill in the `<PROJECT>`, `<TEAM>`, and `@username` placeholders in
`CONTRIBUTING.md`, `README.md`, and `REVIEWERS.md`. Commit on a branch and open
a PR — your first PR should be this setup commit.

### Then every developer installs the hook, on every clone

This is the step people skip, and it is the step that actually protects your
branches.

```bash
# macOS / Linux / Git Bash on Windows
bash scripts/setup-hooks.sh
```

```powershell
# Windows PowerShell
.\scripts\setup-hooks.ps1
```

Verify it works — you *want* to see this fail:

```bash
git checkout main
git push
# -> BLOCKED: direct push to 'main' is not allowed.
git checkout dev
```

If the push succeeded, the hook is not installed. Fix it before you write any
code.

> **Why a script instead of just copying a file into `.git/hooks/`:** the
> script sets `core.hooksPath` to the version-controlled `scripts/git-hooks`
> directory. A **global** `core.hooksPath` — which you have if you use Husky, a
> dotfiles setup, or followed a tutorial that set one — silently overrides
> `.git/hooks/` entirely. A hook copied there would look installed and do
> absolutely nothing, with no warning. A repo-local setting always wins.
>
> It also means the hook is version-controlled: fix it in a PR and everyone gets
> the fix. But **each person must still run the script once per clone**, because
> the config it sets is local to that clone.

---

## Step 8 — Read this before you touch "Rules" in Settings

**Do not create a repository ruleset or branch protection rule on a private repo
and assume you are protected.**

`iotb-tech` is on the **GitHub Free** plan. On a Free organisation, rulesets and
branch protection are enforced on **public** repositories only. On a private
repo, GitHub still lets you create a ruleset, still displays it as **"Active"**,
and enforces **absolutely nothing**. Verified directly against this org: the
rulesets API on a private repo here returns

```
403  Upgrade to GitHub Pro or make this repository public to enable this feature.
```

while a public repo in the same org returns its active rulesets normally.

`CODEOWNERS` is the same story — on a private Free repo it does not request
reviewers. It is an inert text file.

So the enforcement stack for this capstone is:

| Layer | Works on private/Free? | What it does |
|---|---|---|
| `pre-push` git hook | ✅ | Blocks pushes to `main`/`staging`/`dev` on your machine |
| GitHub Actions CI | ✅ | Typecheck/lint/build on every PR; red/green visible to reviewers |
| `REVIEWERS.md` + `assign-reviewers.yml` | ✅ | Auto-requests the right reviewer — our CODEOWNERS replacement |
| PR + issue templates, labels, Projects | ✅ | — |
| Rulesets / branch protection | ❌ | Shows "Active", enforces nothing. **Trap.** |
| `CODEOWNERS` | ❌ | Inert |

**SchoolPulse, specifically:** your repos are public today and your three
rulesets *are* working. When you go private per
[fix-now.md](../fix-now.md), **those rulesets stop
enforcing**. Installing the hook on every member's clone is not optional for
you — it is the direct replacement for protection you are about to lose.

---

## Step 9 — Labels

Delete GitHub's defaults, add a set that means something:

/// details | Label creation commands
    type: example

```bash
gh label create "type:feature"  --color 0E8A16 --description "New user-facing capability"
gh label create "type:bug"      --color D73A4A --description "Something is broken"
gh label create "type:chore"    --color C5DEF5 --description "Tooling, config, cleanup"
gh label create "type:docs"     --color 0075CA --description "Documentation only"
gh label create "area:frontend" --color 1D76DB
gh label create "area:backend"  --color 5319E7
gh label create "area:contract" --color FBCA04 --description "Changes the FE/BE API contract"
gh label create "priority:p0"   --color B60205 --description "Blocks the MVP"
gh label create "priority:p1"   --color FF9800 --description "Needed for MVP"
gh label create "priority:p2"   --color FEF2C0 --description "Nice to have / stretch"
gh label create "blocked"       --color 000000 --description "Waiting on someone or something"
gh label create "needs-design"  --color D4C5F9 --description "Waiting on UI/UX"
gh label create "needs-contract" --color D4C5F9 --description "Waiting on an agreed API contract"
gh label create "good-first-issue" --color 7057FF
```
///

`blocked`, `needs-design`, and `needs-contract` are the ones that make a stalled
project visible before the checkpoint instead of on Demo Day.

---

## Step 10 — The project board

One board for the team, covering **both** repos (Projects can span repos — this
is the one place the two-repo split needs joining back up).

github.com/orgs/iotb-tech -> Projects -> New project -> Board.

Columns: `Backlog` -> `Ready` -> `In Progress` -> `In Review` -> `QA` ->
`Done`.

Rules the PM enforces:

- Nothing enters `In Progress` without a **named assignee**.
- Nothing sits in `In Progress` more than 3 days without a comment.
- `In Review` means a PR is open and waiting on a human.
- Nothing reaches `Done` until the Definition of Done is met
  ([11](../standards/definition-of-done.md)).

---

## Step 11 — Verify, with a throwaway PR

Prove the setup works before anyone depends on it:

```bash
git checkout dev && git pull origin dev
git checkout -b chore/<yourname>/verify-setup
echo "" >> README.md
git commit -am "chore: verify repo setup"
git push -u origin chore/<yourname>/verify-setup
gh pr create --base dev --title "chore: verify repo setup" --body "Setup verification. Safe to close."
```

Check all of this:

- [ ] PR template loaded automatically into the description
- [ ] CI ran and shows a green check
- [ ] A reviewer was requested automatically (`assign-reviewers` workflow)
- [ ] Squash merge is the only merge button offered
- [ ] The branch was deleted after merge
- [ ] `git checkout main && git push` is **refused** by the hook
- [ ] Every teammate can clone, and has run the hook setup script

Then close or merge it. **Now** start building.

---

## After Demo Day

You may want these repos public for your CV. Allowed **after** Demo Day, with
mentor approval, and only after a secrets scan — see
[ops/environments.md](environments.md#going-public-after-demo-day).
Going public also re-enables real rulesets, which is a nice bonus.
