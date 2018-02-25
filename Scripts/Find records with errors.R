# Find records with incomplete data

# **NOTES** ---------------------------------------------------------------
# This script identifies records with missing data.
# There are some issues with dates. A number of records do not have accepted/received date. In cases when the donation is a total value of a number of smaller donations this is ok.
# Similarly for recived date.
# However, all donations should at least have a reported date, which they don't.
# All records have a ReportingPeriodName, but this field isn't apporpriate for analysis due to the inconsistent format of its values.

# Upload data -------------------------------------------------------------
ECdata <- read.csv("~/Documents/TheyWorkForThem/Data/ECdata files/ECdata.csv")


# Missing data ------------------------------------------------------------
## Missing Donor Status
## All these cases have a blank DonorName and DonationType = "Total value of donations not reported individually" 
MissingDonorStatus = ECdata[ECdata$DonorStatus == "N/A", ]

## Missing received date
MissingReceivedDate = ECdata[is.na(ECdata$XReceivedDate), ]

## Missing accepted date
MissingAcceptedDate = ECdata[is.na(ECdata$XAcceptedDate), ]

## Missing reported date
MissingReported = ECdata[is.na(ECdata$XReportedDate), ]

## Missing all dates
MissingAllDates = ECdata[is.na(ECdata$XReceivedDate) & is.na(ECdata$XAcceptedDate) & is.na(ECdata$XReportedDate), ]

## Missing donor name
MissingDonorName = ECdata[is.na(ECdata$DonorName), ]

## Bad date
bad_dates <- ec_data %>% filter(ec_ref %in% 'C0314887')

## No donor name
