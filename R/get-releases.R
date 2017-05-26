#' Retrieve a data frame of GitHub package tag (release) info
#'
#' @param repo Repository address in the format `username/repo`
#' @export
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
    if ((length(commit_info$verification$verified) > 0)) {

      data.frame(user = repo_info[1], repo = repo_info[2],
                 committer = commit_info$commit$author$name,
                 committer = commit_info$commit$email,
                 )

    } else {

      data.frame(user = repo_info[1], repo = repo_info[2])

    }

  })

}



