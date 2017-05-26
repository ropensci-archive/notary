#' Validate that the current GitHub release is GPG signed
#'
#' Check that the latest release of the package at `username/repo` has been signed.
#'
#' @md
#' @param repo Repository address in the format `username/repo`
#' @param verbose if `TRUE` then a message will be returned with information about
#'     the signer of the package.
#' @export
#' @examples
#' validate_release("hrbrmstr/hrbrthemes")
#'
#' validate_release("ironholds/rgeolocate")
validate_release <- function(repo, verbose = TRUE) {

  repo_info <- strsplit(repo, "/")[[1]]

  repo_url <- sprintf("https://api.github.com/repos/%s/%s/releases",
                      repo_info[1], repo_info[2])

  httr::GET(repo_url, add_headers(.headers = build_headers())) -> res

  httr::stop_for_status(res)

  releases_info <- httr::content(res)

  if (length(releases_info) == 0) {
    message("No releases found")
    return(invisible(FALSE))
  }

  httr::GET(releases_info[[1]]$url, add_headers(.headers = build_headers())) -> res

  httr::stop_for_status(res)

  release <- content(res)

  tags_url <- sprintf("https://api.github.com/repos/%s/%s/tags",
                      repo_info[1], repo_info[2])

  httr::GET(tags_url, add_headers(.headers = build_headers())) -> res

  httr::stop_for_status(res)

  tags_info <- httr::content(res)

  tag_num <- which(sapply(tags_info, function(x) x$name) == release$tag_name)

  httr::GET(tags_info[[tag_num]]$commit$url, add_headers(.headers = build_headers())) -> res

  verification_info <- httr::content(res)

  sig_result <- if(length(verification_info$commit$verification$signature)){
    gpg::gpg_verify(
      charToRaw(verification_info$commit$verification$signature),
      charToRaw(verification_info$commit$verification$payload),
      error = FALSE)
  }

  sig_verified_by_github <- identical(verification_info$commit$verification$verified, TRUE)

  list(
    verified = sig_verified_by_github,
    signature = sig_result
  )
}
