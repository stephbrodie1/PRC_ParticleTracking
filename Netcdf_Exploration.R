#####This code opens netcdf files output from OceanParcels####
#Code to be used to make plots in R to understand/summarise results
#Written by Steph w/ edits expected from Elizabeth and Megan

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

#-----Create loop to loop through each year------

file_names <- list.files("~/Dropbox/PRC Particle Tracking/Parcels_output_total/Mon_11_-6_Box_36_38_1_4/", full.names = TRUE)
output <- as.data.frame(matrix(NA,nrow=24,ncol=5))
colnames(output) <- c("year","prop_30","prop_32","prop_34","prop_36")
counter=1
for (f in 1:length(file_names)){
  
  #----Open netcdf file-----
  #Use files in shared dropbox folder
  nc_file <- nc_open(file_names[f])
  # print(nc_file) #geolocation of 171 tracks for 214 days, at the surface.
  
  #grab year from filename 
  year <- as.numeric(unlist(strsplit(file_names[f],"_"))[14])
  print(year)
  
  #----Extract variables from Netcdf-----
  #According to 'print(file)' above, there are 5 variables: trajectory, time, lat, lon, and depth
  id <- ncvar_get(nc_file,'trajectory') #we don't really need to extract this because the dimension of 171 indicates 171 particles. 
  lat <- ncvar_get(nc_file,'lat') 
  lon <- ncvar_get(nc_file,'lon')
  z <- ncvar_get(nc_file,'z') #we don't need this yet because data is surface data
  time <- ncvar_get(nc_file,'time') #time is in seconds since origin date
  
  #----Convert variables to a dataframe------
  #Dataframes are super logical and easy to work with, compared to the matrix or array format that Netcdf files are built with
  #We want a dataframe that shows the coordinates for each trajectory ID and each day. 
  
  #First make dataframe for each variable
  lat_df <- melt(lat) #the 'melt' function does all the hard work to convert to a dataframe with 36594 rows (214 * 171) 
  colnames(lat_df) <- c("day","trajectory", "lat") #give our dataframe columnnames that make sense
  lon_df <- melt(lon)
  colnames(lon_df) <- c("day","trajectory", "lon")
  time_df <- melt(time)
  colnames(time_df) <- c("day","trajectory", "date")
  
  #Second merge dataframes together (not you can only merge two dataframes at once)
  df <- left_join(lon_df,lat_df, by=c("day","trajectory"))
  head(df)
  
  #Now let's add a date to the 'df' dataframe.
  #But first convert time to something sensible. 
  time_origin <- nc_file$var$time$units #get origin from netcdf file. Note that I could just manually type the origin date in, but it's better to get it from the file metadata so we can loop through files 
  time_origin <- unlist(strsplit(time_origin," "))[3] #split text string by "space", then unlist (strsplit function automatically returns a list), then take the third chunk which contains our date of interest
  time_df$date <- as.Date(time_df$date/86400, origin=time_origin) #convert to sensible time, with 86400 seconds in a day and origin from the netcdf file
  #Now add time to 'df'
  df <- left_join(df,time_df, by=c("day","trajectory"))
  head(df) #looks good!
  
  #-----Make a plot of each trajectory------
  #You don't need to do this in R because the code you already have is great, but adding some code to help me understand
  #Base plotting code
  # plot(df$lon,df$lat,col=df$trajectory, pch=19, main=paste0("Year ",year), ylim=c(30,50))
  # map('worldHires',add=TRUE, fill=TRUE, col="grey")
  
  #GGplot code: TBC
  
  #Animated GGplot
  #CAUTION: make sure you comment this out if you don't need it, otherwise the loop will take MUCH longer as each animation takes a while to render. 
  #Making this as a first step to understand which points are getting stuck on land
  animate_map <- ggplot(data = df, aes(x=lon,y=lat))+
    geom_point()+
    theme_classic() +  labs(y="", x="") +
    theme(legend.position="right",legend.title = element_blank())+
    theme( panel.border = element_rect(colour = "black", fill=NA, size=1)) + #makes a box
    # scale_fill_gradientn(colours = cmocean("matter")(256),limits = c(0, max(dat$abundance))) +
    annotation_map(map_data("world"), colour = "black", fill="grey50")+
    coord_quickmap(xlim=c(-134,-115.8),ylim=c(30,48)) +  #Sets aspect ratio
    scale_x_continuous(expand = c(0, 0)) +  scale_y_continuous(expand = c(0, 0))+
    transition_time(date)+
    ease_aes("linear") +
    labs(title="Backwards Trajectory 171 Particles {frame_time}") #takes some time
  animated <- gganimate::animate(animate_map,nframes = 214, fps=5, renderer = gifski_renderer(), rewind=TRUE)#renders in
  anim_save(paste0('AnimatedMap_Trajectory_backwards_',year,'.gif'), animated)
  
  #Next step for Steph: add in velocity field data for the animations
  #Also zoom in on an area where particles are stuck and look at the velocity fields (i.e. are they being pushed onshore by currents)
  
  #-----how to query if particles get stuck-----
  #super simple at this stage
  n_stuck <- as.numeric(summary(duplicated(df[,c(3,4)]))[3]) #number of days particles stay in the same place 
  print(paste0("Percent of time stuck on land ", (1-(36594-n_stuck)/36594)*100))
  # which(duplicated(df[,c(3,4)])) #index of which particles and days they are getting stuck
  
  #----Time-series: porportion of particles south of X degrees-----
  #Adjust latitudes depending on whether simulations are FORWARDS or BACKWARDS
  
  #Count how many particles ended south of 30 degrees
  p_30 <- length(unique(df$trajectory[df$lat<=30])) 
  #Count how many particles ended south of 32 degrees
  p_32 <- length(unique(df$trajectory[df$lat<=32])) 
  #Count how many particles ended south of 33 degrees
  p_34 <- length(unique(df$trajectory[ df$lat<=34]))
  #Count how many particles ended south of 36 degrees
  p_36 <- length(unique(df$trajectory[ df$lat<=36]))
  
  p_all <- 171 #because we now 171 unique particles
  prop_30 <- (p_30/p_all)
  prop_32 <- (p_32/p_all)
  prop_34 <- (p_34/p_all)
  prop_36 <- (p_36/p_all)
  
  #----write out data----
  output[counter,1] <- year
  output[counter,2] <- prop_30
  output[counter,3] <- prop_32
  output[counter,4] <- prop_34
  output[counter,5] <- prop_36
  counter = counter +1
  
  #Remember to close the netcdf file 
  nc_close(nc_file)
}
summary(output)

#-----Make Time-series Plots----
#Basic R code
plot(output$year,output$prop_30, col="black", type="b", ylim=c(0,1), ylab="Proportion",xlab="Year", main="Proportion of Particles south of X degrees")
lines(output$year,output$prop_32, col="green", type="b")
lines(output$year,output$prop_34, col="red", type="b")
lines(output$year,output$prop_36, col="blue", type="b")
legend("topright",legend=c("30 degrees","32 degrees","34 degrees","36 degrees"),col=c("black","green","red","blue"), lty=c(1,1,1))

#-----END------

