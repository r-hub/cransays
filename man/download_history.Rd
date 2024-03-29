% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_history.R
\name{download_history}
\alias{download_history}
\title{Downloads history}
\usage{
download_history()
}
\value{
A `data.frame` with columns:
- `package`: the package name
- `version`: the package submitted version
- `snapshot_time`: time of the \pkg{cransays} snapshot, in `"Europe/Vienna"`
timezone, same, as the CRAN servers.
- `folder`: folder where the submitted package is stored at the time of the
snapshot
- `subfolder`: subfolder where the submitted package is stored at the time of
the snapshot
- `submission_time`: time when the package was submitted to CRAN, in
`"Europe/Vienna"` timezone, same as the CRAN servers
}
\description{
Downloads history of packages on the submission queue as recorded on github branch.
}
\details{
For some periods github actions recording the data didn't run,
so there are some periods with missing data.
}
