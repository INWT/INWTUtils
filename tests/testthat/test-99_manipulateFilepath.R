# nolint start
test_that("addBackslash", {
  expect_equal(INWTUtils:::addBackslash("pathWith/"), "pathWith/")
  expect_equal(INWTUtils:::addBackslash("pathWithout"), "pathWithout/")
})

test_that("rmBackslash", {
  expect_equal(INWTUtils:::rmBackslash("pathWith/"), "pathWith")
  expect_equal(INWTUtils:::rmBackslash("pathWithout"), "pathWithout")
})
# nolint end
