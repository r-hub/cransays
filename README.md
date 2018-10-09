# cransays

[![Build Status](https://travis-ci.org/lockedata/cransays.svg?branch=master)](https://travis-ci.org/lockedata/cransays) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


The goal of cransays is to scrape the [CRAN incoming ftp folder](ftp://cran.r-project.org/incoming/) to find where each of the submission is, and to 
make a [dashboard](https://cransays.itsalocke.com/articles/dashboard.html).

Code adapted from https://github.com/edgararuiz/cran-stages

## Installation

``` r
remotes::install_github("lockedata/cransays")
```

## Example

This is a basic example :

``` r
cran_incoming <- cransays::take_snapshot()
```

The vignette produces a [handy dashboard](https://cransays.itsalocke.com/articles/dashboard.html) that we update every hour.

## Deployment

The pkgdown website is deployed from Travis, the setup was made using [`travis::use_tic()`](https://ropenscilabs.github.io/travis/reference/use_tic.html).

## Contributing

Wanna report a bug or suggest a feature? Great stuff! For more information on how to contribute check out [our contributing guide](.github/CONTRIBUTING.md). 

Please note that this R package is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this package project you agree to abide by its terms.

