get_user_key <- function(username){
  url <- sprintf("https://api.github.com/users/%s/gpg_keys", username)
  httr::GET(url, add_headers(.headers = build_headers())) -> res
  httr::content(res, simplify = TRUE, flatten = TRUE)
}