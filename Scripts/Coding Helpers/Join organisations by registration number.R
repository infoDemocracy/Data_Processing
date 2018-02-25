# Script to join organisations by company id

# Note this only applies to companies, not other kinds of organisations
# First isolate orgs with number (and remove duplicates)
# Then exclude organisations I've already coded

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)
library(stringr)

# Create new list of organisations ----------------------------------------
donor_organisations <- read_csv("Data/donor_organisations.csv") %>% 
  mutate(orga_registry_number = ifelse(!is.na(companies_house),
                                       str_extract(companies_house, '(?<=/company/).{1,}'), 
                                       orga_registry_number) %>% 
           toupper()) #This fixes issue of libre office deleting leading 0's by taking the registry number from the companies house url

already_given_id <- filter(donor_organisations, !is.na(donor_id))

not_yet_given_id <- donor_organisations %>% 
  filter(!is.na(orga_registry_number),
         is.na(donor_id)) %>%
  anti_join(already_given_id, by = 'orga_registry_number') %>% # remove duplicates
  arrange(orga_registry_number) %>% 
  group_by(orga_registry_number) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  mutate(donor_id = paste0('O', row_number() + nrow(already_given_id)))

donor_organisations_new <- bind_rows(already_given_id, not_yet_given_id) %>%
  mutate(order = as.numeric(str_extract(donor_id, '(?<=O).{1,}'))) %>% 
  arrange(order) %>% 
  select(-order)

rm(donor_organisations, already_given_id, not_yet_given_id)

# Add registration numbers to donation_donor_link -------------------------

registration_numbers <- read_csv('Data/ec_data.csv') %>% 
  select(dntn_ec_ref, dntn_company_registration_number)

donation_donor_link_new <- read_csv("Data/donation_donor_link.csv") %>% 
  left_join(registration_numbers, by = 'dntn_ec_ref')

rm(registration_numbers)

# Join new organisation data to link --------------------------------------

# Separate into records with a registration number and those without.
# Then join organisation data to those with a registration number.

donation_donor_link_no_registration_number <- donation_donor_link_new %>% 
  filter(is.na(dntn_company_registration_number))

donation_donor_link_registration_number <- donation_donor_link_new %>% 
  filter(!is.na(dntn_company_registration_number)) %>% 
  left_join(donor_organisations_new, by = c('dntn_company_registration_number' = 'orga_registry_number')) %>% 
  mutate(donor_id = ifelse(!is.na(donor_id.y), donor_id.y, donor_id.x))

donation_donor_link_new <- bind_rows(donation_donor_link_no_registration_number, donation_donor_link_registration_number)

rm(donation_donor_link_no_registration_number,
   donation_donor_link_registration_number)

# Select columns ----------------------------------------------------------

donation_donor_link_new <- donation_donor_link_new %>% 
  select(1:6)

write_csv(x = donation_donor_link_new, path = 'Data/donation_donor_link_new.csv', na = '')
write_csv(x = donor_organisations_new, path = 'Data/donor_organisations_new.csv', na = '')