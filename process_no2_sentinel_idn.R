######################################################################################
# This is an R script to process daily total column NO2 from SENTINEL-5P.            #   
# Product info: https://sentinels.copernicus.eu/web/sentinel/missions/sentinel-5p.   #
# Refer to below comments for more detailed instructions/explanations.               #
# Change line 60 to adjust to the right directory.                                   #
# Created by Alberth Nahas on 2022-06-26 04:00 pm WIB.                               #
# Email: alberth.nahas@bmkg.go.id.                                                   #
# Version 1.0.0.                                                                     #
# Disclaimer: This is a free-to-share, free-to-use script. That said, it comes with  #
#             absolutely no warranty. User discretion is advised.                    #
######################################################################################


### CLEAR WORKSPACE ###
rm(list = ls())
gc()
start.clock <- Sys.time()

### ASSIGN WORKING DIRECTORIES ###
dir <- "~/Documents/SATELLITE/SENTINEL_5P/"

### CREATE ACCOUNT AT https://scihub.copernicus.eu/dhus/#/home ###
user <- "youraccount"
pass <- "yourpassword"


### INCLUDE LIBRARIES ###
require(getSpatialData)
require(sp)
require(dplyr)
require(maptools)
require(raster)
require(ncdf4)
require(gdalUtils)


### SET TIMEFRAME ###
today <- Sys.Date()
tomorrow <- today+1
yesterday <- today-1
start_date <- as.character(today)
end_date <- as.character(tomorrow)
nc_date <- as.character(yesterday)


### SET AREA OF INTEREST FOR INDONESIA ###
indonesia <- cbind(c(90, 90, 145, 145), c(10, -15, -15, 10))
p <- Polygon(indonesia)
ps <- Polygons(list(p),1)
sps <- SpatialPolygons(list(ps))
proj4string(sps) = CRS("+proj=longlat +datum=WGS84 +no_defs")
set_aoi(sps)


### LOGIN TO ACCESS PRODUCTS ###
login_CopHub(username = user, password = pass)


### QUERY THE DATA BASED ON TIME AND PRODUCTS ###
# Use get_products to list the available products
records <- get_records(time_range = c(start_date, end_date),
                       products = c("Sentinel-5P"))
# Filter records for specific product(s)
records_no2 <- records[records$product_type == "L2__NO2___",]
nrti_no2 <- records_no2 %>% filter(grepl('NRTI', record_id))
# Download files
set_archive(dir)
records <- get_data(nrti_no2, dir_out = dir)


### COLLECT .nc FILES ON A LIST ###
new_wd <- paste0(dir,"/sentinel-5p/")
dir2 <- setwd(new_wd)
dir2 <- setwd(new_wd)
fn <- list.files(path = dir2, 
                 pattern = "S5P_NRTI_L2__NO2", 
                 all.files = FALSE, 
                 full.names = FALSE, 
                 recursive = FALSE)
print(paste("There are ",length(fn), " netcdf files in this directory."))


### CHECK FILE ATTRIBUTES ###
ncfile <- nc_open(fn[1])
attributes(ncfile)$names
attributes(ncfile$var)$names
print(paste("This file has",ncfile$nvars, "variables,",
            ncfile$ndims,"dimensions and",
            ncfile$natts,"NetCDF attributes."))
nc_close(ncfile)


### SOME NAMING ###
fvar <- substr(fn[1], start = 14, stop = 16)
fdate <- substr(fn[1], start = 21, stop = 28)
transit <- paste0("temp.nc")
ncname <- paste0("no2.sentinel-5p.nc")
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
  qa <- ncvar_get(nc, "PRODUCT/qa_value")
  # concatenate the new data to the global data frame
  no2df <- rbind(no2df, data.frame(lat=as.vector(lat), 
                                   lon=as.vector(lon),
                                   qa = as.vector(qa),
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
rst01 <- raster(resolution = 0.1, 
                xmn = 90, # Western-most boundary
                xmx = 145, # Eastern-most boundary
                ymn = -15, # Southern-most boundary
                ymx = 10) # Northern-most boundary
# Raster file generated with max values for overlapping grid cell(s).
rst <- rasterize(pts, rst01, pts$tc_no2, fun = max) # max is used instead of mean
rst <- reclassify(rst, cbind(-Inf, NA))
proj4string(rst) <- CRS("+init=EPSG:4326") # Standard WGS 84 map projection
ncdf <- brick(rst)
# Some file metadata are created, others may be added.
writeRaster(ncdf, 
            file = transit, 
            overwrite = TRUE, 
            format = "CDF", # A netcdf format
            varname = "tropcolumn_no2", 
            varunit = "x 10^15 molecules per cm^2", 
            longname = "Tropospheric vertical column of nitrogen dioxide Sentinel-5P",
            xname = "longitude",
            yname = "latitude", 
            zname ="time",
            zunit = paste0("days since ",nc_date))
# Add Coordinate Reference System
gdal_translate(transit, a_srs = "EPSG:4326", of = "netCDF", ncname)


### HOUSEKEEPING ###
unlink(transit)
unlink('S5P_NRTI_L2__NO2*')


### PRINT ELAPSED TIME ###
stop.clock <- Sys.time()
how.many <- round(as.numeric(difftime(stop.clock, start.clock, units = "mins")), 2)
time.spent <- paste("Work has been completed in", how.many,"minutes")
print(time.spent)


### END OF LINES ###
