# Progress report

# Setup -------------------------------------------------------------------
library(tidyverse)

# Update data file --------------------------------------------------------
source('Scripts/Produce output data.R')

# Data --------------------------------------------------------------------
donations <- read_csv("Output/info_democracy.csv")

# Not yet coded -----------------------------------------------------------
not_yet_coded <- donations %>% 
  filter(interest_code == 'ZZZZZ',
         !is.na(donor_id)) %>% # Focus on those that have already been researched
  group_by(donor_id, x_donor_name) %>%
  summarise(Total = sum(dntn_value)) %>%
  arrange(-Total) %>% 
  mutate(Total = format(Total, big.mark = ","))

View(not_yet_coded)
