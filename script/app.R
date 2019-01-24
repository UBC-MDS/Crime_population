library(shiny)
library(ggplot2)
library(dplyr)
library(magrittr)
library(colourpicker)
library(lubridate)
library(plotly)
library(DT)
library(forcats)

#load cleaned data
tidy_data <- read.csv("clean_data.csv")
cities <- unique(tidy_data$department_name)
years <- unique(tidy_data$year)
crime <- unique(tidy_data$crime_type_rate)

# set up ui

ui <- fluidPage( # Application title
  titlePanel(title = "Crime Data Visualizer (U.S.)"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(width = 3,
                 #---------------FIRST PANEL-----------------------
                 h3("Total Comparison"),
                 #select year
                 selectInput("year", "SELECT YEAR", multiple = FALSE,
                             sort(unique(tidy_data$year)),selected = "2015"),
                 #select field
                 radioButtons("field", 
                              "SELECT FIELD",
                              choices = c("Rate (per 100k population)", "Total"),
                              selected = "Total"),
                 #select crime type
                 radioButtons("crime_type_only_one",
                              label = "SELECT CRIME TYPE",
                              choices = c("Total Violent" = "violent_per_100k",
                                          "Homicide" = "homs_per_100k",
                                          "Rape" = "rape_per_100k",
                                          "Robbery" = "rob_per_100k",
                                          "Aggravated Assault" = "agg_ass_per_100k"),
                              selected = "violent_per_100k"),
                 
                 #---------------SECOND PANEL-----------------------
                 hr(),
                 h3("Cross City Comparison"),
                 selectInput("department_name", "SELECT CITY",
                             choices = cities,
                             selected = "Atlanta",
                             multiple = TRUE,
                             selectize = TRUE),
                 br(),
                 
                 

                 sliderInput("year_input", "Year",
                             min = 1975, max = 2015, 
                             value = c(1975, 2015), 
                             sep = "", step = 5),
                 br(),
                 
                 # select crime type
                 radioButtons("crime_type", 
                              "SELECT CRIME TYPE",
                              choices = c("Total Violent" = "violent_per_100k",
                              "Homicide" = "homs_per_100k",
                              "Rape" = "rape_per_100k",
                              "Robbery" = "rob_per_100k",
                              "Aggravated Assault" = "agg_ass_per_100k"),
                              selected = "rape_per_100k")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      #==========FIRST MAIN PANEL=======
      h3('Total Comparison'),
        # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                    tabPanel("Plot", plotOutput("plot")),
                    tabPanel("Table", dataTableOutput("table"))),
      #==========SECOND MAIN PANEL==========
      h3("Cross City Comparison"),
      plotOutput("plot_crime")
    ))
)

#set up server

server <- function(input, output) {
  
  # set up the first panel, the chart for total comparison for all cities
  
  #when users select "Total (for entire population)"

    crime_filtered <- reactive({tidy_data %>%
        filter(crime_type_rate == input$crime_type_only_one,
                           year == input$year) %>%
        select(department_name,count_per_100k) %>%
        mutate(department_name=fct_reorder(department_name,count_per_100k))})
    
  output$table <- DT::renderDataTable({
    DT::datatable(crime_filtered(),options=list(lengthMenu=c(10,40,60), pagelength=10))
  })
  
  output$plot <- renderPlot(
    crime_filtered() %>% 
      ggplot(aes(y=count_per_100k,x=department_name)) +
      geom_bar(stat='identity') +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))+
      labs(y = "Crime rate per 100k population", x = "City"))
  
  #======================SECOND PANEL==================
  observe(print(input$department_name))
  observe(print(input$crime_type))
  observe(print(input$year_input))
  crime_filtered2 <- reactive(
    tidy_data %>% filter(department_name %in%  input$department_name,
                         crime_type_rate ==  input$crime_type,
                         year >= input$year_input[1] &
                           year <= input$year_input[2])
  )
  observe(print(crime_filtered2))
  
  output$plot_crime <- renderPlot(
    crime_filtered2() %>% 
      ggplot(aes(x = year,
                 y = count_per_100k, 
                 colour = department_name)) +
      geom_line()+
      labs(x = "Year", y = "Crime rate per 100k", colour = "City")
    )
  
}

#launch the app
shinyApp(ui = ui, server = server)