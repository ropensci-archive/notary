
<img src="img/notarylogo.png" width="50%" height="50%"/>

### Problems

![](img/problems.png)

### Solutions (current)

**GitHub**

-   Only install signed releases
-   Verify release signatures

**CRAN**

-   Reimagining integrity mirror integrity

<hr noshade size="0.5"/>
 

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Travis-CI Build Status](https://travis-ci.org/ropenscilabs/notary.svg?branch=master)](https://travis-ci.org/ropenscilabs/notary) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropenscilabs/notary?branch=master&svg=true)](https://ci.appveyor.com/project/jeroen/notary)

`notary` : Signing and Verification of R Packages

### Methods

More for users:

CRAN-ish

-   `install_packages`: Install and verify packages
-   `download_packages`: Download and verify packages
-   `available_packages`: Download and verify package indices

GitHub-ish

-   `install_release`: Validate that the current GitHub release is GPG signed and install it if so
-   `validate_release`: Validate that the current GitHub release is GPG signed
-   `retrieve_release_signature`: Retrieve the GitHub signing information for the latest release of a package
-   `get_tags`: Retrieve a data frame of GitHub package tag (release) info

`source()`-ish

-   `source_safe_sign`: Source a file with verification
-   `sys_source_safe_sign`: Source a file with verification

More for plumbers:

-   `package_index_prepare`: Prepare a package index

### The Book of R \[Security\]

<https://ropenscilabs.github.io/r-security-practices/index.html>

### A gif is worth a thousand words

<https://rud.is/dl/notary.gif>

![](img/smaller.gif)

### Usage

``` r
library(notary)
library(tidyverse)
```

``` r
validate_release("hrbrmstr/hrbrthemes")
##    Repo/Package: hrbrmstr/hrbrthemes (v0.3.0)
##       Committer: Bob Rudis <bob@rud.is>
## GitHub Verified: TRUE
## GPG Fingerprint: 3773E53B2013A722FA67C6F02A514A4997464560
##    Trusted peer: TRUE
##       Timestamp: 2017-05-10 11:15:21
##       Algorithm: RSA + SHA256

validate_release("ironholds/rgeolocate")
##    Repo/Package: ironholds/rgeolocate (0.8.0)
##       Committer: Oliver Keyes <ironholds@gmail.com>
## GitHub Verified: FALSE
## GPG Fingerprint: 
##    Trusted peer: 
##       Timestamp: 
##       Algorithm:  +

retrieve_release_signature("hrbrmstr/ggalt")
## Latest release is not signed or has not been verified
## NULL

glimpse(get_tags("hrbrmstr/hrbrthemes"))
## Observations: 2
## Variables: 9
## $ user            <chr> "hrbrmstr", "hrbrmstr"
## $ repo            <chr> "hrbrthemes", "hrbrthemes"
## $ tag             <chr> "v0.3.0", "v0.1.0"
## $ committer       <chr> "Bob Rudis", "boB Rudis"
## $ committer_email <chr> "bob@rud.is", "bob@rud.is"
## $ verified        <lgl> TRUE, FALSE
## $ reason          <chr> "-----BEGIN PGP SIGNATURE-----\n\niQIcBAABCAAGBQJZE1i5AAoJECpRSkmXRkVgYzAP/je9bp3imLA9LZPOF...
## $ signature       <chr> "-----BEGIN PGP SIGNATURE-----\n\niQIcBAABCAAGBQJZE1i5AAoJECpRSkmXRkVgYzAP/je9bp3imLA9LZPOF...
## $ payload         <chr> "tree d2959bd73ad3af822e7370553242fbf045438e8d\nparent 52539bf3dc91776c8cb988efdca6565b8b69...

get_tags("tidyverse/dplyr")
## # A tibble: 14 x 9
##         user  repo            tag       committer          committer_email verified reason signature payload
##        <chr> <chr>          <chr>           <chr>                    <chr>    <lgl>  <chr>     <chr>   <chr>
##  1 tidyverse dplyr      v0.6.0-rc          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  2 tidyverse dplyr         v0.5.0          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  3 tidyverse dplyr         v0.4.3 Romain Francois romain@r-enthusiasts.com    FALSE   <NA>      <NA>    <NA>
##  4 tidyverse dplyr         v0.4.2          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  5 tidyverse dplyr         v0.4.1          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  6 tidyverse dplyr         v0.4.0          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  7 tidyverse dplyr       v0.3.0.1  Hadley Wickham      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  8 tidyverse dplyr           v0.3          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
##  9 tidyverse dplyr         v0.2.0          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
## 10 tidyverse dplyr         v0.1.3          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
## 11 tidyverse dplyr         v0.1.2          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
## 12 tidyverse dplyr v0.1.2-cran-rc          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
## 13 tidyverse dplyr         v0.1.1 Romain François romain@r-enthusiasts.com    FALSE   <NA>      <NA>    <NA>
## 14 tidyverse dplyr           v0.1          hadley      h.wickham@gmail.com    FALSE   <NA>      <NA>    <NA>
```

### Code of Coduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
