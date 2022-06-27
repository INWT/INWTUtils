test_that("checkStyle returns correct type", {
  testFile <- system.file("testScript_checkStyle.R", package = "INWTUtils")
  expect_true(file.exists(testFile))
  erg <- checkStyle(testFile, type = "script")
  expect_s3_class(erg, "lints")
  expect_true(all(unlist(lapply(erg,
                                function(x) class(x) == "lint"))))
})


test_that("checkStyle returns correct content", {
  erg <- checkStyle(system.file("testScript_checkStyle.R",
                                package = "INWTUtils"),
                    type = "script")
  expect_true(erg[[1]]$message == paste("Arguments without default value should",
                                        # nolint start
                                        "be listed before\n         arguments",
                                        # nolint end
                                        "with default value."))
  expect_true(erg[[2]]$message == "Use <-, not =, for assignment.")
  expect_true(erg[[3]]$message == "Commas should always have a space after.")
  expect_true(erg[[4]]$message == "Double whitespace.")
  expect_true(erg[[5]]$message == "Double whitespace.")
  expect_true(erg[[6]]$message == "Put spaces around all infix operators.")
  expect_true(erg[[7]]$message ==
                "Lines should not be more than 100 characters.")
  expect_true(erg[[9]]$message == paste("Variable and function names should",
                                        "not be longer than 30 characters."))
  expect_true(erg[[10]]$message == paste("Internal functions (addressed via",
                                        # nolint start
                                        ":::) should not be used."))
  # nolint end
  expect_true(erg[[11]]$message == paste("Place a space before left",
                                         "parenthesis, except in a function",
                                         "call."))
  expect_true(erg[[length(erg)]]$message == "Trailing blank lines are superfluous.")
})
