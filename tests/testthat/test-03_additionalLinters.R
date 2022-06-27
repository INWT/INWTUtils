test_that("args_no_default_first_linter", {
  testFile <- system.file("testScript_args_without_default.R", package = "INWTUtils")
  expect_true(file.exists(testFile))
  erg <- lint(testFile,
              linters = list(argsWithoutDefault = args_no_default_first_linter))
  expect_equal(lapply(erg, function(lint) lint$line_number) %>% unlist,
               c(9, 13, 15, 19, 23, 26, 29, 33))
})


test_that("args_no_default_first_linter (only within line)", {
  # nolint start
  inputWrong <- list(filename = "An example object",
                     file_lines = c("function(arg1 = TRUE, arg2)",
                                    "function(arg1 = 'aString', arg2, arg3)",
                                    "function(arg1, arg2 = TRUE, arg3) { }",
                                    "function(arg1 = 1, arg2, arg3 = 'aString')",
                                    "function(arg1 = TRUE, arg.2 = 123, arg3)"))
  # nolint end
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("function(arg1 = 2)",
                                      "function(arg1)",
                                      "function(arg1 = 2, arg_2 = 'string')",
                                      "function(arg_1, arg2 = TRUE)",
                                      "function(arg1, arg2 = TRUE)",
                                      "function(arg1, arg2)",
                                      "function(arg1, arg2 = 1, ...)",
                                      "function(arg1 = TRUE, ...)"))
  expect_true(lapply(args_no_default_first_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(args_no_default_first_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(args_no_default_first_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(args_no_default_first_linter(inputCorrect) %>% length, 0)
})


test_that("double_space_linter", {
  # nolint start
  inputWrong <- list(filename = "An example object",
                     file_lines = c("# A header line with faulty  double space  #",
                                    "Simple text with  double whitespace",
                                    "  indented text  with double whitespace",
                                    "  # Commented  text",
                                    "  # Indented  line  commented out",
                                    "x <-  3",
                                    "  x <-  3",
                                    "# A  comment with whitespace after first word",
                                    "mean(x) # Comment  with double whitespace",
                                    "    x <- 3 #  indented and commented",
                                    "#'   \"# This is an example  document violating style conventions\","))
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("# A header line ending with spaces and hash  #",
                                      "# A header line ending with many spaces and hash       #",
                                      "Normal text",
                                      "  ",
                                      "  indented text",
                                      "#'   An indented roxygen comment",
                                      "  # Indented line commented out",
                                      "  #   Indented line commented out",
                                      "    x <- 3",
                                      "#'   \"# This is an example document violating style conventions\",",
                                      "#   \"# This is an example document violating style conventions\","))
  # nolint end
  expect_true(lapply(double_space_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(double_space_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(double_space_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(double_space_linter(inputCorrect) %>% length, 0)
})


test_that("internal_function_linter", {
  inputWrong <- list(filename = "An example object",
                     # nolint start
                     file_lines = c("INWTpackage:::foo",
                                    "anINWTpkg:::foo",
                                    "some code anINWTpkg:::foo",
                                    "INWTpkg:::foo(",
                                    "INWT some test dplyr:::foo"))
  # nolint end
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("INWTpkg::foo",
                                      "# somePkg:::someFun",
                                      "#' @examples INWTpkg:::someFun",
                                      "#' INWTpkg:::someFun"))
  expect_true(lapply(internal_function_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(internal_function_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(internal_function_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(internal_function_linter(inputCorrect) %>% length, 0)
})


test_that("setwd_linter", {
  # nolint start
  inputWrong <- list(filename = "An example object",
                     file_lines = c("setwd(path)",
                                    'setwd("path"',
                                    "  setwd(path)"))
  # nolint end
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("# Comment with the word setwd",
                                      "#' Roxygen comment containing setwd",
                                      "some code 123 # comment with setwd("))
  expect_true(lapply(setwd_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(setwd_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(setwd_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(setwd_linter(inputCorrect) %>% length, 0)
})


test_that("source_linter", {
  # nolint start
  inputWrong <- list(filename = "An example object",
                     file_lines = c("source(file)",
                                    'source("file"',
                                    "  source(file)"))
  # nolint end
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("# Comment with the word source",
                                      "#' Roxygen comment containing source",
                                      "some code 123 # comment with source(",
                                      paste0("PackageInstallArgs: --no-multiarch",
                                             "--with-keep.source")))
  expect_true(lapply(source_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(source_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(source_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(source_linter(inputCorrect) %>% length, 0)
})


test_that("options_linter", {
  # nolint start
  inputWrong <- list(filename = "An example object",
                     file_lines = c("options(scipen = 999)",
                                    'options(editor = "nedit")',
                                    "  options(warn = FALSE)"))
  # nolint end
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("# Comment with the word options",
                                      "#' Roxygen comment containing options",
                                      "some code 123 # comment with options("))
  expect_true(lapply(options_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(options_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(options_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(options_linter(inputCorrect) %>% length, 0)
})


test_that("sapply_linter", {
  inputWrong <- list(filename = "An example object",
                     file_lines = c("sapply(1:5, function(x)",
                                    " %>% sapply(FUN = "))
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("# sapply(",
                                      "#' sapply(",
                                      "'sapply('",
                                      '"sapply(',
                                      "some code # sapply("))
  expect_true(lapply(sapply_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(sapply_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(sapply_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(sapply_linter(inputCorrect) %>% length, 0)

})


test_that("trailing_whitespaces_linter", {
  # nolint start
  inputWrong <- list(filename = "An example object",
                     file_lines = c("x <- 1  ",
                                    "x <- 1 ",
                                    "dat %>%  ",
                                    "#'  ",
                                    "x <- 5 %>%  ",
                                    " x  "))
  # nolint end
  inputCorrect <- list(filename = "An example object",
                       file_lines = c("x <- 1",
                                      "x <- 5 %>% ",
                                      "#' ",
                                      "    ",
                                      "   ",
                                      "  "))
  expect_true(lapply(trailing_whitespaces_linter(inputWrong),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(trailing_whitespaces_linter(inputWrong) %>% length,
               inputWrong$file_lines %>% length)
  expect_true(lapply(trailing_whitespaces_linter(inputCorrect),
                     function(x) class(x) == "lint") %>% unlist %>% all)
  expect_equal(trailing_whitespaces_linter(inputCorrect) %>% length, 0)
})
