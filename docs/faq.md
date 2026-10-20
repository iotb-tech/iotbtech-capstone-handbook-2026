# 13 — FAQ

> **Read this if:** Before you ask any question.  
> **Skip if:** Nobody. Start here when you are stuck.  
> **~8 min.** Long code and setup blocks are collapsed — expand what you need.

Check here before asking. If your question is not here and the handbook does not
answer it, ask in the channel — and if it turns out to be a gap, it gets added.

---

## Repos and the organisation

**Why two repos instead of a monorepo?**
Different deploy targets, different CI, different secrets, and Class 42
containerises the backend alone. Full reasoning:
[01, Ruling 1](rules/ground-rules.md#ruling-1--no-monorepos).
Monorepos are a real pattern — they need tooling you have not been taught and
time you do not have.

**We already built a monorepo. Now what?**
Split it. Both procedures (preserve history, or clean start) are in
[12](fix-now.md#if-your-team-built-a-monorepo).

**Can we use our own GitHub organisation? We already made one.**
No — transfer it back into `iotb-tech` and delete it. Work outside `iotb-tech`
is invisible to graders, which means ungraded.
[01, Ruling 2](rules/ground-rules.md#ruling-2--no-new-github-organisations).

**Who creates the repo — the mentor?**
You do. Repo setup is a skill being assessed.
[01, Ruling 3](rules/ground-rules.md#ruling-3--the-developers-own-the-repository).

**Why private? I want this on my CV.**
Private during the capstone. After Demo Day you can flip to public with mentor
approval, once you have scanned history for secrets —
[09](ops/environments.md#going-public-after-demo-day).

**I made a ruleset on `main` but I can still push to it. Is it broken?**
It is working exactly as GitHub's Free plan dictates, which is: not at all.
Rulesets and branch protection are enforced on **public** repos only for a Free
organisation. On a private repo GitHub still shows the ruleset as **"Active"**
and enforces nothing. That is why we use a `pre-push` hook.
[02, Step 8](ops/repo-setup.md#step-8--read-this-before-you-touch-rules-in-settings).

**Then why not just make the repos public so rulesets work?**
That trade-off was considered and decided: private, with the hook. Private is
the professional default for unfinished work, and holding a workflow without a
machine forcing you to is itself part of the assessment.

**My teammate can't see the repo.**
Org default permission is `none`. Grant your team `Write` on the repo —
[02, Step 6](ops/repo-setup.md#step-6--team-access). Role is `Write`, not
`Admin`.

**Should the repo be named after our team or our product?**
The **product**. `renttrack-backend`, not `team-alpha-backend`. A repo outlives
the team that built it and is read by people who have no idea who your team was
— and it is your portfolio, so a recruiter should see a product, not a group
number. Your team name goes in the README and on your slides.
[Rename procedure](fix-now.md#if-your-repos-are-named-after-your-team).

**Can I rename the repo? Our product name changed.**
Ask the mentor first — a rename breaks everyone's remote and both deploy
integrations. If approved, everyone runs
`git remote set-url origin https://github.com/iotb-tech/<new-name>.git`.
GitHub redirects the old URL for a while, so stale clones keep working just
long enough for someone to forget — do it the same day.

---

## Git and pull requests

**Why can't I push to `main`?**
Nobody pushes to `main`, `staging`, or `dev`. All changes arrive by reviewed PR.
[03](rules/git-workflow.md#hard-rules).

**Which branch do I start from?**
Always the latest `dev`. Never `main` — it lags behind and you will get conflicts.

**I pushed to `main` by accident.**
Tell the Tech Lead immediately. Nobody is in trouble for the mistake; hiding it
is the problem, because the next person pulls a broken branch.
[03](rules/git-workflow.md#when-something-goes-wrong).

**My PR has conflicts.**
Rebase onto `dev` and resolve them — they are yours to fix, not the reviewer's.
Step-by-step: [03](rules/git-workflow.md#my-pr-has-conflicts). `git rebase --abort`
always gets you back safely.

**Who reviews my PR if `CODEOWNERS` doesn't work here?**
`REVIEWERS.md` plus the `assign-reviewers.yml` workflow requests one
automatically. If it misses, tag a reviewer yourself. Review within 12 hours of
being asked — reviewing is part of your grade.

**Can I approve my own PR? Nobody else is online.**
No. It waits, or you ask the Tech Lead. A self-merged PR shows up in the audit.

**CI is red but my feature works. Can I merge?**
No. A red build is a broken build. CI cannot be *enforced* here (Free plan,
private repo), so this one is held by reviewers — and a reviewer who approves a
red PR has not reviewed it.

**How big should a PR be?**
Under ~400 changed lines. A 2,000-line PR is not reviewed, it is rubber-stamped.

**I pushed a secret.**
**Rotate the credential first**, then tell the Tech Lead and DevOps, then clean
up. Deleting the file in a later commit does not remove it from history.
[09](ops/environments.md#if-you-commit-a-secret).

**Can I force-push?**
On your own feature branch nobody has pulled, yes (`--force-with-lease`). On
`main`, `staging`, or `dev`, never.

---

## Stack and building

**Can we use Supabase instead of Express + Prisma?**
No. Building the API *is* what is being assessed — Supabase's generated API
removes most of the marks. Supabase is fine purely as a hosted Postgres that
Prisma connects to.
[01, Ruling 4](rules/ground-rules.md#ruling-4--the-stack-is-fixed).

**Can I use shadcn/ui? Zustand? a date library? this other UI kit?**
shadcn/ui: yes, encouraged. Anything else: ask the Tech Lead, who decides for
the whole repo. Every dev adding their own favourite library is how a
codebase becomes unmaintainable in nine days.

**The backend isn't ready. What do I build?**
Everything. Once the contract entry is merged the shape is known — build the
whole screen against a mock and flip a flag when the endpoint lands. The
frontend is never blocked by the backend.
[06](building/frontend.md#working-before-the-backend-exists).

**Can we use Server Actions yet?**
They are Class 40. Route handlers plus the API client work fine now; Server
Actions are a later refactor, not a prerequisite.
[10](building/build-order.md).

**Can we build our own login with JWT and bcrypt?**
Not yet — that is Class 38. Use Auth.js v5 (Class 37) now, behind a
`requireAuth` middleware seam so Class 38 is a one-function change. Teams that
improvise auth early build something insecure and rewrite it anyway.

**Do we need Docker now?**
No. Docker is Class 42. Deploy from git to Railway/Render today — your frontend
needs a live API in week 1.
[09](ops/environments.md#deploying-the-api-railway--render).

**Should we add realtime chat / notifications?**
Only as a stretch goal, never in your MVP. WebSockets is Class 43, Redis is
Class 44, and they may land after your freeze. A half-working realtime feature
costs more marks than no realtime feature.

**Where do `.env` values go, and why is mine not working?**
`.env.local` (frontend) / `.env` (backend), both git-ignored; keys with
placeholders go in the committed `.env.example`. If a value is missing the
backend tells you by name at startup — that is what `config/env.ts` is for.
Remember `NEXT_PUBLIC_` values are visible in the browser, so never a secret.

**Can I change the Prisma schema?**
Yes, through a PR, after telling the Tech Lead and the frontend owner of any
affected screen, with the contract updated in the same breath. What you must not
do alone is run `prisma migrate reset` on the shared dev database — it wipes
everyone's data.

**Why is my `price` giving a 400?**
HTML inputs give you strings. Use `z.coerce.number()`. This is the single most
common integration bug.

**Why does the list not update after I create something?**
You did not invalidate the query. `onSuccess: () => qc.invalidateQueries(...)`.
The second most common one is filters missing from the `queryKey`.

---

## Team and process

**Who decides X?**
The matrix in
[01](rules/ground-rules.md#decision-authority-matrix).
If you cannot tell which level a decision is, treat it as one level higher than
your instinct and ask.

**The designer hasn't given me the screen. Do I guess?**
No. Label the ticket `needs-design`, say so in standup, and pick up something
else. Guessing produces rework the PM then has to price.
[05, Handoff 1](rules/communication.md#handoff-1--uiux---frontend).

**Our Tech Lead is writing all the code.**
That is a task-assignment failure, not leadership. Split the work into vertical
slices with named owners, and remember the lead rotates weekly.
[04](rules/roles.md#how-work-is-split-vertical-slices-not-layers).

**One teammate isn't contributing.**
Raise it in the team first, then with the mentor with specifics — no commits
since a date, no standups, tickets unmoved. Do not quietly absorb their work and
say nothing until Demo Day; that helps nobody, least of all them.

**I'm stuck. When do I ask?**
After 2 hours on the same problem. Use the four-line format
([05](rules/communication.md#how-to-ask-a-question-that-gets-answered)),
tag the specific person, and switch to another ticket while you wait.

**When do I escalate to the mentor?**
After the team has tried, using the escalation template. Expect a reply within
24 hours on working days, so do not leave an L4 decision until the night before
a checkpoint.

**We have no PM / no designer / no DevOps person.**
The Tech Lead absorbs it, and the minimum bar still applies —
[04](rules/roles.md#if-a-role-is-unfilled). Write down at kickoff who
absorbed what. "We assumed someone was doing it" is not a defence.

**I'm the PM / designer / DevOps — how do I prove I contributed if I don't commit code?**
Your artifacts are your evidence: the validation write-up, the board history,
the Figma file, the CI workflows, the deploy docs. Table in
[11](standards/definition-of-done.md#evidence-for-non-coding-roles). Do your
work where it can be seen.

**We're behind. What do we cut?**
Scope, never quality. Four polished stories beat eight half-working ones. The PM
makes the cut, the mentor is informed, and you write down what you cut and why —
that is a strong Demo Day answer, not a weak one.
[10](building/build-order.md#if-you-are-behind).

**Is the demo really live? Can we show a recording?**
Live, on the production URL. Keep a recording only as a wifi-failure backup.

**Does everyone have to present?**
Yes, and each member gets a direct question about the part they claim to own.
That is why the contribution slide has to be accurate.
[11](standards/definition-of-done.md#demo-day).

---

## Still stuck?

1. Search this handbook — most answers are in it
2. Ask in `<team>-dev` with the four-line format
3. Ask in the cohort capstone channel — another team has probably hit it
4. Escalate to the mentor with the template

And if you find something in here that is wrong, unclear, or missing, say so.
Confusing documentation is a bug and we want to fix it.
