#Red Crabs Particle Tracking
#Modify Glorys 3D files to extract currents at 200m, within CC domain.
#Need output files to be ncdf
# PRC domain: 0 - 50 degrees N; -150 to -100 degrees west

library(ncdf4)

files <- list.files('/Volumes/Triple_Bottom_Line/Data/GlobalData/CMEMS_Physics_OceanModel/Historical/2002/', recursive = TRUE, full.names = TRUE)
shortname_file <- list.files('/Volumes/Triple_Bottom_Line/Data/GlobalData/CMEMS_Physics_OceanModel/Historical/2002/', recursive = TRUE, full.names = FALSE)
for (f in 1:length(files)){
  print(files[f])
  
  #Open glorys file
  nc_full <- nc_open(files[f])
  # print(nc_full)
  
  #get vars
  latitude <- ncvar_get(nc_full,'latitude')
  longitude<- ncvar_get(nc_full,'longitude')
  depth<- ncvar_get(nc_full,'depth')
  time<- ncvar_get(nc_full,'time')
  vo<- ncvar_get(nc_full,'vo')
  uo<- ncvar_get(nc_full,'uo')
  
  #Get revised dims
  lat <- latitude[961:1561]
  lon <- longitude[361:961]
  depth_186 <- depth[26]
  vo2 <- vo[361:961,961:1561,26]
  uo2 <- uo[361:961,961:1561,26]
  
  #Create new file
  #Set dims
  lon_4 <-ncdim_def("lon", "degrees_east", lon)
  lat_4 <-ncdim_def("lat", "degrees_north", lat)
  depth_4 <- ncdim_def("depth", "m", depth_186)
  time_4 <- ncdim_def("time", "hours since 1950-01-01 00:00:00", time)
  #Set Var
  vo_4 <-ncvar_def("vo", "m s-1", list(lon_4,lat_4, depth_4, time_4), -999, longname="Northward velocity", prec="single", compression=5)
  uo_4 <-ncvar_def("uo", "m s-1", list(lon_4,lat_4,depth_4, time_4), -999, longname="Eastward velocity", prec="single", compression=5)
  #Create nc
  sp1 <- unlist(strsplit(shortname_file[f],'.nc'))
  sp2 <- unlist(strsplit(sp1,'/'))[2]
  ncdf_186<-nc_create(paste('~/Dropbox/PRC Particle Tracking/Velocity_NetCDF_Subsurface/2002/',sp2,"_186mDepth.nc", sep=""), list(vo_4,uo_4), force_v4=TRUE)
  #Add data
  ncvar_put(ncdf_186, vo_4, vo2)
  ncvar_put(ncdf_186, uo_4, uo2)
  #close
  nc_close(ncdf_186) #have to close it 

}

#This section gets u, v, temp, and salinity from 0-500m depth for CCS domain

files <- list.files('/Volumes/Triple_Bottom_Line/Data/GlobalData/CMEMS_Physics_OceanModel/Historical/2002/', recursive = TRUE, full.names = TRUE)
shortname_file <- list.files('/Volumes/Triple_Bottom_Line/Data/GlobalData/CMEMS_Physics_OceanModel/Historical/2002/', recursive = TRUE, full.names = FALSE)
for (f in 1:length(files)){
  print(files[f])
  
  #Open glorys file
  nc_full <- nc_open(files[f])
  # print(nc_full)
  
  #get vars
  latitude <- ncvar_get(nc_full,'latitude')
  longitude<- ncvar_get(nc_full,'longitude')
  depth<- ncvar_get(nc_full,'depth')
  time<- ncvar_get(nc_full,'time')
  vo<- ncvar_get(nc_full,'vo')
  uo<- ncvar_get(nc_full,'uo')
  thetao<- ncvar_get(nc_full,'thetao')
  so<- ncvar_get(nc_full,'so')
  
  #Get revised dims
  lat <- latitude[961:1561]
  lon <- longitude[361:961]
  depth2 <- depth[1:31] #0.49m to 541m
  vo2 <- vo[361:961,961:1561,1:31]
  uo2 <- uo[361:961,961:1561,1:31]
  thetao2 <- thetao[361:961,961:1561,1:31]
  so2 <- so[361:961,961:1561,1:31]
  
  #Create new file
  #Set dims
  lon_4 <-ncdim_def("lon", "degrees_east", lon)
  lat_4 <-ncdim_def("lat", "degrees_north", lat)
  depth_4 <- ncdim_def("depth", "m", depth2)
  time_4 <- ncdim_def("time", "hours since 1950-01-01 00:00:00", time)
  #Set Var
  vo_4 <-ncvar_def("vo", "m s-1", list(lon_4,lat_4, depth_4, time_4), -999, longname="Northward velocity", prec="single", compression=5)
  uo_4 <-ncvar_def("uo", "m s-1", list(lon_4,lat_4,depth_4, time_4), -999, longname="Eastward velocity", prec="single", compression=5)
  thetao_4 <-ncvar_def("thetao", "degrees_C", list(lon_4,lat_4, depth_4, time_4), -999, longname="sea_water_potential_temperature", prec="single", compression=5)
  so_4 <-ncvar_def("so", "1e-3", list(lon_4,lat_4,depth_4, time_4), -999, longname="Salinity", prec="single", compression=5)
  
  #Create nc
  sp1 <- unlist(strsplit(shortname_file[f],'.nc'))
  sp2 <- unlist(strsplit(sp1,'/'))[2]
  ncdf_186<-nc_create(paste('~/Dropbox/PRC Particle Tracking/Velocity_NetCDF_Subsurface_0-500m/2002/',sp2,"_0-500mDepth.nc", sep=""), list(vo_4,uo_4, thetao_4, so_4), force_v4=TRUE)
  #Add data
  ncvar_put(ncdf_186, vo_4, vo2)
  ncvar_put(ncdf_186, uo_4, uo2)
  ncvar_put(ncdf_186, thetao_4, thetao2)
  ncvar_put(ncdf_186, so_4, so2)
  #close
  nc_close(ncdf_186) #have to close it 
  
}
