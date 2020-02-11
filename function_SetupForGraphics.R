
####  functions with some graphics specificztions, including colour table and 
####    coastline
library(ncdf4)
suppressWarnings(library(raster))
#suppressWarnings(library(rgdal))
suppressWarnings(library(maps))

# PLOTTING PARAMETERS  
RainfallColors_r = c(255, 252, 250, 247, 244, 242, 239, 236, 234, 231, 229, 226, 223, 221, 218, 215, 213, 210,
                     207, 205, 202, 199, 197, 194, 191, 189, 186, 183, 181, 178, 176, 173, 170, 168, 165, 162,
                     157, 155, 152, 150, 148, 146, 143, 141, 139, 136, 134, 132, 129, 127, 125, 123, 120, 118,
                     116, 113, 111, 109, 106, 104, 102, 100, 97,  95,  93,  90,  88,  86,  83,  81,  79,  77,
                     72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,  72,
                     72,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,  73,
                     73,  78,  83,  87,  92,  97,  102, 106, 111, 116, 121, 126, 130, 135, 140, 145, 150, 154,
                     159, 164, 169, 173, 178, 183, 188, 193, 197, 202, 207, 212, 217, 221, 226, 231, 236, 240,
                     245, 250, 250, 250, 250, 249, 249, 249, 249, 249, 249, 249, 249, 248, 248, 248, 248, 248,
                     248, 248, 247, 247, 247, 247, 247, 247, 247, 246, 246, 246, 246, 246, 246, 246, 246, 245,
                     245, 245, 244, 243, 242, 241, 240, 239, 239, 238, 237, 236, 235, 234, 233, 232, 231, 230,
                     229, 228, 228, 227, 226, 225, 224, 223, 222, 221, 220, 219, 218, 217, 217, 216, 215, 214,
                     213, 211, 209, 207, 206, 204, 202, 200, 199, 197, 195, 193, 192, 190, 188, 186, 185, 183,
                     181, 179, 178, 176, 174, 172, 171, 169, 167, 165, 164, 162, 160, 158, 157, 155, 153, 151, 150, 146)
RainfallColors_g = c(255, 254, 253, 252, 251, 250, 249, 248, 247, 246, 245, 244, 243, 242, 241, 240, 239, 238,
                     237, 236, 235, 234, 233, 232, 231, 230, 229, 228, 227, 226, 225, 224, 223, 222, 221, 220,
                     218, 216, 214, 212, 210, 208, 206, 204, 202, 200, 197, 195, 193, 191, 189, 187, 185, 183,
                     181, 179, 177, 175, 173, 171, 169, 167, 165, 163, 160, 158, 156, 154, 152, 150, 148, 146,
                     142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 153, 154, 155, 156, 157, 158, 159, 160,
                     161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 172, 173, 174, 175, 176, 177, 178, 179,
                     181, 182, 184, 185, 187, 188, 189, 191, 192, 193, 195, 196, 198, 199, 200, 202, 203, 204,
                     206, 207, 209, 210, 211, 213, 214, 215, 217, 218, 220, 221, 222, 224, 225, 226, 228, 229,
                     231, 232, 229, 225, 222, 218, 215, 212, 208, 205, 201, 198, 195, 191, 188, 184, 181, 178,
                     174, 171, 167, 164, 160, 157, 154, 150, 147, 143, 140, 137, 133, 130, 126, 123, 120, 116,
                     113, 106, 104, 102, 100,  98,  96, 94,  92,  90,  88,  86,  84,  82,  80,  78,  76,  74,
                     72,  70,  67,  65,  63,  61,  59,  57,  55,  53,  51,  49,  47,  45,  43,  41,  39,  37,
                     35,  31,  31,  30,  30,  30,  30,  29,  29,  29,  29,  28,  28,  28,  27,  27,  27,  27,
                     26,  26,  26,  26,  25,  25,  25,  25,  24,  24,  24,  23,  23,  23,  23,  22,  22,  22, 22,  21)
RainfallColors_b = c(255, 255, 255, 254, 254, 254, 254, 253, 253, 253, 253, 253, 252, 252, 252, 252, 252, 251,
                     251, 251, 251, 250, 250, 250, 250, 250, 249, 249, 249, 249, 249, 248, 248, 248, 248, 247,
                     247, 246, 245, 243, 242, 241, 240, 238, 237, 236, 235, 234, 232, 231, 230, 229, 228, 226,
                     225, 224, 223, 221, 220, 219, 218, 217, 215, 214, 213, 212, 211, 209, 208, 207, 206, 204,
                     202, 198, 195, 191, 188, 184, 181, 177, 173, 170, 166, 163, 159, 156, 152, 148, 145, 141,
                     138, 134, 131, 127, 124, 120, 116, 113, 109, 106, 102, 99,  95,  91,  88,  84,  81,  77,
                     70,  71,  71,  72,  72,  73,  74,  74,  75,  75,  76,  77,  77,  78,  78,  79,  80,  80,
                     81,  81,  82,  82,  83,  84,  84,  85,  85,  86,  87,  87,  88,  88,  89,  90,  90,  91,
                     91,  92,  91,  89,  88,  86,  85,  84,  82,  81,  80,  78,  77,  75,  74,  73,  71,  70,
                     69,  67,  66,  64,  63,  62,  60,  59,  58,  56,  55,  53,  52,  51,  49,  48,  47,  45,
                     44,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,  41,
                     41,  41,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,  40,
                     40,  40,  40,  39,  39,  38,  38,  38,  37,  37,  36,  36,  36,  35,  35,  34,  34,  34,
                     33,  33,  32,  32,  31,  31,  31,  30,  30,  29,  29,  29,  28,  28,  27,  27,  27,  26, 26,  25)

RainRamp=colorRampPalette(rgb(
  red   = RainfallColors_r / 255.,
  green = RainfallColors_g / 255.,
  blue  = RainfallColors_b / 255.))


SoftRain_rgb = matrix(c(255,255,255,157,218,247,72,142,202,73,181,70,250,232,92,245,106,41,211,31,40,146,21,25),8,3,byrow=TRUE)
SoftRainRamp = colorRampPalette(rgb(red=SoftRain_rgb[,1]/255.,green=SoftRain_rgb[,2]/255.,blue=SoftRain_rgb[,3]/255.))


BOMRainRamp = colorRampPalette(rgb(red  = c(255,245,180,120,20,0,0,0,255,255,255,255,255,200,120,0)/255.,
				   green= c(255,245,180,120,20,216,150,102,255,200,150,100,0,0,0,0)/255.,
				   blue = c(255,255,255,255,255,195,144,102,0,0,0,0,0,0,0,0)/255.))

DifferenceRamp = colorRampPalette(c('darkred','red','white','blue','navy'))

# COAST LINES
addCoastLines = function(Proj=PROJ_TARGET,Colour='darkgrey') {

## ---   if PROJ is lat-lon then plot the whole world coastline
if (length(grep('longlat',Proj)) != 1) {
	CountriesToPlot = c('Australia','New Zealand','Japan','Indonesia','India',
        	            'Papua New Guinea','Thailand','China','Malaysia',
                	    'Philippines','New Caledonia','Vietnam','Cambodia',
	                    'Laos','North Korea','South Korea','Taiwan','Myanmar',
        	            'Fiji','Solomon Islands','Vanuatu','Sri Lanka','Bangladesh',
			    'Afganistan','Pakistan','Iran','Turkmenistan','Uzbekistan',
			    'Kazakstan','Oman')
	gobalLats = map('world',plot=F,region=CountriesToPlot)$y
	gobalLons = map('world',plot=F,region=CountriesToPlot)$x
} else {
	gobalLats = map('world',plot=F)$y
	gobalLons = map('world',plot=F)$x
}

### -- getting rid of the lat and lons with NAs
gLats = gobalLats[!is.na(gobalLats)]
gLons = gobalLons[!is.na(gobalLons)]

gLL   = SpatialPoints(cbind(gLons,gLats),proj4string = CRS('+proj=longlat +datum=WGS84'))
gNE   = spTransform(gLL,CRS(Proj))  # - change to the relavnt NEW projection e.g. PROJ_GEO, PROJ_AEA, ..

gE = coordinates(gNE)[,1]
gN = coordinates(gNE)[,2]

globalEastings  = gobalLons  # initialising arrays
globalNorthings = gobalLats

globalEastings[!is.na(gobalLons)]  = gE
globalNorthings[!is.na(gobalLats)] = gN

#
lines(globalEastings,globalNorthings,col=Colour)

}


#### common projections used in displaying rainfall grids
PROJ_LATLON = '+proj=longlat +datum=WGS84'
PROJ_AEA = '+proj=aea +lat_1=-18.0 +lat_2=-36.0 +lon_0=132 +lat_0=0 +datum=WGS84'
PROJ_GEO = '+proj=geos +lon_0=140.7 +h=35785863 +a=6378137.0 +b=6356752.3'
PROJ_AEA_INDIA = '+proj=aea +lat_1=28 +lat_2=12 +lat_0=20 +lon_0=78 +x_0=2000000 +y_0=2000000 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'
PROJ_INSAT = '+proj=geos +lon_0=82.0 +h=36000000  +datum=WGS84'
