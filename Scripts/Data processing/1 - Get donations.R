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
ec_donations_raw <- GET('http://search.electoralcommission.org.uk/api/csv/Donations',
                   query = list(sort = "AcceptedDate",
                                order = "desc",
                                prePoll = "true",
                                postPoll = "true")) %>% 
  content(type = "text/csv",
          encoding = 'UTF-8',
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
            IsIrishSource = col_logical()
          ),
          na = c("", "NA", "N/A"))

stop_for_problems(ec_donations_raw)

# Process -----------------------------------------------------------------
ec_donations_raw <- 
  ec_donations_raw %>% 
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
  mutate(dntn_value = as.numeric(str_replace_all(dntn_value, '[\\£|,]', '')),
         download_date = today(),
         type = "Donation")

# Update donation-donor link ----------------------------------------------

# Read current file
donation_donor_link <- read_csv(
  "Data/donation_donor_link.csv",
  col_types = cols(
    dntn_ec_ref = col_character(),
    donor_id = col_character(),
    helper_dntn_donor_name = col_character(),
    helper_dntn_company_registration_number = col_character(),
    helper_dntn_regulated_entity_name = col_character(),
    helper_dntn_value = col_double()
  )
)

# Get most recent data
new_donations <- ec_donations_raw %>% 
  select(dntn_ec_ref,
         helper_dntn_donor_name = dntn_donor_name,
         helper_dntn_company_registration_number = dntn_company_registration_number,
         helper_dntn_regulated_entity_name = dntn_regulated_entity_name,
         helper_dntn_value = dntn_value)

# Append the new data to the old and remove duplicates
donation_donor_link_new <- bind_rows(donation_donor_link, new_donations) %>%
  group_by(dntn_ec_ref) %>% 
  arrange(donor_id) %>% 
  slice(1) %>% 
  ungroup() %>% 
  arrange(helper_dntn_donor_name,
          helper_dntn_company_registration_number)

# Update reporting periods ------------------------------------------------

# Read current file
reporting_periods <- read_csv("Data/reporting_periods.csv",
                              col_types = cols(
                                dntn_reporting_period_name = col_character(),
                                x_is_reported_pre_poll = col_logical()
                              ))

# Get most recent data
new_reporting_periods <- ec_donations_raw %>% 
  select(dntn_reporting_period_name) %>% 
  distinct()
  
# Append the new data to the old and remove duplicates
reporting_periods_new <- bind_rows(reporting_periods, new_reporting_periods) %>%
  group_by(dntn_reporting_period_name) %>% 
  arrange(x_is_reported_pre_poll) %>% 
  slice(1) %>% 
  ungroup() %>% 
  arrange(dntn_reporting_period_name)

# Save --------------------------------------------------------------------
write_csv(ec_donations_raw, 'Data/ec_donations_raw.csv')

write_csv(donation_donor_link_new,
          path = "Data/donation_donor_link.csv",
          na = '')

write_csv(reporting_periods_new,
          "Data/reporting_periods.csv",
          na = '')

# Tidy --------------------------------------------------------------------
rm(ec_donations_raw,
   donation_donor_link,
   new_donations,
   donation_donor_link_new,
   reporting_periods,
   new_reporting_periods,
   reporting_periods_new)
