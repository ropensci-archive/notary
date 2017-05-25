context("validate release works")
test_that("validate works", {

  expect_equal(validate_release("hrbrmstr/hrbrthemes"), TRUE)
  expect_equal(validate_release("ironholds/rgeolocate"), FALSE)

})
