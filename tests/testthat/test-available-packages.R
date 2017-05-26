context("available_packages")

if (!file.exists(TEST_PATH)) {
  make_tests(TEST_PATH)
}

test_that("file://, all clear", {
  url <- file_url(file.path(TEST_PATH, "base", "src", "contrib"))
  cmp <- available.packages(url)
  d <- available_packages(url, pubkey = PUBKEY)
  expect_identical(d[, colnames(d) != "SHA256", drop = FALSE], cmp)
  expect_match(d[, "SHA256"], "^[[:xdigit:]]{64}$")
})

test_that("file://, tampered index", {
  url <- file_url(file.path(TEST_PATH, "index", "src", "contrib"))
  cmp <- available.packages(url)
  expect_error(available_packages(url, pubkey = PUBKEY),
               "Signature verification failed")
})

test_that("https://, all clear", {
  url <- file.path(TEST_URL, "base", "src", "contrib")
  cmp <- available.packages(url)
  d <- available_packages(url, pubkey = PUBKEY)
  expect_identical(d[, colnames(d) != "SHA256", drop = FALSE], cmp)
  expect_match(d[, "SHA256"], "^[[:xdigit:]]{64}$")
})

test_that("https://, tampered index", {
  url <- file.path(TEST_URL, "index", "src", "contrib")
  cmp <- suppressWarnings(available.packages(url))
  expect_error(available_packages(url, pubkey = PUBKEY),
               "Signature verification failed")
})
