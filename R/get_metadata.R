

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

  fs::file_delete(destfile)

  DESCRIPTION <- desc::desc(file = file.path(exdir,
                                             snapshot_row$package,
                                             "DESCRIPTION"))

  fs::dir_delete(exdir)

  title <- DESCRIPTION$get_field("Title")
  if (!is.null(DESCRIPTION$get_urls())) {
    return(
      glue::glue('<a href="{DESCRIPTION$get_urls()[1]}" title="{title} by {DESCRIPTION$get_maintainer()}">{snapshot_row$package}</a>')
      )
  } else {
      return(
      glue::glue('<a href="https://blog.r-hub.io/2019/12/10/urls/" title="{title} by {DESCRIPTION$get_maintainer()}">{snapshot_row$package}</a>')
      )
  }

}

get_desc_field <- function(field, DESCRIPTION){
  tibble::tibble(field = field,
                 value = toString(DESCRIPTION$get_field(field)))
}

get_info <- function(snapshot_row, dir = tempdir(check = TRUE)) {
  snapshot_row$package <- get_metadata(snapshot_row, dir)
  snapshot_row
}