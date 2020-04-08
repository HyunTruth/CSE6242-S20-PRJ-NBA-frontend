library(shiny)

server <- function(input, output) {
    
    #------------------#
    ### Player Image ###
    #------------------#
    
    # PlayerImage
    SinglePlayer <- reactive(PlayerInfo %>% filter(Player == input$PlayerSelection) %>% select(urlPlayerHeadshot))
    URL <- reactive(paste(SinglePlayer()$urlPlayerHeadshot[[1]]))
    
    output$PlayerImage <- renderUI({
        url <- URL()
        tags$img(src = url, width = "200px", height = "160px",style="text-align: center;")
    })
    
    #------------------#
    ### Player Title ###
    #------------------#
    player_name <- reactive(input$PlayerSelection)
    output$PlayerHeader <- renderUI({
        tags$h2("Top Comparables", class = "section_header")
    })
    
    #------------------------#
    ### Player Comp Table  ###
    #------------------------#
    output$PlayerComps <- renderReactable({
        reactable(
            CompPlayers,
            bordered = FALSE, 
            pagination = FALSE,
            highlight = TRUE,
            fullWidth = FALSE,
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
                Rk = colDef(name = "Rk", maxWidth = 45,class = "table_contents"),
                Player = colDef(name = "Player",minWidth = 140,class = "table_contents"),
                SimilarityScore = colDef(name = "Score (0-100)",minWidth = 60, class = "table_contents")
            )
        )
        
    })
    #-------------#
    ### Cluster ###
    #-------------#
    output$Clusters <- renderPlotly({
        ClusterData <- PlayerClusters %>%
            select(PLAYER_ID, x, y) %>%
            left_join(PlayerInfo, by = c("PLAYER_ID" = "idPlayer"))
        
        ClusterScatter <- ggplot(data = ClusterData,aes(x = x, y = y,text = Player)) +
            geom_point(color = "#386cb0", alpha = .90, size = 2) +
            gghighlight(Player == input$PlayerSelection, label_key = Player,
                        unhighlighted_params = list(size = 1, colour = alpha("#636363", 0.65))) +
            labs(title = "Defensive Player Clusters",
                 subtitle = glue("NBA 2019-20 Season"),
                 x = "LDA 1",
                 y = "LDA 2",
                 caption = "See Methodology tab for details") +
            theme_minimal(base_family = "Source Sans Pro") +
            theme(plot.title = element_text(size = 14))
        ggplotly(ClusterScatter, tooltip = "text") %>% config(displayModeBar = F)
    })
    
    #---------------#
    ### Shot Zone ###
    #---------------#
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
                show.legend = FALSE
            )+
            ylim(0,35) +
            scale_fill_gradient(low = "yellow", high = "red",limits = c(0,1),
                                breaks = c(0,.25,.50,.75,1),
                                labels = c("0","25","50","75","100")) +
            geom_label(data=ShotZoneLables, aes(x = x,y = y, label = scales::ordinal(label*100)),
                       color="#4d4d4d", 
                       size= 5 , angle=0, fontface="bold" ) +
            labs(title = "DFG% Percentile by Zone") +
            theme(legend.title = element_blank(),
                  legend.key.width = unit(.75,"cm"),
                  legend.position= "bottom")
    })
}