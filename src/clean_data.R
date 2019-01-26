library(tidyverse)
library(dplyr)

# Load data
data <- read.csv("../data/ucr_crime_1975_2015.csv")

# Filter out the data from 1980-2015
data <- data %>% filter(year>1979)
data$months_reported <- NULL

# Re-group columns
tidy_data <- (data %>% 
                gather( key = "crime_type_rate", value = "count_per_100k", 
                        violent_per_100k, 
                        homs_per_100k, 
                        rape_per_100k, 
                        rob_per_100k, 
                        agg_ass_per_100k) %>%
                 mutate(crime_sum=total_pop*count_per_100k/100000) %>%
                 mutate_at(vars(crime_sum), funs(round(., 1))) %>%
                 mutate_at(vars(count_per_100k), funs(round(.,3))))

# Removed unused columns
tidy_data <- select(tidy_data, c(ORI,year,department_name,total_pop,crime_type_rate,count_per_100k,crime_sum))
tidy_data <- tidy_data[ grep("County", tidy_data$department_name, invert = TRUE) , ]
# Omit NA
tidy_data <- na.omit(tidy_data)

# Export CSV
write_csv(tidy_data, "../data/clean_data.csv")