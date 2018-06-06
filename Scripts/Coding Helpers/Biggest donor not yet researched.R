# Progress report

# Setup -------------------------------------------------------------------
library(tidyverse)

# Update data file --------------------------------------------------------
source('Scripts/Produce output data.R')

# Data --------------------------------------------------------------------
donations <- read_csv("Output/info_democracy.csv")

# Not yet researched ------------------------------------------------------
not_yet_researched <- donations %>% 
  filter(is.na(donor_id)) %>% 
  group_by(dntn_donor_name, dntn_company_registration_number) %>% 
  summarise(Value = sum(dntn_value)) %>% 
  arrange(-Value)

View(not_yet_researched)