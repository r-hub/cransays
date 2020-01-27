# cransays

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![Locke Data Slack](https://img.shields.io/badge/Slack-discuss-blue.svg?logo=slack&longCache=true&style=flat)](https://join.slack.com/t/lockedata/shared_invite/enQtMjkwNjY3ODkwMzg2LTI1OGU1NTM3ZGIyZGFiNTdlODI3MzU2N2ZlNDczMjM4M2U2OWVmNDMzZTQ1ZGNlZDQ3MGM2MGVjMjI2MWIyMjI)


The goal of cransays is to scrape the [CRAN incoming ftp folder](ftp://cran.r-project.org/incoming/) to find where each of the submission is, and to 
make a [dashboard](https://cransays.itsalocke.com/articles/dashboard.html).

## Installation

``` r
remotes::install_github("lockedata/cransays")
```

## Example

This is a basic example :

``` r
cran_incoming <- cransays::take_snapshot()
```

The vignette produces a [handy dashboard](https://cransays.itsalocke.com/articles/dashboard.html) that we update every hour via [GitHub Actions](https://github.com/lockedata/cransays/actions).

## Related work

* Code originally adapted from https://github.com/edgararuiz/cran-stages That repository features an interesting analysis of CRAN incoming folder, including a diagram of the process deducted from that analysis.

* The [`foghorn` package](https://github.com/fmichonneau/foghorn), to summarize CRAN Check Results in the Terminal, provides an `foghorn::cran_incoming()` function to where your package stands in the CRAN incoming queue.

* If you wanna increase the chance of a smooth submission, check out [this collaborative list of things to know before submitting to CRAN](https://github.com/ThinkR-open/prepare-for-cran).

## Contributing

Wanna report a bug or suggest a feature? Great stuff! For more information on how to contribute check out [our contributing guide](.github/CONTRIBUTING.md). 

Please note that this R package is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this package project you agree to abide by its terms.

