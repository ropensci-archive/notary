##' Prepare a package index for use with notary; computes and adds MD5
##' and SHA256 hashes the index and then signs them with your private
##' key.
##' @title Prepare a package index
##' @param path Directory that contains a \code{PACKAGES} file and a
##'   set of packages.
##' @export
package_index_prepare <- function(path, key) {
  package_index_add_hash(path)
  package_index_sign(path, key)
}

package_index_add_hash <- function(path) {
  filename <- file.path(path, "PACKAGES")
  dat <- read.dcf(filename)
  pkg_base <- sprintf("%s_%s", dat[, "Package"], dat[, "Version"])
  tmp <- grep(pkg_base[[1]], dir(path), fixed = TRUE, value = TRUE)
  stopifnot(length(tmp) == 1L)
  ext <- sub(pkg_base, "", tmp)
  pkg <- file.path(path, paste0(pkg_base, ext))

  msg <- setdiff(c("MD5sum", "SHA256"), colnames(dat))
  if (length(msg) > 0L) {
    extra <- matrix(NA_character_, length(pkg), length(msg),
                    dimnames = list(NULL, msg))
    dat <- cbind(dat, extra)
  }

  dat[, "MD5sum"] <- unname(tools::md5sum(pkg))
  dat[, "SHA256"] <- sha256sum(filename, FALSE)
  write.dcf(dat, filename)
  write_dcf_gz(dat, paste0(filename, ".gz"))
  rownames(dat) <- dat[, "Package"]
  saveRDS(dat, paste0(filename, ".rds"))
}

package_index_sign <- function(path, key) {
  for (p in file.path(path, c("PACKAGES", "PACKAGES.gz", "PACKAGES.rds"))) {
    sign_file(p, key)
  }
}

sha256sum <- function(x, named = TRUE) {
  hash <- vapply(x, function(f) as.character(openssl::sha256(read_bin(x))),
                 character(1))
  if (named) {
    names(hash) <- x
  }
  hash
}

write_dcf_gz <- function(dat, filename) {
  con <- gzfile(filename, "wb")
  on.exit(close(con))
  write.dcf(dat, con)
}

sign_file <- function(filename, key) {
  if (is.character(key)) {
    key <- read_bin(key)
  }
  writeBin(sodium::sig_sign(read_bin(filename), key),
           paste0(filename, ".sig"))
}
