#' Validate that the current GitHub release is GPG signed and install it if so
#'
#' @md
#' @param repo Repository address in the format `username/repo`
#' @export
#' @examples \dontrun{
#' install_release("hrbrmstr/hrbrthemes")
#'
#' # fails
#' install_release("ironholds/rgeolocate")
#' }
install_release <- function(repo) {

  if (!validate_release(repo)) {
    stop(sprintf("Latest release of '%s' is not signed or non-existent. Aborting installation.", repo))
  }

  repo_info <- strsplit(repo, "/")[[1]]

  repo_url <- sprintf("https://api.github.com/repos/%s/%s/releases",
                      repo_info[1], repo_info[2])

  httr::GET(repo_url, add_headers(.headers = build_headers())) -> res

  httr::stop_for_status(res)

  releases_info <- httr::content(res)

  remotes::install_github(sprintf("%s@%s", repo, releases_info[[1]]$tag))

}
