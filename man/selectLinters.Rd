% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/02_checkStyle.R
\name{selectLinters}
\alias{selectLinters}
\title{List of linters to check INWT style conventions}
\usage{
selectLinters(type = NULL, excludeLinters = list(), addLinters = list())
}
\arguments{
\item{type}{character: Type of the file (\code{"script"}, \code{"pkgFuns"},
or \code{NULL})}

\item{excludeLinters}{character vector: Names of linters to be excluded}

\item{addLinters}{list: Named list of linter functions to be added}
}
\value{
Named list of linter functions
}
\description{
Used in \code{\link{checkStyle}}.

If you want to customize the set of tested linters, you can
\itemize{
  \item Specify the file \code{type} ("script" or "pkgFuns") to add linters
  \item exclude particular linters to the default linter set via
        \code{excludeLinters}
  \item add linters via \code{addLinters}
 }
\code{excludeLinters} is evaluated in the end, i.e., it affects all linters
included by default, file type, or \code{addLinters}.
}
\details{
The following linters are always included:
\itemize{
  \item\code{\link[INWTUtils]{args_no_default_first_linter}},
  \item\code{\link[lintr]{assignment_linter}},
  \item\code{\link[lintr]{commas_linter}},
  \item\code{\link[INWTUtils]{double_space_linter}},
  \item\code{\link[lintr]{infix_spaces_linter}},
  \item\code{\link[INWTUtils]{internal_function_linter}},
  \item\code{\link[lintr]{line_length_linter}},
  \item\code{\link[lintr]{no_tab_linter}},
  \item\code{\link[lintr]{object_length_linter}},
  \item\code{\link[INWTUtils]{options_linter}},
  \item\code{\link[lintr]{spaces_left_parentheses_linter}},
  \item\code{\link[lintr]{trailing_blank_lines_linter}},
  \item\code{\link[INWTUtils]{trailing_whitespaces_linter}},
}

The following linters are only included if \code{type = "pkgFuns"}:
\itemize{
  \item\code{\link{setwd_linter}},
  \item\code{\link{source_linter}}
}

The following linters are only included if \code{type = "script"}:
\itemize{
  \item (currently empty)
}
}
\examples{
selectLinters(type = "script",
            excludeLinters = c("object_length_linter",
                               "args_no_default_first_linter"),
            addLinters = list(setwd_l = setwd_linter,
                              source_l = source_linter))

# Code listing tested linters:
linterNames <- sort(names(selectLinters()))
packages <- unlist(lapply(linterNames,
                          function(name) {
                            erg <- help.search(name)
                            erg$matches$Package
                          }))
# nolint start
cat("#' \\\\itemize{\n#'",
    paste0("  \\\\item\\\\code{\\\\link[", packages, "]{", linterNames, "}}",
           collapse = ",\n#' "), "\n#' }")
# nolint end

}
