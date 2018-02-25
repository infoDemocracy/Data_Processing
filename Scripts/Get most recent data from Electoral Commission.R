# Get most recent data from Eletoral Commission.

# This script gets the most recent data from the Electoral Commmission.
# It also updates the donation_donor_link data.

# Packages ----------------------------------------------------------------
library(dplyr)
library(readr)
library(httr)
library(stringr)
library(lubridate)

# Get data from Electoral Commission --------------------------------------
ec_data <- GET('http://search.electoralcommission.org.uk/api/csv/Donations',
               query = list(sort = "AcceptedDate",
                            order = "desc",
                            prePoll = "true",
                            postPoll = "true")) %>% 
  content("parsed") %>% 
  as.data.frame() %>% 
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
         dntn_campaigning_name = CampaigningName) %>%
  mutate(dntn_value = as.numeric(str_replace_all(dntn_value, '[\\£|,]', '')),
         dntn_accepted_date = dmy(dntn_accepted_date),
         dntn_received_date = dmy(dntn_received_date),
         dntn_reported_date = dmy(dntn_reported_date),
         download_date = Sys.Date())

# Update donation-donor link ----------------------------------------------

# Read current file
donation_donor_link <- read_csv("Data/donation_donor_link.csv")

# Get most recent data
new_donations <- ec_data %>% 
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

# Save --------------------------------------------------------------------
write_csv(ec_data, path = "Data/ec_data.csv")
write_csv(donation_donor_link_new, path = "Data/donation_donor_link.csv", na = '')

# Tidy --------------------------------------------------------------------
rm(ec_data,
   donation_donor_link,
   new_donations,
   donation_donor_link_new)
