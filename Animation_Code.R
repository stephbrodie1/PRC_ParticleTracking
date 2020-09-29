##### Animated Plots ######
#This code animates backwards particles on top of velocity fields
#Plots used to help visualise why particles are getting 'stuck'
#Written by Steph
#Sep 25 2020

#----load librarys-----
library(ncdf4)
library(raster)
library(reshape2)
library(dplyr)
library(maps)
library(maptools)
library(mapdata)
library(ggplot2)
library(gganimate)
library(gifski)
library(cmocean)

#---Animate velocity data with crab trajectories-----

for(y in c(2015:2016)){ #1994, 2007, 2010, 2012, 2014 have a different file structure, just excluding them for now
  vel_output <- as.data.frame(matrix(NA,nrow=85600,ncol=9))
  colnames(vel_output) <- c("lon","lat","u","v", "vel","lats","lons","year","DOY")
  counter=1
  
  files <- list.files(paste0("~/Dropbox/PRC Particle Tracking/Velocity_NetCDF/",y), full.names = TRUE)
  
  #Get Julian dates of backwards simulation
  j1 <- as.numeric(format(as.Date(paste0(y,"-05-01"),format="%Y-%m-%d"),"%j"))
  j2 <- as.numeric(format(as.Date(paste0(y,"-11-30"),format="%Y-%m-%d"),"%j"))
  
  for (f in j1:j2){
    print(f)
    #Open ncfile
    nc <- nc_open(files[f])
    #Get day of year
    DOY <- as.numeric(unlist(strsplit(files[f],"_"))[3])
    #get vars
    lat <- ncvar_get(nc,'lat') 
    lon <- ncvar_get(nc,'lon')
    u <- ncvar_get(nc,'U')
    v <- ncvar_get(nc,'V')
    #reshape to dataframe
    u_df <- melt(u)
    v_df <- melt(v)
    lat_df <- melt(lat)
    lon_df <- melt(lon)
    df <- left_join(u_df,v_df,by=c("Var1","Var2"))
    colnames(df) <- c("lon","lat","u","v")
    df$vel <- sqrt(df$u^2 + df$v^2)
    df$lats  <- rep(seq(from= min(lat),to = max(lat),length.out=200), each=200)
    df$lons  <- rep(seq(from= min(lon),to = max(lon),length.out=200),200)
    df$year <- y
    df$DOY <- DOY
    df_trim<- df
    df_trim <- df_trim[df_trim$lats<=40 & df_trim$lats>=35,]
    df_trim <- df_trim[df_trim$lons<=-120 & df_trim$lons>=-125,]
    
    #write out data
    sc <- counter
    ec <- counter + 399
    vel_output[sc:ec,] <- df_trim
    
    #prepare for next loop iteration
    counter = counter + 400
    nc_close(nc)
  }
  vel_output$date <- as.Date(paste0(vel_output$year,vel_output$DOY), format = "%Y%j")
  
  #get red crab data and merge with vel_output (note this is the same code from Netcdf_Exploration, just more compacted)
  tracking_files <- list.files("~/Dropbox/PRC Particle Tracking/Parcels_output_total/Mon_11_-6_Box_36_38_1_4/", full.names = TRUE)
  years <- c(1993:2016)
  idx <- which(years %in% y) #y is in the loop
  nc_file <- nc_open(tracking_files[idx])
  id <- ncvar_get(nc_file,'trajectory') #we don't really need to extract this because the dimension of 171 indicates 171 particles. 
  lat <- ncvar_get(nc_file,'lat') 
  lon <- ncvar_get(nc_file,'lon')
  time <- ncvar_get(nc_file,'time') #time is in seconds since origin date
  lat_df <- melt(lat) #the 'melt' function does all the hard work to convert to a dataframe with 36594 rows (214 * 171) 
  colnames(lat_df) <- c("day","trajectory", "lat") #give our dataframe columnnames that make sense
  lon_df <- melt(lon)
  colnames(lon_df) <- c("day","trajectory", "lon")
  time_df <- melt(time)
  colnames(time_df) <- c("day","trajectory", "date")
  df <- left_join(lon_df,lat_df, by=c("day","trajectory"))
  time_origin <- nc_file$var$time$units #get origin from netcdf file. Note that I could just manually type the origin date in, but it's better to get it from the file metadata so we can loop through files 
  time_origin <- unlist(strsplit(time_origin," "))[3] #split text string by "space", then unlist (strsplit function automatically returns a list), then take the third chunk which contains our date of interest
  time_df$date <- as.Date(time_df$date/86400, origin=time_origin) #convert to sensible time, with 86400 seconds in a day and origin from the netcdf file
  nc_close(nc_file)
  #Now add time to 'df'
  df <- left_join(df,time_df, by=c("day","trajectory"))
  colnames(df) <- c("day","trajectory","lon_tj","lat_tj","date")
  df <- df[df$lat_tj<=40 & df$lat_tj>=35,]
  df <- df[df$lon_tj<=-120 & df$lon_tj>=-125,]
  

  # d = "1993-05-01" #[vel_output$date==d,]
  vel_animated <- ggplot(data=vel_output,aes(x=lons,y=lats))+
    geom_tile(aes(fill=vel))+
    scale_fill_gradientn(colours = cmocean("speed")(256)) +
    theme_classic()+
    labs(x = "", y = "")+
    annotation_map(map_data("world"), colour = "black", fill="grey50")+
    coord_quickmap(xlim=c(-125,-120),ylim=c(35,40)) +  #Sets aspect ratio
    scale_x_continuous(expand = c(0, 0)) +  scale_y_continuous(expand = c(0, 0))+
    theme(panel.border = element_rect(colour = "black", fill=NA, size=1))+
    geom_segment(data = vel_output, 
                 aes(x = lons, xend = lons+u, y = lats, 
                     yend = lats+v), arrow = arrow(length = unit(0.2, "cm")))+
    geom_point(data = df, aes(x=lon_tj,y=lat_tj,col="red"))+
    transition_time(date)+
    ease_aes("linear") +
    labs(title="Velocity Fields: Day {frame_time}") #takes some time
  
  animated <- gganimate::animate(vel_animated,nframes = 214, fps=4, renderer = gifski_renderer(), rewind=FALSE)#renders in
  anim_save(paste0('AnimatedMap_Trajectory_backwards_withVelocity',y,'.gif'), animated)
  
  rm(vel_output)
}





  
  
  


