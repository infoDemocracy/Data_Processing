# Scrape data from companies house

# ABANDONED!!!

# Setup -------------------------------------------------------------------
library(tidyverse)
output <- read_csv("Scripts/Get company data/output.csv")

left_overs <- filter(output, is.na(SIC_1)) %>% 
  select(reg_number)

left_overs <- left_overs$reg_number

for (i in seq_along(left_overs)){
  x <- paste("https://beta.companieshouse.gov.uk/company/", left_overs[i], sep = "")
  print(x)
  
  SIC <- x %>% 
    html_nodes("strong span") %>%
    html_text() %>%
    as.numeric()
}
