
#' Downloads history
#'
#' Downloads history of packages on the submission queue as recorded on github branch.
#'
#' For some periods github actions recording the data didn't run,
#' so there are some periods with missing data.
#' @return A `data.frame` with columns:
#' - `package`: the package name
#' - `version`: the package submitted version
#' - `snapshot_time`: time of the \pkg{cransays} snapshot, in `"Europe/Vienna"`
#' timezone, same, as the CRAN servers.
#' - `folder`: folder where the submitted package is stored at the time of the
#' snapshot
#' - `subfolder`: subfolder where the submitted package is stored at the time of
#' the snapshot
#' - `submission_time`: time when the package was submitted to CRAN, in
#' `"Europe/Vienna"` timezone, same as the CRAN servers
#'
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
  # Header used 2020-09-12 till 2020-09-12 (15 hours)
  # Changed in 977a76f3eaa069270ae0f923e6357b3da691c218.
  incoming_1 <- dat[startsWith(basename(dat), "cran-incoming_-")]
  headers_1 <- lapply(incoming_1, read.csv, nrow = 1, header = FALSE)
  headers_1_length <- lengths(headers_1)
  header_1 <- lapply(incoming_1[headers_1_length == 11], read.csv)
  h1 <- do.call(rbind, header_1)
  # Header used 2020-09-12 till 2020-09-14
  # Changed in 55aa8ee7311143289e03d3f9bdc8cea8016bf208.
  # Removes the `submitted` column, which contains human readable time since
  # submission.
  header_2 <- lapply(incoming_1[headers_1_length == 10], read.csv)
  h2 <- do.call(rbind, header_2)
  h1[, setdiff(colnames(h2), colnames(h1))] <- NA
  h12 <- rbind(h1[, colnames(h2)], h2)

  # Stable heading system 1
  incoming_2 <- dat[grepl("^cran\\-incoming\\-[^v]", basename(dat))]
  headers_2 <- lapply(incoming_2, read.csv, nrow = 1, header = FALSE)
  headers_2_length <- lengths(headers_2)

  # De difference between headers are the length if they are reordered/rename
  # It might fail.
  # Header 3 from 2020-09-14 to 2022-02-14
  header_3 <- lapply(incoming_2[headers_2_length == 5], read.csv)
  h3 <- do.call(rbind, header_3)
  # Header 4 from 2022-02-14 onward.
  # Changed in 799f779d4b0004039b9f14a6fcdbe7a154c78a67.
  # Restores the `submission_time` column.
  header_4 <- lapply(incoming_2[headers_2_length == 6], read.csv)
  h4 <- do.call(rbind, header_4)
  h3[, setdiff(colnames(h4), colnames(h3))] <- NA
  h34 <- rbind(h3[, colnames(h4)], h4)


  h1234 <- rbind(h12[, colnames(h34)], h34)
  h1234$submission_time <- as.POSIXct(h1234$submission_time, tz = "UTC")
  attr(h1234$submission_time, "tzone") <- "Europe/Vienna"

  # Explicit versioning system.
  # Introduced in e2250076a123136e7d03dc840636e605d57bd468.
  v5 <- dat[grepl("^cran\\-incoming\\-v5-", basename(dat))]
  h5 <- do.call(rbind, lapply(v5, read.csv))

  h_all <- rbind(h1234, h5)
  h_all$snapshot_time <- as.POSIXct(h_all$snapshot_time, tz = "Europe/Vienna")

  return(h_all)
}