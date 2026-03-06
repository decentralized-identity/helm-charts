# Contributing to DIF Helm Charts

## Developer Certificate of Origin (DCO)

This project requires that all commits are signed off to certify the [Developer Certificate of Origin](https://developercertificate.org/) (DCO). Pull requests will fail CI if any commit is missing a valid `Signed-off-by` line.

**To sign off your commits**, use the `-s` (or `--signoff`) flag:

```bash
git commit -s -m "feat(didwebvh-server): add configurable serviceAccount"
```

Or configure your editor/IDE to add sign-off by default. The sign-off line will use the name and email from your Git config (`user.name` and `user.email`).

## Development workflow

1. Fork the repo and create a branch from `main`.
2. Make your changes (one chart per PR when adding or changing charts).
3. Run `make check CHART=<chart-name>` before opening a PR.
4. Ensure every commit is signed off (see above).
5. Open a pull request; fill in the PR template and ensure CI passes.

See the main [README](README.md) for chart development commands and release process.
