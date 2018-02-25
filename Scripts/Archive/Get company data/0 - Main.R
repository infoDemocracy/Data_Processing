# Main

# Setup -------------------------------------------------------------------
library(tidyverse)
library(httr)
source('Scripts/Load EC data.R')

# Source ------------------------------------------------------------------
source('Scripts/Get company data/1 - Company number list.R')
source('Scripts/Get company data/2 - GET Company Profile from Companies House.R')