
#' Downloads history
#'
#' Downloads history of packages on the submission queue as recorded on github
#' @export
#' @importFrom utils download.file read.csv unzip
download_history <- function() {
  tmp_f <- tempfile(pattern = "cransays-history", fileext = ".zip")
  tmp_dir <- tempdir()
  download.file("https://github.com/r-hub/cransays/archive/history.zip",
                destfile = tmp_f)
  # We unzip the files
  dat <- unzip(tmp_f, exdir = tmp_dir, setTimes = TRUE)
  dat <- dat[endsWith(dat, ".csv")]

  # First two heading systems:
  incoming_1 <- dat[startsWith(basename(dat), "cran-incoming_-")]
  # Header used 2020-09-12 till 2020-09-14
  headers_1 <- lapply(incoming_1, read.csv, nrow = 1, header = FALSE)
  headers_1_length <- lengths(headers_1)
  header_1 <- lapply(incoming_1[headers_1_length == 10], read.csv)
  h1 <- do.call(rbind, header_1)
  # Header used 2020-09-12 till 2020-09-12 (15 hours)
  header_2 <- lapply(incoming_1[headers_1_length == 11], read.csv)
  h2 <- do.call(rbind, header_2)
  h1[, setdiff(colnames(h2), colnames(h1))] <- NA
  h12 <- rbind(h1, h2[, colnames(h1)])

  # Stable heading system 1
  incoming_2 <- dat[startsWith(basename(dat), "cran-incoming-")]
  headers_2 <- lapply(incoming_2, read.csv, nrow = 1, header = FALSE)
  headers_2_length <- lengths(headers_2)

  # De difference between headers are the length if they are reordered/rename
  # It might fail.
  header_3 <- lapply(incoming_2[headers_2_length == 5], read.csv)
  h3 <- do.call(rbind, header_3)
  header_4 <- lapply(incoming_2[headers_2_length == 6], read.csv)
  h4 <- do.call(rbind, header_4)
  h3[, setdiff(colnames(h4), colnames(h3))] <- NA
  h34 <- rbind(h3[, colnames(h4)], h4)
  rbind(h12[, colnames(h34)], h34)
}