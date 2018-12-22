# New donations from old donors

# This script checks for donations from donors who have already be identified.

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)

# Update data file --------------------------------------------------------
source('Scripts/Data processing/2 - Produce output data.R')

# Data --------------------------------------------------------------------
load("Output/Rdata/info_democracy.Rdata")

# New donations -----------------------------------------------------------
donations_old <- donations %>% 
  filter(!is.na(donor_id))

returning_donors <- donations %>% 
  filter(is.na(donor_id)) %>% 
  semi_join(donations_old, by = 'dntn_donor_name') %>% 
  select(dntn_donor_name, dntn_value) %>% 
  group_by(dntn_donor_name) %>% 
  summarise(n = n(),
            value = sum(dntn_value)) %>% 
  arrange(-value)

View(returning_donors)

# Tidy --------------------------------------------------------------------
rm(donations_old)
