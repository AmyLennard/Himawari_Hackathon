rm(list=ls())
# 
# source script for raster processing, analysis and visualisation.  Script also
#  contains the Projection Info Strings (Proj4Object) for GEO and LATLON
#       PROJ_GEO    = '+proj=geos +lon_0=140.7 +h=35785863 +a=6378137.0 +b=6356752.3'
#       PROJ_LATLON = '+proj=longlat +datum=WGS84'
        source('~/Workspace/RainfallSpectralAnalysis/SpectralAnalysis/function_SetupForGraphics.R')


# paths to H-8 spectral data
        path2h8 = '/g/data/rr5/satellite/obs/himawari8/FLDK/'

# date and time range of period of interest
        Time = seq(ISOdatetime(2020,1,21,23,50,0,tz='GMT'),
                   ISOdatetime(2020,1,24,0,0,0,tz='GMT'),60*10)


#
# now to get spectral indices. Eumetsat alg. uses bands 11, 13, 14 and 15, corresponding
#   to wavelengths 8.6 um, 10.45 um, 11.20 um, and 12.35 um.
#
# h8 geo extent (meters)  and resolution
        Xmn=-5500000; Xmx=5500000; Ymn=-5500000; Ymx=5500000; dX = 2000; dY = 2000 # m

#
#   raster template for study are:
        bt_LL = raster(crs=PROJ_LATLON,res=c(0.05,0.05),xmn=111.975,xmx=154.025,ymn=-44.025,ymx=-9.975)


        k = 160
#       for (k in 1:length(Time)) {
        for (k in 155:185) {
                datetime = format(Time[k],'%Y%m%d%H%M00-P1S-ABOM_OBS_')
                bandID   = 'B11'
                bandname = 'channel_0011_brightness_temperature'
                filename = paste0(path2h8,format(Time[k],'%Y/%m/%d/%H%M/'),
                                  datetime,bandID,'-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc')

                if (file.exists(filename)) {
                        xo  = nc_open(filename)
                        b_x = t(ncvar_get(xo,bandname)); nc_close(xo)
                        b_x_rst = raster(b_x,crs=PROJ_GEO,Xmn,Xmx,Ymn,Ymx)
                        b11_rst = projectRaster(b_x_rst,bt_LL)
                                rm(b_x,b_x_rst)

                        bandID   = 'B13'
                        bandname = 'channel_0013_brightness_temperature'
                        filename = paste0(path2h8,format(Time[k],'%Y/%m/%d/%H%M/'),
                                          datetime,bandID,'-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc')
                        xo  = nc_open(filename)
                        b_x = t(ncvar_get(xo,bandname)); nc_close(xo)
                        b_x_rst = raster(b_x,crs=PROJ_GEO,Xmn,Xmx,Ymn,Ymx)
                        b13_rst = projectRaster(b_x_rst,bt_LL)
                                rm(b_x,b_x_rst)

                        bandID   = 'B14'
                        bandname = 'channel_0014_brightness_temperature'
                        filename = paste0(path2h8,format(Time[k],'%Y/%m/%d/%H%M/'),
                                          datetime,bandID,'-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc')
                        xo  = nc_open(filename)
                        b_x = t(ncvar_get(xo,bandname)); nc_close(xo)
                        b_x_rst = raster(b_x,crs=PROJ_GEO,Xmn,Xmx,Ymn,Ymx)
                        b14_rst = projectRaster(b_x_rst,bt_LL)
                                rm(b_x,b_x_rst)

                        bandID   = 'B15'
                        bandname = 'channel_0015_brightness_temperature'
                        filename = paste0(path2h8,format(Time[k],'%Y/%m/%d/%H%M/'),
                                          datetime,bandID,'-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc')
                        xo  = nc_open(filename)
                        b_x = t(ncvar_get(xo,bandname)); nc_close(xo)
                        b_x_rst = raster(b_x,crs=PROJ_GEO,Xmn,Xmx,Ymn,Ymx)
                        b15_rst = projectRaster(b_x_rst,bt_LL)
                                rm(b_x,b_x_rst)

                        Red_rst   = b15_rst - b13_rst
                        Green_rst = b14_rst - b11_rst
                        Blue_rst  = b13_rst

                        # scale from 0 - 255
                        Red_rst   = ((Red_rst - Red_rst@data@min)/(Red_rst@data@max - Red_rst@data@min))*255
                        Green_rst = ((Green_rst - Green_rst@data@min)/(Green_rst@data@max - Green_rst@data@min))*255
                        Blue_rst  = ((Blue_rst - Blue_rst@data@min)/(Blue_rst@data@max - Blue_rst@data@min))*255

                        RGB_stack = stack(Red_rst,Green_rst,Blue_rst)
                        plotRGB(RGB_stack); addCoastLines(PROJ_LATLON,Colour='black')


                } # end if condition

        } # end of k loop

