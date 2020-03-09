# Main

# This script downloads the latest data from the Electoral Commission.
# It then processes the data and saves an output file.
# It then runs some validation checks on the output file.

# Scripts -----------------------------------------------------------------
source('Scripts/Data processing/1 - Get donations.R')
source('Scripts/Data processing/2 - Get loans.R')
source('Scripts/Data processing/3 - Produce output data.R')

# Validation --------------------------------------------------------------
source('Validation/Validation.R')
