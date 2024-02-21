#library
library(shiny)
library(dplyr)
library(rsconnect)
library(plotly)
#import data
data <- read.csv('DisasterDeclarationsSummaries.csv')
declareT <- unique(data$declarationType)
incidentT <- unique(data$incidentType)
yearDeclear <- unique(data$fyDeclared)

#data processing
incident <- data$incidentType
year<- substr(data$incidentBeginDate, 1, 4)
data <- data.frame(year,incident)
grpby <- data %>% group_by(year, incident) %>%
  summarise(total_count=n(),
            .groups = 'drop')
full_years <- seq(1953, 2023)
full_df <- data.frame(year = full_years)

#shiny app
# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Time Plot of Declared Disasters in US"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: 
      helpText("Create a plot to display the number of all federally declared 
      disasters in time sequence with Disaster Declarations Summaries."),
      selectInput(inputId = "var",
                  label =" Choose one incident to display",
                  choices = incidentT,
                  selected = NULL)),
    
    # Main panel for displaying outputs ----
    mainPanel(
      #time plot
      plotlyOutput("timePlot")
      
    )
  )
)

server <- function(input, output) {
 
  output$timePlot <- renderPlotly({
    
    table <- grpby[grpby$incident==input$var,]
    merged_df <- merge(full_df, table, by = "year", all = TRUE)
    merged_df$total_count[is.na(merged_df$total_count)] <- 0
    s <- ts(merged_df$total_count,start = 1953)
    df <- data.frame(
      time = merged_df$year,
      value = merged_df$total_count
    )
    plot_ly(df, x = ~time, y = ~value, type = 'scatter', mode = 'lines+markers',
            hoverinfo = 'text',
            text = ~paste('Count:', value,'\nYear:',time)) %>%
      layout(title = toupper(input$var),
             xaxis = list(title = "Time"),
             yaxis = list(title = "The number of declarations"))
    
  })
  

}

shinyApp(ui = ui, server = server)

