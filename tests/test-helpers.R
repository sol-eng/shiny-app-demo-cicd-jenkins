# Fast unit tests for the app's pure data functions. These exercise the data
# transformations that back the UI without launching a browser, hitting the
# OpenFDA API, or starting a Shiny server, so they run in any CI container
# (including non-root hosted agents) in a second or two. app.R is sourced by
# run-tests.R, which makes clean_data(), subset_data() and adverse_event_plot()
# available here.

test_that("clean_data turns an OpenFDA count response into a ranked data frame", {
  # jsonlite::fromJSON() simplifies the OpenFDA count array into a data frame, so
  # the real raw_data$results is a data frame with `term` and `count` columns.
  raw <- list(results = data.frame(
    term  = c("NAUSEA", "HEADACHE", "FATIGUE", "RASH"),
    count = c(40L, 30L, 20L, 10L),
    stringsAsFactors = FALSE
  ))

  df <- clean_data(raw)

  expect_s3_class(df, "data.frame")
  expect_setequal(colnames(df), c("Rank", "Event", "Count", "Frequency"))
  expect_equal(nrow(df), 4L)
  expect_equal(df$Rank, 1:4)
  expect_equal(df$Count, c(40, 30, 20, 10))
  expect_equal(df$Event[1], "NAUSEA")
  # Frequency is the count as a percentage of the total, formatted to 3 dp.
  expect_equal(df$Frequency[1], "40.000 %")
})

test_that("subset_data keeps only the top 10 events", {
  df <- data.frame(
    Rank      = 1:25,
    Event     = paste0("EVENT_", 1:25),
    Count     = 25:1,
    Frequency = sprintf("%.3f %%", (25:1) / sum(1:25) * 100),
    stringsAsFactors = FALSE
  )

  out <- subset_data(df)

  expect_equal(nrow(out), 10L)
  expect_equal(out$Rank, 1:10)
})

test_that("adverse_event_plot renders bars for the supplied events", {
  df <- subset_data(data.frame(
    Rank      = 1:12,
    Event     = paste0("EVENT_", 1:12),
    Count     = 12:1,
    Frequency = sprintf("%.3f %%", (12:1) / sum(1:12) * 100),
    stringsAsFactors = FALSE
  ))

  p <- adverse_event_plot(df, "keytruda")
  expect_s3_class(p, "ggplot")

  # Force ggplot to evaluate its aesthetic mappings against the data. Building the plot
  # (not merely constructing the object, which ggplot2 does lazily) is what catches a
  # mapping that references a column clean_data/subset_data no longer produces — a bug
  # that would otherwise surface only at renderPlot() time in the deployed app.
  bars <- ggplot2::layer_data(p, 1L)
  expect_equal(nrow(bars), nrow(df))
  expect_setequal(bars$y, df$Count)
})
