library(ggmap)
library(raster)
library(automap)
library(splancs)
library(maps)
library(foreach)
library(doMC)

registerDoMC(20)

getRaster <- function(file, boundingbox)
{
	yearlyTemp <- read.csv(file, header=T) # load file
	for (i in 1:12) #Subset by month 1:12
	{
		sub <- yearlyTemp[yearlyTemp$Month==i,]		
		foreach (j=1:31) %dopar% #Subset by day 1:31 
		{			
			myDay <- sub[,c(1:8,j+8)] 			
			myDay[myDay=="-9999"] <- NA #Replace ascii no data (-9999) with R no data (NA)			
			t <- na.omit(myDay) #Omit rows with no data values
			if (nrow(t) == 0) #check if you have run out of days in the month 
			{				
				return 
			} 
			else 
			{
				coordinates(t) <- ~ Lon+Lat #Specify coordinate columns in temperature data frame
				day <- paste("Day", j, sep="") 			
				kriging_result <- autoKrige(t[[day]]~1, t, boundingbox) #Interpolate temperatures using ordinary kriging
				#plotting
				#plot(kriging_result)
				#image(kriging_result$krige_output)
				#map("state", add=T)
				#Convert kriging results to raster and write to ascii file
				myraster <- raster(kriging_result$krige_output)
				measure <- strsplit(file, "_")[[1]][2] 				
				year <- substr(strsplit(file, "_")[[1]][5], 1, 4)			
				mybase <- paste(measure, i, j, year, "5ArcMin", sep="_")
				newRaster <- paste(mybase, ".asc", sep="") 			
				writeRaster(myraster, filename=newRaster, format="ascii", overwrite=TRUE)
			}
		}
	}
}

#Create new lat (y) and lon (x) values with a bounding box for the us for interpolation grid
#10 arc minutes = 0.16666666666666666
#5 arc minutes = 0.0833333333335
#1 arc minute = 0.0166666666667
newX <- seq(-124.68134, -67.00742, by= 0.0833333333335)
newY <- seq(25.12993, 49.38323, by= 0.0833333333335)
newXY = expand.grid(newX,newY) #Create intepolation grid with all pairs of lat and lon
names(newXY)=c('x','y') #change the lon/lat colum headings to x/y in the interpolation grid
us <- map("usa") #store us map data
#create dataframe with coordinate sorounding the continental us
usaBound <- data.frame(us$x, us$y)
usaBound <- na.omit(usaBound)
#test if coordinates in interpolation grid fall within the us
test2 <- inout(newXY, usaBound)
#subset interpolation grid to include only coordinates in the us
inUSA <- newXY[,1:2][test2==T,]
#change interpolation datafram to spatial data frame
names(inUSA) <- c("Lon", "Lat")
coordinates(inUSA) <- ~Lon+Lat
gridded(inUSA) <- T

#create a list of all temerature files
files <- list.files(path="~/TentProject/yearly/past12", pattern="*.txt2", full.names=T, recursive=FALSE)

#Read in lat,lon,daily temperature files and apply the kriging function
lapply(files, function(x) {
	# apply function
	getRaster(x, inUSA)
    	})

#read in ascii file
#r <- raster("Jan1_1922.asc")
