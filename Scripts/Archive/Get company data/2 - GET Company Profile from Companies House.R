# GET Company Profile from Companies House

# GET data from companies house -------------------------------------------

#company_numbers <- c("test", "00096056", "01697461")

collect <- NULL # Null data frame to collect data

for (i in seq_along(company_numbers)){
  try({
    url <- paste("https://api.companieshouse.gov.uk/company/", company_numbers[i], sep = "")

  company_profile <- GET(url,
                         authenticate(user = "qOshzMl3R5ZrEWwqNubZWRUk7tGYi78mI7REvTXN",
                                      password = "",
                                      type = "basic")
                         )
  
  if(company_profile$status_code == 429){
    Sys.sleep(310)
    company_profile <- GET(url,
                           authenticate(user = "qOshzMl3R5ZrEWwqNubZWRUk7tGYi78mI7REvTXN",
                                        password = "",
                                        type = "basic")
    )
  }
  
  company_profile_content <- content(company_profile, "parsed") %>%
    as.data.frame()
  
  #rename SIC columns
  names(company_profile_content) <- sub("^X.[0-9]{1,}.", "SIC_1", names(company_profile_content))
  
  sic_columns <- grep("^sic_codes..", names(company_profile_content))
  
  for (j in seq_along(sic_columns)){
    
    names(company_profile_content)[sic_columns[j]] <- paste("SIC_", j, sep = "")
    
  }
  
  #add reference column to see which company number the row refers to
  company_profile_content$reg_number <- company_numbers[i]
  
  #bind to collect
  collect <- bind_rows(collect, company_profile_content)
  })
}

write_csv(x = collect, path = 'Scripts/Get company data/output.csv')

rm(i, j,sic_columns, url, company_numbers, company_profile, company_profile_content)