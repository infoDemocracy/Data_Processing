# Upload data to drop box

# Packages ----------------------------------------------------------------
library(rdrop2)

# Authenticate ------------------------------------------------------------
drop_auth()

# Upload ------------------------------------------------------------------
drop_upload(file = 'Data/donor_individual.csv',
            path = 'infoDemocracy/Data/donor_individual.csv')

files <- paste0('Data/', list.files('Data', recursive = T))
paths <- paste0('infoDmeocracy/', files)

lapply(files, drop_upload, path = paths)
