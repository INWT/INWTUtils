#' Check code style
#'
#' @description Checks a file for violations of the INWT style conventions using
#' \code{\link[lintr]{lint}}.
#' The \code{\link[lintr]{linters}} are partly taken from the package
#' \code{lintr}, and partly from this package.
#'
#' @param files character vector: One or more filepaths
#' @param linters list: Named list of used linter functions
#' @param ... Arguments passed to \code{\link{selectLinters}}
#'
#' @details Per default, the used linters are selected via
#' \code{\link{selectLinters}}. If you pass a list of linters directly via the
#' \code{linters} argument, all arguments passed to \code{\link{selectLinters}}
#' via \code{...} will be ignored.
#'
#' @examples \dontrun{
#' writeLines(con = "lintExample.txt",
#'            text = c("# Example script to demonstrate INWT's own linters",
#'            # nolint start
#'                     "",
#'                     "foo <- function(x = 1, y) {",
#'                     "  2*x + 1",
#'                     "}",
#'                     "",
#'                     paste0("# This  line contains  double spaces and is ",
#'                            "very long. The following lines will use = ",
#'                            "instead of <- and access an internal INWT ",
#'                            "function."),
#'                     "z = 1",
#'                     "print(INWTUtils:::scriptLinters())",
#'                     ""))
#'            # nolint end
#' checkStyle("lintExample.txt", type = "script")
#' unlink("lintExample.txt") # Remove file
#' }
#'
#' @export
#'
checkStyle <- function(files,
                       linters = selectLinters(...),
                       ...) {
  erg <- lapply(files, function(file) lint(file, linters))
  erg <- do.call(c, erg)
  class(erg) <- "lints"
  erg
}


#' List of linters to check INWT style conventions
#'
#' @description Used in \code{\link{checkStyle}}.
#'
#' If you want to customize the set of tested linters, you can
#' \itemize{
#'   \item Specify the file \code{type} ("script" or "pkgFuns") to add linters
#'   \item exclude particular linters to the default linter set via
#'         \code{excludeLinters}
#'   \item add linters via \code{addLinters}
#'  }
#' \code{excludeLinters} is evaluated in the end, i.e., it affects all linters
#' included by default, file type, or \code{addLinters}.
#'
#' @details The following linters are always included:
#' \itemize{
#'   \item\code{\link[lintr]{functione_argument_linter}},
#'   \item\code{\link[lintr]{assignment_linter}},
#'   \item\code{\link[lintr]{commas_linter}},
#'   \item\code{\link[INWTUtils]{double_space_linter}},
#'   \item\code{\link[lintr]{infix_spaces_linter}},
#'   \item\code{\link[INWTUtils]{internal_function_linter}},
#'   \item\code{\link[lintr]{line_length_linter}},
#'   \item\code{\link[lintr]{no_tab_linter}},
#'   \item\code{\link[lintr]{object_length_linter}},
#'   \item\code{\link[INWTUtils]{options_linter}},
#'   \item\code{\link[lintr]{spaces_left_parentheses_linter}},
#'   \item\code{\link[lintr]{trailing_blank_lines_linter}},
#'   \item\code{\link[INWTUtils]{trailing_whitespaces_linter}},
#' }
#'
#' The following linters are only included if \code{type = "pkgFuns"}:
#' \itemize{
#'   \item\code{\link{setwd_linter}},
#'   \item\code{\link{source_linter}}
#' }
#'
#' The following linters are only included if \code{type = "script"}:
#' \itemize{
#'   \item (currently empty)
#' }
#'
#' @param type character: Type of the file (\code{"script"}, \code{"pkgFuns"},
#' or \code{NULL})
#' @param excludeLinters character vector: Names of linters to be excluded
#' @param addLinters list: Named list of linter functions to be added
#'
#' @return Named list of linter functions
#'
#' @examples
#' selectLinters(type = "script",
#'             excludeLinters = c("object_length_linter", "function_argument_linter"),
#'             addLinters = list(setwd_l = setwd_linter,
#'                               source_l = source_linter))
#'
#' # Code listing tested linters:
#' linterNames <- sort(names(selectLinters()))
#' packages <- unlist(lapply(linterNames,
#'                           function(name) {
#'                             erg <- help.search(name)
#'                             erg$matches$Package
#'                           }))
#' # nolint start
#' cat("#' \\itemize{\n#'",
#'     paste0("  \\item\\code{\\link[", packages, "]{", linterNames, "}}",
#'            collapse = ",\n#' "), "\n#' }")
#' # nolint end
#'
#' @export
#'
selectLinters <- function(type = NULL,
                          excludeLinters = list(),
                          addLinters = list()) {

  if (is.null(type)) type <- ""

  linters <- generalLinters()

  if (type == "script") linters <- c(linters, scriptLinters())
  if (type == "pkgFuns") linters <- c(linters, pkgFunLinters())

  linters <- c(linters, addLinters)
  linters <- linters[setdiff(names(linters), excludeLinters)]

  return(linters[unique(names(linters))])
}


#' General linters
#' @description Linters used by default
generalLinters <- function() {
  list(function_argument_linter = function_argument_linter(),
       assignment_linter = assignment_linter(),
       commas_linter = commas_linter(),
       double_space_linter = double_space_linter(),
       infix_spaces_linter = infix_spaces_linter(),
       internal_function_linter = internal_function_linter(),
       line_length_linter = line_length_linter(100),
       no_tab_linter = no_tab_linter(),
       object_length_linter = object_length_linter(30L),
       sapply_linter = sapply_linter(),
       spaces_left_parentheses_linter =
         spaces_left_parentheses_linter(),
       trailing_blank_lines_linter = trailing_blank_lines_linter(),
       trailing_whitespaces_linter = trailing_whitespaces_linter())
}


#' Package function linters
#' @description Linters for files containing (package) functions
pkgFunLinters <- function() {
  list(setwd_linter = setwd_linter(),
       source_linter = source_linter(),
       options_linter = options_linter())
}


#' Script linters
#' @description Linters for files of type script
scriptLinters <- function() {
  list()
}
