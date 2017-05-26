## It's really nasty to try and intercept the calls to download
## PACKAGES index files because R will load one of the three different
## files (PACKAGES.rds, PACKAGES.gz, PACKAGES in order of preference)
## unless it's a file url in which case it will take PACKAGES by
## preference.  If one fails it tries to grab the next one.  The
## resulting data ends up with a `Repository` field added so we need
## to reset that too.

##' Download verified package indices
##' @title Download verified package indices
##' @param contriburl URL of the contrib section of the repository
##' @param method Ignored, but included for compatibility with
##'   \code{available.packages}
##' @param fields See \code{available.packages}
##' @param type The type of package
##' @param filters See \code{available.packages}
##' @param repos Repositories
##' @param pubkey Path or contents of public key
##' @export
available_packages <- function(contriburl = contrib.url(repos, type),
                               method, fields = NULL,
                               type = getOption("pkgType"),
                               filters = NULL, repos = getOption("repos"),
                               pubkey = NULL) {
  idx <- vapply(contriburl, package_index_download, character(1),
                tempfile(), pubkey)
  tmp <- file_url(dirname(idx))
  ret <- utils::available.packages(tmp, filters = filters,
                                   fields = union(fields, "SHA256"))
  ret[, "SHA256"] <- trimws(ret[, "SHA256"])
  ret[, "Repository"] <- contriburl[match(ret[, "Repository"], tmp)]
  ret
}

package_index_download <- function(url, dest_dir, pubkey) {
  protocol <- uri_protocol(url)
  dir.create(dest_dir)
  idx <- file.path(dest_dir, "PACKAGES")
  ## TODO: this could be simplified for the file ones because we don't
  ## usually need to copy them around.
  for (u in index_filename(url, protocol)) {
    path <- tryCatch(download_file_verify(u, tempfile(), pubkey),
                     download_error = function(e) e)
    if (!inherits(path, "download_error")) {
      if (u == "PACKAGES.rds") {
        saveRDS(readRDS(path), idx)
      } else if (u == "PACKAGES.gz") {
        writeLines(readLines(path), idx)
      } else {
        file.copy(path, idx)
      }
      unlink(path)
      break
    }
  }
  if (inherits(path, "download_error")) {
    stop(path)
  }
  idx
}

index_filename <- function(base, protocol) {
  if (protocol == "file") {
    file <- "PACKAGES"
  } else {
    file <- c(if (getRversion() >= "3.4.0")  "PACKAGES.rds",
              "PACKAGES.gz", "PACKAGES")
  }
  file.path(base, file)
}
