# Agent Development Guidelines

## Python Virtual Environment Requirement

- **Conda Environment Name**: `pillbox-backend`
- **Mandatory Rule**: All backend development, dependency management, testing, and script execution **MUST** use the `pillbox-backend` Conda environment.

### Usage

Before executing backend tasks or running the server, activate the environment:

```bash
conda activate pillbox-backend
```

Or run commands directly in the environment:

```bash
conda run -n pillbox-backend <command>
```
