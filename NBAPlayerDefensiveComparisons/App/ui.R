library(shiny)
library(shinythemes)

source("global.R")

ui <- fluidPage(
    #------------------#
    ### HTML + Theme ###
    #------------------#
    #Theme
    theme = shinytheme("cosmo"),
    #HTML/CSS Components to include
    tags$head(tags$link(rel="stylesheet", type="text/css", href="comptable.css")),
    tags$head(tags$link(rel="stylesheet", type="text/css", href="page.css")),
    h1(id="page_title", "NBA Defensive Player Comparisons"),
    #--------------------#
    ### Navigation Bar ###
    #--------------------#
    navbarPage(title = "Defensive Comparables",windowTitle = "NBA Player Defensive Comparables",
               #---------------------------#
               ### Player Comparison Tab ###
               #---------------------------#
               tabPanel("Player Comparisons",
                        fluidRow(
                            column(3,selectInput("PlayerSelection","Players",choices = player_list))
                        ),
                        fluidRow(
                            sidebarLayout(fluid = FALSE,
                                sidebarPanel(id = "sidebar",
                                             uiOutput("PlayerImage"),
                                             uiOutput("PlayerHeader"),
                                             uiOutput("PlayerSubheader"),
                                             uiOutput("TableHeader"),
                                             reactableOutput("PlayerComps", width = "100%", height = "260px"),
                                             width = 4
                                            ),
                                mainPanel(plotlyOutput("Clusters", width = "90%", height = "480px"),
                                          width = 8
                                          )
                                        )
                                )
                    ),
               #----------------------#
               ### Player Stats Tab ###
               #----------------------#
               tabPanel("Player Stats",
                        tabsetPanel(
                            tabPanel("DFG% Shot Zone",
                                     fluidRow(column(3,selectInput("SeasonSelection", "Season", choices = c("2019-20","2018-19")))),
                                    fluidRow(plotlyOutput("ShotZones",width = "550px", height = "400px"))
                            ),
                            tabPanel("DFG% vs Shots Defended/36 min",
                                     fluidRow(selectInput("Distance","Distance",choices = distance_list)),
                                     fluidRow(plotlyOutput("DFGPercent",width = "600px", height = "450px")))
                        )
                        ),
               #---------------------#
               ### Methodology Tab ###
               #---------------------#
                tabPanel("Methodology",
                         includeMarkdown("methodology.md"))
        )
)
