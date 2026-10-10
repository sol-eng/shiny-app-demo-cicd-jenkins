// Jenkins pipeline: test + deploy this Shiny app to Posit Connect.
//
// Follows the original repo pattern (posit-dev/connect#26353 CI/CD how-to):
//   - Package dependencies are restored with renv from the pinned renv.lock. renv auto-activates
//     via .Rprofile and installs into the project-local renv/library, so the job needs no root.
//   - deploy-to-connect.sh bundles content-dir (including its committed manifest.json) and deploys
//     to Connect via the Connect Server API with an API key. It uses only curl and jq.
//
// Agent prerequisites: R on PATH, plus curl and jq.
// Configure in Jenkins before the first run:
//   - an environment variable CONNECT_SERVER = your Connect base URL *with a trailing slash*
//     (e.g. https://connect.example.com/). Set it globally (Manage Jenkins > System) or on the job.
//   - a "Secret text" credential with ID `connect-api-key` holding a Connect API key owned by a
//     publisher account. The pipeline binds it to CONNECT_API_KEY; never commit the key.

pipeline {
  agent any

  environment {
    CONNECT_SERVER    = "${env.CONNECT_SERVER}"
    CONNECT_API_KEY   = credentials('connect-api-key')
    CONTENT_DIRECTORY = 'content-dir'
    UNIQ_NAME         = 'shiny-app-demo-cicd-jenkins'
  }

  stages {
    stage('Restore R packages (renv)') {
      steps {
        sh 'R -e "renv::restore()"'
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
