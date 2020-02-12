module load gdal/2.2.2
module load cdo
module load nco


YEAR=2019
DATE=$(date -u -d $YEAR"-01-26")
END=$(date -u -d "2019-02-28")
COUNTER=0
while [ "$DATE" != "$END" ]; do
	echo $DATE
	for BAND in {8..16}; do
		FILE="/g/data/rr5/satellite/obs/himawari8/FLDK/"$(date -u +%Y -d "$DATE")"/"$(date -u +%m -d "$DATE")"/"$(date -u +%d -d "$DATE")"/"$(date -u +%H%M -d "$DATE")"/"$(date -u +%Y%m%d%H%M -d "$DATE")"00-P1S-ABOM_OBS_B"$(printf %02d $BAND)"-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc"
		echo $FILE
		if [ -f $FILE ]; then
			gdalwarp -of netCDF -co WRITE_BOTTOMUP=NO -r bilinear -t_srs '+proj=longlat +datum=GDA94 +no_defs' -te 135 -30 155 -10 -tr 0.02 -0.02 $FILE B$BAND.nc
			ncrename -v Band1,B$BAND B$BAND.nc
		fi
	done
	echo "HIM8_"$COUNTER"_TWNV.nc"
	cdo merge B8.nc B9.nc B10.nc B11.nc B12.nc B13.nc B14.nc B15.nc B16.nc BS.nc
	cdo setdate,$(date -u +%Y-%m-%d -d "$DATE") BS.nc BD.nc
	cdo settime,$(date -u +%H:%M:%S -d "$DATE") BD.nc "HIM8_"$COUNTER"_TWNV.nc"
	rm B*.nc
	DATE=$(date -u -d "$DATE + 1 hour")
	COUNTER=$(( $COUNTER + 1 ))
        if [ $COUNTER -gt 100 ] || [ "$DATE" == "$END" ]; then
		cdo mergetime HIM8_*_TWNV.nc batch.nc
		if [ $? -ne 0 ]; then
    			continue
		fi
		rm HIM8_*_TWNV.nc
		if [ ! -f "HIM8_TWNV_SE_"$YEAR".nc" ]; then
			mv batch.nc "HIM8_TWNV_SE_"$YEAR".nc"
		else
			mv "HIM8_TWNV_SE_"$YEAR".nc" aux.nc
			cdo mergetime aux.nc batch.nc "HIM8_TWNV_SE_"$YEAR".nc"
			rm aux.nc
			rm batch.nc
		fi
		COUNTER=0
	fi
done
