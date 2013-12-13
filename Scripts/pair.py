'''
Pair location name with lat/lon data from ushcn-stations.txt.

Downloaded from http://cdiac.ornl.gov/ftp/ushcn_daily/

Split into files for each individual year.

'''

def writefile(y):

    def latlon(x):
        with open(x, 'r') as infile:
            latlonDB = {}
            for line in infile:
                line = line.strip("\n").split()
                ID = line[0].strip()
                Lat = line[1].strip()
                Lon = line[2].strip()
                State = line[4].strip()
                Name = line[5].strip()
                latlonDB[ID]={"Lat":Lat,"Lon":Lon, "State":State, "Name":Name}
        return latlonDB
    
    latlonDB = latlon("ushcn-stations.txt")
    
    with open(y, 'r') as infile:
        y = y.split(".")[0]
        outfile = "%s_latlon.txt" %y
    
        header = infile.readline()
        header = header.strip('\n').split(',')
        header = "%s, Lat, Lon, State, Name, %s" %(header[0], ",".join(header[1:]))
        with open(outfile,'w') as latlonfile:
            latlonfile.write(header)
            for line in infile:
                latlonfile.write("\n")
                line = line.strip('\n').split(',')
                ID = line[0]
                latlon = latlonDB[ID]
                line = "%s, %s, %s" %(ID, ','.join([latlon["Lat"], latlon["Lon"], latlon["State"], latlon["Name"]]), ','.join(line[1:]))
                latlonfile.write(line)
    return

writefile("us_tmin_daily.txt")
writefile("us_tmax_daily.txt")
