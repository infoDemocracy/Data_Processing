# Combine api results with ECdata

# Setup -------------------------------------------------------------------
library(tidyverse)
output <- read_csv("Scripts/Get company data/output.csv")
source('Scripts/Load EC data.R')

# Combine -----------------------------------------------------------------

organisations <- select(ECdata,
                        DonorStatus,
                        DonorName,
                        CompanyRegistrationNumber,
                        XDonorStatus) %>% 
  filter(XDonorStatus %in% c("Organisation",
                             "Political Party",
                             "Trade Union")) %>% 
  unique()

output <- select(output,
                 company_name,
                 type,
                 registered_office_address.postal_code,
                 registered_office_address.address_line_1,
                 registered_office_address.locality,
                 registered_office_address.address_line_2,
                 company_number,
                 previous_company_names.name,
                 links.self,
                 reg_number,
                 SIC_1,
                 SIC_2,
                 SIC_3,
                 SIC_4,
                 errors.type)

organisations <- left_join(organisations, output, by = c("CompanyRegistrationNumber" = "reg_number")) %>% 
  arrange(DonorName)

write_csv(x = organisations, path = 'Scripts/Get company data/organisations.csv', na = "")
