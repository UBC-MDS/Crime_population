library(shiny)
library(ggplot2)
library(plotly)
library(DT)
library(forcats)
library(shinythemes)

#load cleaned data
tidy_data <- read.csv("../data/clean_data.csv")
cities <- unique(tidy_data$City)
years <- unique(tidy_data$year)
crime <- unique(tidy_data$crime_type_rate)

# set up ui

ui <- fluidPage(
  # application theme
  theme = shinytheme("united"),
  # Application title
  titlePanel(title = "Crime Data Visualizer (U.S.)"),
  
  navbarPage( "",
              
              ##======================FIRST PANEL==================           
              tabPanel("Total Comparison",
                       sidebarLayout(
                         sidebarPanel(width = 3,
                           h5("To compare the crime data of all major cities in United States"),
                           selectInput("year", "SELECT YEAR", multiple = FALSE,
                                       sort(unique(tidy_data$year)),selected = "2010"),
                           radioButtons("field", 
                                        "SELECT FIELD",
                                        choices = c("Rate (per 100k population)", "Total"),
                                        selected = "Total"),
                           radioButtons("crime_type_only_one",
                                        label = "SELECT CRIME TYPE",
                                        choices = c("Total Violent" = "violent_per_100k",
                                                    "Homicide" = "homs_per_100k",
                                                    "Rape" = "rape_per_100k",
                                                    "Robbery" = "rob_per_100k",
                                                    "Aggravated Assault" = "agg_ass_per_100k"),
                                        selected = "violent_per_100k")),
                         mainPanel(
                           # Output: Tabset w/ plot, summary, and table ----
                           tabsetPanel(type = "tabs",
                                       tabPanel("Plot", plotlyOutput("plot")),
                                       tabPanel("Table", dataTableOutput("table")))))),
              
              ##======================SECOND PANEL==================     
              tabPanel("Cross City Comparison", 
                       sidebarLayout(
                         sidebarPanel(width = 3,
                           h5("By Crime Rate (per 100k population)"),
                           # Select cities
                           selectInput("City", "SELECT CITY",
                                       choices = cities,
                                       selected = "Atlanta",
                                       multiple = TRUE,
                                       selectize = FALSE),
                           helpText("Hold Ctrl to select multiple"),
                           br(),
                           # Select range of years
                           sliderInput("year_input", "SELECT YEAR RANGE",
                                       min = 1980, max = 2015, 
                                       value = c(1980, 2015), 
                                       sep = "", step = 1),
                           br(),
                           # Select crime type
                           radioButtons("crime_type", 
                                        "SELECT CRIME TYPE",
                                        choices = c("Total Violent" = "violent_per_100k",
                                                    "Homicide" = "homs_per_100k",
                                                    "Rape" = "rape_per_100k",
                                                    "Robbery" = "rob_per_100k",
                                                    "Aggravated Assault" = "agg_ass_per_100k"),
                                        selected = "violent_per_100k")),
                         
                        mainPanel(br(),
                                  plotlyOutput("plot_crime")))),
  
  ## =================== THIRD PANEL : About  ==================
            tabPanel("About", 
                     br(), 
                     "Crime is a problem in major cities where it causes negative emotional and physical effects and requires", br(),
                      "costly solutions for the public. This app aims to help explore violent crime trends across cities over time.",
                     br(), br(),
                     span("Data source:",
                          tags$a(href = "https://www.themarshallproject.org/", "The Marshall Project")),
                     br(),
                     span("Github Repository:",
                          tags$a(href = "https://github.com/UBC-MDS/Crime_population", "Crime_population")),
                     br(),
                     span("Developers:",
                          tags$a(href = "https://github.com/huijuechen", "Juno Chen"),
                          "and",
                          tags$a(href = "https://github.com/K3ra-y", "Kera Yucel")
                     )
                
                     
                     )
                     
  
  
))

#set up server

server <- function(input, output) {
  
  ##======================FIRST PANEL================== 
  
  
    #when users select "Rate(per 100k population)"
    crime_filtered_rate <- reactive({tidy_data %>%
        filter(crime_type_rate == input$crime_type_only_one,
                           year == input$year) %>%
        select(City,incidents_per_100k_population) %>%
        mutate(City=fct_reorder(City,incidents_per_100k_population))})
   
    #when users select "Total (for entire population)"
    crime_filtered_total <- reactive({tidy_data %>%
        filter(crime_type_rate == input$crime_type_only_one,
               year == input$year) %>%
        select(City,incidents_for_total_population) %>%
        mutate(City=fct_reorder(City,incidents_for_total_population))})
    
  output$table <- DT::renderDataTable({
    if(input$field == "Total"){
      datatable(crime_filtered_total(),options=list(lengthMenu=c(10,40,60), pagelength=10))
    }else{
      datatable(crime_filtered_rate(),options=list(lengthMenu=c(10,40,60), pagelength=10))
        }})
  
  output$plot <- renderPlotly(
    if(input$field == "Total"){
      ggplot()+
      geom_bar(data= crime_filtered_total(),
               mapping = aes(y = incidents_for_total_population, x = City),
               stat='identity',
               fill = "tomato2",
               alpha=0.8) +
      theme(axis.text.x = element_text(angle = 60, hjust = 1))+
      labs(y = "Total", x = "City")
  }else{
    crime_filtered_rate() %>% 
      ggplot(aes(y=incidents_per_100k_population,x=City)) +
      geom_bar(stat='identity', fill = "tomato2", alpha=0.8) +
      theme(axis.text.x = element_text(angle = 60, hjust = 1))+
      labs(y = "Crime rate per 100k population", x = "City")})
  
  #======================SECOND PANEL==================
  observe(print(input$City))
  observe(print(input$crime_type))
  observe(print(input$year_input))
  crime_filtered2 <- reactive(
    tidy_data %>% filter(City %in%  input$City,
                         crime_type_rate ==  input$crime_type,
                         year >= input$year_input[1] &
                           year <= input$year_input[2])
  )
  observe(print(crime_filtered2))
  
  output$plot_crime <- renderPlotly(
    crime_filtered2() %>% 
      ggplot(aes(x = year,
                 y = incidents_per_100k_population, 
                 colour = City)) +
      geom_line() +
      geom_point() +
      labs(x = "Year", 
           y = "Crime rate per 100k",
           colour = "City") +
      stat_summary(fun.y=mean, size=1, 
                   geom='line', 
                   aes(colour="Average crime rate of \nthe selected cities")) +
      theme_bw()+
      theme(axis.text.x = element_text(size = 12),
            axis.text.y = element_text(size = 12),
            axis.title.y = element_text(size = 14),
            axis.title.x = element_text(size=14),
            axis.line = element_blank(),
            legend.text = element_text(size = 12),
            legend.title = element_text(size = 14, face = "bold"))
      )
  
}

#launch the app
shinyApp(ui = ui, server = server)