test_that("showLibs returns correct type", {
  expect_equal(showLibs("pkgDoesNotExist123"),
               list(pkgDoesNotExist123 = "Package not installed"))
  expect_type(showLibs(), "list")
  someLibs <- c("ggplot2", "INWTUtils", "stats", "lintr")
  expect_named(showLibs(someLibs), someLibs)
  expect_true(lapply(showLibs(someLibs), function(x) {
    class(x) == "character"
  }) %>% unlist %>% all)
})
