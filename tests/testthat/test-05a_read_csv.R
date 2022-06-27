tmpdir <- tempdir()
if (interactive()) {
  if (dir.exists("../temp")) unlink("../temp", recursive = TRUE)
  dir.create("../temp")
  tmpdir <- "../temp"
}

test_that("Wrapper read_csv returns correct message", {
  path <- paste0(tmpdir, "/iris.csv")
  write.csv(x = iris, file = path, row.names = FALSE)
  expect_message(INWTUtils::read_csv(file = path))
  expect_message(INWTUtils::read_csv(file = path, skip = 2))
  expect_message(INWTUtils::read_csv(file = path, col_names = FALSE))
  expect_message(INWTUtils::read_csv(file = path, n_max = 5))
  expect_message(INWTUtils::read_csv(file = path, skip = 3, col_names = FALSE,
                                     n_max = 10))
  expect_message(INWTUtils::read_csv(file = path, skip = 3, col_names = FALSE,
                                     n_max = 148))
  expect_message(INWTUtils::read_csv(file = path, skip = 10, col_names = FALSE,
                                     n_max = 3))
})

test_that("Wrapper read_csv returns correct message", {
  path <- paste0(tmpdir, "/iris.csv")
  write.csv(x = iris, file = path, row.names = FALSE)
  expect_true(is.data.frame(INWTUtils::read_csv(file = path)))
  expect_true(is.data.frame(INWTUtils::read_csv(file = path, skip = 3,
                                                col_names = FALSE, n_max = 10)))
})
