# Templates

Copy-paste scaffolding. Do not hand-write any of this.

| File | Goes to | Notes |
|---|---|---|
| `scripts/git-hooks/pre-push` | `scripts/git-hooks/` | Blocks pushes to `main`/`staging`/`dev` |
| `scripts/setup-hooks.sh` | `scripts/` | **Every dev runs this once per clone** |
| `scripts/setup-hooks.ps1` | `scripts/` | Windows PowerShell equivalent |
| `github/pull_request_template.md` | `.github/` | Loads automatically into every PR |
| `github/ISSUE_TEMPLATE/*.md` | `.github/ISSUE_TEMPLATE/` | User story, bug, task |
| `github/workflows/ci-frontend.yml` | `.github/workflows/` | Frontend repo only |
| `github/workflows/ci-backend.yml` | `.github/workflows/` | Backend repo only — spins up Postgres |
| `github/workflows/assign-reviewers.yml` | `.github/workflows/` | Replaces inert `CODEOWNERS` |
| `github/reviewers.json` | `.github/` | Ownership map the workflow reads |
| `REVIEWERS.md` | repo root | Human-readable version of the same map |
| `CONTRIBUTING.md` | repo root | Team handbook — fill in the placeholders |
| `README_TEMPLATE.md` | repo root, as `README.md` | |
| `API_CONTRACT_TEMPLATE.md` | backend repo, as `docs/api.md` | |
| `env/frontend.env.example` | frontend repo, as `.env.example` | |
| `env/backend.env.example` | backend repo, as `.env.example` | |
| `STANDUP_TEMPLATE.md` | pin in the team channel | |
| `PEER_EVAL_TEMPLATE.md` | submitted privately to the mentor | |

Install order and the exact commands: [`../ops/repo-setup.md`](../ops/repo-setup.md).

## After copying

Search for and replace every placeholder — a shipped `<PROJECT>` or
`TECH_LEAD_USERNAME` is an easy thing for a reviewer to notice:

```bash
grep -rn "<PROJECT>\|<REPO>\|<project>\|_USERNAME" . --exclude-dir=node_modules
```

Then run `bash scripts/setup-hooks.sh` and verify the hook actually blocks a
push to `main`.
