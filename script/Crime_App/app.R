#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(ggplot2)


#load data

dat <- read.csv("../../data/ucr_crime_1975_2015.csv")
str(dat)
library(shiny)

#filter out the data that was reported less than 12 months


tidy_data <- (dat %>% 
    gather( key = "crime_type", value = "count_per_100k", 
            violent_per_100k, 
            homs_per_100k, 
            rape_per_100k, 
            rob_per_100k, 
            agg_ass_per_100k))


dat <- tidy_data %>% filter(months_reported == 12)
sum(is.na(tidy_data))

cities <- unique(tidy_data$department_name)
cities
years <- unique(tidy_data$year)
years
crime <- unique(tidy_data$crime_type)
crime

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Crime Data Visualizer (U.S.)",
             windowTitle = "US Crime App"),
  
  # Sidebar select year range 
  sidebarLayout(
    sidebarPanel(
      selectInput("department_name", "SELECT CITY",
                  choices = cities,
                  selected = "Atlanta"),
      br(),
      
      sliderInput("year_input", "Year",
                  min = 1975, max = 2015, 
                  value = c(1975, 2015), 
                  sep = ""),
      br(),
      
    # select crime type
    radioButtons("crime_type", 
                 "SELECT CRIME TYPE",
                 choices = crime,
                 selected = "rape_per_100k"),
 
      mainPanel(plotOutput("plot_crime"))
)
)
)


# Define server logic required to draw a histogram
 server <- function(input, output) {
   crime_filtered <- reactive(
     dat %>% filter(cities ==  input$department_name,
                    crime_type ==  input$crime_type,
                    year >= input$year_input[1] &
                      year <= input$year_input[2])
   )
   
   output$plot_crime <- renderPlot(
     crime_filtered() %>% 
       ggplot(aes_(input$year_input,
                   input$crime_type, 
                   input$department_name)) +
       geom_line()+
       labs(x = "Year", y = "Crime per 100k")
   )
 }


    
##    if (input$crime_input == "homs_per_100k") {
##      ggplot(filter_crime, aes(year, homs_per_100k, department_name)) +
##        geom_line()+
##        labs(x = "Year", y = "Homicide per 100K")+
##        geom_point()
##    }
##    else if(input$crime_input == "rape_per_100k"){
##      ggplot(filter_crime, aes(year, rape_per_100k, department_name)) +
##        geom_line()+
##        labs(x = "Year", y = "Rape per 100K")+
##        geom_point()
##    }
##    else if(input$crime_input == "rob_per_100k"){
##      ggplot(filter_crime, aes(year, rob_per_100k, department_name)) +
##        geom_line()+
##        labs(x = "Year", y = "Robbery per 100K")+
##        geom_point()
##    }
##    else if(input$crime_input == "agg_ass_per_100k"){
##      ggplot(filter_crime, aes(year, agg_ass_per_100k, department_name)) +
##        geom_line()+
##        labs(x = "Year", y = "Assaults per 100K")+
##        geom_point()
##    }
##  
##})
##}
      
 


# Run the application 
shinyApp(ui = ui, server = server)

