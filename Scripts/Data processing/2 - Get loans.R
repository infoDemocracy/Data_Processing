# Get loans

# Packages ----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(tibble)
library(readr)
library(httr)
library(stringr)
library(lubridate)

# Get loans ---------------------------------------------------------------
ec_loans_raw <- GET('http://search.electoralcommission.org.uk/api/csv/loans',
                    query = list(sort = "StartDate",
                                 order = "desc")) %>% 
  content(type = "text/csv",
          encoding = 'UTF-8',
          col_types = cols(
            ECRef = col_character(),
            RegulatedEntityName = col_character(),
            RegulatedEntityType = col_character(),
            Value = col_character(),
            LoanStatus = col_character(),
            StartDate = col_date(format = '%d/%m/%Y'),
            AccountingUnitName = col_character(),
            LoanParticipantName = col_character(),
            LoanParticipantType = col_character(),
            CompanyRegistrationNumber = col_character(),
            Postcode = col_character(),
            LoanType = col_character(),
            RateOfInterestDescription = col_character(),
            AmountRepaid = col_character(),
            AmountConverted = col_character(),
            AmountOutstanding = col_character(),
            EndDate = col_date(format = '%d/%m/%Y'),
            DateRepaid = col_date(format = '%d/%m/%Y'),
            DateEcLastNotified = col_character(),
            IsReportedPrePoll = col_logical(),
            ReportingPeriodName = col_character(),
            IsAggregation = col_logical(),
            RegulatedEntityId = col_double(),
            AccountingUnitId = col_double(),
            LoanParticipantId = col_double(),
            CampaigningName = col_character(),
            RegisterName = col_character(),
            IsIrishSource = col_logical()
          ))

stop_for_problems(ec_loans_raw)

# Process -----------------------------------------------------------------
ec_loans_raw <- ec_loans_raw %>% 
  rename(dntn_ec_ref = ECRef,
         dntn_regulated_entity_name = RegulatedEntityName,
         dntn_regulated_entity_type = RegulatedEntityType,
         dntn_value = Value,
         dntn_loan_status = LoanStatus,
         dntn_start_date = StartDate,
         dntn_accounting_unit_name = AccountingUnitName,
         dntn_loan_participnt_name = LoanParticipantName,
         dntn_loan_participnt_type = LoanParticipantType,
         dntn_company_registration_number = CompanyRegistrationNumber,
         dntn_postcode = Postcode,
         dntn_loan_type = LoanType,
         dntn_rate_of_interest_description = RateOfInterestDescription,
         dntn_amount_repaid = AmountRepaid,
         dntn_amount_converted = AmountConverted,
         dntn_amount_outstanding = AmountOutstanding,
         dntn_end_date = EndDate,
         dntn_date_repaid = DateRepaid,
         dntn_date_ec_last_notified = DateEcLastNotified,
         dntn_is_reported_pre_poll = IsReportedPrePoll,
         dntn_reporting_period_name = ReportingPeriodName,
         dntn_is_aggregation = IsAggregation,
         dntn_regulated_entity_id = RegulatedEntityId,
         dntn_accounting_unit_id = AccountingUnitId,
         dntn_loan_participant_id = LoanParticipantId,
         dntn_campaigning_name = CampaigningName,
         dntn_register_name = RegisterName,
         dntn_is_irish_source = IsIrishSource) %>% 
  mutate(dntn_value = as.numeric(str_replace_all(dntn_value, '[\\£|,]', '')),
         dntn_amount_repaid = as.numeric(str_replace_all(dntn_amount_repaid, '[\\£|,]', '')),
         dntn_amount_converted = as.numeric(str_replace_all(dntn_amount_converted, '[\\£|,]', '')),
         dntn_amount_outstanding = as.numeric(str_replace_all(dntn_amount_outstanding, '[\\£|,]', '')),
         download_date = today(),
         type = "Loan")

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
new_loans <- ec_loans_raw %>% 
  select(dntn_ec_ref,
         helper_dntn_donor_name = dntn_loan_participnt_name,
         helper_dntn_company_registration_number = dntn_company_registration_number,
         helper_dntn_regulated_entity_name = dntn_regulated_entity_name,
         helper_dntn_value = dntn_value)

# Append the new data to the old and remove duplicates
donation_donor_link_new <- bind_rows(donation_donor_link, new_loans) %>%
  group_by(dntn_ec_ref) %>% 
  arrange(donor_id) %>% 
  slice(1) %>% 
  ungroup() %>% 
  arrange(helper_dntn_donor_name,
          helper_dntn_company_registration_number)

# Save --------------------------------------------------------------------
write_csv(ec_loans_raw, 'Data/ec_loans_raw.csv')

write_csv(donation_donor_link_new,
          path = "Data/donation_donor_link.csv",
          na = '')

# Tidy --------------------------------------------------------------------
rm(ec_loans_raw,
   donation_donor_link,
   new_loans,
   donation_donor_link_new)
