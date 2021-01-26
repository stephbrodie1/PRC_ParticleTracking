#Code to subset global netcdf files: uses NCO
#For red crab particle tracking analysis
#Desired domain: 0 - 50 degrees N; -150 to -100 degrees west
#File types: (1) surface u & v, temp & salinity; (2) 0-500m u, v, temp & salinity
#Note: this code uses command line syntax, as indicted by system2()

#To install NCO, and to see a good summary of what it can do go here: https://github.com/elhazen/NCO_ERD

#---library----
library(glue)

#----Subset u,v,s,t for CCS----
#Loop through global glorys historical netcdf files (using nested loops because of folder structure)
#Create new netcdfs for CCS domain for variables u, v, salinity, temp

dir <- "/Volumes/Triple_Bottom_Line/Data/GlobalData/CMEMS_MLD_New/Historical/"
out_dir <- '/Volumes/Triple_Bottom_Line/Steph_working/PRC/velocity_nc_0-500/'
for (y in 1993:2017){
  for (m in c("01","02","03","04","05","06","07","08","09","10","11","12")){
    print(glue("running year {y} and month {m}"))
    input_files <- list.files(glue('{dir}{y}/{m}'), full.names = T)
    for (i in 1:length(input_files)){
      file <- input_files[[i]]
      fdate <- unlist(strsplit(input_files[[i]],"_"))[8]
      year <- lubridate::year(as.Date(fdate,"%Y%m%d"))
      jdate <- format(as.Date(fdate,"%Y%m%d"), "%j")
      
      out_dir_year <- glue("{out_dir}{y}")
      dir.create(out_dir_year)
      #File_out needs a specific naming terms inc: full date, year, julian date
      file_out <- glue("{out_dir}{y}/mercatorglorys12v1_gl12_mean_{fdate}_{year}_{jdate}_uvst_surface_ccs.nc")
      
      # system2('ncdump', args=c('-h', file)) #check out headers
      # system2('ncdump', args=c('-v','depth', file)) #check out depth intervals
      # system2('ncks') #check out switches for kitchen sink command
      system2('ncks', args=c('-F', '-v', 'vo,uo,so,thetao',
                             '-d', 'longitude,-150.0,-100.0,1',
                             '-d', 'latitude,0.0,50.0,1',
                             '-d', 'depth,1,31,1',
                             file,file_out))
    }
  }
}

#----Repeat for NRT file structure----
#TBC

#----END----

