base_ftp_url <- function(){
  "ftp://cran.r-project.org/incoming/"
}

#' Take Snapshot of CRAN incoming folder
#'
#' @return A data.frame, one line per submission.
#' @export
#'
take_snapshot <- function(){
  tmppath <- file.path(tempdir(check = TRUE),
                       "tempfilecransays")
  file.create(tmppath)
  system2("ncftpls",
          args = c(
            "-l",
            "-R",
            "'ftp://cran.r-project.org/incoming/'",
            glue::glue(">{tmppath}")
          ))
  infos <- readLines(tmppath)
  infos <- infos[infos != ""]
  library("magrittr")
  infos <- tibble::tibble(
    info = infos,
    foldern = ifelse(
      grepl("\\:$", info),
      info, NA)
  ) %>%
    dplyr::mutate(folder = zoo::na.locf(foldern),
                  folder = gsub("\\:$", "", folder),
                  folder = gsub("^\\.\\/", "", folder),
                  info = paste(info, folder, sep = "\t")) %>%
    dplyr::filter(is.na(foldern),
                  grepl("\\.tar\\.gz", info),
                  folder != "archive")
  write.table(infos[,1], tmppath,
              col.names = FALSE, row.names = FALSE,
              quote = FALSE)

  cran_incoming <- read.table(tmppath,
                              stringsAsFactors = FALSE)  %>%
    dplyr::mutate(
      snapshot_time = Sys.time(),
      year = ifelse(grepl(":", V8, fixed = TRUE), format(snapshot_time, "%Y"), V8),
      time = ifelse(grepl(":", V8, fixed = TRUE), V8, "00:00"),
      package = sub("\\.tar\\.gz", "", V9), # Remove package extension
      submission_time = lubridate::parse_date_time(paste(year, V6, V7, time),
                                                   "%Y %b %d %R",
                                                   tz="Europe/Vienna"),
      submission_time = dplyr::if_else(as.numeric(snapshot_time - submission_time, units = "days") < 0,
                                       lubridate::parse_date_time(paste(as.numeric(as.character(year)) - 1, V6, V7, time),
                                                                  "%Y %b %d %R"),
                                       submission_time),
      howlongago = round(as.numeric(snapshot_time - submission_time, units = "days"), digits = 1)
    ) %>%
    dplyr::rename(folder = V10) %>%
    tidyr::separate(package, c("package", "version"), "_") %>%
    tibble::as_tibble()

  file.remove(tmppath)

  cran_incoming
}
