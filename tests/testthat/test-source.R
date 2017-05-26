context("source_safe")

test_that("path - clear", {
  e <- new.env(parent = .GlobalEnv)
  path <- file.path("notary-repos", "source", "example.R")
  source_safe_sign(path, local = e, pubkey = PUBKEY)
  expect_equal(e$a, 1)
})

test_that("file:// - clear", {
  e <- new.env(parent = .GlobalEnv)
  path <- file.path("notary-repos", "source", "example.R")
  source_safe_sign(file_url(path), local = e, pubkey = PUBKEY)
  expect_equal(e$a, 1)
})

test_that("https:// - clear", {
  e <- new.env(parent = .GlobalEnv)
  path <- file.path(TEST_URL, "source", "example.R")
  source_safe_sign(path, local = e, pubkey = PUBKEY)
  expect_equal(e$a, 1)
})

test_that("path - tampered", {
  e <- new.env(parent = .GlobalEnv)
  path <- file.path("notary-repos", "source", "example-tampered.R")
  expect_error(source_safe_sign(path, local = e, pubkey = PUBKEY),
               "Signature verification failed")
  expect_equal(names(e), character(0))
})

test_that("file:// - tampered", {
  e <- new.env(parent = .GlobalEnv)
  path <- file.path(TEST_URL, "source", "example-tampered.R")
  expect_error(source_safe_sign(path, local = e, pubkey = PUBKEY),
               "Signature verification failed")
  expect_equal(names(e), character(0))
})

## sys.source
test_that("path - clear (sys.source)", {
  e <- new.env(parent = .GlobalEnv)
  path <- file.path("notary-repos", "source", "example.R")
  sys_source_safe_sign(path, e, pubkey = PUBKEY)
  expect_equal(e$a, 1)
})
