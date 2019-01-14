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

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Crime Data Visualizer (U.S.)",
              windowTitle = "US Crime App"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("year_input",
                     "SELECT YEAR",
                     min = 1975,
                     max = 2015, 
                     value = c(1975, 2015),
                     sep = "")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("year_line"),   #COMMA HERE
        tableOutput("table")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
                crime_filtered <- reactive({
                  dat %>% 
                    filter(year > input$year_input[1], 
                           year < input$year_input[2])
                })
                
                output$year_line <- renderPlot(
                  crime_filtered() %>% 
                    ggplot(aes(year)) +
                    geom_line()
                )                              #NO COMMA HERE
                #output$table <- renderTable({
                 # crime_filtered()
                #})
}

# Run the application 
shinyApp(ui = ui, server = server)

