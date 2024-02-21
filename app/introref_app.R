library(shiny)
library(shinythemes)

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
                          tags$style(HTML("
      .box.box-primary>.box-header {
        color: white;
      }
    "))
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
                 )
                 
)

# Define server logic
server <- function(input, output) { }


shinyApp(ui = ui, server = server)
