% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/04_controlWorkspaceLibpath.R
\name{showLibs}
\alias{showLibs}
\title{List libraries where package is installed}
\usage{
showLibs(packages = NULL)
}
\arguments{
\item{packages}{character: vector package names}
}
\value{
Named list with one entry for each package. The entries list all
libraries of the search path where the package is installed.
}
\description{
List all libraries where packages are installed
}
\examples{
showLibs(c("lintr", "INWTUtils", "nonexistentPackage"))
}
