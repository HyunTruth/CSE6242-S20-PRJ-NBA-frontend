library(shiny)

server <- function(input, output) {
    # Distance Scatterplot
    output$DistanceScatter <- renderHighchart({
        DFG_Percentage <- GameLogs %>%
            filter(Season == input$Season_Selection,
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
            hc_add_theme(hc_theme_elementary()) %>%
            hc_colors(QualColors)
    })
    # Distance Line
    output$DistanceLine <- renderHighchart({
        Running_DFGP <- GameLogs %>%
            mutate(Color_Col = if_else(Team == input$Team_Selection,input$Team_Selection,"All Other")) %>%
            filter(Season == input$Season_Selection,
                   Distance == input$Distance_Selection) %>%
            group_by(Color_Col,Game_Date) %>%
            summarise(DFGM = sum(DFGM), DFGA = sum(DFGA)) %>%
            mutate(DFGP = round(DFGM/DFGA,2),
                   RollingDFGP = round(if_else(rolling(DFGP) == 0, DFGP, rolling(DFGP)),2))
        
        hchart(Running_DFGP, "spline", hcaes(x = "Game_Date", y = "RollingDFGP", group = "Color_Col",
                                             team = "Color_Col", Date  = "Game_Date",
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
    
    
    #TKAD For react table
    tags$h2(textOutput("Defensive Field Goal Percentages by Season"))
    tags$h5("Expected shot value varies depending on the risk and payoff of a shot.")
    output$Team_DFG_Reactable <- renderReactable({
      
      #code to create tables and create Reactable table
      ###Insert below here#################
      DFG_Teams <- GameLogs %>%
        group_by(Team, Season, Distance) %>%
        summarise("DFGP" = round(sum(DFGM)/sum(DFGA), 3)) %>%
        spread(Distance, DFGP)
      
      #input
      DFG_rating <- DFG_Teams %>% filter(Season == input$Season_Selection_Team)
      
      DFG_rating <- DFG_rating[, c("Team","0-5ft", "5-9ft", "10-14ft", "15-19ft", "20-24ft", "25-29ft")]
      
      #Determine average expected values
      Av_Exp_value = 2*mean(DFG_rating$`0-5ft`) + 2*mean(DFG_rating$`5-9ft`) + 2*mean(DFG_rating$`10-14ft`) + 2*mean(DFG_rating$`15-19ft`) + 2*mean(DFG_rating$`20-24ft`) + 3*mean(DFG_rating$`25-29ft`)
      
      #Determine rating based on expected value for each team
      DFG_rating <- DFG_rating %>% mutate(Def_Exp_Points = round((2*`0-5ft` + 2*`10-14ft`+2*`15-19ft`+2*`20-24ft`+2*`5-9ft`+3*`25-29ft`) - Av_Exp_value, 3))
      
      
      
      
      
      colorizer <- function(x) rgb(colorRamp(c("#386cb0", "#ffff99"))(x), maxColorValue = 255)
      
      stylizer <- function(value, col_name) {
        normalized <- (value - min(DFG_rating[,col_name]))/(max(DFG_rating[,col_name]) - min(DFG_rating[,col_name]))
        color <- colorizer(normalized)
        list(background =color)
      }
      
      format_pct <- function(value) {
        formatC(paste0(round(value * 100), "%"), width = 4)
      }
      
      dist_column <- function(maxWidth = 65, col_name, class = NULL, ...) {
        colDef(
          cell = format_pct,
          maxWidth = maxWidth,
          style = function(value) stylizer(value, col_name),
          ...
        )
      }
      
      
      tbl <- reactable(
        DFG_rating,
        bordered = TRUE, 
        pagination = FALSE,
        columns = list(
          Team = colDef(
            minWidth = 100,
            headerStyle = list(fontWeight = 700),
            cell = function(value, index) {
              div(
                img(
                  src = sprintf(paste(team_img_path, paste(value,"_logo.svg", sep = ""), sep = "")),
                  height = '25px',
                  width = '40px',
                  style = "float:left"
                ),
                div(value,
                    style = "float:right",
                    style = "padding:10px;")
              )
            }
          ),
          
          Def_Exp_Points = colDef(
            minWidth = 80,
            style = function(value) stylizer(value, "Def_Exp_Points"),
            name = "Exp. Shot Value Metric"
          ),
          `0-5ft` = dist_column(col_name = "0-5ft"),
          `5-9ft` = dist_column(col_name = "5-9ft"),
          `10-14ft` = dist_column(col_name = "10-14ft"),
          `15-19ft` = dist_column(col_name = "15-19ft"),
          `20-24ft` = dist_column(col_name = "20-24ft"),
          `25-29ft` = dist_column(col_name = "25-29ft")
          
        )
      )
        
        #Creat react table
        h2("Defensive Field Goal Efficiencies by Season")
        "Field goals made vs attempted. The lower the number the better"
        tbl
      
      ###Insert above here
      #######################
    })
    

    
    
}