---
name: devops
description: Methodology for safely changing infrastructure, CI/CD pipelines, Docker/Compose configuration, environment/secrets setup, and deployment rollout. Use when the user is modifying docker-compose.yml, Dockerfiles, GitHub Actions workflows, environment variables, deployment scripts, or asking about rollout strategy. Do NOT use for application code changes — use /plan + /tdd for those.
---

## Philosophy

Infrastructure changes fail silently and often in production. Every change
must be tested locally before it can be trusted remotely. Rollback must be
defined before rollout begins.

## Domains

Apply the relevant sections for the type of change being made.

---

### Docker / Compose changes

**Before changing:**
- Identify which services are affected and their dependencies.
- Check volume mounts, network aliases, and port bindings for conflicts.

**Verify after changing:**
```bash
docker compose config          # validate compose file syntax
docker compose build           # confirm image builds cleanly
docker compose up -d           # start all services
docker compose ps              # confirm all services are healthy
docker compose logs --tail=50  # check for startup errors
```

**Done when:** all services reach healthy/running state with no errors in logs.

**Rollback:** `git checkout -- docker-compose.yml` and `docker compose up -d`.

---

### CI/CD pipeline changes (GitHub Actions)

**Before changing:**
- Identify the trigger (push, PR, schedule, manual) and confirm the change matches the intent.
- Check secrets referenced — are they defined in the repo/org settings?
- Check job ordering — does any job depend on another that might not have run?

**Verify after changing:**
- Dry-run locally if the action supports it (e.g., `act` for GitHub Actions).
- Push to a non-main branch and confirm the workflow triggers correctly.
- Check that failure modes are explicit — jobs should fail loudly, not silently pass.

**Common failure modes:**
| Failure | Check |
|---|---|
| Secret not found | Secret name in workflow matches repo settings exactly (case-sensitive) |
| Job skipped silently | `if:` condition too broad; add explicit failure step |
| Workflow runs on wrong branch | `branches:` filter too narrow or too wide |
| Build passes locally, fails CI | Missing env var or different runner OS |

---

### Secrets / environment configuration

**Rules (always):**
- Never commit real values — only update `.env.example` with key names and descriptions.
- When adding a new env var: add to `.env.example`, document in README, confirm default if optional.
- When rotating a secret: confirm all consumers are updated before the old value expires.

**Checklist for a new env var:**
- [ ] Added to `.env.example` with a descriptive comment
- [ ] Documented in README under Environment Variables
- [ ] Consumed in code via `os.getenv()` / config layer — not hardcoded
- [ ] Has a safe default if optional, or raises clearly at startup if required

---

### Deployment / rollout

**Order matters when migrations are involved:**

```
1. Run schema migrations (migrations before new code sees the DB)
2. Deploy new application code
3. Verify health endpoint / smoke test
4. If failure: rollback code first, then downgrade the migration if safe
```

**Zero-downtime checklist:**
- [ ] Migration is backward-compatible with the current running code
- [ ] New code is backward-compatible with the pre-migration schema
- [ ] Health check endpoint responds after deploy
- [ ] Rollback steps are defined and tested before starting

**Rollback decision:**
- Rollback code: always fast, always safe.
- Rollback migration: only if the downgrade is data-safe (no destructive column drops yet).

---

## Hand-off rules

- If infrastructure changes require application code changes too, use `/plan` to coordinate both.
- If a CI failure needs debugging, use `/diagnose` on the pipeline output.
- If the change is ready for release, hand off to the Release Manager agent.

## Related

- `/plan` — coordinate infra + application changes together
- `/diagnose` — debug a failing CI/CD run or Docker startup failure
- `/verify` — confirm application tests pass after infra change
