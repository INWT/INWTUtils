#' @title INWT's own linters
#'
#' @name INWTLinters
#'
#' @description Linters added by INWT. Usually not called directly but used
#' with \code{\link[lintr]{lint}}.
#'
#' @examples \dontrun{
#' writeLines(con = "lintExample.txt",
#' # nolint start
#'            text = c("# Example script to demonstrate INWT's own linters",
#'                     "",
#'                     "source(anotherScript.R)",
#'                     "",
#'                     "foo <- function(x = 1, y) {",
#'                     "  2 * x + 1  ",
#'                     "}",
#'                     "",
#'                     "# This  line contains  double spaces",
#'                     "",
#'                     "print(INWTUtils:::scriptLinters())"))
#' # nolint end
#' lintr::lint("lintExample.txt",
#'      linters = list(argsWithoutDefault = args_no_default_first_linter,
#'                     doubeWhitespace = double_space_linter,
#'                     sourceLinter = source_linter))
#' }
#'
NULL


#' @describeIn INWTLinters Arguments without default values should come before
#' arguments with default values.
#' @export
args_no_default_first_linter <- function() {

  Linter(function(source_file) {

  pattern <- paste0("function\\([^\\)]*[A-z0-9_\\. '\"]+=[A-z0-9_\\. '\"]+,",
                    "[ ]*",
                    "[A-z0-9_\\. '\"]+[^(\\.\\.\\.)][\\),]+")
  ## Argument with default value
  # String "function("
  # Any number of characters which are not ")"
  # At least one character of A-z, 0-9, "_", ".", space, and quotes (name of an
    # argument)
  # Exaclty one "="
  # Default value of the argument
  # Comma separating this argument from the next one
  ## Arbitrary number of spaces
  ## Argument without default value
  # Name of an argument
  # NOT "..." (since this would be allowed)
  # Closing bracket or comma (without having defined a default value)

  # Problems within lines
  idsWithin <- grep(pattern, source_file$file_lines)

  # Problems over two lines
  pastedText <- lapply(1:(length(source_file$file_lines) - 1),
                       function(x) paste(source_file$file_lines[x],
                                         source_file$file_lines[x + 1]))

  idsMult <- grep(pattern, pastedText)

  # Remove double-counted problems
  ids <- c(idsWithin, setdiff(idsMult, c(idsWithin - 1))) %>% unique

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = "Arguments without default value should be listed before
         arguments with default value.")
  })},
  "args_no_default_first_linter")
}


#' @describeIn INWTLinters Are there double whitespaces?
#' @export
double_space_linter <- function() {
  Linter(function(source_file) {

  ids <- grep("([^#' ]+.*[^ ]+ {2,}[^( +#$)])|(^# \\w {2,})",
              source_file$file_lines)
  # At least one character which is neither # nor '
  # Any characters
  # At least one character which is not space
  # At least two spaces
  # ...not directly followed by some spaces and a hash
  # OR: Starting with #, then space, then word character, then at least two
  # spaces
  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = "Double whitespace.")
  })},
  "double_space_linter")
}


#' @describeIn INWTLinters Internal functions should not be used since there is
#' in general a reason why they have not been exported by the package author.
#' They may not have been tested outside the context of the function they are
#' used in.
#' @export
internal_function_linter <- function() {
  Linter(function(source_file) {

  # nolint start
  ids <- grep(paste0(exceptInComments(), ":::"), source_file$file_lines)
  # nolint end

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         # nolint start
         message = "Internal functions (addressed via :::) should not be used.")
         # nolint end
  })},
  "internal_function_linter")
}


#' @describeIn INWTLinters Changing the working directory in package functions
#' can have unexpected side effects. (only for package functions)
#' @export
setwd_linter <- function() {
  Linter(function(source_file) {

  ids <- grep(paste0(exceptInComments(), "setwd\\("), source_file$file_lines)
  # Starting with arbitrary number of characters which are NOT # or quotes (to
    # exclude comments and quoted text)
  # String "setwd("

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = "Avoid side effects caused by setwd.")
  })},
  "setwd_linter")
}


#' @describeIn INWTLinters Sourcing files in package functions can have
#' unexpected side effects. (only for package functions)
#' @export
source_linter <- function() {
  Linter(function(source_file) {

  ids <- grep(paste0(exceptInComments(), "source\\("), source_file$file_lines)
  # Starting with arbitrary number of characters which are NOT # or quotes (to
    # exclude comments and quoted text)
  # String "source("

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = "Don't use source in package functions.")
  })},
  "source_linter")
}


#' @describeIn INWTLinters Changing options in package functions can have
#' unexpected side effects and is not visible from the outside. (only for
#' package functions)
#' @export
options_linter <- function() {
  Linter(function(source_file) {

  ids <- grep(paste0(exceptInComments(), "options\\("), source_file$file_lines)
  # Starting with arbitrary number of characters which are NOT # or quotes (to
  # exclude comments and quoted text)
  # String "options("

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = "Don't use options() in package functions.")
  })},
  "options_linter")
}


#' @describeIn INWTLinters The automatic simplification performed by
#' \code{\link[base]{sapply}} introduces uncertainty. If the input changes, the
#' output can change unexpectedly and the code crashes. Replace it with
#' \code{\link[base]{sapply}}. If you use \code{sapply} with
#' \code{simplify = FALSE}, it is equivalent to \code{lapply} anyway.
#' @export
sapply_linter <- function() {
  Linter(function(source_file) {

  ids <- grep(paste0(exceptInComments(), "sapply\\("), source_file$file_lines)

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = paste("Don't use sapply. It can simplify the output in an",
                         "unexpected way. Choose lapply."))
  })},
  "sapply_linter")
}



#' @describeIn INWTLinters Trailing whitespaces are superfluos. In contrast to
#' \code{\link[lintr]{trailing_whitespace_linter}}, this function detects
#' whitespaces after \code{\link[dplyr]{\%>\%}} only if there are at least two
#' (since one whitespace is inserted automatically after
#' \code{\link[dplyr]{\%>\%}}).
#' @export
trailing_whitespaces_linter <- function() {
  Linter(function(source_file) {

  ids <- grep("([^(%>%)(#') ] +$)|(%>% {2,})|(#' {2,})$", source_file$file_lines)
  # Space at the end of string
  # Or: two spaces after pipe operator (at the end of the string)

  lapply(ids, function(id) {
    Lint(filename = source_file$filename,
         line_number = id,
         column_number = 1L,
         type = "style",
         message = "Trailing whitespaces.")
  })},
  "trailing_whitespaces_linter")
}


#' First part of a regular expression to exclude the pattern if it appears in
#' a comment
#' @description Must be pasted together with the actual pattern that should be
#' found only outside comment (and roxygen comments).
exceptInComments <- function() {
  "^[^#\'\"]*"
}
