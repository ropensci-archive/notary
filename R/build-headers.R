#' Build request headers
build_headers <- function() {

  hdrs <- c(Accept="application/vnd.github.cryptographer-preview")

  gh_pat <- Sys.getenv("GITHUB_PAT", "")
  if (gh_pat != "") hdrs <- c(hdrs, Authorization = sprintf("token %s", gh_pat))

  hdrs

}

