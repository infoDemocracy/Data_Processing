# New donations from old donors

# This script checks for donations from donors who have already be identified.

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)

# Update data file --------------------------------------------------------
source('Scripts/Produce output data.R')

# Data --------------------------------------------------------------------
donations <- read_csv("Output/info_democracy.csv")

# New donations -----------------------------------------------------------
donations_old <- donations %>% 
  filter(!is.na(donor_id))

returning_donors <- donations %>% 
  filter(is.na(donor_id)) %>% 
  semi_join(donations_old, by = 'dntn_donor_name') %>% 
  select(dntn_donor_name, dntn_value) %>% 
  group_by(dntn_donor_name) %>% 
  summarise(value = sum(dntn_value)) %>% 
  arrange(-value)

View(returning_donors)

# Tidy --------------------------------------------------------------------
rm(donations_old)
