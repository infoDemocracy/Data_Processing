# Produce output data

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

# Read data ---------------------------------------------------------------

# Electoral Commission
ec_data <- read_csv("Data/ec_data.csv")

# Donation-Donor Link
donation_donor_link <- read_csv("Data/donation_donor_link.csv") %>%
  filter(!is.na(donor_id)) %>% 
  select(dntn_ec_ref, donor_id)

# Donor information
donor_individual <- read_csv("Data/donor_individual.csv")
donor_organisations <- read_csv("Data/donor_organisations.csv")

donor_all <- bind_rows(donor_individual, donor_organisations)
donor_all_na <- donor_all %>%
  filter(!is.na(donor_id)) %>% 
  mutate(interest_code = str_replace(interest_code,
                                     pattern = '^_',
                                     replacement = ''))

# Interest codes
level_5 <- read_csv("Data/Interest codes/level_5.csv")
level_4 <- read_csv("Data/Interest codes/level_4.csv")
level_3 <- read_csv("Data/Interest codes/level_3.csv")
level_2 <- read_csv("Data/Interest codes/level_2.csv")
level_1 <- read_csv("Data/Interest codes/level_1.csv")
additional_codes <- read_csv('Data/Interest codes/Additional codes.csv')

interest_codes <- level_5 %>% 
  left_join(level_4, 'level_4') %>% 
  left_join(level_3, 'level_3') %>%
  left_join(level_2, 'level_2') %>%
  left_join(level_1, 'level_1') %>% 
  bind_rows(additional_codes)

# Join --------------------------------------------------------------------

donations <- left_join(ec_data, donation_donor_link, by = "dntn_ec_ref") %>% 
  left_join(donor_all_na, by = "donor_id") %>% 
  replace_na(list(interest_code = 'ZZZZZ')) %>% 
  left_join(interest_codes, by = c('interest_code' = 'level_5'))

# Derived fields ----------------------------------------------------------

donations <- donations %>% 
  mutate(x_researched = !is.na(donor_id),
         x_coded = interest_code != 'ZZZZZ',
         x_reported_year = year(dntn_reported_date),
         x_donor_name = case_when(
          str_sub(donor_id, 1, 1) == 'I'  ~ paste(ifelse(is.na(title), '', title), first_name, last_name),
          str_sub(donor_id, 1, 1) == 'O'  ~ orga_name))

# Save --------------------------------------------------------------------
write_csv(donations, 'Output/info_democracy.csv')
save(donations, file = 'Output/info_democracy.Rdata')

# Tidy --------------------------------------------------------------------
rm(ec_data,
   donation_donor_link,
   donor_individual,
   donor_organisations,
   donor_all,
   donor_all_na,
   level_1,
   level_2,
   level_3,
   level_4,
   level_5,
   additional_codes,
   interest_codes,
   donations)
