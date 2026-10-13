// Jenkins pipeline: deploy this Shiny app to Posit Connect.
//
// posit-dev/connect#26353 CI/CD how-to. Package management is renv, and the manifest Connect
// deploys from is regenerated from that same environment so the two can never drift:
//   - renv::restore() installs the exact versions pinned in renv.lock (including rsconnect, the
//     deploy tool) into the project-local renv/library, so the job needs no root.
//   - rsconnect::writeManifest() rewrites content-dir/manifest.json from the restored library.
//     Connect reads manifest.json (not renv.lock) to rebuild the server-side environment, so
//     regenerating it keeps the deployed packages in step with the lockfile.
//   - deploy-to-connect.sh bundles content-dir (with the fresh manifest.json) and deploys to
//     Connect via the Connect Server API with an API key. It uses only curl and jq.
//
// Agent prerequisites: an Ubuntu 24.04 (noble) agent with R 4.5.x on PATH, plus curl and jq, and
// the system libraries the pinned binary packages link against (libcurl, libssl, libxml2, libicu,
// libpng, libjpeg, libtiff, libcairo, libfontconfig, libfreetype, libuv). renv.lock pins noble
// binaries, so a non-noble agent would fall back to source compilation (needing a toolchain).
// Configure in Jenkins before the first run:
//   - an environment variable CONNECT_SERVER = your Connect base URL *with a trailing slash*
//     (e.g. https://connect.example.com/). Set it globally (Manage Jenkins > System) or on the job.
//   - a "Secret text" credential with ID `connect-api-key` holding a Connect API key owned by a
//     publisher account. The pipeline binds it to CONNECT_API_KEY; never commit the key.

pipeline {
  agent any

  environment {
    CONNECT_SERVER          = "${env.CONNECT_SERVER}"
    CONNECT_API_KEY         = credentials('connect-api-key')
    CONTENT_DIRECTORY       = 'content-dir'
    UNIQ_NAME               = 'shiny-app-demo-cicd-jenkins'
    // Keep the literal __linux__/noble binary URL from renv.lock (don't let renv re-derive it).
    RENV_CONFIG_PPM_ENABLED = 'FALSE'
  }

  stages {
    stage('Restore R packages (renv)') {
      steps {
        sh 'R -e "renv::restore(prompt = FALSE)"'
      }
    }
    // Gate the deploy on fast unit tests of the app's data functions (no browser/network).
    // testthat is a CI-only tool, installed here rather than pinned in renv.lock so the
    // deployed manifest stays limited to the app's own runtime dependencies. A test failure
    // aborts the stage (non-zero exit) and the Write manifest / Deploy stages never run.
    stage('Test app data functions') {
      steps {
        sh '''
          set -eu
          R -e "renv::install('testthat', prompt = FALSE)"
          Rscript run-tests.R
        '''
      }
    }
    stage('Write Connect manifest') {
      steps {
        sh 'R -e "rsconnect::writeManifest(Sys.getenv(\'CONTENT_DIRECTORY\'))"'
      }
    }
    stage('Deploy to Connect') {
      steps {
        sh '''
          set -euo pipefail
          chmod +x ./deploy-to-connect.sh
          ./deploy-to-connect.sh
        '''
      }
    }
  }
}
