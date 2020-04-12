#-------------#
### Imports ###
#-------------#

library(ggtext)
library(reactable)
library(plotly)
library(tidyverse)
library(tibbletime)
library(gghighlight)
library(glue)
library(extrafont)
library(scales)
library(htmltools)
source("../R/court.R")

#------------------#
### Data & Logic ###
#------------------#
# (1)
GameLogs <- read.csv("../data/GameLogs.csv")
levels(GameLogs$Distance) <- c("0-4ft","10-14ft","15-19ft","20-24ft","25-29ft","5-9ft")

# (2)
zones <- read.csv("../data/ShotZones.csv")

# (3)
BoxScores <- read.csv("../data/BoxScores.csv")
PlayerInfo <- BoxScores %>%
  distinct(idPlayer,Player,urlPlayerHeadshot)

# (4)
PlayerClusters <- read.csv("../data/PlayerClusters.csv")

# (5)
PlayerComparisons <- read.csv("../data/PlayerComparisons.csv")

# (6)
AllDefense <- read.csv('../data/AllDefense.csv')

colnames(AllDefense)[1] <- "Player"
AllDefense$first_or_second[AllDefense$first_or_second == 2] = 1
AllDefense <- AllDefense %>% 
  group_by(Player, playerID) %>% 
  summarise(selections = sum(first_or_second))

PlayerComparisons <- PlayerComparisons %>%
  left_join(AllDefense,by = c("neighbor_player_id"="playerID")) %>%
  select(player_id,player_name,rank,neighbor_player_id,
         neighbor_player_name,pct_match, selections) %>%
  replace_na(list(selections = 0))

#------------------------------------#
### Filters, Functions, and Colors ###
#------------------------------------#

# Static Filters
distance_list <- c("0-4ft","5-9ft","10-14ft","15-19ft","20-24ft","25-29ft")

## Functions
rolling <- rollify(mean,window = 5,na_value = 0)

ScatterColors <- c(
  "#636363",
  "#386cb0"
)