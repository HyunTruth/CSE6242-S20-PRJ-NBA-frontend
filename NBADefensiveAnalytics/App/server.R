library(shiny)

server <- function(input, output) {
    
    output$DistanceScatter <- renderHighchart({
        
        # Distance Scatterplot
        DFG_Percentage <- GameLogs %>%
            filter(Season == "2019-20",
                   Distance == input$Distance_Selection) %>% # Filters
            group_by(idPlayer,Player, Team, Distance) %>%
            summarise(DFGM = sum(DFGM), DFGA = sum(DFGA)) %>%
            mutate(DFGP = round(DFGM/DFGA,3),
                   Color_Col = if_else(Team == input$Team_Selection,input$Team_Selection,"All Other")) %>%
            filter(DFGA >= 150) # Filters with default value (20th percentile and up?)
        
        hchart(DFG_Percentage, "scatter", hcaes(x = "DFGA", y = "DFGP",
                                                group = "Color_Col",
                                                name = "Player", DFGA  = "DFGA", 
                                                DFGEfficiency = "DFGP", Distance = "Distance")) %>%
            hc_tooltip(pointFormat = "<b>{point.name}</b><br />DFGA: {point.DFGA}<br />DFG%: {point.DFGEfficiency}") %>%
            hc_title(text = "DFGA vs. DFG%") %>%
            hc_subtitle(text = "NBA 2019-2020 Season") %>%
            hc_credits(enabled = TRUE,
                       text = "data via stats.nba.com",
                       style = list(
                           fontSize = "10px"
                       )
            ) %>%
            hc_add_theme(hc_theme_elementary()) %>%
            hc_colors(QualColors)
    })
}