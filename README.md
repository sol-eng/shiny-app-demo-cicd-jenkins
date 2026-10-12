# Using Jenkins to deploy to Posit Connect

Posit Connect hosts a variety of data artifacts with different development life cycles. Whenever you
want to publish one of these artifacts to Connect, there are three paths you can follow:

 - Push-button deployment from the IDE (RStudio / Positron)
 - Git-backed deployment within Posit Connect
 - Programmatic deployment

This repository is an example of the third path, using **Jenkins** as a CI/CD pipeline to
deploy a Shiny application to Posit Connect.

## How it works

Package dependencies are managed with [`renv`](https://rstudio.github.io/renv/). The pinned
`renv.lock` records the app's packages plus `rsconnect` (the deploy tool); `renv::restore()`
installs them into the project-local `renv/library`, so the job needs no root.

Connect rebuilds the server-side environment from `manifest.json`, **not** from `renv.lock`, so the
pipeline regenerates `content-dir/manifest.json` from the restored environment with
`rsconnect::writeManifest()`. That keeps the deployed package set in step with the lockfile instead
of relying on a hand-committed manifest that can drift. `deploy-to-connect.sh` then bundles
`content-dir` (including the fresh `manifest.json`) and deploys it to Connect through the Connect
Server API with an API key (it uses only `curl` and `jq`).

## Running this in Jenkins

The pipeline is defined in [`Jenkinsfile`](Jenkinsfile). Point a Jenkins "Pipeline" job at this
repository (Pipeline script from SCM) and configure, before the first run:

- an environment variable **`CONNECT_SERVER`** — your Connect base URL *with a trailing slash*
  (e.g. `https://connect.example.com/`), set globally (Manage Jenkins > System) or on the job;
- a **Secret text** credential with ID **`connect-api-key`** holding a Connect API key owned by a
  publisher account. The pipeline binds it to `CONNECT_API_KEY`; the key is never committed.

The build agent needs **R** on `PATH` (renv restores the pinned package versions), plus `curl` and
`jq` (used by `deploy-to-connect.sh`).

The content item is created automatically on the first deploy (`deploy-to-connect.sh` looks it up by
`UNIQ_NAME` and creates it if missing), then updated on each subsequent run.
