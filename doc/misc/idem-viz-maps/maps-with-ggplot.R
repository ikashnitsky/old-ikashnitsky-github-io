################################################################################
#                                                    
# IDEM viz 2017-06-22
# Creating maps with ggplot2
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
#                                                  
################################################################################

# Erase all objects in memory
rm(list = ls(all = TRUE))

# load required packages
library(tidyverse) # data manipulation and viz
library(lubridate) # easy manipulations with dates
library(ggthemes) # themes for ggplot2
library(viridis) # the best color palette
library(forcats) # good for dealing with factors
library(stringr) # good for dealing with text strings

library(rgdal) # deal with shapefiles
library(tmap) # this is a useful package; we take it for read_shape()
library(tmaptools)

library(eurostat)

# there is quite a useful cheatsheet for the package
# http://ropengov.github.io/eurostat/articles/cheatsheet.html

# let's try to search
search_eurostat("life expectancy") %>% View

# Not nearly as cool as we'd like
# better go to 
# http://ec.europa.eu/eurostat/data/database
# OR
# http://ec.europa.eu/eurostat/web/regions/data/database

# download the dataset found manually
df <- get_eurostat("demo_r_mlifexp")

# if the automated download does not work, the data can be grabbed manually at
# http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing

# time series length
df$time %>% unique()

# ages
df$age %>% unique()

# subset (filter) only life exp at birth
e0 <- df %>% filter(age=="Y_LT1", nchar(paste(geo))==4) %>% 
        droplevels()


################################################################################
# Download geodata
# Eurostat official shapefiles for regions
# http://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units

# geodata will be stored in a directory "geodata"
ifelse(!dir.exists('geodata'),
       dir.create('geodata'),
       paste("Directory already exists"))

f <- tempfile()
download.file("http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2013_20M_SH.zip", destfile = f)
unzip(f, exdir = "geodata/.")
NUTS_raw <- read_shape("geodata/NUTS_2013_20M_SH/data/NUTS_RG_20M_2013.shp")
# there are several shapefiles; we chose the one that contains NUTS codes

# the same operation using rgdal::readOGR
# NUTS_raw <- readOGR("geodata/NUTS_2013_20M_SH/data/NUTS_RG_20M_2013.shp")

# attributive table
NUTS_raw@data %>% View

# colnames to lower case
names(NUTS_raw@data) <- tolower(names(NUTS_raw@data))

NUTS_raw@data %>% View

# let's have a look
plot(NUTS_raw)


# change coordinate system to LAEA Europe (EPSG:3035)
epsg3035 <- "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

NUTS <- spTransform(NUTS_raw, CRS(epsg3035)) 

# now
plot(NUTS)

# Much better!

NUTS@data %>% View

NUTS0 <- NUTS[NUTS$stat_levl_==0,]
plot(NUTS0)

NUTS2 <- NUTS[NUTS$stat_levl_==2,]
plot(NUTS2)




# make the geodata ready for ggplot
gd2 <- fortify(NUTS2, region = "nuts_id")


# create a blank map
basemap <- ggplot()+
        geom_polygon(data = gd2,
                     aes(x = long, y = lat, group = group),
                     fill = "grey90",color = "grey90")+
        coord_equal(ylim = c(1350000,5450000), xlim = c(2500000, 6600000))+
        theme_map()+
        theme(panel.border = element_rect(color = "black",size = .5,fill = NA),
              legend.position = c(1, 1),
              legend.justification = c(1, 1),
              legend.background = element_rect(colour = NA, fill = NA),
              legend.title = element_text(size = 15),
              legend.text = element_text(size = 15))+
        scale_x_continuous(expand = c(0,0)) +
        scale_y_continuous(expand = c(0,0)) +
        labs(x = NULL, y = NULL)

basemap


# let's add neighbouring countries
f <- tempfile()
download.file("http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/CNTR_2010_20M_SH.zip", destfile = f)
unzip(f, exdir = "geodata/.")
WORLD <- read_shape("geodata/CNTR_2010_20M_SH/CNTR_2010_20M_SH/Data/CNTR_RG_20M_2010.shp")

WORLD@data %>% View

# colnames to lower case
names(WORLD@data) <- tolower(names(WORLD@data))

plot(WORLD)

# filter only Europe and the neighbouring countries
eu_subset <- c("AT", "BE", "BG", "CH", "CZ", "DE", "DK", 
               "EE", "EL", "ES", "FI", "FR", "HU", "IE", "IS", "IT", "LT", "LV", 
               "NL", "NO", "PL", "PT", "SE", "SI", "SK", "UK", "IM", "FO", "GI", 
               "LU", "LI", "AD", "MC", "MT", "VA", "SM", "HR", "BA", "ME", "MK", 
               "AL", "RS", "RO", "MD", "UA", "BY", "RU", "TR", "CY", "EG", "LY", 
               "TN", "DZ", "MA", "GG", "JE")

EU <- WORLD[WORLD$cntr_id %in% eu_subset,]

plot(EU)

# reproject the shapefile to a pretty projection for mapping Europe
NEIGH <- spTransform(EU, CRS(epsg3035))

plot(NEIGH) # nice!


# create a blank map
basemap <- ggplot()+
        geom_polygon(data = fortify(NEIGH),
                     aes(x = long, y = lat, group = group),
                     fill = "grey90",color = "grey90")+
        coord_equal(ylim = c(1350000,5450000), xlim = c(2500000, 6600000))+
        theme_map()+
        theme(panel.border = element_rect(color = "black",size = .5,fill = NA),
              legend.position = c(1, 1),
              legend.justification = c(1, 1),
              legend.background = element_rect(colour = NA, fill = NA),
              legend.title = element_text(size = 15),
              legend.text = element_text(size = 15))+
        scale_x_continuous(expand = c(0,0)) +
        scale_y_continuous(expand = c(0,0)) +
        labs(x = NULL, y = NULL)


################################################################################
# Ready to play!

basemap +
        geom_map(map = gd2, data = e0,
                 aes(map_id = geo, fill = values))

# better colors
basemap +
        geom_map(map = gd2, data = e0,
                 aes(map_id = geo, fill = values))+
        scale_fill_viridis(option = "B")
#
#
# What's wrong?
#
#


plot(NUTS2)
# remove the overseas region's data

gd2c <- gd2 %>% filter(long  %>% between(2500000, 6600000),
                     lat %>% between(1350000,5450000)) %>% 
        droplevels()

ggplot()+
        geom_map(map = gd2, data = e0,
                 aes(map_id = geo, fill = values))+
        scale_fill_viridis(option = "B")+
        expand_limits(x = gd2$long, y = gd2$lat)+
        coord_equal()

# only core Europe
basemap +
        geom_map(map = gd2c, data = e0,
                 aes(map_id = geo, fill = values))+
        scale_fill_viridis(option = "B")


#
#
# What else is forgotten?
#
#


# we forgot about sex!
basemap +
        geom_map(map = gd2c, data = e0 %>% filter(year(time)==2015, sex=="T"),
                 aes(map_id = geo, fill = values))+
        scale_fill_viridis(option = "B", direction = -1)

basemap +
        geom_map(map = gd2c, data = e0 %>% filter(year(time)==2015),
                 aes(map_id = geo, fill = values))+
        scale_fill_viridis(option = "B", direction = -1)+
        facet_wrap(~sex, ncol = 3)+
        theme(legend.position = "right")




################################################################################
# A PROBLEM: nested polygons

# let's crop Czech Republic
gdcz <- gd2c %>% filter(str_sub(id, 1, 2)=="CZ")



base_cz <- ggplot()+
        geom_polygon(data = gdcz,
                     aes(x = long, y = lat, group = group),
                     fill = "grey90",color = "grey10")+
        theme_map()

base_cz


# a subset of e0 for both sex in 2015
e0t2015 <- e0 %>% filter(year(time)==2015, sex=="T") %>% 
        droplevels()

base_cz +
        geom_map(map = gdcz, data = e0t2015,
                 aes(map_id = geo, fill = values))


#
#
# There is no Prague!
#
#

# The not-so-elegant solution; comes from SO
# https://stackoverflow.com/a/32186989/4638884

gghole <- function(fort){
        poly <- fort[fort$id %in% fort[fort$hole,]$id,]
        hole <- fort[!fort$id %in% fort[fort$hole,]$id,]
        out <- list(poly,hole)
        names(out) <- c('poly','hole')
        return(out)
}


# now plot the subsets one by one as separate layers: first the polygons with
# holes, then polygons without holes

base_cz +
        geom_map(map = gghole(gdcz)[[1]], data = e0t2015,
                 aes(map_id = geo, fill = values))

base_cz +
        geom_map(map = gghole(gdcz)[[2]], data = e0t2015,
                 aes(map_id = geo, fill = values))


base_cz +
        geom_map(map = gghole(gdcz)[[1]], data = e0t2015,
                 aes(map_id = geo, fill = values))+
        geom_map(map = gghole(gdcz)[[2]], data = e0t2015,
                 aes(map_id = geo, fill = values))

#
#
# What about the color range?
#
#

e0t2015$values %>% range

# a subset of e0 for both sex in Czech Rep in 2015
e0t2015cz <- e0 %>% filter(year(time)==2015, 
                         sex=="T",
                         str_sub(geo, 1, 2)=="CZ") %>% 
        droplevels()

e0t2015cz$values %>% range

base_cz +
        geom_map(map = gghole(gdcz)[[1]], data = e0t2015cz,
                 aes(map_id = geo, fill = values))+
        geom_map(map = gghole(gdcz)[[2]], data = e0t2015cz,
                 aes(map_id = geo, fill = values))




# of course, this solutions makes the proces longer

library(microbenchmark)

gdcz_joined <- left_join(gdcz, e0t2015, c("id" = "geo"))

microbenchmark(
        A = ggplot()+
                geom_polygon(data = gghole(gdcz_joined)[[1]], 
                             aes(x=long, y=lat, group=group, fill = values))+
                geom_polygon(data = gghole(gdcz_joined)[[2]], 
                             aes(x=long, y=lat, group=group, fill = values))+
                expand_limits(x = gdcz_joined$long, y = gdcz_joined$lat)+
                theme_map()
        
        ,
        
        B = ggplot()+
                geom_map(map = gghole(gdcz)[[1]], data = e0t2015cz,
                         aes(map_id = geo, fill = values))+
                geom_map(map = gghole(gdcz)[[2]], data = e0t2015cz,
                         aes(map_id = geo, fill = values))+
                expand_limits(x = gdcz$long, y = gdcz$lat)+
                theme_map()
        
        ,
        
        C = base_cz +
                geom_map(map = gghole(gdcz)[[1]], data = e0t2015cz,
                         aes(map_id = geo, fill = values))+
                geom_map(map = gghole(gdcz)[[2]], data = e0t2015cz,
                         aes(map_id = geo, fill = values))
        
        ,
        
        D = ggplot() +
                geom_map(map = gdcz, data = e0t2015cz,
                         aes(map_id = geo, fill = values))+
                expand_limits(x = gdcz$long, y = gdcz$lat)+
                theme_map()
        
        ,
        
        E = base_cz +
                geom_map(map = gdcz, data = e0t2015cz,
                         aes(map_id = geo, fill = values))
        
        ,
        
        times = 10
)



#
#
# A small challenge now: map the TFR of one country of Europe
#
#




################################################################################
# animation

# https://github.com/dgrtwo/gganimate
devtools::install_github("dgrtwo/gganimate")

# we also need one prog that proceeds animation 
# https://www.imagemagick.org/script/binary-releases.php

# some more 
install.packages("animation")
library(animation)
# Thank you guys from SO!
# https://stackoverflow.com/a/41394446/4638884
magickPath <- shortPathName("C:\\Program Files\\ImageMagick-7.0.3-Q16\\magick.exe")
ani.options(convert=magickPath)

library(gganimate)


gg <- basemap +
        geom_map(map = gghole(gd2c)[[1]], data = e0 %>% filter(sex=="T"),
                 aes(map_id = geo, fill = values, frame = time))+
        geom_map(map = gghole(gd2c)[[2]], data = e0 %>% filter(sex=="T"),
                 aes(map_id = geo, fill = values, frame = time))+
        scale_fill_viridis(option = "B", direction = -1)

gganimate(gg, "output.gif")

# The result stored online
# http://i.imgur.com/gLLHSWU.gif




################################################################################
# A bit of magic: interactive plots with PLOTLY

library(plotly)

# let's create a basic plot
q <- qplot(data = mtcars, hp, mpg, color = cyl %>% factor)
q
# now, magic
ggplotly(q)


# let's try with maps
gg_cz <- base_cz +
        geom_map(map = gghole(gdcz)[[1]], data = e0t2015cz,
                 aes(map_id = geo, fill = values))+
        geom_map(map = gghole(gdcz)[[2]], data = e0t2015cz,
                 aes(map_id = geo, fill = values)) 

gg_cz

ggplotly(gg_cz)

pl_cz <- ggplotly(gg_cz)
htmlwidgets::saveWidget(pl_cz, "cz-ggplotly.html")


# a more complicated map
gg_eu <- basemap +
        geom_map(map = gghole(gd2c)[[1]], data = e0t2015,
                 aes(map_id = geo, fill = values))+
        geom_map(map = gghole(gd2c)[[2]], data = e0t2015,
                 aes(map_id = geo, fill = values))+
        scale_fill_viridis(option = "B", direction = -1)

pl_eu <- ggplotly(gg_eu, width = 8, height = 8)
htmlwidgets::saveWidget(pl_eu, "eu-ggplotly.html")








################################################################################
################################################################################
# The US

ifelse(!dir.exists('data'),dir.create('data'),paste("Directory already exists"))

# download unemployment data for the US counties
url <- "https://www.ers.usda.gov/webdocs/DataFiles/48747/Unemployment.xls?v=42894"
download.file(url = url, destfile = 'data/us_unemp.xls', mode="wb")

# read the data
readxl::excel_sheets(path = 'data/us_unemp.xls')
df_us <- readxl::read_excel(path = 'data/us_unemp.xls', 
                            sheet = "Unemployment Med HH Inc", skip = 9)

library(magrittr)


# Let us clean the dataset a bit.
names(df_us) %<>% tolower()
df_us %<>% select(1:6, contains('rate')) 


# Download geodata
f <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2010/gz_2010_us_050_00_20m.zip", destfile = f)
unzip(f, exdir = "geodata/.")
US <- readOGR("geodata/.", "gz_2010_us_050_00_20m")

# reproject
US_prj <- spTransform(US, CRS('+init=epsg:2163'))
names(US_prj@data) %<>%  str_to_lower()
US_prj@data %<>% mutate(id = str_sub(geo_id,10,14))
row.names(US_prj) <- US_prj$id

#
#
# Careful now!
#
#

# Transform Alaska and Hawaii to fit in the map. The solution found at
# https://rpubs.com/technocrat/thematic-alaska-hawaii

library(rgeos)
library(maptools) 

alaska <-  US_prj[US_prj$state=="02",]
alaska <- elide(alaska, rotate=-36)
alaska <- elide(alaska, scale=max(apply(bbox(alaska), 1, diff)) / 2.5)
alaska <-  elide(alaska, shift=c(-2500000, -2200000))
proj4string(alaska) <- proj4string(US_prj)

hawaii <- US_prj[US_prj$state=="15",]
hawaii <- elide(hawaii, rotate=-35)
hawaii <- elide(hawaii, shift=c(5100000, -1300000))
proj4string(hawaii) <- proj4string(US_prj)

US_prj <- US_prj[!US_prj$state %in% c("02","15","72"),]
US_prj <- rbind(US_prj, alaska, hawaii)

# fortify
gd_county <- fortify(US_prj, region = 'id')


# Now do the same for the states shapefile.
f <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2010/gz_2010_us_040_00_20m.zip", destfile = f)
unzip(f, exdir = "geodata/.")
US_st <- readOGR("geodata/.", "gz_2010_us_040_00_20m")
# reproject geodata
US_st_prj <- spTransform(US_st, CRS('+init=epsg:2163'))
names(US_st_prj@data) <- str_to_lower(names(US_st_prj@data))
row.names(US_st_prj) <- paste(US_st_prj$state)

alaska_st <-  US_st_prj[US_st_prj$state=="02",]
alaska_st <- elide(alaska_st, rotate=-36)
alaska_st <- elide(alaska_st, scale=max(apply(bbox(alaska_st), 1, diff)) / 2.5)
alaska_st <-  elide(alaska_st, shift=c(-2500000, -2200000))
proj4string(alaska_st) <- proj4string(US_st_prj)

hawaii_st <- US_st_prj[US_st_prj$state=="15",]
hawaii_st <- elide(hawaii_st, rotate=-35)
hawaii_st <- elide(hawaii_st, shift=c(5100000, -1300000))
proj4string(hawaii_st) <- proj4string(US_st_prj)

US_st_prj <- US_st_prj[!US_st_prj$state %in% c("02","15","72"),]
US_st_prj <- rbind(US_st_prj, alaska_st, hawaii_st)

# fortify
gd_state <- fortify(US_st_prj, region = 'state')

#
# Identifying state borders
#
# To plot a nice map at county level, we need to identify states' borders as a 
# ployline object from the polygon object. To do this I wrote a special function 
# using a solution from an SO answer
# http://stackoverflow.com/a/35795927/4638884

identify_borders <- function(SPolyDF){
        require(rgeos)
        require(sp)
        borders <- gDifference(
                as(SPolyDF,"SpatialLines"),
                as(gUnaryUnion(SPolyDF),"SpatialLines"),
                byid=TRUE)
        
        df <- data.frame(len = sapply(1:length(borders), function(i) gLength(borders[i, ])))
        rownames(df) <- sapply(1:length(borders), function(i) borders@lines[[i]]@ID)
        
        SLDF <- SpatialLinesDataFrame(borders, data = df)
        return(SLDF)
}

US_st_borders <- identify_borders(US_st_prj)
gd_state_borders <- fortify(US_st_borders)


# Finally, it would be nice to plot major cities.
f <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Small-scale/data/Structures/citiesx020_nt00007.tar.gz", destfile = f)
ifelse(!dir.exists('geodata/us_cities'),
       dir.create('geodata/us_cities'),
       paste("Directory already exists"))
untar(f, exdir = "geodata/us_cities/.")
# doe to some win7 bug I had to do this step manually

cities <- readOGR(dsn = 'geodata/us_cities', layer = 'citiesx020')
cities_sub <- cities[cities$FEATURE %in% c("State Capital","State Capital   County Seat") | cities$POP_RANGE %in% c("1,000,000 - 9,999,999","500,000 - 999,999"),]
cities_sub@data <- cities_sub@data %>% droplevels()

proj4string(cities_sub) <- CRS('+proj=longlat')
cities_prj <- spTransform(cities_sub, CRS('+init=epsg:2163'))


gd_cities <- data.frame(cities_prj) %>%
        transmute(id = CITIESX020, long = coords.x1, lat = coords.x2,
                  name = NAME, fips = FIPS, state = STATE,
                  huge = POP_RANGE %in% c("1,000,000 - 9,999,999","500,000 - 999,999"),
                  capital = FEATURE %in% c("State Capital","State Capital   County Seat"))

# adjust positions for Juneau (AK) and Honolulu (HI)
gd_cities[gd_cities$state=='AK','long'] <- -1270000
gd_cities[gd_cities$state=='AK','lat'] <- -2030000
gd_cities[gd_cities$state=='HI','long'] <- -775000
gd_cities[gd_cities$state=='HI','lat'] <- -1900000

# SAVE GEODATA
save(gd_state_borders, gd_state, gd_county, gd_cities,
     file = 'geodata/us_geodata.RData')


### Create templates for maps: one each for continious and discrete scales

basemap_cont <- ggplot()+
        geom_polygon(data = gd_county, 
                     aes(x=long, y=lat, group=group), fill='grey50')+
        guides(fill = guide_colorbar(barwidth = 1, barheight = 10))+
        coord_equal(xlim = c(-2100000,3300000),ylim = c(-2400000,800000),
                    expand = c(0,0))+
        theme_map()+
        theme(panel.border=element_rect(color = 'black',size=.5,fill = NA),
              panel.background=element_rect(fill='grey15'),
              legend.position = c(1, 0),
              legend.justification = c(1, 0),
              legend.background = element_rect(colour = NA, fill = 'grey95'),
              legend.title = element_text(size=15),
              legend.text = element_text(size=15))+
        scale_x_continuous(expand=c(0,0)) +
        scale_y_continuous(expand=c(0,0)) +
        labs(x = NULL, y = NULL)

basemap_disc <- ggplot()+
        geom_polygon(data = gd_county, 
                     aes(x=long, y=lat, group=group), fill='grey50')+
        coord_equal(xlim = c(-2100000,3300000),ylim = c(-2400000,800000),
                    expand = c(0,0))+
        theme_map()+
        theme(panel.border=element_rect(color = 'black',size=.5,fill = NA),
              panel.background=element_rect(fill='grey15'),
              legend.position = c(1, 0),
              legend.justification = c(1, 0),
              legend.background = element_rect(colour = NA, fill = 'grey95'),
              legend.title = element_text(size=15),
              legend.text = element_text(size=15))+
        scale_x_continuous(expand=c(0,0)) +
        scale_y_continuous(expand=c(0,0)) +
        labs(x = NULL, y = NULL)


#
# LET'S MAP!
#


### Map of unemployment rates in 2015

basemap_cont +
        geom_map(map = gd_county, data = df_us, 
                 aes(map_id=fipstxt, fill=unemployment_rate_2015))+
        geom_path(data = gd_state_borders, aes(x=long, y=lat, group=group), 
                  color='grey50', size = .5)+
        geom_point(data = gd_cities %>% filter(capital==T, huge==F), 
                   aes(x=long, y=lat), color = 'red', size = 3, pch=1)+
        geom_point(data = gd_cities %>% filter(capital==T, huge==T), 
                   aes(x=long, y=lat), color = 'red', size = 5, pch=1)+
        geom_point(data = gd_cities %>% filter(capital==F, huge==T), 
                   aes(x=long, y=lat), color = 'gold', size = 5, pch=1)+
        scale_fill_gradientn('Unemployment\nrate, %\n', 
                             colours = viridis(100), trans = 'log', 
                             breaks = c(2,5,10,20))



### Map of urban-rural classification

basemap_disc +
        geom_map(map = gd_county, data = df_us, 
                 aes(map_id=fipstxt, fill=factor(rural_urban_continuum_code_2013)))+
        geom_path(data = gd_state_borders, aes(x=long, y=lat, group=group), 
                  color='grey50', size = .5)+
        scale_fill_viridis('Urban\nRural\ncounty\nclassification\n', 
                           option = 'B', discrete = T, direction = -1)+
        
        geom_point(data = gd_cities %>% filter(capital==T, huge==F), 
                   aes(x=long, y=lat), color = 'red', size = 3, pch=1)+
        geom_point(data = gd_cities %>% filter(capital==T, huge==T), 
                   aes(x=long, y=lat), color = 'red', size = 5, pch=1)+
        geom_point(data = gd_cities %>% filter(capital==F, huge==T), 
                   aes(x=long, y=lat), color = 'purple4', size = 5, pch=1)
