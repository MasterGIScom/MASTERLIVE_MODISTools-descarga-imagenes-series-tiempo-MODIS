install.packages('rasterVis')
install.packages('MODIS')
library(raster)
library(MODISTools)
library(dplyr) # para pipe %>%

#Descargar todo los productos disponibles de los productos MONDLAND
products <- mt_products()

#Bandas disponibles para un producto del subconjunto
bands <- mt_bands(product = "MOD13Q1")
View(bands)

# Fechas disponibles para un producto 
dates <- mt_dates(product = "MOD13Q1", lat = 28.490895, lon = -111.287063) %>% 
  mutate(calendar_date = lubridate::ymd(calendar_date)) %>% 
  arrange(desc(calendar_date))
View(dates)

#Descarga de producto MOD12

TDF_NDVI <- mt_subset(product = "MOD13Q1", lat = 16.3, lon = -95, 
                      band = "250m_16_days_NDVI", start = "2020-11-15", end = "2021-01-02", 
                      km_lr = 50, km_ab = 50, site_name = "Tierra del fuego", internal = TRUE, 
                      progress = FALSE)

#transformar los valores en un raster
TDF_Raster <- mt_to_raster(df = TDF_NDVI)
plot(TDF_Raster)

#valores nulos de los valores -0.2
values(TDF_Raster) <- ifelse(
  values(TDF_Raster) < -0.2, NA, values(TDF_Raster)
  )
plot(TDF_Raster)

