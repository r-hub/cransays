#' Take Snapshot of CRAN incoming folder
#'
#' @return A data.frame, one line per submission.
#' @export
#'
take_snapshot <- function(){
  # Map sub-folders within the 'incoming' folder ----------------------
  incoming <- get_ftp_contents("ftp://cran.r-project.org/incoming/")
  folders <- incoming[["V9"]]

  # Iterate through the mapped folders to extract contents ------------

  cran_incoming <- folders %>%
    paste0("ftp://cran.r-project.org/incoming/", ., "/") %>%
    purrr::map_df(possibly(get_ftp_contents, NULL)) %>%
    dplyr::bind_rows(
      incoming
    ) %>%
    dplyr::mutate(
      snapshot_time = Sys.time()
    )

  # one level more for humans
  # since they use subfolders
  cran_human <- c("DS", "UL", "SH", "KH")
  human_folders <- cran_incoming %>%
    filter(subfolder %in% cran_human) %>%
    with(paste0("ftp://cran.r-project.org/incoming/", subfolder, "/", V9, "/"))

  cran_incoming <- human_folders %>%
    purrr::map_df(possibly(get_ftp_contents, NULL)) %>%
    dplyr::bind_rows(
      cran_incoming
    ) %>%
    dplyr::mutate(
      snapshot_time = Sys.time()
    )

  cran_incoming <- cran_incoming %>%
    filter(grepl(".*\\.tar\\.gz", V9)) %>%
    dplyr::mutate(
      year = 2018,
      package = sub("\\.tar\\.gz", "", V9),
      submission_time = as.POSIXct(paste(year, V6, V7, V8), format = "%Y %b %d %R"),
      howlongago = round(as.numeric(snapshot_time - submission_time, units = "days"), digits = 1)
    ) %>%
    tidyr::separate(package, c("package", "version"), "_")

  cran_incoming
}

# helper
get_ftp_contents <- function(url){
  res <- read.table(url, stringsAsFactors = FALSE)
  res[["subfolder"]] <- basename(url)
  res
}
