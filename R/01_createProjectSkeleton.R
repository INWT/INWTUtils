#' Create file structure
#'
#' @description Creates a useful file and folder structure. This includes:
#' \itemize{
#'   \item data (folder)
#'   \item reports (folder)
#'   \item rScripts (folder)
#'   \item .Rproj (optional; created with \code{\link{createProject}})
#' }
#' The infrastructure for a package can also be added optionally (created with
#' \code{\link{createPackage}}).
#'
#' @param dir character: Directory where the file structure is created, absolute
#' or relative to the current working directory. The current working directory
#' by default.
#' @param pkgName character: If \code{pkgName} is specified, a package with this
#' name is created.
#' @param pkgFolder character: Folder where the package (if created) should
#' live, relative to \code{dir}. "." per default, i.e., the project root.
#' @param rProject logical: Create Rproject file?
#' @param exampleScript logical: Create example script? (not yet used)
#' @param ... not used atm
#'
#' @examples createProjectSkeleton("tmp", rProject = TRUE)
#'
#' @export
createProjectSkeleton <- function(dir = ".",
                                  pkgName = NULL,
                                  pkgFolder = ".",
                                  rProject = TRUE,
                                  exampleScript = TRUE,
                                  ...) {

  if (dir != ".") {
    if (dir.exists(dir)) {
      message("Directory already exists and will be used.")
    } else {
      message(paste0("Creating '", dir, "/'"))
      dir.create(dir)
    }
  }

  dir <- addBackslash(dir)

  folders <- c("data", "reports", "RScripts")
  message(paste0("Creating directories: ", paste0(folders, collapse = ", ")))
  lapply(paste0(dir, folders), dir.create)

  if (exampleScript) {
    message("Writing example script")
    copyFile(dir, "exampleScript.R", "RScripts")
  }

  checkingScript <- readLines(system.file("00_checkCodeStyle.R",
                                          package = "INWTUtils"))

  if (!is.null(pkgName)) {
    createPackage(dir, pkgName, pkgFolder, ...)
    checkingScript[22] <- gsub("\\./",
                               addBackslash(pkgFolder),
                               checkingScript[22])
  } else {
    checkingScript <- checkingScript[-c(22, 52, 60:63, 67:68)]
  }

  if (rProject) {
    message("Creating R Project")
    createProject(!is.null(pkgName), pkgFolder, dir)
  }

  message("Writing script for style checking")
  writeLines(text = checkingScript,
             con = paste0(dir, "RScripts/00_checkCodeStyle.R"))

}


#' Copy file from inst
#' @description Copy a file from inst to the - per default - respective
#' directory relative to the project root
#' @param dir character: project root
#' @param origin character: name/path of file relative to inst
#' @param dest character: new path (path to directory or path with filename)
#' relative to project root
#' @param ... Further arguments passed to \code{\link[base]{file.copy}}
copyFile <- function(dir, origin, dest = origin, ...) {
  file.copy(from = system.file(origin, package = "INWTUtils"),
            to = paste0(dir, "/", dest),
            ...)
}


#' Create package with style test
#'
#' @description Creates a package, either directly into the directory specified
#' in \code{dir} or in a subfolder. Also creates an infrastructure
#' for \code{testthat}, a test for the package style and an .Rbuildignore.
#' An R project can be created separately with \code{\link{createProject}}.
#' Used by \code{\link{createProjectSkeleton}}.
#'
#' @param dir character: Directory
#' @param pkgName character: Package name
#' @param pkgFolder character: Folder where the package should live. \code{dir}
#' per default.
#' @param ... not used atm
#'
#' @examples
#' \dontrun{
#' createPackage(dir = "./", pkgName = "aTestPackage", pkgFolder = "package")
#' dir.create("tmp")
#' createPackage(dir = "tmp/", pkgName = "aTestPackage")
#' }
#'
#' @export
#'
createPackage <- function(dir, pkgName, pkgFolder = ".", ...) {

  dir <- addBackslash(dir)

  pkgFolder <- addBackslash(pkgFolder)
  pkgOnToplevel <- (pkgFolder %in% c("./", "/"))
  if (!pkgOnToplevel) dir.create(paste0(dir, pkgFolder))

  packageDir <- if (pkgOnToplevel) dir else paste0(dir, pkgFolder)

  message("Create package in temporary folder")
  # This is required since setup cannot create a package in a folder whose name
  # is not suited as a package name, even if the package gets another name

  tmpDir <- createTmpPackage(
    pkgName = pkgName,
    description = list(Suggests = "INWTUtils, lintr")
  )

  message("Copy files from temporary folder to package destination")
  file.copy(from = list.files(tmpDir, full.names = TRUE, all.files = TRUE, no.. = TRUE),
            to = packageDir,
            recursive = TRUE)

  unlink(tmpDir, recursive = TRUE)
}

createTmpPackage <- function(pkgName, description) {
  wd <- getwd()
  on.exit(setwd(wd))

  tmpDir <- tempdir()
  dir.create(path = paste0(tmpDir, "/", pkgName))
  tmpDir <- paste0(tmpDir, "/", pkgName)

  setwd(tmpDir)
  proj_set(tmpDir, force = TRUE)

  suppressWarnings(create_package(path = tmpDir, fields = description, rstudio = FALSE))
  suppressWarnings(use_testthat())

  copyFile(paste0(tmpDir, "/tests/testthat/"), "testForCodeStyle.R", "test-00_codeStyle.R")
  copyFile(tmpDir, "Rbuildignore", ".Rbuildignore")

  tmpDir
}


#' Create R project
#'
#' @description Creates an R project with useful configuration. If the project
#' contains a package, the respective options are set. The project is named
#' after the folder which contains it.
#' Used in \code{\link{createProjectSkeleton}}.

#' @param pkg logical: Does the project contain a package?
#' @param pkgFolder character: Folder where the package lives. "." per
#' default, i.e., \code{dir}.
#' @param dir character: Directory where the R project is created; current
#' working directory by default
#'
#' @examples
#' \dontrun{
#' createProject(pkg = FALSE, dir = "./")
#' dir.create("tmp")
#' createProject(pkg = TRUE, pkgOnToplevel = FALSE, dir = "tmp")}
#'
#' @export
#'
createProject <- function(pkg, pkgFolder = ".", dir = ".") {

  pkgFolder <- rmBackslash(pkgFolder)

  prefs <- c("Version: 1.0",
             "",
             "RestoreWorkspace: No",
             "SaveWorkspace: No",
             "AlwaysSaveHistory: No",
             "",
             "EnableCodeIndexing: Yes",
             "UseSpacesForTab: Yes",
             "NumSpacesForTab: 2",
             "Encoding: UTF-8",
             "",
             "RnwWeave: Sweave",
             "LaTeX: pdfLaTeX")
  if (pkg) prefs <- c(prefs,
                      "",
                      "BuildType: Package",
                      "PackageUseDevtools: Yes",
                      if (pkgFolder != ".") paste0("PackagePath: ", pkgFolder),
                      "PackageInstallArgs: --no-multiarch --with-keep.source",
                      "PackageRoxygenize: rd,collate,namespace,vignette")

  dir <- addBackslash(dir)

  projName <- (if (dir == "./") getwd() else dir) %>%
    strsplit("/") %>% unlist %>% `[`(length(.))

  writeLines(text = prefs,
             con = paste0(dir, projName, ".Rproj"))
}
