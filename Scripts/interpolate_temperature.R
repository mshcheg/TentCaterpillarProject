library(ggmap)
library(raster)
library(automap)
library(splancs)
library(maps)

#Read in lat,lon,daily temperature file
min1922 <- read.csv("us_tmin_daily_latlon_1922.txt2", header=T)


#Create new lat (y) and lon (x) values with a bounding box for the us for interpolation grid
#10 arc minutes = 0.16666666666666666
newX <- seq(-124.68134, -67.00742, by= 0.16666666666666666)
newY <- seq(25.12993, 49.38323, by= 0.16666666666666666)
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

for (i in 1:2) #Subset by month {
	sub <- min1922[day2$Month==i,]
	for (j in 1:31) #Subset by day 1:31 {
		sub <- sub[,c(1:8,j+8)] 
		sub[sub=="-9999"] <- NA #Replace ascii no data (-9999) with R no data (NA)
		t <- na.omit(sub) #Omit rows with no data values 
		if (nrow(t) == 0) #check if you have run out of days in the month {
			break 
		} else {
			coordinates(t) <- ~ Lon+Lat #Specify coordinate columns in temperature data frame
			kriging_result <- autoKrige(Day2~1, t, inUSA) #Interpolate temperatures using ordinary kriging
			#plotting
			#plot(kriging_result)
			#image(kriging_result$krige_output)
			#map("state", add=T)

			#Convert kriging results to raster and write to ascii file
			myraster <- raster(kriging_result$krige_output)
			writeRaster(myraster, filename="Jan1_1922.asc", format="ascii")
		}
	}
}


#read in ascii file
#r <- raster("Jan1_1922.asc")




#Read in lat,lon,daily temperature file
min1922 <- read.csv("us_tmin_daily_latlon_1922.txt2", header=T)


#Subset by day 1:31
day2 <- min1922[,c(1:8,39)]

#Subset by month
day2month1 <- day2[day2$Month==9,]
#Replace ascii no data (-9999) with R no data (NA)
day2month1[day2month1=="-9999"] <- NA
#Omit rows with no data values 
t <- na.omit(day2month1)

#Specify coordinate columns in temperature data frame
coordinates(t) <- ~ Lon+Lat

#Create new lat (y) and lon (x) values with a bounding box for the us for interpolation grid
#10 arc minutes = 0.16666666666666666
newX <- seq(-124.68134, -67.00742, by= 0.16666666666666666)
newY <- seq(25.12993, 49.38323, by= 0.16666666666666666)
#Create intepolation grid with all pairs of lat and lon
newXY = expand.grid(newX,newY)
#change the lon/lat colum headings to x/y in the interpolation grid
names(newXY)=c('x','y')

#store us map data
us <- map("usa")
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

#Interpolate temperatures using ordinary kriging 
kriging_result <- autoKrige(Day2~1, t, inUSA)

#plotting
#plot(kriging_result)
#image(kriging_result$krige_output)
#map("state", add=T)

#Convert kriging results to raster and write to ascii file
myraster <- raster(kriging_result$krige_output)
writeRaster(myraster, filename="Jan1_1922.asc", format="ascii")

#read in ascii file
#r <- raster("Jan1_1922.asc")

