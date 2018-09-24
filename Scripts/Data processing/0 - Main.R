# Main

# This script downloads the latest data from the Electoral Commission.
# It then processes the data and saves an output file.
# The data is then copied to other projects.

# Scripts -----------------------------------------------------------------
source('Scripts/Data processing/1 - Get most recent data.R')
source('Scripts/Data processing/2 - Produce output data.R')
source('Scripts/Data processing/3 - Copy files.R')
