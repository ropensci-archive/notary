install_packages <- function(...) {
  f <- utils::install.packages
  subs <- list(download.packages = quote(notary::download_packages),
               available.packages = quote(notary::available_packages))
  body(f) <- substitute_(body(utils::install.packages), subs)
  f(...)
}

##' Version of \code{download.file} that verifies downloads.  All
##' arguments are passed through to \code{utils::download.packages}
##' verbatim and the documentation there should be consulted for the
##' meaning of arguments.
##'
##' @title Download and verify packages
##' @param pkgs Character vector of packages to download
##' @param destdir Destination directory
##' @param available Set of available packages, as created by
##'   \code{available.packages}
##' @param repos Character vector of base URL(s) of repositories
##'   (passed through to \code{available.packages}.
##' @param contriburl URL(s) of the contrib sections of the
##'   repositories
##' @param method Download method
##' @param type character string, indicating which type of packages to
##'   install.
##' @param ... Additional arguments passed through to
##'   \code{utils::download.packages} (and from there through to
##'   \code{download.file}.
##' @param pubkey Public key used to verify the package index
##' @export
##' @importFrom utils contrib.url
download_packages <- function(pkgs, destdir, available = NULL,
                              repos = getOption("repos"),
                              contriburl = contrib.url(repos, type),
                              method, type = getOption("pkgType"), ...,
                              pubkey) {
  ## Issues: this will not do well if there is more than one version
  ## for a package because we have to mimic what download.packages
  ## actually does.  If that *is* what we do this probably moves way
  ## from mimicing an interface to using actual code in which case we
  ## need to be careful with licence and copyright.
  if (is.null(available)) {
    available <- available_packages(contriburl = contriburl,
                                    method = method,
                                    pubkey = pubkey)
  }
  ret <- utils::download.packages(pkgs, destdir, available, repos, contriburl,
                                  method, type)
  exp <- available[ret[, 1], "MD5sum"]
  if (any(is.na(exp))) {
    stop("This mirror does not provide MD5 sums of packages")
  }
  rcv <- tools::md5sum(ret[, 2])
  err <- rcv != exp
  if (any(err)) {
    stop("WHOA THERE! Package hash was not expected for ",
         paste(ret[err, 1], collapse = ", "))
  }
  ret
}

substitute_ <- function(expr, env) {
  eval(substitute(substitute(y, env), list(y = expr)))
}
