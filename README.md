# DIF Helm Charts

This repository hosts Helm charts for projects hosted by the [Decentralized Identity Foundation](https://identity.foundation) (DIF).

## Quick Start

Add the Helm repository:

```bash
helm repo add dif https://decentralized-identity.github.io/helm-charts-dif
helm repo update
```

Search and install charts:

```bash
helm search repo dif
helm install my-release dif/didwebvh-server-py
```

**Note:** Replace the repo URL with your actual GitHub Pages URL once you enable GitHub Pages for this repo (e.g. `https://<org>.github.io/helm-charts-dif`).

## Development

### Development Environment

Install tools manually—versions are pinned in `hack/versions.env`. Run `make tools-check` to verify.

### Common Tasks

All commands require `CHART=<name>` (e.g., `didwebvh-server`).

```bash
# Testing & Validation
make check CHART=didwebvh-server           # Fast: lint + docs validation (pre-PR)
make test CHART=didwebvh-server            # Full: deps + lint + template + install in kind
make lint CHART=didwebvh-server            # Chart linting (helm + yaml + maintainers + version)
make install CHART=didwebvh-server          # Install test only (in kind cluster)

# Documentation
make docs CHART=didwebvh-server            # Regenerate/validate README from values.yaml annotations

# Tools
make tools-check                           # Verify tool versions match pins
make help                                  # Show all available targets
```

**Typical workflow:**

- Use `make check` during development for fast feedback
- Run `make test` before opening a PR for full validation

### Contributing

All commits must be [signed off](https://developercertificate.org/) (DCO). Use `git commit -s`. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Adding a New Chart

1. Create a new directory under `charts/<chart-name>/` with a standard Helm chart layout (`Chart.yaml`, `values.yaml`, `templates/`, etc.).
2. Add `ci/ci-values.yaml` with minimal values for chart-testing install (e.g. disable persistence).
3. Add `.helmignore` and ensure `Chart.yaml` has maintainers.
4. Open a PR; CI will lint and test the chart. One chart per PR.

### Release Process

- Merges to `main` (and the daily schedule) trigger the **Generate Release PRs** workflow, which opens release PRs for charts with unreleased commits (using [Conventional Commits](https://www.conventionalcommits.org/)).
- Merge a release PR (branch `release/<chart>-vX.Y.Z`) to publish: the **Publish Release** workflow tags the chart, packages it, and updates the Helm index on the `gh-pages` branch.

## License

See [LICENSE](LICENSE) in this repository.
