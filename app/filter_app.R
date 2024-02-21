dis = read.csv("DisasterDeclarationsSummaries.csv")

if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("leaflet")) {
  install.packages("leaflet")
  library(leaflet)
}
if (!require("leaflet.extras")) {
  install.packages("leaflet.extras")
  library(leaflet.extras)
}
if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require("magrittr")) {
  install.packages("magrittr")
  library(magrittr)
}
if (!require("mapview")) {
  install.packages("mapview")
  library(mapview)
}
if (!require("leafsync")) {
  install.packages("leafsync")
  library(leafsync)
}
if (!require("ggplot2")) {
  install.packages("ggplot2")
  library(ggplot2)
}



ui = fluidPage(
  titlePanel("Disaster Data Filtered Plot"),
  sidebarLayout(
    sidebarPanel(
      selectInput("group", "Grouping",
                  c("state", "declarationType", "incidentType"))
    ),
    mainPanel(
      plotOutput("stacked_bar_plot")
    )
  )
)


server = function(input, output) {
    output$stacked_bar_plot = renderPlot({
      dis_grouped = dis %>% group_by_at(vars(get(input$group))) %>% summarise(count = n())
      
      ggplot(dis_grouped, aes(x = as.factor(.data[[input$group]]), y = count, fill = as.factor(.data[[input$group]]))) +
        geom_bar(stat = "identity") +
        labs(x = input$group, y = "Count", fill = input$group) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    })
  }




shinyApp(ui = ui, server = server)


runApp("filter_app.R", host = "127.0.0.1", port = 8888)
