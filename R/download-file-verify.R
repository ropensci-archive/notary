download_file_verify <- function(url, destfile, pubkey, ...) {
  if (!is.raw(pubkey) && length(pubkey) == 32L) {
    stop("Expected a 32 byte pubk")
  }
  protocol <- uri_protocol(url)
  pubkey <- get_sodium_pubkey(pubkey)
  if (protocol == "https") {
    path_sig <- tempfile()
    method <- "libcurl"
    z <- download_file(paste0(url, ".sig"), dest = path_sig)
    z <- download_file(url, dest = destfile)
  } else if (protocol == "file") {
    url <- file_unurl(url)
    path_sig <- paste0(url, ".sig")
    if (!file.exists(path_sig)) {
      stop("Did not find signature")
    }
    if (!file.exists(url)) {
      stop("Did not find file")
    }
    file.copy(url, destfile, overwrite = TRUE)
  } else {
    stop("Invalid protocol ", protocol)
  }
  if (file.size(path_sig) != 64) {
    stop("Expected a 64 byte signature")
  }
  sig <- read_bin(path_sig)

  ## Then we download the actual file itself:
  contents <- read_bin(destfile)
  withCallingHandlers(sodium::sig_verify(contents, sig, pubkey),
                      error = function(e) stop(verification_error(e)))
  invisible(destfile)
  }

download_file <- function(url, ..., dest = tempfile(),
                          verbose = FALSE, overwrite = FALSE) {
  ## oo <- options(warnPartialMatchArgs = FALSE)
  ## if (isTRUE(oo$warnPartialMatchArgs)) {
  ##   on.exit(options(oo))
  ## }
  content <- httr::GET(url,
                       httr::write_disk(dest, overwrite),
                       if (verbose) httr::progress("down"), ...)
  code <- httr::status_code(content)
  if (code != 200L) {
    stop(download_error(content, code))
  }
  dest
}

uri_protocol <- function(x) {
  re <- "^([a-z]+)://.*$"
  if (!grepl(re, x)) {
    stop("Can't determine protocol")
  }
  sub("^([a-z]+)://.*$", "\\1", x)
}

download_error <- function(url, code) {
  msg <- sprintf("Downloading %s failed with code %d", url, code)
  structure(list(message = msg, call = NULL),
            class = c("download_error", "error", "condition"))
}

verification_error <- function(e) {
  class(e) <- c("verification_error", e)
  e
}

read_bin <- function(x) {
  readBin(x, raw(), file.size(x))
}

file_url <- function(path) {
  full_path <- normalizePath(path, winslash = "/")
  paste0("file://", if (substr(full_path, 1, 1) == "/") "" else "/", full_path)
}

file_unurl <- function(url) {
  if (Sys.info()[["sysname"]] == "Windows") {
    sub("^file:///", "", url)
  } else {
    sub("^file://", "", url)
  }
}

get_sodium_pubkey <- function(x) {
  if (is.raw(x)) {
    if (length(x) != 32L) {
      stop("Invalid key")
    }
  } else if (is.character(x)) {
    if (!file.exists(x)) {
      stop("'x' must be an existing file")
    }
    x <- get_sodium_pubkey(read_bin(x))
  } else if (is.null(x)) {
    x <- get_sodium_pubkey(getOption("notary.cran.pubkey",
                                     stop("Default key not set")))
  } else {
    stop("Invalid key input")
  }
  x
}
