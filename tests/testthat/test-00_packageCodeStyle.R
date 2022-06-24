context("Package code style")


test_that("Code is lint-free", {
  res_r <- lint_dir("R", linters = selectLinters())
  expect_length(res_r, 0)
  res_tests <- lint_dir("tests", linters = selectLinters())
  expect_length(res_tests, 0)
})


test_that("Example script is lint-free", {
  exampleScript <-
    system.file("exampleScript.R", package = "INWTUtils")
  expect_length(checkStyle(exampleScript, type = "script"), 0)
})
