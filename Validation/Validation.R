# Validate data

# Packages ----------------------------------------------------------------
library(tidyverse)
library(validate)

# Data --------------------------------------------------------------------
load('Output/info_democracy.Rdata')

# Rules -------------------------------------------------------------------
validator_info_democracy <- validator(.file = 'Validation/Rules/info_democracy.yaml')

# Validate ----------------------------------------------------------------
errors_info_democracy <- confront(info_democracy, validator_info_democracy, key = "dntn_ec_ref") %>% 
  as.data.frame() %>% 
  left_join(as.data.frame(validator_info_democracy), by = 'name') %>% 
  filter(value == F) %>% 
  select(-value, -expression, -label) %>% 
  rename(error = name)

print(paste('There are', nrow(errors_info_democracy), 'errors in the info_democracy file.'))

count(errors_info_democracy, error, description)

# Tidy --------------------------------------------------------------------
rm(validator_info_democracy)
