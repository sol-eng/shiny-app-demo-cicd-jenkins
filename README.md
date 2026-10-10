# Using Jenkins to test & deploy to Posit Connect

Posit Connect hosts a variety of data artifacts with different development life cycles. Whenever you
want to publish one of these artifacts to Connect, there are three paths you can follow:

 - Push-button deployment from the IDE (RStudio / Positron)
 - Git-backed deployment within Posit Connect
 - Programmatic deployment

This repository is an example of the third path, using **Jenkins** as a CI/CD pipeline to test and
deploy a Shiny application to Posit Connect.

## Running this in Jenkins

The pipeline is defined in [`Jenkinsfile`](Jenkinsfile). Point a Jenkins "Pipeline" job at this
repository (Pipeline script from SCM) and configure, before the first run:

- an environment variable **`CONNECT_SERVER`** — your Connect base URL *with a trailing slash*
  (e.g. `https://connect.example.com/`), set globally (Manage Jenkins > System) or on the job;
- a **Secret text** credential with ID **`connect-api-key`** holding a Connect API key owned by a
  publisher account. The pipeline binds it to `CONNECT_API_KEY`; the key is never committed.

The build agent needs **R** (4.5.x) on `PATH`, plus `curl` and `jq`. R packages are installed from
Posit Package Manager binaries into a per-build library, so no root is required.

The content item is created automatically on the first deploy (`deploy-to-connect.sh` looks it up by
`UNIQ_NAME` and creates it if missing), then updated on each subsequent run.
