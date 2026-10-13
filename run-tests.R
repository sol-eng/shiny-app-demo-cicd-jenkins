# Gate the deploy on fast unit tests of the app's data functions.
#
# Sourcing app.R defines its helper functions (clean_data, subset_data,
# adverse_event_plot) and attaches the packages they use. shinyApp() at the end
# of app.R only *builds* the application object; it does not start a server, so
# this is safe to source in a non-interactive test run.
library(testthat)
content <- Sys.getenv("CONTENT_DIRECTORY", unset = ".")
source(file.path(content, "app.R"))

# stop_on_failure => a failing test aborts with a non-zero exit, which fails the
# CI job and blocks the publish steps that follow (test-then-deploy gating).
testthat::test_file(file.path("tests", "test-helpers.R"), stop_on_failure = TRUE)
