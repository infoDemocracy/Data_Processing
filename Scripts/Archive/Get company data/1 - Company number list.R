# Produce list of company numbers for use it api for loop

# Company numbers ---------------------------------------------------------
company_numbers <- ECdata[["CompanyRegistrationNumber"]] %>%
  unique() %>% 
  as.character()

company_numbers <- company_numbers[!is.na(company_numbers)] #remove NA

# remove problems
company_numbers <- company_numbers[company_numbers != "10097916"]

rm(ECdata)
