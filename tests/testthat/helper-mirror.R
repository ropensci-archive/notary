make_keys <- function(path = "keys") {
  dir.create(path, FALSE, TRUE)
  writeBin(pubkey, file.path(path, "pub"))
  writeBin(key, file.path(path, "key"))
}

## Mirror a subsection of CRAN.  At the moment I am using just R6
## because it's small and has zero dependencies and no compiled code.
## We will need to build this out though.
make_local_cran <- function(path = "local_cran", key = "keys/key") {
  repo <- "https://cran.rstudio.com"
  packages <- "R6"
  on.exit(unlink(path, recursive = TRUE))
  dest <- contrib.url(path, "source")
  src <- contrib.url(repo, "source")
  db <- available.packages(src)
  dir.create(dest, FALSE, TRUE)
  download.packages(packages, dest, db, repo, src, type = "source")
  ## TODO: we could do more than this with a SHA256 hash not MD5, but
  ## this works with existing tooling.
  tools::write_PACKAGES(dest, type = "source")
  package_index_prepare(dest, key)
  on.exit()
}

copy_directory <- function(from, to) {
  dir.create(to, FALSE, TRUE)
  file.copy(dir(from, full.names = TRUE), to, recursive = TRUE)
  invisible(to)
}

make_tests <- function(path = "notary-repos", key = "keys/key") {
  base <- file.path(path, "base")
  make_local_cran(base, key)

  ## Break the index:
  index <- file.path(path, "index")
  index_pkg <- file.path(index, "src", "contrib", "PACKAGES")
  copy_directory(base, index)
  d <- read.dcf(index_pkg)
  d[d[, "Package"] == "R6", "MD5sum"] <- strrep("a", 32)
  write.dcf(d, index_pkg)

  ## Break the file:
  file <- file.path(path, "file")
  copy_directory(base, file)
  pkg <- dir(file.path(file, "src", "contrib"), pattern = "^R6_",
             full.names = TRUE)
  dat <- read_bin(pkg)
  writeBin(c(dat, as.raw(0)), pkg)
  path
}

TEST_PATH <- "notary-repos"
TEST_URL <- "https://ropenscilabs.github.io/notary-repos"
PUBKEY <- "keys/pub"
