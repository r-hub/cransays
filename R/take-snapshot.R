base_ftp_url <- "ftp://cran.r-project.org/incoming/"

#' Take Snapshot of CRAN incoming folder
#'
#' @return A data.frame, one line per submission.
#' @export
#'
take_snapshot <- function(){
  # Map sub-folders within the 'incoming' folder ----------------------
  incoming <- get_ftp_contents(base_ftp_url)
  folders <- incoming[["V9"]]

  # Iterate through the mapped folders to extract contents ------------
  cran_incoming <- folders %>%
    paste0(base_ftp_url, ., "/") %>%
    purrr::map_df(purrr::possibly(get_ftp_contents, NULL)) %>%
    dplyr::bind_rows(
      incoming
    )

  # one level more for humans
  # since they use subfolders
  cran_human <- c("DS", "UL", "SH", "KH")
  human_folders <- cran_incoming %>%
    filter(subfolder %in% cran_human) %>%
    with(paste0(base_ftp_url, subfolder, "/", V9, "/"))

  cran_incoming <- human_folders %>%
    purrr::map_df(purrr::possibly(get_ftp_contents, NULL)) %>%
    dplyr::bind_rows(
      cran_incoming
    ) %>%
    dplyr::mutate(
      snapshot_time = Sys.time()
    )

  # Tidy results ------------------------------------------------------
  cran_incoming <- cran_incoming %>%
    filter(grepl(".*\\.tar\\.gz", V9)) %>% # Remove non-package files
    dplyr::mutate(
      package = sub("\\.tar\\.gz", "", V9), # Remove package extension
      submission_time = as.POSIXct(paste("2018", V6, V7, V8), format = "%Y %b %d %R"),
      howlongago = round(as.numeric(snapshot_time - submission_time, units = "days"), digits = 1)
    ) %>%
    tidyr::separate(package, c("package", "version"), "_") %>%
    tibble::as_tibble()

  cran_incoming
}

# helper
get_ftp_contents <- function(url){
  # Read ftp table results
  res <- read.table(url, stringsAsFactors = FALSE)

  # Add ftp subfolder info from url
  subfolder <- sub(base_ftp_url, "", url, fixed = TRUE)
  res[["subfolder"]] <- substr(subfolder, 1, nchar(subfolder) - 1)

  res
}
