#' Retrieve a data frame of GitHub package tag (release) info
#'
#' @param repo Repository address in the format `username/repo`
#' @export
#' @examples
#' get_tags("hrbrmstr/hrbrthemes")
get_tags <- function(repo) {

  repo_info <- strsplit(repo, "/")[[1]]

  tags_url <- sprintf("https://api.github.com/repos/%s/%s/tags",
                      repo_info[1], repo_info[2])

  httr::GET(tags_url, add_headers(.headers = build_headers())) -> res

  httr::stop_for_status(res)

  tags_info <- httr::content(res)

  lapply(tags_info, function(x) {

    httr::GET(x$commit$url, add_headers(.headers = build_headers())) -> res

    httr::stop_for_status(res)

    commit_info <- httr::content(res)

    if ((length(commit_info$commit$verification$verified) == 0)) {

      data.frame(
        user = repo_info[1], repo = repo_info[2],
        tag = x$name,
        committer = commit_info$commit$author$name %||% NA_character_,
        committer_email = commit_info$commit$author$email %||% NA_character_,
        verified = FALSE,
        reason = NA_character_,
        signature = NA_character_,
        payload = NA_character_,
        stringsAsFactors = FALSE
      )

    } else {

      data.frame(
        user = repo_info[1], repo = repo_info[2],
        tag = x$name,
        committer = commit_info$commit$author$name %||% NA_character_,
        committer_email = commit_info$commit$author$email %||% NA_character_,
        verified = commit_info$commit$verification$verified %||% NA,
        reason = commit_info$commit$verification$signature %||% NA_character_,
        signature = commit_info$commit$verification$signature %||% NA_character_,
        payload = commit_info$commit$verification$payload %||% NA_character_,
        stringsAsFactors = FALSE
      )

    }

  }) ->  rls_list

  ret <- do.call(rbind.data.frame, c(rls_list, stringsAsFactors=FALSE))

  class(ret) <- c("tbl_df", "tbl", "data.frame")

  ret

}
