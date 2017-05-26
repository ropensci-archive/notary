download_file_verify <- function(url, destfile, pubkey, method, ...) {
  if (!is.raw(pubkey) && length(pubkey) == 32L) {
    stop("Expected a 32 byte pubk")
  }
  protocol <- uri_protocol(url)
  pubkey <- get_sodium_pubkey(pubkey)
  if (protocol == "https") {
    path_sig <- tempfile()
    withCallingHandlers({
      z <- download.file(paste0(url, ".sig"), destfile = path_sig,
                         method = method, cacheOK = FALSE, quiet = TRUE,
                         mode = "wb")
      z <- download.file(url, destfile, method = method,
                         cacheOK = FALSE, quiet = TRUE, mode = "wb")
    }, error = function(e) stop(download_error(e)))
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

uri_protocol <- function(x) {
  re <- "^([a-z]+)://.*$"
  if (!grepl(re, x)) {
    stop("Can't determine protocol")
  }
  sub("^([a-z]+)://.*$", "\\1", x)
}

download_error <- function(e) {
  class(e) <- c("download_error", e)
  e
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
  } else {
    stop("Invalid key input")
  }
  x
}
