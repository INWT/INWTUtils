#' @importFrom devtools build check load_all
#' @importFrom magrittr %>%
#' @importFrom lintr Linter absolute_path_linter expect_lint_free lint
#' assignment_linter commas_linter function_argument_linter infix_spaces_linter
#'  Lint line_length_linter no_tab_linter object_length_linter object_usage_linter
#' spaces_left_parentheses_linter trailing_blank_lines_linter
#' @importFrom readr read_csv write_csv
#' @importFrom stats setNames
#' @importFrom usethis proj_set create_package use_testthat
#' @importFrom utils installed.packages remove.packages sessionInfo
NULL

globalVariables(".")
