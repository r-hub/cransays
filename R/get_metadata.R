

#' Get metadata from a submission
#'
#' @param snapshot_row a row of \code{take_snapshot()} output
#' @param dir folder where to download and untar information.
#'
#' @return tibble
#' @export
get_metadata <- function(snapshot_row, dir = tempdir(check = TRUE)){
  URL <- glue::glue("{base_ftp_url()}{snapshot_row$subfolder}/{snapshot_row$package}_{snapshot_row$version}.tar.gz")
  destfile <- file.path(dir, glue::glue("{snapshot_row$package}_{snapshot_row$version}.tar.gz"))
  curl::curl_download(URL, destfile)

  size <- file.size(destfile)

  exdir <- file.path(dir, glue::glue("{snapshot_row$package}_{snapshot_row$version}"))

  utils::untar(destfile, files = c(file.path(snapshot_row$package,
                                           "DESCRIPTION"),
                                   file.path(snapshot_row$package,
                                             "NAMESPACE")),
               exdir = exdir)

  DESCRIPTION <- desc::desc(file = file.path(exdir,
                                             snapshot_row$package,
                                             "DESCRIPTION"))

  desc <- purrr::map_df(DESCRIPTION$fields(), get_desc_field,
                DESCRIPTION)

  desc <- rbind(desc,
                tibble::tibble(field = "size", value = size))

  desc
}

get_desc_field <- function(field, DESCRIPTION){
  tibble::tibble(field = field,
                 value = toString(DESCRIPTION$get_field(field)))
}