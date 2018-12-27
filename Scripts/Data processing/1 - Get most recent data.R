# Get most recent data from Eletoral Commission.

# This script gets the most recent data from the Electoral Commmission.
# It also updates the donation_donor_link data.
# Both are saved to the Data folder in advance of further processing.

# Packages ----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(tibble)
library(readr)
library(httr)
library(stringr)
library(lubridate)

# Get raw data from Electoral Commission ----------------------------------
ec_data <- GET('http://search.electoralcommission.org.uk/api/csv/Donations',
               query = list(sort = "AcceptedDate",
                            order = "desc",
                            prePoll = "true",
                            postPoll = "true"))

ec_data_raw <- content(ec_data, "text") 

writeLines(ec_data_raw, 'Data/ec_data_raw.txt')

# Update donation-donor link ----------------------------------------------

# Read current file
donation_donor_link <- read_csv("Data/donation_donor_link.csv")

# Get most recent data
new_donations <- ec_data %>% 
  content("parsed") %>% 
  select(dntn_ec_ref = ECRef,
         helper_dntn_donor_name = DonorName,
         helper_dntn_company_registration_number = CompanyRegistrationNumber,
         helper_dntn_regulated_entity_name = RegulatedEntityName,
         helper_dntn_value = Value) %>% 
  mutate(helper_dntn_value = as.numeric(str_replace_all(helper_dntn_value, '[\\£|,]', '')))

# Append the new data to the old and remove duplicates
donation_donor_link_new <- bind_rows(donation_donor_link, new_donations) %>%
  group_by(dntn_ec_ref) %>% 
  arrange(donor_id) %>% 
  slice(1) %>% 
  ungroup() %>% 
  arrange(helper_dntn_donor_name,
          helper_dntn_company_registration_number)

# Save --------------------------------------------------------------------
write_csv(donation_donor_link_new,
          path = "Data/donation_donor_link.csv",
          na = '')

# Tidy --------------------------------------------------------------------
rm(ec_data,
   ec_data_raw,
   donation_donor_link,
   new_donations,
   donation_donor_link_new)
