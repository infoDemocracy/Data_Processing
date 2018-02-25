# Check for erroneous interest codes

# This script checks for erroneous interest codes.
# These are codes that do not find a match in the lookup.

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)

# Update data file --------------------------------------------------------
source('Scripts/Produce output data.R')

# Data --------------------------------------------------------------------
donations <- read_csv("Output/process_data.csv")

# Find errors -------------------------------------------------------------
errors <- donations %>% 
  filter(is.na(level_5_description)) %>%
  count(donor_id, dntn_donor_name, dntn_company_registration_number, interest_code) %>% 
  arrange(interest_code)

if(nrow(errors) == 0) {
  message('There are no errors.')
} else {
    View(errors)}

