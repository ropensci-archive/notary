##' Source a file with verification
##' @title Source a file with verification
##' @param file The file to source.  Can be a path, file:// or
##'   https:// URL
##' @param ... Additional parameters passed through to \code{source}
##'   or \code{sys.source}.
##' @param pubkey Public key (filename or contents)
##' @param verbose Be verbose when downloading files?
##' @export
source_safe_sign <- function(file, ..., pubkey = NULL, verbose = FALSE) {
  file <- verify_uri(file, pubkey, verbose)
  source(file, ...)
}

##' @export
##' @rdname source_safe_sign
sys_source_safe_sign <- function(file, ..., pubkey = NULL, verbose = FALSE) {
  file <- verify_uri(file, pubkey, verbose)
  sys.source(file, ...)
}
