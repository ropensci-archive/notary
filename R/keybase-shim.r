#' Check to see if a file exists under a users Keybase public folder
#'
#' First tries local `/keybase` filesystem for access. Upon failure, tests for access
#' via the keybase filesystem web interface.
#'
#' @md
#' @param path file path for existence test
#' @return `NA` if not found, otherwise the either the filesystem path or URL path
#' @export
#' @examples \dontrun{
#' kb_file_exists("/hrbrmstr/cran/PACKAGES")
#' kb_file_exists("/hrbrmstr/cran/PACKAGES.gz")
#' kb_file_exists("/hrbrmstr/cran/PACKAGES.rds")
#' }
kb_file_exists <- function(path) {
  x <- path

  x <- sub("^/", "", x)

  keybase_direct <- sprintf("/keybase/public/%s", x)

  if (dir.exists(dirname(keybase_direct))) {

    if (file.exists(keybase_direct)) {
      return(keybase_direct)
    } else {
      return(NA_character_)
    }

  } else {

    parts <- strsplit(x, "/")
    keybase_user <- parts
    keybase_path <- paste0(parts[2:length(parts)], collapse = "/")

    keybase_web <- sprintf("https://%s.keybase.pub/%s", keybase_user, keybase_path)

    res <- httr::HEAD(keybase_web)

    if (httr::status_code(res) < 300) {
      return(keybase_web)
    } else {
      return(NA_character_)
    }

  }

}
