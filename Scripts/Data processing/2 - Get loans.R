# Get loans

# Packages ----------------------------------------------------------------
library(dplyr)
library(readr)
library(RinfoDemocracy)

# Get loans ---------------------------------------------------------------
ec_loans_raw <- get_loans()

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

# Update reporting periods ------------------------------------------------

# Read current file
reporting_periods <- read_csv("Data/reporting_periods.csv",
                              col_types = cols(
                                dntn_reporting_period_name = col_character(),
                                x_is_reported_pre_poll = col_logical()
                              ))

# Get most recent data
new_reporting_periods <- ec_loans_raw %>% 
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
write_csv(ec_loans_raw, 'Data/ec_loans_raw.csv')

write_csv(donation_donor_link_new,
          path = "Data/donation_donor_link.csv",
          na = '')

write_csv(reporting_periods_new,
          "Data/reporting_periods.csv",
          na = '')

# Tidy --------------------------------------------------------------------
rm(ec_loans_raw,
   donation_donor_link,
   new_loans,
   donation_donor_link_new,
   reporting_periods,
   new_reporting_periods,
   reporting_periods_new)
