# Agent Development Guidelines

## 1. Python Virtual Environment Requirement

- **Conda Environment Name**: `pillbox-backend`
- **Mandatory Rule**: All backend development, dependency management, testing, and script execution **MUST** use the `pillbox-backend` Conda environment.

### Usage

```bash
conda activate pillbox-backend
# Or run commands directly:
conda run -n pillbox-backend <command>
```

---

## 2. Git & Branching Workflow

- **Protected Main Branch**: The `main` branch is protected. Direct `git push origin main` is strictly prohibited.
- **Feature Branch Strategy**: All modifications must be developed on dedicated branches using standard naming (e.g., `feature/<feature-name>`, `fix/<issue-name>`).
- **Pull Request Protocol**: All changes must be merged into `main` via Pull Requests.
- **Commit Message Convention**: Commit messages must follow Conventional Commits (e.g., `feat:`, `fix:`, `chore:`, `build:`, `ci:`, `test:`) with clear, descriptive summaries.
- **Scope Separation**: Keep PRs atomic and independent. Infrastructure/CI changes and business features must not be arbitrarily mixed.

---

## 3. Continuous Integration & Quality Gate

- **Mandatory CI Checks**: All Pull Requests targeting `main` must pass the GitHub Actions CI status check (`Run Pytest`).
- **Zero Tolerance for Broken Tests**: A PR with failing tests or zero collected tests must not be merged.
- **Local Pre-push Verification**: Always execute and verify the full test suite locally before pushing:
  ```bash
  conda run -n pillbox-backend pytest -v
  ```

---

## 4. Container & Service Guidelines

- **Docker Consistency**: Ensure `backend/Dockerfile` and `docker-compose.yml` stay in sync with `requirements.txt` and the Python 3.10 runtime environment.
