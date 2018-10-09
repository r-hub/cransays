# cransays

The goal of cransays is to scrape the [CRAN incoming ftp folder](ftp://cran.r-project.org/incoming/) to find where each of the submission is, and to 
make a dashboard.

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

The vignette produces a handy dashboard.

## Deployment

The pkgdown website is deployed from Travis, the setup was made using [`travis::use_tic()`](https://ropenscilabs.github.io/travis/reference/use_tic.html).

