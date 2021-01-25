#Code to subset global netcdf files: uses NCO
#For red crab particle tracking analysis
#Desired domain: 0 - 50 degrees N; -150 to -100 degrees west
#File types: (1) surface u & v, temp & salinity; (2) 0-500m u, v, temp & salinity

#Note: this code uses command line syntax, as indictaed by system()

#-----install NCO----
#Install developer tools
# system(xcode-select --install)

#Install homebrew if you don't have it (homebrew website: https://brew.sh/)
# system(sudo xcode-select -s /Library/Developer/CommandLineTools) #prepares for homebrew
# system(/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

#Install nco
# system(brew install nco)

#-----Couple of simple NCO commands----
#STORING HERE
# Plot metadata
# ncdump -h file_in.nc

# Print the values for a single variable (e.g., depth) #CAUTION: only run this for certain variables
# ncdump -v variable_name file_in.nc

# Extract a single variable to a new file
# ncks -v variable_name file_in.nc file_out.nc # Example: Extract temperature (variable name thetao) from a GLORYS file to a new file (glorys_temp.nc) ncks -v thetao glorys_sample_day.nc glorys_temp.nc

# Extract temperature for a subset region
# ncks -F -v thetao -d dimension,min,max,stride -d dimension,min,max,stride file_in.nc file_out.nc
# Example: Extract temperature from GLORYS for northeast Pacific only ncks -F -v thetao -d longitude,-140.0,-110.0,1 -d latitude,25.0,50.0,1 glorys_sample_day.nc ccs_temp.nc
# Example: Extract surface temperature from GLORYS for northeast Pacific only ncks -F -v thetao -d longitude,-140.0,-110.0,1 -d latitude,25.0,50.0,1 -d depth 1,1,1 glorys_sample_day.nc ccs_sst.nc
# FYI: Including decimals in the dimensions will extract between the specified latitude and longitudes. If no decimals are used, then the subsetting is done by index rather than the actual lat/lon 
# FYI: -F specifies that counting starts at 1 instead of 0
# FYI: Stride is the spacing between records being extracted. To extract everything, stride is 1, if one wanted to extract every fifth latitude, for example, stride would be 5.

#----Now let's try it for some files

# in_dir <- "~/Dropbox/PRC Particle Tracking/Velocity_NetCDF_Subsurface_0-500m/2002/"
input_files <- list.files("~/Dropbox/PRC Particle Tracking/Velocity_NetCDF_Subsurface_0-500m/2002/", full.names = TRUE)
out_dir <- '~/Dropbox/PRC Particle Tracking/test_outputfiles/'

for (i in 1:length(input_files)){
  print(input_files[[i]])
  system2("ncdump -h", input =input_files[[i]], stdout = "", stderr = "") #-h is header
  file <- "mercatorglorys12v1_gl12_mean_20021230_R20030101_0-500mDepth.nc"
  file_out <- "mercatorglorys12v1_gl12_mean_20021230_R20030101_0-500mDepth_REVISED.nc"
  system2('ncdump', args=c('-h', file))
  
  system2('ncks', args=c('-F', '-v', 'thetao', '-d', 'lon,-130.0,-115.0,1',
                         '-d', 'lat,25.0,40.0,1',file,file_out))

}

