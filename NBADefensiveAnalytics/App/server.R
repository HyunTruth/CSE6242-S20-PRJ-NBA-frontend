library(shiny)

server <- function(input, output) {
    
    #### Player Profile ####
    
    # PlayerImage
    HeadshotURL <- reactive(input$PlayerSelection)
    SinglePlayer <- reactive(PlayerInfo %>% filter(Player == input$PlayerSelection) %>% select(urlPlayerHeadshot))
    URL <- reactive(paste(SinglePlayer()$urlPlayerHeadshot[[1]]))
    
    output$PlayerImage <- renderUI({
        url <- URL()
        div(id = "player_img",
            tags$img(src = URL))
        tags$img(src = url)
    })
    
    output$PlayerProfile <- renderReactable({
        PlayerProfile <- tibble(
            Type = c("Name","Age","Height","Weight","Team","All-Defensive Team Selections"),
            Info = c("Anthony Davis","27","6'10","253 lb", "LAL","3")
        )
        
        
        reactable(
            PlayerProfile,
            bordered = FALSE, 
            pagination = FALSE,
            highlight = TRUE,
            fullWidth = TRUE,
            class = "CompTable",
            columns = list(
                Type = colDef(name = "Player Info", minWidth = 150, style = list(color = "black"),
                              headerStyle = list(color = "black")),
                Info = colDef(name = "Values",minWidth = 110,style = list(color = "black"),
                              headerStyle = list(color = "black"))
            )
        )
        
        Profile
    })
    
    output$PlayerComps <- renderReactable({
        reactable(
            CompPlayers,
            bordered = FALSE, 
            pagination = FALSE,
            highlight = TRUE,
            fullWidth = TRUE,
            class = "CompTable",
            defaultColDef = colDef(headerClass = "header", align = "left"),
            columns = list(
                idPlayer = colDef(
                    name = "",
                    minWidth = 50,
                    cell = function(value, index) {
                        div(
                            img(
                                src = sprintf(paste("https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/", 
                                                    paste(value,".png", sep = ""), sep = "")),
                                height = '25px',
                                width = '40px',
                                style = "float:left"
                            )
                        )
                    },
                    maxWidth = 50
                ),
                Rk = colDef(name = "Rk", maxWidth = 45, style = list(color = "#252525")),
                Player = colDef(name = "Player",minWidth = 140,style = list(color = "#252525")),
                SimilarityScore = colDef(name = "Score (0-100)",minWidth = 60,style = list(color = "#252525",align = "right"))
            )
        )
        
    })
    
    # Distance Scatterplot
    output$PlayerScatter <- renderHighchart({
        DFG_Percentage <- GameLogs %>%
            filter(Season == input$SeasonSelection,
                   Distance == input$DistanceSelection) %>% # Filters
            group_by(idPlayer,Player, Team, Distance) %>%
            summarise(DFGM = sum(DFGM), DFGA = sum(DFGA), TotalMins = sum(minutes)) %>%
            mutate(DFGP = round(DFGM/DFGA,3),
                   DFGAPer36 = round((DFGM/TotalMins)*36,2),
                   Color_Col = if_else(Player != input$PlayerSelection,"All Other",input$PlayerSelection)) %>%
            filter(DFGA > 50) # Filters with default value (20th percentile and up?)

        hchart(DFG_Percentage, "scatter", hcaes(x = "DFGAPer36", y = "DFGP",
                                                group = "Color_Col",
                                                name = "Player", DFGA36  = "DFGAPer36", 
                                                DFGEfficiency = "DFGP", Distance = "Distance")) %>%
            hc_tooltip(pointFormat = "<b>{point.name}</b><br />Shots Defended/36min: {point.DFGA36}<br />DFG%: {point.DFGEfficiency}") %>%
            hc_title(text = "<b>Shots Defended Per 36 minutes vs. DFG%</b>",
                     margin = 10,
                     align = "left") %>%
            hc_add_theme(hc_theme_elementary()) %>%
            hc_colors(ScatterOppacity2)
    })
    
    output$ShotZones <- renderPlot({
        # Data
        PercentileRanks <- GameLogs %>%
            filter(Season == input$SeasonSelection) %>%
            group_by(idPlayer,Player,Distance) %>%
            summarise(DFGM = sum(DFGM),DFGA = sum(DFGA)) %>%
            pivot_wider(id_cols = c(idPlayer, Player), 
                        names_from = Distance, 
                        values_from = c(DFGM,DFGA),
                        values_fill = list(DFGM = 0, DFGA = 0)) %>%
            transmute("0-9ft" = sum(`DFGM_0-4ft`,`DFGM_5-9ft`)/sum(`DFGA_0-4ft`,`DFGA_5-9ft`),
                      "10-19ft" = sum(`DFGM_10-14ft`,`DFGM_15-19ft`)/sum(`DFGA_10-14ft`,`DFGA_15-19ft`),
                      "20-24ft" = sum(`DFGM_20-24ft`)/sum(`DFGA_20-24ft`),
                      "25-29ft" = sum(`DFGM_25-29ft`)/sum(`DFGA_25-29ft`)
            ) %>%
            replace_na(list("0-9ft" = 0, "10-19ft" = 0, "20-24ft" = 0, "25-29ft" = 0))
        
        PercentileRanks$zero_nine_zone <- round(percent_rank(desc(PercentileRanks$`0-9ft`)),2)
        PercentileRanks$ten_nineteen_zone <- round(percent_rank(desc(PercentileRanks$`10-19ft`)),2)
        PercentileRanks$twenty_twentyfour_zone <- round(percent_rank(desc(PercentileRanks$`20-24ft`)),2)
        PercentileRanks$twentyfour_twentynine_zone <- round(percent_rank(desc(PercentileRanks$`25-29ft`)),2)
        
        # Player Selection
        PlayerSelection <- PercentileRanks %>%
            filter(Player == input$PlayerSelection)
        
        player_ranks <- tibble(
            zone = c("zero_nine_zone","ten_nineteen_zone","twenty_twentyfour_zone","twentyfour_twentynine_zone"),
            Percentile = c(PlayerSelection$zero_nine_zone[1],
                           PlayerSelection$ten_nineteen_zone[1],
                           PlayerSelection$twenty_twentyfour_zone[1],
                           PlayerSelection$twentyfour_twentynine_zone[1])
            ) %>%
            arrange(zone)

        player_ranks$zone = as.factor(player_ranks$zone)         
        zonesPlayer <- zones %>% left_join(player_ranks, by = c("desc"="zone"))
        
        ShotZoneLables <- tibble(
            x = c(0,0,0,0),
            y = c(10,19,27,32),
            label = c(PlayerSelection$zero_nine_zone[1],
                      PlayerSelection$ten_nineteen_zone[1],
                      PlayerSelection$twenty_twentyfour_zone[1],
                      PlayerSelection$twentyfour_twentynine_zone[1]
            )
        )
        
        # Shot Zone Plot
        plot_court() +
            coord_fixed(ylim = c(0, 35), xlim = c(-25, 25)) +
            geom_polygon(
                data = zonesPlayer,aes(x = x, y = y, group = desc, fill = Percentile), color = "white", alpha =.70,
                show.legend = TRUE
            )+
            scale_fill_gradient(low = "yellow", high = "red",limits = c(0,1),
                                breaks = c(0,.25,.50,.75,1),
                                labels = c("0","25","50","75","100")) +
            geom_label(data=ShotZoneLables, aes(x = x,y = y, label = scales::ordinal(label*100)),
                       color="#4d4d4d", 
                       size= 5 , angle=0, fontface="bold" ) +
            ggtitle("Defensive Percentile by Zone")+
            theme(legend.title = element_blank(),
                  legend.key.height = unit(1,"cm"),
                  legend.position=c(1.05, 0.5))
    })
}