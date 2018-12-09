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

donors <- bind_rows(donor_individual, donor_organisations) %>% 
  donors_all %>%
  filter(!is.na(donor_id)) %>% 
  mutate(interest_code = str_replace(interest_code,
                                     pattern = '^_',
                                     replacement = ''))

# Interest codes
level_5 <- read_csv("Data/interest_code_level_5.csv")
level_4 <- read_csv("Data/interest_code_level_4.csv")
level_3 <- read_csv("Data/interest_code_level_3.csv")
level_2 <- read_csv("Data/interest_code_level_2.csv")
level_1 <- read_csv("Data/interest_code_level_1.csv")
additional_codes <- read_csv('Data/interest_code_additional_codes.csv')

interest_codes <- level_5 %>% 
  left_join(level_4, 'level_4') %>% 
  left_join(level_3, 'level_3') %>%
  left_join(level_2, 'level_2') %>%
  left_join(level_1, 'level_1') %>% 
  bind_rows(additional_codes)

# Join --------------------------------------------------------------------
donations <- left_join(ec_data, donation_donor_link, by = "dntn_ec_ref") %>% 
  left_join(donors, by = "donor_id") %>% 
  mutate(interest_code = case_when(
    is.na(dntn_donor_name) ~ 'XXXXX',
    TRUE ~ interest_code
  )) %>% 
  replace_na(list(interest_code = 'ZZZZZ')) %>% 
  left_join(interest_codes, by = c('interest_code' = 'level_5'))

# Manual fixes ------------------------------------------------------------
donations <- donations %>% 
  mutate(
    dntn_accepted_date = case_when(
    dntn_ec_ref == 'C0314887' ~ as_date('2016-06-17'),
    TRUE ~ dntn_accepted_date
    ),
    dntn_received_date = case_when(
      dntn_ec_ref == 'C0314887' ~ as_date('2016-06-17'),
      TRUE ~ dntn_received_date
    )
  )

# Fix pre-poll
donations <- donations %>% 
  mutate(dntn_is_reported_pre_poll = case_when(
    dntn_is_reported_pre_poll == 'True' ~ TRUE,
    str_detect(dntn_reporting_period_name, '[Pp]re-[Pp]oll') ~ TRUE,
    TRUE ~ FALSE
  ))

# Derived fields ----------------------------------------------------------
donations <- donations %>% 
  mutate(x_researched = !is.na(donor_id),
         x_coded = interest_code != 'ZZZZZ',
         x_donor_name = case_when(
          str_sub(donor_id, 1, 1) == 'I'  ~ paste0(ifelse(is.na(title), '', paste0(title, ' ')), first_name, ' ', last_name),
          str_sub(donor_id, 1, 1) == 'O'  ~ orga_name),
         x_donation_date = case_when(
           !is.na(dntn_received_date) ~ dntn_received_date,
           !is.na(dntn_accepted_date) ~ dntn_accepted_date,
           !is.na(dntn_reported_date) ~ dntn_reported_date
           ),
         x_donation_year = year(x_donation_date)
         )

# Save --------------------------------------------------------------------

# Donations
write_csv(donations, 'Output/csv/info_democracy.csv')
save(donations, file = 'Output/Rdata/info_democracy.Rdata')

# Donors
save(donors, file = 'Output/Rdata/donors.Rdata')

# Interest codes
save(interest_codes, file = 'Output/Rdata/interest_codes.Rdata')

# Tidy --------------------------------------------------------------------
rm(ec_data,
   donation_donor_link,
   donor_individual,
   donor_organisations,
   donors,
   level_1,
   level_2,
   level_3,
   level_4,
   level_5,
   additional_codes,
   interest_codes,
   donations)
