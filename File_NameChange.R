#Quick R code to change file names
#Jan 12 2021

#---Step 1: read in files
#UPDATE WD
setwd("~/Dropbox/PRC Particle Tracking/Velocity_NetCDF_Subsurface_186m/2002/")
files <- list.files()

#---Step 2: change name
for (d in 1:length(files)){
  split <- unlist(strsplit(files[d],"_"))
  date <- as.Date(split[4],format="%Y%m%d")
  date_j <- format(date,"%j")
  year <- format(date,"%Y")
  split_new <- paste(split[1],split[2],split[3],split[4],year,date_j,"uv",split[6],sep="_")
  
  #---Step 3: save new name
  file.rename(from = files[d] , to = split_new)
}
