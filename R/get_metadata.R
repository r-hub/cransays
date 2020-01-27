

.get_metadata <- function(snapshot_row, dir = tempdir(check = TRUE)){

  URL <- glue::glue("{base_ftp_url()}{snapshot_row$folder}/{snapshot_row$package}_{snapshot_row$version}.tar.gz")
  destfile <- file.path(dir, glue::glue("{snapshot_row$package}_{snapshot_row$version}.tar.gz"))
  tryit <- try(curl::curl_download(URL, destfile),
               silent = TRUE)

  if (is(tryit, "try-error")) {
    return(snapshot_row)
  }

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
  if (length(DESCRIPTION$get_urls())) {
    pkg <-
      glue::glue('<a href="{DESCRIPTION$get_urls()[1]}" title="{title} by {DESCRIPTION$get_maintainer()}">{snapshot_row$package}</a>')

  } else {
    pkg <-
      glue::glue('<a href="https://blog.r-hub.io/2019/12/10/urls/" title="{title} by {DESCRIPTION$get_maintainer()}">{snapshot_row$package}</a>')

  }

  snapshot_row$package <- as.character(pkg)
  snapshot_row
}

#' Get metadata from a submission
#'
#' @param snapshot_row a row of \code{take_snapshot()} output
#' @param dir folder where to download and untar information.
#'
#' @return tibble
#' @export
get_metadata <- ratelimitr::limit_rate(.get_metadata,
                                       ratelimitr::rate(1, 1))
