install_packages <- function(...) {
  f <- utils::install.packages
  body(f) <- substitute_(body(utils::install.packages),
                         list(download.packages =
                                quote(notary::download_packages)))
  f(...)
}

download_packages <- function(pkgs, destdir, available = NULL,
                              repos = getOption("repos"),
                              contriburl = contrib.url(repos, type),
                              method, type = getOption("pkgType"), ...) {
  ## Issues: this will not do well if there is more than one version
  ## for a package because we have to mimic what download.packages
  ## actually does.  If that *is* what we do this probably moves way
  ## from mimicing an interface to using actual code in which case we
  ## need to be careful with licence and copyright.
  if (is.null(available)) {
    available <- available.packages(contriburl = contriburl, method = method)
  }
  ret <- utils::download.packages(pkgs, destdir, available, repos, contriburl,
                                  method, type)
  rcv <- tools::md5sum(ret[, 2])
  exp <- available[ret[, 1], "MD5sum"]
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
