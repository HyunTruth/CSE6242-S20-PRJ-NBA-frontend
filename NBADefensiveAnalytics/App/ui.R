library(shiny)
library(shinythemes)

source("global.R")

ui <- fluidPage(
    #Theme
    theme = shinytheme("cosmo"),
    #HTML/CSS Components to include
    tags$head(tags$link(rel="stylesheet", type="text/css", href="comptable.css")),
    tags$head(tags$link(rel="stylesheet", type="text/css", href="page.css")),
    h1(id="page_title", "NBA Defensive Player Comparisons"),
    # Tabs
    navbarPage(title = "NBA Defensive Clusters",windowTitle = "NBA Defensive Clusters",
               tabPanel("Player Comparisons",
                        fluidRow(
                            column(3,selectInput("PlayerSelection","Players",choices = levels(BoxScores$Player))),
                            column(3,selectInput("SeasonSelection", "Season", choices = c("2019-20","2018-19")))
                        ),
                        fluidRow(
                            sidebarLayout(fluid = FALSE,
                                sidebarPanel(id = "sidebar",
                                             uiOutput("PlayerImage"),
                                             uiOutput("PlayerHeader"),
                                             reactableOutput("PlayerComps", width = "100%", height = "260px"),
                                             width = 4
                                            ),
                                mainPanel(plotlyOutput("Clusters", width = "90%", height = "480px"),
                                          width = 8
                                          )
                                        )
                                ),
                        fluidRow(h2(class = "section_header", "Player Stats"))
                        #fluidRow() Shot Zone
                        #fluidRow() Rebounding Zone
                    ),
               tabPanel("Player Stats",
                        fluidRow(h2(class = "section_header", "Player Stats"))
                        ),
            tabPanel("Methodology")
        )
)
