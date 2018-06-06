# Run tests

# This script runs some tests on the processed data.

# Packages ----------------------------------------------------------------
library(testthat)
library(dplyr)

# Data --------------------------------------------------------------------
source('Scripts/Produce output data.R')
data <- read_csv("Output/info_democracy.csv")

# Test --------------------------------------------------------------------
test_dir('Tests/tests')
