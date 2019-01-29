library(tidyverse)
library(dplyr)

# Load data
data <- read.csv("../data/ucr_crime_1975_2015.csv")

# Filter out the data from 1980-2015
data <- data %>% filter(year>1979)
data$months_reported <- NULL

# Re-group columns
tidy_data <- (data %>% 
                gather( key = "crime_type_rate", value = "incidents_per_100k_population", 
                        violent_per_100k, 
                        homs_per_100k, 
                        rape_per_100k, 
                        rob_per_100k, 
                        agg_ass_per_100k) %>%
                 mutate(incidents_for_total_population=total_pop*incidents_per_100k_population/100000) %>%
                 mutate_at(vars(incidents_for_total_population), funs(round(., 1))) %>%
                 mutate_at(vars(incidents_per_100k_population), funs(round(.,3))))

# Removed unused columns/cities
tidy_data <- select(tidy_data, c(ORI,year,department_name,total_pop,crime_type_rate,incidents_per_100k_population,incidents_for_total_population))
tidy_data <- tidy_data[ grep("County", tidy_data$department_name, invert = TRUE) , ]
colnames(tidy_data)[3] <- "City"
# Omit NA
tidy_data <- na.omit(tidy_data)

# Export CSV
write_csv(tidy_data, "../data/clean_data.csv")