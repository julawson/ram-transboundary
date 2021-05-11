###Linking Transboundary Database to Ram and FishBase###

library(grid)
library(gridExtra)
library(tidyverse)
library(here)
remotes::install_github("ropensci/rfishbase")
library(rfishbase)

### Extracting RAM Datasets ###
#Loading Ram Database#

load(here("data", "DBdata[mdl][v4.491].RData"))

# RAM datasets to use
ram_datasets <- c('timeseries_values_views', 'stock', 'area', 'bioparams', 'timeseries_assessments_views',
                  'bioparams_values_views', 'assessor', 'management', 'assessment')
# Remove all unneccessary RAM data
rm(list = c(ls()[!(ls() %in% ram_datasets)]))

#What parameters do I want?
#stockid, stocklong, scientificname, commonname, areaid, region, primary_country, primary_FAOarea

# Extract main RAM timeseries, with BdivBmsypref and UdivUmsypref
ram.ts <- timeseries_values_views %>%
  tbl_df() %>%
  select(stockid, stocklong, year, TCbest, TBbest, BdivBmsypref, UdivUmsypref) %>% 
  left_join(tbl_df(stock),by = c("stockid", "stocklong")) %>%
  left_join(tbl_df(area), by = "areaid") %>%
  select(-inmyersdb, -myersstockid, -alternateareaname) %>% 
  rename (status_bio = BdivBmsypref) %>% 
  rename (status_f = UdivUmsypref) %>% 
  select(stockid, stocklong, year, TCbest, TBbest, status_f, status_bio, scientificname, commonname, areaid, region, primary_country, primary_FAOarea)

ram.bio <- bioparams_values_views %>% 
  tbl_df()

### Loading Owen and Renato's Database ###
#proportional ownership of fish stocks by EEZs
all_sp_prop_eezs <- readRDS(here("data", "all_sp_prop_eezs.rds"))
#Dataset from full paper, which includes cuttoff thresholds and management type
#Not using this dataset for now.
edf_cs_ram_panel <- read.csv(here("data", "edf_cs_ram_panel.csv"))

### Joining Ram Database with Owen and Renato's Database ###
ram.combo <- all_sp_prop_eezs %>% 
  left_join(ram.ts, by="stockid")

###Loading in FishBase Data###
###Had trouble pulling unique values from FishBase data set.

fishbase.species<- as.character(ram.combo$scientificname)
fishbase.species<- species(fishbase.species) %>% 
  select(Species,BodyShapeI,)


