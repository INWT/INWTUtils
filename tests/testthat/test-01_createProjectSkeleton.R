tmpdir <- tempdir()
if (interactive()) {
  if (dir.exists("../temp")) unlink("../temp", recursive = TRUE)
  dir.create("../temp")
  tmpdir <- "../temp"
}

test_that("createProjectSkeleton does not produce any errors", {
  expect_error(invisible(capture.output(
    createProjectSkeleton(paste0(tmpdir, "/tmp1")), NA)), NA)
  expect_error(invisible(capture.output(
    createProjectSkeleton(paste0(tmpdir, "/tmp2"),
                          pkgName = "aTestPackage"),
    NA)), NA)
  expect_error(invisible(capture.output(
    createProjectSkeleton(paste0(tmpdir, "/tmp3"),
                          pkgName = "aTestPackage",
                          pkgFolder = "package"),
    NA)), NA)
  expect_error(invisible(capture.output(
    createProjectSkeleton(paste0(tmpdir, "/tmp4/"),
                          rProject = TRUE),
    NA)), NA)
  expect_error(invisible(capture.output(
    createProjectSkeleton(paste0(tmpdir, "/tmp5"),
                          pkgName = "aTestPackage",
                          rProject = TRUE),
    NA)), NA)
  expect_error(invisible(capture.output(
    createProjectSkeleton(paste0(tmpdir, "/tmp6/"),
                          pkgName = "aTestPackage",
                          pkgFolder = "package",
                          rProject = TRUE),
    NA)), NA)
})


test_that("createProjectSkeleton creates correct files (absolute path)", {
  dir.create(paste0(tmpdir, "/tmpAbs"))

  absPath <- normalizePath(paste0(tmpdir, "/tmpAbs"))

  invisible(capture.output(createProjectSkeleton(absPath,
                                                 pkgName = "aTestPackage",
                                                 pkgFolder = ".",
                                                 rProject = FALSE)))
  expect_true(file.exists(paste0(absPath)))
  expect_true(file.exists(paste0(absPath, "/data")))
  expect_true(file.exists(paste0(absPath, "/reports")))
  expect_true(file.exists(paste0(absPath, "/RScripts")))
  expect_true(file.exists(paste0(absPath, "/RScripts/exampleScript.R")))
  expect_true(file.exists(paste0(absPath, "/RScripts/00_checkCodeStyle.R")))
  expect_true(file.exists(paste0(absPath, "/.Rbuildignore")))

  expect_equal(readLines(paste0(absPath, "/RScripts/00_checkCodeStyle.R"))[22],
               'PKG_DIR <- "./"')
})


test_that("createProjectSkeleton creates correct files", {

  invisible(capture.output(createProjectSkeleton(paste0(tmpdir, "/tmp7"),
                                                 pkgName = "aTestPackage",
                                                 pkgFolder = "package",
                                                 rProject = TRUE)))
  expect_true(file.exists(paste0(tmpdir, "/tmp7")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/data")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/reports")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/RScripts")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/RScripts/exampleScript.R")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/RScripts/00_checkCodeStyle.R")))
  # Package files
  expect_true(file.exists(paste0(tmpdir, "/tmp7/package")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/package/DESCRIPTION")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/package/tests/testthat.R")))
  expect_true(file.exists(paste0(
    tmpdir, "/tmp7/package/tests/testthat/test-00_codeStyle.R")))
  expect_true(file.exists(paste0(tmpdir, "/tmp7/package/.Rbuildignore")))
  # rProject
  expect_true(file.exists(paste0(tmpdir, "/tmp7/tmp7.Rproj")))

  expect_equal(readLines(paste0(tmpdir,
                                "/tmp7/RScripts/00_checkCodeStyle.R"))[22],
               'PKG_DIR <- "package/"')
})


test_that("Style checking script if there is no package", {
  invisible(capture.output(createProjectSkeleton(paste0(tmpdir, "/tmp7a"),
                                                 rProject = FALSE)))
  expect_true(file.exists(paste0(tmpdir, "/tmp7a")))
  checkingScript <- readLines(paste0(tmpdir,
                                     "/tmp7a/RScripts/00_checkCodeStyle.R"))
  expect_length(checkingScript, 71)
  expect_equal(checkingScript[22],
               'PATH_PURL_FILES <- "purlFiles/"')
})


test_that("createProject creates correct files - absolute path", {
  dir.create(paste0(tmpdir, "/tmp8"))

  createProject(pkg = FALSE, dir = paste0(tmpdir, "/tmp8"))
  expect_true(file.exists(paste0(tmpdir, "/tmp8/tmp8.Rproj")))
  expect_length(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj")), 13)
  unlink(paste0(tmpdir, "/tmp8/tmp8.Rproj"), TRUE, TRUE)

  createProject(pkg = TRUE, dir = paste0(tmpdir, "/tmp8"))
  expect_true(file.exists(paste0(tmpdir, "/tmp8/tmp8.Rproj")))
  expect_length(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj")), 18)
  expect_equal(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj"))[15],
               "BuildType: Package")
  expect_equal(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj"))[17],
               "PackageInstallArgs: --no-multiarch --with-keep.source")
  unlink(paste0(tmpdir, "/tmp8/tmp8.Rproj", TRUE, TRUE))

  createProject(pkg = TRUE, pkgFolder = "package", paste0(tmpdir, "/tmp8"))
  expect_true(file.exists(paste0(tmpdir, "/tmp8/tmp8.Rproj")))
  expect_length(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj")), 19)
  expect_equal(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj"))[15],
               "BuildType: Package")
  expect_equal(readLines(paste0(tmpdir, "/tmp8/tmp8.Rproj"))[17],
               "PackagePath: package")
})


test_that("createPackage creates correct files - pkg on top level", {

  dir.create(paste0(tmpdir, "/tmp9"))

  invisible(capture.output(createPackage(dir = paste0(tmpdir, "/tmp9"),
                                         pkgName = "testPackage")))
  expect_true(file.exists(paste0(tmpdir, "/tmp9/.Rbuildignore")))
  expect_equal(readLines(paste0(tmpdir, "/tmp9/.Rbuildignore")),
               c("^.+\\.Rproj$", "^\\.Rproj\\.user$", "^RScripts$", "^reports$"))
  expect_true(file.exists(paste0(tmpdir, "/tmp9/DESCRIPTION")))
  expect_equal(readLines(paste0(tmpdir, "/tmp9/DESCRIPTION"))[1],
               "Package: testPackage")
  expect_true(file.exists(paste0(tmpdir, "/tmp9/NAMESPACE")))
  expect_true(file.exists(paste0(tmpdir, "/tmp9/R")))
  expect_true(file.exists(paste0(tmpdir, "/tmp9/tests/testthat.R")))
  expect_true(file.exists(paste0(tmpdir,
                                 "/tmp9/tests/testthat/test-00_codeStyle.R")))
})


test_that("createPackage creates correct files - pkg in own folder", {
  dir.create(paste0(tmpdir, "/tmp0"))
  invisible(capture.output(createPackage(dir = paste0(tmpdir, "/tmp0"),
                                         pkgName = "testPackage",
                                         pkgFolder = "package")))
  expect_true(file.exists(paste0(tmpdir, "/tmp0/package/.Rbuildignore")))
  expect_equal(readLines(paste0(tmpdir, "/tmp0/package/.Rbuildignore")),
               c("^.+\\.Rproj$", "^\\.Rproj\\.user$", "^RScripts$", "^reports$"))
  expect_true(file.exists(paste0(tmpdir, "/tmp0/package/DESCRIPTION")))
  expect_equal(readLines(paste0(tmpdir, "/tmp0/package/DESCRIPTION"))[1],
               "Package: testPackage")
  expect_true(file.exists(paste0(tmpdir, "/tmp0/package/NAMESPACE")))
  expect_true(file.exists(paste0(tmpdir, "/tmp0/package/R")))
  expect_true(file.exists(paste0(tmpdir, "/tmp0/package/tests/testthat.R")))
  expect_true(file.exists(paste0(
    tmpdir, "/tmp0/package/tests/testthat/test-00_codeStyle.R")))
})


test_that("packages created with createProjectSkeleton can be built/checked", {
  invisible(capture.output(createProjectSkeleton(paste0(tmpdir, "/tmp10/"),
                                                 pkgName = "aTestPackage",
                                                 rProject = FALSE)))
  res10 <- check(pkg = paste0(tmpdir, "/tmp10"),
                 document = FALSE,
                 quiet = TRUE,
                 error_on = "never")

  expect_length(res10$errors, 0)
  expect_length(res10$warnings, 1)

  invisible(capture.output(createProjectSkeleton(paste0(tmpdir, "/tmp11"),
                                                 pkgName = "aTestPackage",
                                                 pkgFolder = "package",
                                                 rProject = FALSE)))

  expect_error(build(pkg = paste0(tmpdir, "/tmp11/package"),
                     path = paste0(tmpdir, "/tmp11")),
               NA)
  expect_warning(build(pkg = paste0(tmpdir, "/tmp11/package"),
                     path = paste0(tmpdir, "/tmp11")),
               NA)


  invisible(capture.output(createProjectSkeleton(paste0(tmpdir, "/tmp12"),
                                                 pkgName = "aTestPackage",
                                                 rProject = TRUE)))
  res12 <- check(pkg = paste0(tmpdir, "/tmp12"),
                 document = FALSE,
                 quiet = TRUE,
                 error_on = "never")
  expect_length(res12$errors, 0)
  expect_length(res12$warnings, 1)

  invisible(capture.output(createProjectSkeleton(paste0(tmpdir, "/tmp13/"),
                                                 pkgName = "aTestPackage",
                                                 pkgFolder = "package",
                                                 rProject = TRUE)))
  res13 <- check(pkg = paste0(tmpdir, "/tmp13/package"),
                 document = FALSE,
                 quiet = TRUE,
                 error_on = "never")
  expect_length(res13$errors, 0)
  expect_length(res13$warnings, 1)
})
