# Run tests

# This script runs some tests on the processed data.

# Packages ----------------------------------------------------------------
library(testthat)
library(dplyr)

# Data --------------------------------------------------------------------
source('Scripts/Produce output data.R')
data <- read_csv("Output/info_democracy.csv")
ec_data <- read_csv("Data/ec_data.csv")
donation_donor_link <- read_csv("Data/donation_donor_link.csv")

# Test --------------------------------------------------------------------
test_dir('Tests/tests')
