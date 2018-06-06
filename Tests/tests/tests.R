# Tests

# Remove known errors

# Tests -------------------------------------------------------------------

# Test that:
# - organisations with different registration numbers aren't grouped
# - All donations have appropriate date columns
# - All donations have a donor i.e. donor name not NA (except where unidentified donor).
# - Donation_donor_link$dntn_ec_ref is same as ec_data$dntn_ec_ref (although note that link file may have more records)

context('Tests')

test_that('If dntn_donor_status is Trade Union then coded as T1', {
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

test_that('If dntn_donor_status is Public Fund then coded as P1', {
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

test_that('The code 70100 is not used', {
  expect_false('70100' %in% data$interest_code)
})

test_that('Every donation is given a valid interest code', {
  expect_false(NA %in% data$interest_code)
  expect_false(NA %in% data$level_5_description)
})
