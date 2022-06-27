test_that("makePct is working with different inputs", {
  res1 <- makePct(0.25)
  res2 <- makePct(-1.251, percSymbol = FALSE)
  res3 <- makePct(0.999, digits = 2)
  res4 <- makePct(0.26, digits = 2, keepTrailing0 = FALSE)

  expect_type(res1, "character")
  expect_type(res2, "character")
  expect_type(res3, "character")
  expect_type(res4, "character")

  expect_equal(res1, "25%")
  expect_equal(res2, "-125")
  expect_equal(res3, "99.90%")
  expect_equal(res4, "26%")
})


test_that("formatBigNumbers", {
  res1 <- formatBigNumbers(1234567.123, digits = 2)
  res2 <- formatBigNumbers(1234567, bigMark = " ")

  expect_type(res1, "character")
  expect_type(res2, "character")

  expect_equal(res1, "1\\,234\\,567.12")
  expect_equal(res2, "1 234 567")
})
