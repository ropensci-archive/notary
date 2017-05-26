download_file_verify <- function(url, destfile, pubkey, ...) {
  if (!is.raw(pubkey) && length(pubkey) == 32L) {
    stop("Expected a 32 byte pubk")
  }
  protocol <- uri_protocol(url)
  pubkey <- get_sodium_pubkey(pubkey) # Fail early here
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

verify_uri <- function(uri, pubkey = NULL, verbose = FALSE) {
  protocol <- uri_protocol(uri, TRUE)
  if (protocol == "https") {
    file <- download_file_verify(uri, tempfile(), pubkey, verbose = verbose)
  } else if (protocol == "file") {
    file <- file_unurl(uri)
    verify_file(file, paste0(file, ".sig"), pubkey)
  } else if (protocol == "") {
    file <- uri
    verify_file(file, paste0(file, ".sig"), pubkey)
  } else {
    stop("Invalid protocol")
  }
  file
}

verify_file <- function(file, file_sig, pubkey) {
  pubkey <- get_sodium_pubkey(pubkey)
  sig <- read_bin(file_sig)
  contents <- read_bin(file)
  withCallingHandlers(sodium::sig_verify(contents, sig, pubkey),
                      error = function(e) stop(verification_error(e)))
}

download_file <- function(url, ..., dest = tempfile(),
                          verbose = FALSE, overwrite = FALSE) {
  content <- httr::GET(url,
                       httr::write_disk(dest, overwrite),
                       if (verbose) httr::progress("down"), ...)
  code <- httr::status_code(content)
  if (code != 200L) {
    stop(download_error(content, code))
  }
  dest
}

uri_protocol <- function(x, allow_non_uri = FALSE) {
  re <- "^([a-z]+)://.*$"
  if (!grepl(re, x)) {
    if (allow_non_uri) {
      return("")
    } else {
      stop("Can't determine protocol")
    }
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
