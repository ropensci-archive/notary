
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](http://www.repostatus.org/badges/latest/concept.svg)](http://www.repostatus.org/#concept) [![Travis-CI Build Status](https://travis-ci.org/ropenscilabs/notary.svg?branch=master)](https://travis-ci.org/ropenscilabs/notary)

`notary` : Signing and Verification of R Packages

### Methods

-   `install_release`: Validate that the current release is signed and install it if so
-   `validate_release`: Validate that the latest release of a GitHub pacakge is

### Usage

``` r
library(notary)

validate_release("hrbrmstr/hrbrthemes")
```

    ## List of 4
    ##  $ verified : logi TRUE
    ##  $ reason   : chr "valid"
    ##  $ signature: chr "-----BEGIN PGP SIGNATURE-----\n\niQIcBAABCAAGBQJZE1i5AAoJECpRSkmXRkVgYzAP/je9bp3imLA9LZPOF1sqG7lb\nBeR20XeXR4gT"| __truncated__
    ##  $ payload  : chr "tree d2959bd73ad3af822e7370553242fbf045438e8d\nparent 52539bf3dc91776c8cb988efdca6565b8b69fd17\nauthor Bob Rudi"| __truncated__

    ## 

    ## [1] TRUE

``` r
validate_release("ironholds/rgeolocate")
```

    ## [1] FALSE

### Code of Coduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
