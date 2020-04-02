library(shiny)
library(shinythemes)

source("global.R")

ui <- fluidPage(
    #Theme
    theme = shinytheme("cosmo"),
    #HTML/CSS Components to include
    tags$head(tags$link(rel="stylesheet", type="text/css", href="comptable.css")),
    titlePanel("NBA Defensive Player Comparisons", windowTitle = "NBADefensivePlayerComparisons"),
    # Tabs
    mainPanel(
        tabsetPanel(
            
            tabPanel("Player Profile",
                     fluidRow(
                         column(4,selectInput("PlayerSelection","Players",choices = levels(BoxScores$Player))),
                         column(4,selectInput("DistanceSelection", "Distance", choices = distance_list)),
                         column(4,selectInput("SeasonSelection", "Season", choices = c("2019-20","2018-19")))
                     ),
                     fluidRow(column(6,uiOutput("PlayerImage", width = "250px")),
                              column(3,reactableOutput("PlayerProfile",width = "200px"))),
                     br(),
                     fluidRow(reactableOutput("PlayerComps",width = "500px", height = "250px")),
                     br(),
                     fluidRow(highchartOutput("PlayerScatter", width = "550px", height = "380px")),
                     fluidRow(plotOutput("ShotZones",width = "90%",height = "380px"))
                    ),
            tabPanel("Player Clusters")
        ) 
    )
)
