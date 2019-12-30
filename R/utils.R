#' Generate HTML to embed a Tweet
#'
#' This code shamelessly ripped from
#' <https://github.com/ropensci/rtweet/pull/305>.
#'
#' @param screen_name Screen name of the user as a character vector.
#' @param status_id Status ID of tweet, as character.
#' @param ... Parameters to pass to the GET call.
#'
#' @return HTML to embed the tweet as a character vector.
#'
#' @details Arguments to pass to the API call can be found at
#'   <https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-oembed>.
#'
#'
#' @examples
#'
#' name   <- "kearneymw"
#' status <- "1087047171306856451"
#'
#' tweet_embed(screen_name = name, status_id = status)
#'
#' tweet_embed(
#'  screen_name = name,
#'  status_id = status,
#'  hide_thread = TRUE,
#'  hide_media = FALSE,
#'  align = "center"
#' )
#'
#' @seealso [httr::GET()], [httr::content()]
#'
#' @importFrom httr GET content
#' @importFrom glue glue

tweet_embed <- function(screen_name, status_id, ...) {

  stem <- 'https://publish.twitter.com/oembed'

  params <- list(...)

  params$url <- glue(
    "https://twitter.com/{screen_name}/status/{status_id}"
  )

  merged_params <- paste(
    names(params),
    tolower(as.character(params)),
    sep = "=",
    collapse = "&"
  )

  URI <- paste(stem, merged_params, sep = '?')
  ret <- httr::content(httr::GET(URI))
  ret$html
}


#' Generate markdown summary of Twitter users
#'
#' To be used in an R markdown section with `results = "asis"`.
#'
#' @param user_ids A character vector of Twitter user ids.
#' @param recent_tweets
#'
#' @export
#' @import glue glue
report_bio <- function(user_ids, recent_tweets = 0) {

  tweep_data <- rtweet::lookup_users(user_ids)

  if (recent_tweets > 0)
    tweep_timelines <- rtweet::get_timelines(user_ids, n = recent_tweets)

  output <- character()

  for (index in 1:nrow(tweep_data)) {

    ##### user bio

    desc <- stringr::str_remove_all(
      tweep_data$description[index],
      "\n"
    )

    prof_pic_url <- tweep_data$profile_image_url[index]
    screen_name <- tweep_data$screen_name[index]
    user_id <- tweep_data$user_id[index]

    item <- glue(
      "{index}. ![twitter profile image of {screen_name}]({prof_pic_url}) ",
      " [{screen_name}](https://twitter.com/{screen_name})",
      ": {desc} \n \n",
      .trim = FALSE
    )

    ##### recent tweets

    if (recent_tweets > 0) {

      user_timeline <- dplyr::filter(tweep_timelines, user_id == !!user_id)

      for (tweet_index in 1:recent_tweets) {
        status_id <- user_timeline$status_id[tweet_index]
        tweet_as_html <- tweet_embed(screen_name, status_id)
        item <- append(item, tweet_as_html)
      }
    }

    output <- append(output, item)
  }

  knitr::asis_output(output)
}
