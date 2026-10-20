# IOTBTECH 2026 — Full-Stack Capstone Handbook

Guidelines for the 2026 full-stack capstone: repository standards, git workflow,
team roles and handoffs, what to build at each stage of the course, and how the
project is assessed.

### 📖 Read it here: <https://iotb-tech.github.io/iotbtech-capstone-handbook-2026/>

Start with **Start here** (3 minutes), then follow the reading path for your
role. Most questions are answered in the **FAQ** — check it before asking.

Every team also has a dated fix-it list under **Fix this now**.

---

## What's in here

| Path | Contents |
|---|---|
| `docs/index.md` | Start here — the non-negotiables and the role reading paths |
| `docs/fix-now.md` | Per-team remediation, with the deadline |
| `docs/one-pager.md` | One printable page of the rules that matter |
| `docs/rules/` | Decision authority, git workflow, roles & RACI, communication |
| `docs/building/` | Build order and class gating, frontend, backend, API contract |
| `docs/ops/` | Repository setup, environments, secrets, deployment |
| `docs/standards/` | Definition of done, rubric, Demo Day |
| `docs/templates/` | Copy-paste scaffolding: PR/issue templates, CI, hooks, `.env.example` |

## Editing

Edit the markdown in `docs/`, push to `main`, and the site redeploys itself
(`.github/workflows/deploy-docs.yml`). The build runs `mkdocs build --strict`,
so a broken internal link fails CI instead of shipping.

Optional local preview:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve          # http://127.0.0.1:8000
```

> **Note:** this repository is public so that GitHub Pages works on the
> organisation's Free plan. It contains no credentials. The capstone **project**
> repositories are private.
