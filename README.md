
`notary` : Signing and Verification of R Packages

### Methods

-   `install_release`: Validate that the current release is signed and install it if so
-   `validate_release`: Validate that the latest release of a GitHub pacakge is

### Usage

``` r
library(notary)

validate_release("hrbrmstr/hrbrthemes")
```

    ## [1] TRUE

``` r
validate_release("ironholds/rgeolocate")
```

    ## [1] FALSE

### Code of Coduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
