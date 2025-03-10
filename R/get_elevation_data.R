#' Get elevation data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves the elevation (in meters) for those locations at an approximate 100m spatial resolution.
#' Data come from the [SRTM](https://www.usgs.gov/centers/eros/science/usgs-eros-archive-digital-elevation-shuttle-radar-topography-mission-srtm-1)
#' DEM which are accessed through the Amazon Web Services (AWS) API and the [`elevatr`](https://CRAN.R-project.org/package=elevatr)
#' R package.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#'
#' @returns data.frame
#'
#' @examples
#' \donttest{
#'
#' get_elevation_data(lon = template_WES_data$lon,
#'                    lat = template_WES_data$lat)
#'
#' }

get_elevation_data <- function(lon,
                               lat
){

     # Checks
     check <- length(lat) == length(lon)
     if (!check) stop('lat and lon args must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')

     # Get distinct coordinate sets
     unique_lonlat <- data.frame(x=lon, y=lat)
     unique_lonlat <- dplyr::distinct(unique_lonlat)
     n_locations <- nrow(unique_lonlat)

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message("Downloading elevation data from AWS API via elevatr package ...")

     wgs_proj_string <- sf::st_crs(sp::CRS('+proj=longlat +datum=WGS84'))

     data_elev <- elevatr::get_elev_point(locations = unique_lonlat,
                                          prj = wgs_proj_string,
                                          src = 'aws',
                                          z = 10)

     out <- data.frame(
          lon = unique_lonlat$x,
          lat = unique_lonlat$y,
          elevation = data_elev$elevation
     )

     return(out)

}
