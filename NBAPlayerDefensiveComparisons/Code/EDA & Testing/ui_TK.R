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
                         column(3,selectInput("Distance_Selection", "Distance", choices = distance_list)),
                         column(3,selectInput("Season_Selection", "Season", choices = levels(GameLogs$Season)))
                     ),
                     fluidRow(highchartOutput("DistanceScatter", width = "100%", height = "400px")),
                     fluidRow(highchartOutput("DistanceLine", width = "100%", height = "400px")),
                     
                     #TKADD Adding dropdown selection for reactivity table
                     fluidRow(
                       column(3,selectInput("Season_Selection_Team", "Season", choices = levels(GameLogs$Season)))
                     ),
                     fluidRow(reactableOutput("Team_DFG_Reactable"))
                     
            ),
            tabPanel("Player Profile"),
            tabPanel("Player Clusters")
        ) 
    )
)
