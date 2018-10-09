#' Take Snapshot of CRAN incoming folder
#'
#' @return A data.frame, one line per submission.
#' @export
#'
take_snapshot <- function(){
  # Map sub-folders within the 'incoming' folder ----------------------
  incoming_folders <- curl::curl("ftp://cran.r-project.org/incoming/")
  dir <- readLines(incoming_folders)
  folders <- dir %>%
    strsplit(split = " ") %>%
    purrr::map_chr(~ .x[length(.x)])

  # Iterate through the mapped folders to extract contents ------------

  cran_incoming <- folders %>%
    paste0("ftp://cran.r-project.org/incoming/", ., "/") %>%
    purrr::map_df(get_folder_contents) %>%
    dplyr::bind_rows(
      tibble::tibble(
        lines = dir,
        subfolder = "root"
      )
    ) %>%
    dplyr::mutate(
      snapshot_time = Sys.time()
    )

  # one level more for humans
  # since they use subfolders
  cran_human <- c("DS", "UL", "SH", "KH")
  human_folders <- cran_incoming$lines[cran_incoming$subfolder %in%
                                         cran_human] %>%
    strsplit(split = " ") %>%
    purrr::map_chr(~ .x[length(.x)])

  human_folders <- glue::glue("ftp://cran.r-project.org/incoming/{cran_incoming$subfolder[cran_incoming$subfolder %in%
                              cran_human]}/{human_folders}/")

  human_cran_incoming <- human_folders %>%
    purrr::map_df(get_folder_contents) %>%
    dplyr::bind_rows(
      tibble::tibble(
        lines = dir,
        subfolder = "root"
      )
    ) %>%
    dplyr::mutate(
      snapshot_time = Sys.time()
    )

  cran_incoming <- rbind(cran_incoming,
                         human_cran_incoming)




  cran_incoming <- cran_incoming %>%
    dplyr::rowwise() %>%
    dplyr::mutate(info = list(parse_line(lines))) %>%
    tidyr::unnest()

  cran_incoming <- dplyr::filter(cran_incoming,
                                 grepl("\\.tar\\.gz",
                                       cran_incoming$lines))

  cran_incoming$howlongago <- round(as.numeric(parsedate::parse_iso_8601(cran_incoming$snapshot_time) -
                                                 parsedate::parse_iso_8601(cran_incoming$submission_time),
                                               units = "days"), digits = 1)

  cran_incoming
  }

# helper
get_folder_contents <- function(folder){
  current_folder <- curl::curl(folder)
  res <- tibble::tibble(
    lines = readLines(current_folder),
    subfolder = sub("ftp\\:\\/\\/cran\\.r\\-project\\.org\\/incoming\\/",
                    "", folder)
  )
  close(current_folder)

  res$subfolder <- sub("\\/", "", res$subfolder)

  res
}

parse_line <- function(line){
  words <- strsplit(line, " ")[[1]]
  words <- words[words != ""]
  words[length(words)] <- sub("\\.tar\\.gz", "",
                              words[length(words)])

  package <- strsplit(words[length(words)], "_")[[1]]
  package_name <- package[1]
  package_version <- package[2]
  # at the moment hardcode year
  year <- format(Sys.Date(), "%Y")
  time <- anytime::anytime(glue::glue("{year} {words[length(words) - 3]} {words[length(words) - 2]} {words[length(words) - 1]}"),
                           tz = Sys.timezone())

 if(time > Sys.time()){
   time <- anytime::anytime(glue::glue("{as.numeric(year)-1} {words[length(words) - 3]} {words[length(words) - 2]} {words[length(words) - 1]}"))

 }

  tibble::tibble(submission_time = time,
                 package = package_name,
                 version = package_version)

}