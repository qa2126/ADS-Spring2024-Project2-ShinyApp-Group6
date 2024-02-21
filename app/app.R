library(shiny)
library(shinythemes)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(DT)
library(plotly)
library(geojsonio)


# Bar plot
dis = readr::read_csv("DisasterDeclarationsSummaries.csv")

# Map plot
ddf =  dis |>
    mutate(declarationDate = as.Date(declarationDate)) |>
    rename(state2 = state) |>
    select(-id, -hash)

state_abbr = readr::read_csv("us_state_abbr.csv") 

ddf2 = left_join(ddf, state_abbr)

declarationType_list = unique(ddf2$declarationType) |> sort()
incidentType_list = unique(ddf2$incidentType) |> sort()

states <- geojsonio::geojson_read("https://rstudio.github.io/leaflet/json/us-states.geojson", what = "sp")


# Time Plot
data <- dis

declareT <- unique(data$declarationType)
incidentT <- unique(data$incidentType)
yearDeclear <- unique(data$fyDeclared)

incident <- data$incidentType
year<- substr(data$incidentBeginDate, 1, 4)
data <- data.frame(year,incident)
grpby <- data %>% group_by(year, incident) %>%
    summarise(total_count=n(), .groups = 'drop')
full_years <- seq(1953, 2023)
full_df <- data.frame(year = full_years)


# Define UI
ui <- navbarPage(theme = shinytheme("flatly"), title = "FEMA Disaster Declarations",
                 tabPanel("Introduction",
                          div(style = "background-image: url('https://zhl.org.in/blog/wp-content/uploads/2023/09/Natural-Disasters.jpg'); background-size: cover; height: calc(100vh - 100px); color: white;",
                              fluidRow(
                                  box(title = "Welcome to the FEMA Disaster Declarations interactive analysis tool", status = "primary", solidHeader = TRUE,
                                      p("This platform provides a comprehensive exploration of disaster events in the U.S. from 1953 to 2024, as recorded in the Disaster Declarations Summaries dataset. 
                                      Dive into the visual stories of disaster declarations, understand the scope and scale of assistance, and gain insights into the resilience of communities across the nation....and more ", style = "color: white;"),
                                      width = 12
                                  )
                              )
                          ),
                          tags$style(HTML(".box.box-primary>.box-header {color: white; }"))
                 ),
                 tabPanel("BarPlot",
                          sidebarLayout(
                              sidebarPanel(
                                  selectInput("group", "Grouping",
                                              c("state", "declarationType", "incidentType", "month"))
                              ),
                              mainPanel(
                                  plotOutput("stacked_bar_plot")
                              )
                          )                          
                 ),                 
                 tabPanel("MapPlot",
                          sidebarLayout(
                              sidebarPanel(
                                  selectInput("declarationType", "Declaration Type:", c("All Type" = "", declarationType_list)),
                                  
                                  selectInput("incidentType", "Incident Type:", incidentType_list),
                                  
                                  sliderInput("declarationYear", "Declaration Year Range:",
                                              min = min(ddf$fyDeclared),
                                              max = max(ddf$fyDeclared),
                                              value = c(min(ddf$fyDeclared), max(ddf$fyDeclared)),
                                              sep = ""),
                                  br(),
                                  DTOutput("mapDataTable")
                                  
                              ),
                              
                              # Show a plot of the generated distribution
                              mainPanel(
                                  
                                  leafletOutput("mapPlot",height = 700),
                                  
                              ),
                              
                          )
                          
                 ),
                 tabPanel("TimePlot",
                          sidebarLayout(
                              
                              # Sidebar panel for inputs ----
                              sidebarPanel(
                                  
                                  # Input: 
                                  helpText("Create a plot to display the number of all federally declared disasters in time sequence with Disaster Declarations Summaries."),
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
                          
                 ),                
                 
                 tabPanel("References",
                          # Keep the references without background image
                          fluidRow(
                              box(title = "References", status = "info", solidHeader = TRUE,
                                  p("Data:"),
                                  p("https://www.fema.gov/openfema-data-page/disaster-declarations-summaries-v2"),
                                  p("Images:"),
                                  p("https://zhl.org.in/blog/wp-content/uploads/2023/09/Natural-Disasters.jpg"),
                                  width = 12
                              )
                          )
                 ),
                 
)

# Define server logic
dis = read.csv("DisasterDeclarationsSummaries.csv")
dis = dis[dis$fyDeclared > 1999,]
dis$month = month(ymd_hms(dis$declarationDate))

server = function(input, output) {
    
    # bar plot
  output$stacked_bar_plot = renderPlot({
    dis_grouped <- dis %>% 
      group_by(fyDeclared, pick(input$group)) %>% 
      summarise(count = n()) %>%
      group_by(fyDeclared) %>%
      mutate(percentage = count / sum(count))
    
    ggplot(dis_grouped, aes(x = as.factor(fyDeclared), y = percentage, fill = !!rlang::sym(input$group))) +
      geom_bar(stat = "identity") +
      labs(x = "Year", y = "Percentage", fill = input$group) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    })
    
    # map plot
    disaster_df = reactive({
        
        if(input$declarationType != ""){
            ddf2 = ddf2 %>%
                filter(declarationType == input$declarationType)
        } 
        
        
        df = ddf2 %>%
            filter(incidentType == input$incidentType) %>%
            filter(fyDeclared  >= input$declarationYear[1] & fyDeclared <= input$declarationYear[2] ) %>%
            group_by(state) %>%
            summarise(Number = n()) %>%
            drop_na()
    })
    
    
    output$mapPlot <- renderLeaflet({
        
        ddf3  = disaster_df()
        
        states@data= left_join(states@data, ddf3, by = join_by(name == state))
        
        labels <- sprintf(
            "<strong>%s</strong><br/>Disaster Number: %g",
            states@data$name, states@data$Number
        ) %>% lapply(htmltools::HTML)
        
        
        
        bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
        pal <- colorBin("YlOrRd", domain = states@data$Number, bins = bins)
        # pal <- colorBin("Blues", domain = states@data$Number, bins = bins)
        
        
        
        
        leaflet(states) %>%
            setView(-96, 37.8, 4) %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
            # addProviderTiles("CartoDB.Positron",
            #                  options = providerTileOptions(noWrap = TRUE)) %>%
            addPolygons(
                fillColor = ~pal(Number),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.7,
                highlightOptions = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
            addLegend(pal = pal, values = ~Number, opacity = 0.7, title = NULL,
                      position = "bottomright")
        
    })
    
    output$mapDataTable = renderDT({
        
        df = disaster_df()
        
        datatable(df,
                  selection = 'none',
                  class = "display",
                  rownames = FALSE,
                  options = list(
                      dom = 'tp',  # t: table
                      scrollX=TRUE
                  )
        ) %>% 
            formatStyle(columns = 1,  backgroundColor = "#c9e3ee", fontWeight = 'bold')
        
        
    })
    
    # time plot
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
