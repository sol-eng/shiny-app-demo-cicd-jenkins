// Jenkins pipeline: test + deploy this Shiny app to Posit Connect.
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
// Agent prerequisites: R on PATH (renv restores everything else), plus curl and jq.
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
        sh 'R -e "renv::restore(prompt = FALSE)"'
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
