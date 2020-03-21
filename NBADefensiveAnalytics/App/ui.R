library(shiny)
library(shinythemes)

source("global.R")

ui <- fluidPage(
    #Theme
    theme = shinytheme("cosmo"),
    # Application title
    titlePanel("NBA Defensive Analytics"),
    # Tabs
    mainPanel(
        tabsetPanel(
            tabPanel("DFG% by Shot Distance",
                     fluidRow(
                         column(3,selectInput("Team_Selection","Teams",choices = levels(GameLogs$Team))),
                         column(3,selectInput("Distance_Selection", "Distance", choices = distance_list))
                     ),
                     fluidRow(highchartOutput("DistanceScatter", width = "700px", height = "500px"))
            ),
            tabPanel("Player Profile"),
            tabPanel("Player Clusters")
        ) 
    )
)
