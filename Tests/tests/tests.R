# Tests

# Remove known errors

# Tests -------------------------------------------------------------------

# Test that:
# - organisations with different registration numbers aren't grouped
# - All donations have a donor i.e. donor name not NA (except where unidentified donor).

context("Tests")

test_that("Every donation in ec_data is is donation_donor_link data", {
  missing_donations <- ec_data %>% 
    anti_join(donation_donor_link, by = "dntn_ec_ref")
  
  expect_equal(nrow(missing_donations), 0)
})

test_that("If dntn_donor_status is 'Trade Union' then coded as T1", {
  trade_union <- data %>% 
    filter(dntn_donor_status == 'Trade Union',
           level_1 != 'T1') %>% 
    select(dntn_ec_ref,
           dntn_regulated_entity_name,
           dntn_donor_name,
           dntn_donor_status,
           donor_id,
           level_1,
           dntn_value)
  
  expect_equal(nrow(trade_union), 0) 

})

test_that("If dntn_donor_status is 'Public Fund' then coded as P1", {
  public_fund <- data %>% 
    filter(dntn_donor_status == 'Public Fund',
           level_1 != 'P1') %>% 
    select(dntn_ec_ref,
           dntn_regulated_entity_name,
           dntn_donor_name,
           dntn_donor_status,
           donor_id,
           level_1,
           dntn_value)
  
  expect_equal(nrow(public_fund), 0) 
  
})

test_that("The code 70100 is not used", {
  expect_false('70100' %in% data$interest_code)
})

test_that("Every donation is given a valid interest code", {
  expect_false(NA %in% data$interest_code)
  expect_false(NA %in% data$level_5_description)
})

test_that("Every donation has a date field", {
  missing_date <- data %>% 
    filter(is.na(dntn_received_date) & is.na(dntn_accepted_date) & is.na(dntn_reported_date))
  
  expect_equal(nrow(missing_date), 0)
})
