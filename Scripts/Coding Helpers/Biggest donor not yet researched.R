# Progress report

# Setup -------------------------------------------------------------------
library(tidyverse)
library(leebunce)

# Update data file --------------------------------------------------------
source('Scripts/Data processing/2 - Produce output data.R')

# Data --------------------------------------------------------------------
load("Output/info_democracy.Rdata")

# Not yet researched ------------------------------------------------------
not_yet_researched <- donations %>% 
  filter(is.na(donor_id),
         !is.na(dntn_donor_name)) %>% 
  group_by(dntn_donor_name, dntn_company_registration_number) %>% 
  summarise(n = n(),
            Total = sum(dntn_value)) %>% 
  ungroup() %>% 
  arrange(-Total) %>% 
  mutate(Percent = percent(Total/sum(Total), digits = 3),
         `Cumulative percent` = cumsum(Percent))

View(not_yet_researched)