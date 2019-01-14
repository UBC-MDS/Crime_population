#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(shiny)
library(tidyverse)
library(ggplot2)


#load data

dat <- read.csv("../../data/ucr_crime_1975_2015.csv")
str(dat)
library(shiny)

#filter out the data that was reported less than 12 months
dat <- dat %>% filter(months_reported == 12)
sum(is.na(dat))

cities <- dat$department_name

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Crime Data Visualizer (U.S.)",
             windowTitle = "US Crime App"),
  
  # Sidebar select year range 
  sidebarLayout(
    sidebarPanel(
      sliderInput("year_input",
                  "SELECT YEAR",
                  min = 1975,
                  max = 2015, 
                  value = c(1975, 2015),
                  sep = ""),
      selectInput("department_name", "SELECT CITY",
                  choices = cities,
                  selected = "Atlanta"),
    # select crime type
      radioButtons("crime_type", 
                   "SELECT CRIME TYPE",
                   c("Homicide" = "homs_per_100k",
                     "Rape" = "rape_per_100k",
                     "Robbery" = "rob_per_100k",
                     "Aggravated Assault" = "agg_ass_per_100k"),
                   selected = "rape_per_100k")),
 
      mainPanel(
        plotOutput("plot_crime")   
    )
)
)


# Define server logic required to draw a histogram
server <- function(input, output) {
 crime_filtered <- reactive({
   dat %>% 
     filter(year > input$year_input[1], 
            year < input$year_input[2])
    
    output$plot_crime <- renderPlot({
      ggplot(crime_filtered, aes_(year_input, crime_type), department_name) +
        geom_line()+
        labs(x = "Crime per 100k", y = "Year")
    }
      
    )
    
 }
 )
}
 
# Run the application 
shinyApp(ui = ui, server = server)

