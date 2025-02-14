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
    AllD <- reactive(if (player_name() %in% AllDefense$Player) {
            subset <- AllDefense %>% dplyr::filter(Player == player_name()) %>% select(selections)
            subset$selections[[1]]
        }
        else{
            0
        })
    
    output$PlayerHeader <- renderUI({
        tags$h3(player_name(), class = "section_header")
    })
    output$PlayerSubheader <- renderUI({
        symbol <- if (AllD() > 0) {
            "\u2605"
        }
        else{
            ""
        }
        tags$h5(paste("All Defensive Selections:",AllD(),symbol), class = "player_subheader")
    })
    
    output$TableHeader <- renderUI({
        tags$h3("Top Comparables", class = "section_header")
    })
    
    #------------------------#
    ### Player Comp Table  ###
    #------------------------#
    #Data
    CompPlayers <- reactive(PlayerComparisons %>%
        filter(player_name == input$PlayerSelection) %>%
        select(neighbor_player_id, neighbor_player_name, pct_match,selections) %>%
        mutate(pct_match = scales::percent(round(pct_match,2))))

    
    
    output$PlayerComps <- renderReactable({
        data <- PlayerComparisons %>%
            filter(player_name == input$PlayerSelection) %>%
            select(neighbor_player_id, neighbor_player_name, pct_match,selections) %>%
            mutate(pct_match = scales::percent(round(pct_match,2)))
        CompTable <- reactable(
            data,
            bordered = FALSE, 
            pagination = FALSE,
            highlight = TRUE,
            fullWidth = FALSE,
            class = "CompTable",
            defaultColDef = colDef(headerClass = "header", align = "left"),
            columns = list(
                neighbor_player_id = colDef(
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
                neighbor_player_name = colDef(name = "Player",minWidth = 140,class = "table_contents"),
                pct_match = colDef(name = "Percent Match",minWidth = 60, class = "table_contents"),
                selections = colDef(
                    name = 'All Def Selections',
                    cell = function(value) {
                        if (value > 0) {
                            paste(toString(value),"\u2605")
                        }
                        else {"0"}
                    }
                )
            )
        )
        CompTable
        
    })
    #-------------#
    ### Cluster ###
    #-------------#
    
    
    output$Clusters <- renderPlotly({
        CP <- CompPlayers()
        NN <- CP %>%
            select(neighbor_player_id, neighbor_player_name, pct_match) %>%
            pull(neighbor_player_name)
        
        NearestNeighbors <- append(input$PlayerSelection,as.vector(NN))
        
        ClusterData <- PlayerClusters %>%
            select(PLAYER_ID, x, y) %>%
            left_join(PlayerInfo, by = c("PLAYER_ID" = "idPlayer")) %>%
            mutate(PlayerComp = if_else(Player %in% NearestNeighbors,"Comparison","All Other"))
        
        ClusterScatter <- ggplot(data = ClusterData,aes(x = x, y = y,
                                                        text = paste(Player,"<br>",PlayerComp),
                                                        color = PlayerComp)) +
            geom_point(alpha = .80, aes(size = PlayerComp),
                       show.legend = TRUE) +
            scale_color_manual(values = ScatterColors) +
            scale_size_manual(values = c(1,2.1)) +
            labs(title = "Defensive Player Comparisons",
                 subtitle = glue("2-Dimensional Space from T-SNE algorithm"),
                 x = "Dimension 1",
                 y = "Dimension 2",
                 caption = "See Methodology tab for details") +
            theme_minimal(base_family = "Source Sans Pro") +
            theme(plot.title = element_text(size = 14),
                  legend.title = element_blank())
        ggplotly(ClusterScatter, tooltip = "text") %>%
            config(displayModeBar = F) %>%
            layout(title = list(text = paste0("t-SNE Results",
                                                     "<br>",
                                                     "<sup>",
                                                     "See Methodology tab for details",
                                                     "</sup>")))
    })
    
    #---------------#
    ### Shot Zone ###
    #---------------#
    playerName <- reactive(input$PlayerSelection)
    output$ShotZones <- renderPlotly({
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
        shot_zone <- plot_court() +
            coord_fixed(ylim = c(0, 35), xlim = c(-25, 25)) +
            geom_polygon(
                data = zonesPlayer,aes(x = x, y = y, group = desc, fill = Percentile,
                                       text = scales::ordinal(Percentile*100)),
                color = "white", alpha =.70,
                show.legend = TRUE
            )+
            ylim(0,35) +
            scale_fill_gradient(low = "yellow", high = "red",limits = c(0,1),
                                breaks = c(0,.25,.50,.75,1),
                                labels = c("0","25","50","75","100")) +
            geom_label(data=ShotZoneLables, aes(x = x,y = y, label = scales::ordinal(label*100)),
                       color="#4d4d4d", 
                       size= 5 , angle=0, fontface="bold" ) +
            labs(title = "FillerText for Plotly",
                 subtitle = "FillerText for Plotly")+
            theme(text=element_text(family="Source Sans Pro"),
                  plot.title = element_markdown(),
                  legend.title = element_text(size = 12),
                  legend.key.width = unit(.5,"cm"),
                  legend.position= "bottom"
                  )
        ggplotly(shot_zone, tooltip = "text") %>% 
            config(displayModeBar = F) %>%
            layout(title = list(text = paste0("Percentile by Shot Zone",
                                              "<br>",
                                              "<sup>",
                                              playerName(),
                                              "</sup>")))
    })
    
    
    #-----------------#
    ### DFG Percent ###
    #-----------------#
    
    output$DFGPercent <- renderPlotly({
        
        CP <- CompPlayers()
        NN <- CP %>%
            select(neighbor_player_id, neighbor_player_name, pct_match) %>%
            pull(neighbor_player_name)
        
        NearestNeighbors <- append(input$PlayerSelection,as.vector(NN))
        
        DFG_Percentage <- GameLogs %>%
            filter(Season == input$SeasonSelection,
                   Distance == input$Distance) %>%
            group_by(idPlayer,Player,Distance) %>%
            summarise(T_DFGM = sum(DFGM), T_DFGA = sum(DFGA), Min = sum(minutes)) %>%
            mutate(DFG_Percent = round(T_DFGM/T_DFGA,3), 
                   ShotsDefended_Per36 = round((T_DFGM/Min)*36,2),
                   PlayerComp = if_else(Player %in% NearestNeighbors,"Comparison","All Other")) %>%
            filter(T_DFGA >= 100)
        
        max_x <- max(DFG_Percentage$ShotsDefended_Per36)
        
        DFPScatter <- ggplot(data = DFG_Percentage,aes(x = ShotsDefended_Per36, 
                                                       y = DFG_Percent,
                                                       text = paste0("Player:",Player,"\n","DFG%:",scales::percent(round(DFG_Percent,2))),
                                                       color = PlayerComp)) +
            geom_point(alpha = .90, aes(size = PlayerComp)) +
            scale_color_manual(values = ScatterColors) +
            scale_size_manual(values = c(1,2.1)) +
            labs(title = "Defensive FG% vs Shots Defended/36 min",
                 subtitle = glue("NBA 2019-20 Season"),
                 x = "Shots Defended/36 min",
                 y = "Defensive FG%",
                 caption = "Players with >= 150 shots defended only") +
            theme_minimal(base_family = "Source Sans Pro") +
            theme(plot.title = element_text(size = 14),
                  legend.title = element_blank())
        ggplotly(DFPScatter, tooltip = "text") %>% 
            config(displayModeBar = F) %>%
            layout(title = list(text = paste0("Defensive FG% vs Shots Defended/36 min ",input$SeasonSelection, " Season",
                                              "<br>",
                                              "<sup>",
                                              "Players with less than 100 shots defended are excluded"),
                                              "</sup>"))
    })
}