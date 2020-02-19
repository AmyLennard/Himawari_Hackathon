#!/bin/bash -v
#PBS -l storage=gdata/oe9+gdata/rr5
#PBS -l wd

if [ `echo $HOSTNAME | cut -c-3` == "vdi" ]; then
  echo module load gdal/2.2.2
else
  echo module load gdal/3.0.2
fi
module load cdo
module load nco

### Set up variables for this particular run
YEAR_START=2019
MONTH_START=01
DAY_START=01
HOUR_START=00
DATE_START=$YEAR_START$MONTH_START$DAY_START"T"$HOUR_START"00"
DATE_START_SECONDS=$(date -d $YEAR_START"-"$MONTH_START"-"$DAY_START" "$HOUR_START":00:00" +%s)

YEAR_END=2019
MONTH_END=01
DAY_END=31
HOUR_END=23
DATE_END=$YEAR_END$MONTH_END$DAY_END"T"$HOUR_END"00"
DATE_END_SECONDS=$(date -d $YEAR_END"-"$MONTH_END"-"$DAY_END" "$HOUR_END":00:00" +%s)

DATE_RANGE=$DATE_START"-"$DATE_END

LOCATION="QLD"
LON_W=135
LON_E=155
LAT_S=-30
LAT_N=-10

#LOCATION="TAS"
#LON_W=144
#LON_E=149
#LAT_S=-44
#LAT_N=-40

TIME_INCREMENT="1 hour"
#TIME_INCREMENT="10 minutes"

### end setup

OUTPUT_FILE="HIM8_${LOCATION}_$DATE_RANGE.nc"

DATE=$(date -u -d $YEAR_START"-"$MONTH_START"-"$DAY_START" "$HOUR_START":00:00")
END=$(date -u -d $YEAR_END"-"$MONTH_END"-"$DAY_END" "$HOUR_END":00:00")
COUNTER=0

if [ $DATE_START_SECONDS -gt $DATE_END_SECONDS ]; then
    echo "Start date later than end date - exiting"
    exit 1
fi

LOOP_COUNT=$(( $COUNTER + 1 ))
while [ "$DATE" != "$END" ]; do
  echo $DATE
  for BAND in {8..16}; do
    FILE="/g/data/rr5/satellite/obs/himawari8/FLDK/"$(date -u +%Y -d "$DATE")"/\
"$(date -u +%m -d "$DATE")"/"$(date -u +%d -d "$DATE")"/"$(date -u +%H%M -d "$DATE")"/\
"$(date -u +%Y%m%d%H%M -d "$DATE")"00-P1S-ABOM_OBS_B"$(printf %02d $BAND)"-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc"
    echo $FILE
    if [ -f "$FILE" ]; then
      gdalwarp -of netCDF -co WRITE_BOTTOMUP=NO -r bilinear -t_srs \
                          '+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs' -te $LON_W $LAT_S $LON_E $LAT_N \
                          -tr 0.02 -0.02 $FILE B${BAND}.$$.nc
      ncrename -v Band1,B$BAND B${BAND}.$$.nc
    fi
  done
  echo "HIM8_"$COUNTER"_${LOCATION}.nc"
  cdo merge B8.$$.nc B9.$$.nc B10.$$.nc B11.$$.nc B12.$$.nc B13.$$.nc B14.$$.nc B15.$$.nc B16.$$.nc BS.$$.nc
  cdo setdate,$(date -u +%Y-%m-%d -d "$DATE") BS.$$.nc BD.$$.nc
  cdo settime,$(date -u +%H:%M:%S -d "$DATE") BD.$$.nc "HIM8_"$COUNTER"_${LOCATION}.$$.nc"
  rm B*.$$.nc
  DATE=$(date -u -d "$DATE + $TIME_INCREMENT")
  COUNTER=$(( $COUNTER + 1 ))

        if [ $COUNTER -gt $COUNT_LIMIT ] || [ "$DATE" == "$END" ]; then
    cdo mergetime HIM8_*_${LOCATION}.$$.nc batch.$LOOP_COUNT.$$.nc
    if [ $? -ne 0 ]; then
       continue
    fi
    rm HIM8_*_${LOCATION}.$$.nc
    if [ ! -f $OUTPUT_FILE ]; then
      mv batch.$LOOP_COUNT.$$.nc $OUTPUT_FILE
    else
      mv $OUTPUT_FILE aux.$LOOP_COUNT.$$.nc
      cdo mergetime aux.$LOOP_COUNT.$$.nc batch.$LOOP_COUNT.$$.nc $OUTPUT_FILE
      rm aux.$LOOP_COUNT.$$.nc
      rm batch.$LOOP_COUNT.$$.nc
    fi
    COUNTER=0
    LOOP_COUNT=$(( $LOOP_COUNT + 1 ))
  fi
done
