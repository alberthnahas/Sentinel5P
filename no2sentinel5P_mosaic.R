######################################################################################
# This is an R script to create a raster map from L2 NO2 SENTINEL 5P.                #   
# Input files are of a NETCDF (.nc) type taken from satellite observations.          #
# Files are downloaded from https://s5phub.copernicus.eu/dhus/#/home, with user and  #
#     password are s5pguest and s5pguest, respectively.                              #
# This script transforms a mosaic consisting of a number of satellite observations   #
#     in one day to a dataframe.                                                     #
# Refer to below comments for more detailed instructions/explanations.               #
# Created by Alberth Nahas on 2022-04-21 07:00 am WIB.                               #
# Email: alberth.nahas@bmkg.go.id                                                    #
# Version 1.0.0                                                                      #
# Disclaimer: This is a free-to-share, free-to-use script. That said, it comes with  #
#             absolutely no warranty. User discretion is advised.                    #
######################################################################################


### CLEAR WORKSPACE ###
rm(list = ls())
gc()
start.clock <- Sys.time()

### INCLUDE LIBRARIES ###
require(maptools)
require(raster)
require(ncdf4)
require(sp)

### SET .nc FILES TO WORK WITH ###
setwd("~/Documents/R/Rprojects/")
ffile <- file.choose() 
fn01 <- basename(ffile)
fpath <- dirname(ffile)

### COLLECT .nc FILES ON A LIST ###
fn <- list.files(path = fpath, 
                 pattern = "S5P_", 
                 all.files = FALSE, 
                 full.names = FALSE, 
                 recursive = FALSE)
print(paste("There are ",length(fn), " netcdf file(s) in this directory."))

### CHECK FILE ATTRIBUTES ###
ncfile <- nc_open(fn[1])
attributes(ncfile)$names
attributes(ncfile$var)$names
print(paste("The file has",ncfile$nvars, "variables,",
            ncfile$ndims,"dimensions and",
            ncfile$natts,"NetCDF attributes."))
nc_close(ncfile)

### SOME NAMING ###
fvar <- substr(fn01, start = 14, stop = 16)
fdate <- substr(fn01, start = 21, stop = 28)
ncname <- paste0(fvar, "_", fdate,"_L2_SENTINEL_5P.nc")
csvname <- paste0(fvar, "_", fdate,"_L2_SENTINEL_5P.csv")

### CONSTRUCT A DATAFRAME FROM .nc FILES ###
no2df <- NULL
for (i in seq_along(fn)) {
  nc <- nc_open(fn[i])
  tc_no2 <- ncvar_get(nc, "PRODUCT/nitrogendioxide_tropospheric_column")
  mfactor = ncatt_get(nc, "PRODUCT/nitrogendioxide_tropospheric_column", 
                      "multiplication_factor_to_convert_to_molecules_percm2")
  fillvalue = ncatt_get(nc, "PRODUCT/nitrogendioxide_tropospheric_column", 
                        "_FillValue")
  # apply multiplication factor for unit conversion
  tc_no2 <- tc_no2 * mfactor$value * 1e-15 # expressed in 10^15 molecules per cm^2
  lat <- ncvar_get(nc, "PRODUCT/latitude")
  lon <- ncvar_get(nc, "PRODUCT/longitude")
  # concatenate the new data to the global data frame
  no2df <- rbind(no2df, data.frame(lat=as.vector(lat), 
                                   lon=as.vector(lon), 
                                   tc_no2=as.vector(tc_no2)))
  # close file
  nc_close(nc)
}

### CREATE A .csv FILE TO BUILD THE RASTER FILE ###
write.csv(no2df, file = csvname, row.names = FALSE, quote = TRUE, na = "NA")

### CREATE A RASTER FILE FROM THE .csv FILE ###
# Generating a netcdf file by following a template.
# Resolution of the file may be changed, but make sure it will be
#    well-mapped when plotted.
# Lon-lat boundaries cover the Indonesian Region.
pts <- read.table(csvname, header = TRUE, sep = ",")
coordinates(pts) <- ~lon+lat
rst01 <- raster(resolution = 0.06, 
                xmn = 94.95, # Western-most boundary
                xmx = 141.05, # Eastern-most boundary
                ymn = -11.05, # Southern-most boundary
                ymx = 6.05) # Northern-most boundary
# Raster file generated with max values for overlapping grid cell(s).
rst <- rasterize(pts, rst01, pts$tc_no2, fun = max) # max is used instead of mean
rst <- reclassify(rst, cbind(-Inf, NA))
proj4string(rst) <- CRS("+init=EPSG:4326") # Standard WGS 84 map projection
ncdf <- brick(rst)
# Some file metadata are created, others may be added.
writeRaster(ncdf, 
            file = ncname, 
            overwrite = TRUE, 
            format = "CDF", # A netcdf format
            varname = "tropcolumn_no2", 
            varunit = "x 10^15 molecules per cm^2", 
            longname = "Tropospheric vertical column of nitrogen dioxide Sentinel-5P",
            xname = "longitude",
            yname = "latitude", 
            zname="time") # Timestep and time origin are not specified

### PRINT ELAPSED TIME ###
stop.clock <- Sys.time()
how.many <- round(as.numeric(difftime(stop.clock, start.clock, units = "mins")), 2)
time.spent <- paste("Work has been completed in", how.many,"minutes")
print(time.spent)


### END OF LINE ###