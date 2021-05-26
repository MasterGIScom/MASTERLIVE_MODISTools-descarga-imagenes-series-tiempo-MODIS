install.packages('rworldxtra')
install.packages('lubridate')
library(rasterVis)
library(rworldxtra)
library(tidyverse)
library(lubridate)
library(ggplot2)
#Bandas disponibles para un producto del subconjunto
bandasMCD <- mt_bands("MCD12Q2")
view(bandasMCD)
# Fechas disponibles para un producto 
datesMCD <- mt_dates(product = "MCD12Q1", lat = -9.1238, lon = -77.61) %>% 
  mutate(calendar_date = lubridate::ymd(calendar_date)) %>% 
  arrange(desc(calendar_date))
View(datesMCD)

#Descarga de productos MCD12Q2 de cobertura de suelo 
TDF_Type <- mt_subset(product = "MCD12Q1", lat = -9.123876, lon = -77.618597, 
                      band = "LC_Type1", start = '2016-01-01', 
                      end = "2020-06-01", km_lr = 50, km_ab = 50, site_name = "Tierra del fuego", 
                      internal = TRUE, progress = FALSE)

#transformar los valores en un raster
TDF_Raster_Type <- mt_to_raster(df = TDF_Type, reproject = TRUE)
funcol<-colorRampPalette(c('red', 
                           'blue',
                           'yellow', 
                           'green', 
                           'orange', 
                           'white',
                           'pink'))
plot(TDF_Raster_Type)
plot(TDF_Raster_Type[[1]], col= funcol(10))

#Display en ratserVis
rasterVis::levelplot(TDF_Raster_Type)

#rwordextra
data('countriesHigh')

#convertir a sf
TDF_sf<-countriesHigh %>% st_as_sf() %>% st_make_valid() %>% st_crop(TDF_Raster_Type)

#data frame de los pixeles 
TDF_raster_DF<-TDF_Raster_Type %>% as('SpatialPixelsDataFrame')%>%
  as.data.frame() %>%
  pivot_longer(starts_with(c('X2016', 'X2017', 'X2018', 'X2019')), 
               names_to = 'Fecha', 
               values_to = 'Uso') %>%
  mutate(Fecha=str_remove_all(Fecha, 'X'), Fecha= lubridate::ymd(Fecha))

head(TDF_raster_DF)

#Visualizacion en ggplot 
ggplot() + geom_raster(data = TDF_raster_DF, 
                     aes(x = x, y = y, fill= Uso)) +
  geom_sf(data = TDF_sf, alpha = 0) + theme_bw()+
  facet_wrap(~Fecha) + scale_fill_viridis_c()
  
