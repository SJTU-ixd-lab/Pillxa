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

## 4. Container & Docker Deployment Guidelines

- **Docker Consistency**: Ensure `backend/Dockerfile` and `docker-compose.yml` stay in sync with `backend/requirements.txt` and the Python 3.10 runtime environment.
- **Port Mapping**:
  - Container internal port: `8000`
  - Host mapped port: `8011` (to avoid conflicts with other existing server services)
- **Standard Server Operations**:
  - Build & Start: `docker compose up -d --build`
  - Check Status: `docker compose ps`
  - View Logs: `docker compose logs -f backend`
  - Stop Service: `docker compose down`

---

## 5. Server Public Access & Reverse Proxy Architecture

- **Public Base URL**: `https://ixd.sjtu.edu.cn/pillxa-demo`
- **Architecture Topology**:
  `Client (HTTPS)` -> `Nginx (Port 443 / 80)` -> `Host (127.0.0.1:8011)` -> `Docker Container (Port 8000)`
- **Nginx Reverse Proxy Rule**:
  ```nginx
  location /pillxa-demo/ {
      proxy_pass http://127.0.0.1:8011/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
  }
  ```
- **Public Verification Endpoints**:
  - Health Check: `curl -i https://ixd.sjtu.edu.cn/pillxa-demo/health`
  - Today's Medication: `curl -i https://ixd.sjtu.edu.cn/pillxa-demo/medications/today`
