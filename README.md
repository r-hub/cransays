# cransays

The goal of cransays is to scrape the CRAN incoming ftp folder to find where each of the submission is, and to 
make a dashboard.

## Installation

``` r
remotes::install_github("lockedata/cransays")
```

## Example

This is a basic example :

``` r
cran_incoming <- cransays::take_snapshot()
```

