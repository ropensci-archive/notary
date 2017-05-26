## Mirror a subsection of CRAN
make_local_cran <- function(path = "local_cran") {
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
  file.remove(file.path(dest, "PACKAGES.gz"))
  on.exit()
}

file_url <- function(path) {
  full_path <- normalizePath(path, winslash = "/")
  paste0("file://", if (substr(full_path, 1, 1) == "/") "" else "/", full_path)
}
