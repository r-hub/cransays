base_ftp_url <- function(){
  "ftp://cran.r-project.org/incoming/"
}

#' Take Snapshot of CRAN incoming folder
#'
#' @return A data.frame, one line per submission.
#' @export
#'
take_snapshot <- function(){
  # Map sub-folders within the 'incoming' folder ----------------------
  incoming <- get_ftp_contents(base_ftp_url())
  folders <- incoming[["V9"]]

  # Iterate through the mapped folders to extract contents ------------
  cran_incoming <- folders %>%
    paste0(base_ftp_url(), ., "/") %>%
    purrr::map_df(purrr::possibly(get_ftp_contents, NULL)) %>%
    dplyr::bind_rows(
      incoming
    )

  # one level more for humans
  # since they use subfolders
  cran_human <- c("DS", "UL", "SH", "KH")
  human_folders <- cran_incoming %>%
    dplyr::filter(subfolder %in% cran_human) %>%
    with(paste0(base_ftp_url(), subfolder, "/", V9, "/"))

  cran_incoming <- human_folders %>%
    purrr::map_df(purrr::possibly(get_ftp_contents, NULL)) %>%
    dplyr::bind_rows(
      cran_incoming
    ) %>%
    dplyr::mutate(
      snapshot_time = as.POSIXct(format(Sys.time(), tz="Europe/Vienna"))
    )

  # Tidy results ------------------------------------------------------
  cran_incoming <- cran_incoming %>%
    dplyr::filter(grepl(".*\\.tar\\.gz", V9)) %>% # Remove non-package files
    dplyr::mutate(
      year = ifelse(grepl(":", V8, fixed = TRUE), format(snapshot_time, "%Y"), V8),
      time = ifelse(grepl(":", V8, fixed = TRUE), V8, "00:00"),
      package = sub("\\.tar\\.gz", "", V9), # Remove package extension
      submission_time = lubridate::parse_date_time(paste(year, V6, V7, time),
                                                   "%Y %b %d %R",
                                                   tz="Europe/Vienna"),
      submission_time = dplyr::if_else(as.numeric(snapshot_time - submission_time, units = "days") < 0,
                               lubridate::parse_date_time(paste(as.numeric(as.character(year)) - 1, V6, V7, time),
                                                          "%Y %b %d %R",
                                                          tz="Europe/Vienna"),
                               submission_time),
      howlongago = round(as.numeric(snapshot_time - submission_time, units = "days"), digits = 1)
    ) %>%
    tidyr::separate(package, c("package", "version"), "_") %>%
    tibble::as_tibble()

  cran_incoming <- dplyr::select(cran_incoming,
                                 - dplyr::starts_with("V",
                                                    ignore.case = FALSE))

  cran_incoming
}

# helper
get_ftp_contents <- function(url){
  # Read ftp table results
  res <- utils::read.table(curl::curl(url),
                           stringsAsFactors = FALSE)

  # Add ftp subfolder info from url
  subfolder <- sub(base_ftp_url(), "", url, fixed = TRUE)
  res[["subfolder"]] <- substr(subfolder, 1, nchar(subfolder) - 1)
  res$V8 <- as.character(res$V8)
  res
}
