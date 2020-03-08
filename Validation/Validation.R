# Validate data

# Packages ----------------------------------------------------------------
library(readr)
library(validate)

# Data --------------------------------------------------------------------
load('Output/info_democracy.Rdata')

# Rules -------------------------------------------------------------------
validator_info_democracy <- validator(.file = 'Validation/Rules/info_democracy.yaml')

# Error function ----------------------------------------------------------
get_errors <- function(df, rules, key){
  confront(df, rules, key = key) %>% 
    as.data.frame() %>% 
    left_join(as.data.frame(rules), by = 'name') %>% 
    filter(value == F) %>% 
    select(-value, -expression, -label) %>% 
    #arrange(key, name) %>% Need tidyeval for this step I think 
    rename(error = name)
}

# Validate ----------------------------------------------------------------
errors_info_democracy <- get_errors(info_democracy, validator_info_democracy, key = "dntn_ec_ref")

# Print errors ------------------------------------------------------------
file.remove(list.files('Validation/Errors', full.names = T))
if(nrow(errors_info_democracy) > 0) write_csv(errors_info_democracy, 'Validation/Errors/errors_info_democracy.csv')

print(paste('There are', nrow(errors_info_democracy), 'errors in the info_democracy file.'))
