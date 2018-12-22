#Coding Helper

# This helps in creating the individual donor table. 
# It selects from the EC data the main fields used in coding.

# Packages ----------------------------------------------------------------
library(tidyverse)

# View relevant fields ----------------------------------------------------

ec_data <- read_csv("Data/ec_data.csv", na = c("", "NA"))
ec_data_main <- select(ec_data,
                       dntn_regulated_entity_name,
                       dntn_value, dntn_donor_name,
                       dntn_accounting_unit_name,
                       dntn_is_bequest,
                       dntn_accepted_date,
                       dntn_donor_id)

View(ec_data)
View(ec_data_main)