# Produce output data

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)
library(digest)

# Donations ---------------------------------------------------------------
ec_donations <- read_csv("Data/ec_donations_raw.csv",
                         col_types = cols(
                           dntn_ec_ref = col_character(),
                           dntn_regulated_entity_name = col_character(),
                           dntn_regulated_entity_type = col_character(),
                           dntn_value = col_double(),
                           dntn_accepted_date = col_date(format = ""),
                           dntn_accounting_unit_name = col_character(),
                           dntn_donor_name = col_character(),
                           dntn_accounting_unit_as_central_party = col_logical(),
                           dntn_is_sponsorship = col_logical(),
                           dntn_donor_status = col_character(),
                           dntn_regulated_donee_type = col_character(),
                           dntn_company_registration_number = col_character(),
                           dntn_postcode = col_character(),
                           dntn_donation_type = col_character(),
                           dntn_nature_of_donation = col_character(),
                           dntn_purpose_of_visit = col_character(),
                           dntn_donation_action = col_character(),
                           dntn_received_date = col_date(format = ""),
                           dntn_reported_date = col_date(format = ""),
                           dntn_is_reported_pre_poll = col_logical(),
                           dntn_reporting_period_name = col_character(),
                           dntn_is_bequest = col_logical(),
                           dntn_is_aggregation = col_logical(),
                           dntn_regulated_entity_id = col_double(),
                           dntn_accounting_unit_id = col_double(),
                           dntn_donor_id = col_double(),
                           dntn_campaigning_name = col_character(),
                           dntn_register_name = col_character(),
                           dntn_is_irish_source = col_logical(),
                           download_date = col_date(format = ""),
                           type = col_character()
                         ))

# Loans -------------------------------------------------------------------
ec_loans <- read_csv('Data/ec_loans_raw.csv',
                     col_types = cols(
                       dntn_ec_ref = col_character(),
                       dntn_regulated_entity_name = col_character(),
                       dntn_regulated_entity_type = col_character(),
                       dntn_value = col_double(),
                       dntn_loan_status = col_character(),
                       dntn_start_date = col_date(format = ""),
                       dntn_accounting_unit_name = col_character(),
                       dntn_loan_participnt_name = col_character(),
                       dntn_loan_participnt_type = col_character(),
                       dntn_company_registration_number = col_character(),
                       dntn_postcode = col_character(),
                       dntn_loan_type = col_character(),
                       dntn_rate_of_interest_description = col_character(),
                       dntn_amount_repaid = col_double(),
                       dntn_amount_converted = col_double(),
                       dntn_amount_outstanding = col_double(),
                       dntn_end_date = col_date(format = ""),
                       dntn_date_repaid = col_date(format = ""),
                       dntn_date_ec_last_notified = col_character(),
                       dntn_is_reported_pre_poll = col_logical(),
                       dntn_reporting_period_name = col_character(),
                       dntn_is_aggregation = col_logical(),
                       dntn_regulated_entity_id = col_double(),
                       dntn_accounting_unit_id = col_double(),
                       dntn_loan_participant_id = col_double(),
                       dntn_campaigning_name = col_logical(),
                       dntn_register_name = col_character(),
                       dntn_is_irish_source = col_logical(),
                       download_date = col_date(format = ""),
                       type = col_character()
                     )) %>% 
  rename(dntn_received_date = dntn_start_date,
         dntn_donor_name = dntn_loan_participnt_name,
         dntn_donor_status = dntn_loan_participnt_type,
         dntn_donor_id = dntn_loan_participant_id) %>% 
  select(-dntn_loan_status,
         -dntn_loan_type,
         -dntn_rate_of_interest_description,
         -dntn_amount_repaid,
         -dntn_amount_converted,
         -dntn_amount_outstanding,
         -dntn_end_date,
         -dntn_date_repaid,
         -dntn_date_ec_last_notified)

# Donation Donor Link -----------------------------------------------------
donation_donor_link <- 
  read_csv("Data/donation_donor_link.csv",
           col_types = cols(
             dntn_ec_ref = col_character(),
             donor_id = col_character(),
             helper_dntn_donor_name = col_character(),
             helper_dntn_company_registration_number = col_character(),
             helper_dntn_regulated_entity_name = col_character(),
             helper_dntn_value = col_double()
           )) %>%
  filter(!is.na(donor_id)) %>% 
  select(dntn_ec_ref, donor_id)

# Donors ------------------------------------------------------------------
donor_individual <- read_csv("Data/donor_individual.csv",
                             col_types = cols(
                               donor_id = col_character(),
                               title = col_character(),
                               first_name = col_character(),
                               middle_names = col_character(),
                               last_name = col_character(),
                               suffix = col_character(),
                               previous_last_name = col_character(),
                               designation = col_character(),
                               alias = col_character(),
                               gender = col_character(),
                               birth_year = col_double(),
                               birth_month = col_double(),
                               birth_day = col_double(),
                               death_year = col_double(),
                               death_month = col_double(),
                               death_day = col_double(),
                               interest_code = col_character(),
                               company = col_character(),
                               powerbase = col_character(),
                               wikipedia = col_character(),
                               notes = col_character()
                             ))

donor_organisations <- read_csv("Data/donor_organisations.csv",
                                col_types = cols(
                                  donor_id = col_character(),
                                  orga_name = col_character(),
                                  interest_code = col_character(),
                                  powerbase = col_character(),
                                  wikipedia = col_character(),
                                  orga_website = col_character(),
                                  notes = col_character(),
                                  companies_house = col_character(),
                                  orga_registry_number = col_character()
                                ))

donors <- bind_rows(donor_individual, donor_organisations) %>% 
  filter(!is.na(donor_id)) %>% 
  mutate(interest_code = str_replace(interest_code,
                                     pattern = '^_',
                                     replacement = ''))

# Interest Codes ----------------------------------------------------------
level_5 <- read_csv("Data/interest_code_level_5.csv",
                    col_types = cols(
                      level_5 = col_character(),
                      level_5_description = col_character(),
                      level_4 = col_character()
                    ))

level_4 <- read_csv("Data/interest_code_level_4.csv",
                    col_types = cols(
                      level_4 = col_character(),
                      level_4_description = col_character(),
                      level_3 = col_character()
                    ))

level_3 <- read_csv("Data/interest_code_level_3.csv",
                    col_types = cols(
                      level_3 = col_character(),
                      level_3_description = col_character(),
                      level_2 = col_character()
                    ))

level_2 <- read_csv("Data/interest_code_level_2.csv",
                    col_types = cols(
                      level_2 = col_character(),
                      level_2_description = col_character(),
                      level_1 = col_character()
                    ))

level_1 <- read_csv("Data/interest_code_level_1.csv",
                    col_types = cols(
                      level_1 = col_character(),
                      level_1_description = col_character(),
                      level_1_short = col_character()
                    ))

additional_codes <- read_csv('Data/interest_code_additional_codes.csv',
                             col_types = cols(
                               level_5 = col_character(),
                               level_5_description = col_character(),
                               level_4 = col_character(),
                               level_4_description = col_character(),
                               level_3 = col_character(),
                               level_3_description = col_character(),
                               level_2 = col_character(),
                               level_2_description = col_character(),
                               level_1 = col_character(),
                               level_1_description = col_character(),
                               level_1_short = col_character()
                             ))

interest_codes <- level_5 %>% 
  left_join(level_4, 'level_4') %>% 
  left_join(level_3, 'level_3') %>%
  left_join(level_2, 'level_2') %>%
  left_join(level_1, 'level_1') %>% 
  bind_rows(additional_codes)

# Info_democracy ----------------------------------------------------------

# Bind donations and loans
info_democracy <- bind_rows(ec_donations, ec_loans)

# Join to donors
info_democracy <- left_join(info_democracy, donation_donor_link, by = "dntn_ec_ref") %>% 
  left_join(donors, by = "donor_id") %>% 
  mutate(interest_code = case_when(
    is.na(dntn_donor_name) ~ 'XXXXX',
    TRUE ~ interest_code
  )) %>% 
  replace_na(list(interest_code = 'ZZZZZ')) %>% 
  left_join(interest_codes, by = c('interest_code' = 'level_5'))

# Fix pre-poll
info_democracy <- info_democracy %>% 
  mutate(x_is_reported_pre_poll = case_when(
    dntn_is_reported_pre_poll == 'True' ~ TRUE,
    str_detect(dntn_reporting_period_name, '[Pp]re-[Pp]oll') ~ TRUE,
    TRUE ~ FALSE
  ))

# Derived fields
info_democracy <- info_democracy %>% 
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
         x_donation_year = year(x_donation_date),
         x_donation_month = month(x_donation_date),
         x_donation_quarter = quarter(x_donation_date)
         )

# Create unique id for donation - To check same donation does not appear twice in pre or post poll data
info_democracy <- info_democracy %>% 
  mutate(x_donation_id = map_chr(paste(dntn_donor_name,
                                       dntn_regulated_entity_name,
                                       dntn_value,
                                       x_donation_date,
                                       sep = '_'),
                                 digest))

# Save --------------------------------------------------------------------
write_csv(info_democracy, 'Output/info_democracy.csv')
save(info_democracy, file = 'Output/info_democracy.Rdata')

# Tidy --------------------------------------------------------------------
rm(ec_donations,
   ec_loans,
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
   info_democracy)
