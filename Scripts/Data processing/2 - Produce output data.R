# Produce output data

# Packages ----------------------------------------------------------------
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)


# ec_data -----------------------------------------------------------------
ec_data <- read_csv("Data/ec_data_raw.csv",
                    col_types = cols(
                      ECRef = col_character(),
                      RegulatedEntityName = col_character(),
                      RegulatedEntityType = col_character(),
                      Value = col_character(),
                      AcceptedDate = col_date(format = '%d/%m/%Y'),
                      AccountingUnitName = col_character(),
                      DonorName = col_character(),
                      AccountingUnitsAsCentralParty = col_logical(),
                      IsSponsorship = col_logical(),
                      DonorStatus = col_character(),
                      RegulatedDoneeType = col_character(),
                      CompanyRegistrationNumber = col_character(),
                      Postcode = col_character(),
                      DonationType = col_character(),
                      NatureOfDonation = col_character(),
                      PurposeOfVisit = col_character(),
                      DonationAction = col_character(),
                      ReceivedDate = col_date(format = '%d/%m/%Y'),
                      ReportedDate = col_date(format = '%d/%m/%Y'),
                      IsReportedPrePoll = col_logical(),
                      ReportingPeriodName = col_character(),
                      IsBequest = col_logical(),
                      IsAggregation = col_logical(),
                      RegulatedEntityId = col_double(),
                      AccountingUnitId = col_double(),
                      DonorId = col_double(),
                      CampaigningName = col_character(),
                      RegisterName = col_character(),
                      IsIrishSource = col_logical(),
                      download_date = col_date()
                    ),
                    na = c("", "NA", "N/A")) %>% 
  rename(dntn_ec_ref = ECRef,
         dntn_regulated_entity_name = RegulatedEntityName,
         dntn_regulated_entity_type = RegulatedEntityType,
         dntn_value = Value,
         dntn_accepted_date = AcceptedDate,
         dntn_accounting_unit_name = AccountingUnitName,
         dntn_donor_name = DonorName,
         dntn_accounting_unit_as_central_party = AccountingUnitsAsCentralParty,
         dntn_is_sponsorship = IsSponsorship,
         dntn_donor_status = DonorStatus,
         dntn_regulated_donee_type = RegulatedDoneeType,
         dntn_company_registration_number = CompanyRegistrationNumber,
         dntn_postcode = Postcode,
         dntn_donation_type = DonationType,
         dntn_nature_of_donation = NatureOfDonation,
         dntn_purpose_of_visit = PurposeOfVisit,
         dntn_donation_action = DonationAction,
         dntn_received_date = ReceivedDate,
         dntn_reported_date = ReportedDate,
         dntn_is_reported_pre_poll = IsReportedPrePoll,
         dntn_reporting_period_name = ReportingPeriodName,
         dntn_is_bequest = IsBequest,
         dntn_is_aggregation = IsAggregation,
         dntn_regulated_entity_id = RegulatedEntityId,
         dntn_accounting_unit_id = AccountingUnitId,
         dntn_donor_id = DonorId,
         dntn_campaigning_name = CampaigningName,
         dntn_register_name = RegisterName,
         dntn_is_irish_source = IsIrishSource) %>%
  mutate(dntn_value = as.numeric(str_replace_all(dntn_value, '[\\£|,]', '')))

# donation_donor_link -----------------------------------------------------
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

# donors ------------------------------------------------------------------
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

# interest_codes ----------------------------------------------------------
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

# info_democracy ----------------------------------------------------------

# Join
info_democracy <- left_join(ec_data, donation_donor_link, by = "dntn_ec_ref") %>% 
  left_join(donors, by = "donor_id") %>% 
  mutate(interest_code = case_when(
    is.na(dntn_donor_name) ~ 'XXXXX',
    TRUE ~ interest_code
  )) %>% 
  replace_na(list(interest_code = 'ZZZZZ')) %>% 
  left_join(interest_codes, by = c('interest_code' = 'level_5'))

# Fix pre-poll
info_democracy <- info_democracy %>% 
  mutate(dntn_is_reported_pre_poll = case_when(
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
         x_donation_year = year(x_donation_date)
         )

# Save --------------------------------------------------------------------

# ec_data
save(ec_data, file = 'Output/Rdata/ec_data.Rdata')

# donation_donor_link
save(donation_donor_link, file = 'Output/Rdata/donation_donor_link.Rdata')

# donors
save(donors, file = 'Output/Rdata/donors.Rdata')

# interest_codes
save(interest_codes, file = 'Output/Rdata/interest_codes.Rdata')

# info_democracy
write_csv(info_democracy, 'Output/csv/info_democracy.csv')
save(info_democracy, file = 'Output/Rdata/info_democracy.Rdata')

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
   info_democracy)
