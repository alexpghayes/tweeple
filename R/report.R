#' Create report
#'
#' @param user_ids User IDs or screen names of users you want to include
#'   in the report.
#'
#' @param recent_tweets Number of recent tweets to include from each user.
#'   Default is 0, so that no tweets are included. I recommend starting
#'   with no recent tweets and then including 3-5 tweets after you've read
#'   the user bios.
#'
#' @param output_format Passed to [rmarkdown::render()]. Default value is
#'   `html_document(theme = "paper")`.
#'
#' @param output_file Passed to [rmarkdown::render()]. Default is
#'   `"tweep_report.html"`.
#'
#' @param output_dir Passed to [rmarkdown::render()]. Default is
#'   `getwd()`, which is the user's current directory.
#'
#' @import rmarkdown
#' @export
#'
#' @examples
#'
#' # summarize the Rohe Lab
#'
#' rohe_lab <- c("karlrohe",  "krauskae", "alexpghayes", "fchen365",
#'   "JosephineLukito", "yinizhang2011")
#'
#' \dontrun{
#'
#' create_report(
#'   rohe_lab,
#'   output_file = "rohe_lab_without_recent_tweets.html"
#' )
#'
#' create_report(
#'   rohe_lab,
#'   recent_tweets = 3,
#'   output_file = "rohe_lab_with_recent_tweets.html"
#' )
#'
#' }
#'
create_report <- function(
  user_ids,
  recent_tweets = 0,
  output_format = html_document(
    theme = "paper"
  ),
  output_file = "tweep_report.html",
  output_dir = getwd()) {

  report_dir <- system.file("tweep_report_template.Rmd", package = "tweeple")

  # rmarkdown::render()
  render(
    input = report_dir,
    output_format = output_format,
    output_file = output_file,
    output_dir = output_dir,
    intermediates_dir = output_dir,
    params = list(user_ids = user_ids, recent_tweets = recent_tweets)
  )

  # open the report
  report_path <- path.expand(file.path(output_dir, output_file))
  utils::browseURL(report_path)

  # print path to report
  message(paste0("\n\nReport is generated at \"", report_path, "\"."))
}
