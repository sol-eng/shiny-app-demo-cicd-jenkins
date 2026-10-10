// Jenkins pipeline: test + deploy this Shiny app to Posit Connect.
//
// This is the validated working pipeline for the sol-eng CI/CD how-to (posit-dev/connect#26353).
//
// Agent prerequisites: R (4.5.x) on PATH, plus `curl` and `jq` (used by deploy-to-connect.sh).
// Configure in Jenkins before the first run:
//   - an environment variable CONNECT_SERVER = your Connect base URL *with a trailing slash*
//     (e.g. https://connect.example.com/). Set it globally (Manage Jenkins > System) or on the job.
//   - a "Secret text" credential with ID `connect-api-key` holding a Connect API key owned by a
//     publisher account. The pipeline binds it to CONNECT_API_KEY; never commit the key.
//
// Packages are installed from Posit Package Manager *binaries* into a writable per-build library,
// so the job needs no root and no system-library writes.

pipeline {
  agent any

  environment {
    CONNECT_SERVER    = "${env.CONNECT_SERVER}"
    CONNECT_API_KEY   = credentials('connect-api-key')
    CONTENT_DIRECTORY = 'content-dir'
    UNIQ_NAME         = 'shiny-app-demo-cicd-jenkins'
    R_LIBS_USER       = "${WORKSPACE}/.rlib"
  }

  stages {
    stage('Build, test, and deploy to Connect') {
      steps {
        sh '''
          set -euo pipefail
          mkdir -p "$R_LIBS_USER"
          # Disable renv auto-activation so install.packages targets the writable user library.
          rm -f .Rprofile
          Rscript -e '.libPaths(Sys.getenv("R_LIBS_USER")); options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest")); install.packages(c("shiny","jsonlite","ggplot2","stringr","DT","rsconnect"))'
          Rscript -e '.libPaths(Sys.getenv("R_LIBS_USER")); rsconnect::writeManifest(Sys.getenv("CONTENT_DIRECTORY"))'
          chmod +x ./deploy-to-connect.sh
          ./deploy-to-connect.sh
        '''
      }
    }
  }
}
