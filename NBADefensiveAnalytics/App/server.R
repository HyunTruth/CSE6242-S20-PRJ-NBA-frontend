library(shiny)

server <- function(input, output) {
    # Distance Scatterplot
    output$DistanceScatter <- renderHighchart({
        DFG_Percentage <- GameLogs %>%
            filter(Season == input$Season_Selection,
                   Distance == input$Distance_Selection) %>% # Filters
            group_by(idPlayer,Player, Team, Distance) %>%
            summarise(DFGM = sum(DFGM), DFGA = sum(DFGA), TotalMins = sum(minutes)) %>%
            mutate(DFGP = round(DFGM/DFGA,3),
                   DFGAPer36 = round((DFGM/TotalMins)*36,1),
                   Color_Col = if_else(Team == input$Team_Selection,input$Team_Selection,"All Other")) %>%
            filter(DFGA >= 150) # Filters with default value (20th percentile and up?)
        
        hchart(DFG_Percentage, "scatter", hcaes(x = "DFGAPer36", y = "DFGP",
                                                group = "Color_Col",
                                                name = "Player", DFGA36  = "DFGAPer36", 
                                                DFGEfficiency = "DFGP", Distance = "Distance")) %>%
            hc_tooltip(pointFormat = "<b>{point.name}</b><br />Shots Defended/36min: {point.DFGA36}<br />DFG%: {point.DFGEfficiency}") %>%
            hc_title(text = "<b>Shots Defended Per 36 minutes vs. DFG%</b>",
                     margin = 10,
                     align = "left") %>%
            hc_add_theme(hc_theme_elementary()) %>%
            hc_colors(ScatterOppacity)
    })
    # Distance Line
    output$DistanceLine <- renderHighchart({
        Running_DFGP <- GameLogs %>%
            mutate(Color_Col = if_else(Team == input$Team_Selection,input$Team_Selection,"All Other")) %>%
            filter(Season == input$Season_Selection,
                   Distance == input$Distance_Selection) %>%
            group_by(Color_Col,numberGameTeamSeason) %>%
            summarise(DFGM = sum(DFGM), DFGA = sum(DFGA)) %>%
            mutate(DFGP = round(DFGM/DFGA,2),
                   RollingDFGP = round(if_else(rolling(DFGP) == 0, DFGP, rolling(DFGP)),2))
        
        hchart(Running_DFGP, "spline", hcaes(x = "numberGameTeamSeason", y = "RollingDFGP", group = "Color_Col",
                                             team = "Color_Col", Game  = "numberGameTeamSeason",
                                             DFGP = "RollingDFGP")) %>%
            hc_tooltip(pointFormat = "<b>{point.team}</b><br />DFG%: {point.DFGP}") %>%
            hc_title(text = "DFG% Season Trend") %>%
            hc_subtitle(text = "Rolling 5-Game Average") %>%
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