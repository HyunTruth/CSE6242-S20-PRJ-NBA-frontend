library(tidyverse)
library(highcharter)
library(tibbletime)
library(ggtext)
source("C:/Users/Spelk/Desktop/Georgia Tech Analytics/CSE 6242/CSE6242-S20-PRJ-NBA-frontend/NBADefensiveAnalytics/R/court.R")

## Data & Logic
GameLogs <- read.csv("C:/MAMP/htdocs/FinalGameLogs.csv")
zones <- read.csv("../data/ShotZones.csv")
GameLogs$Game_Date <- as.Date(GameLogs$Game_Date)
levels(GameLogs$Distance) <- c("0-4ft","10-14ft","15-19ft","20-24ft","25-29ft","5-9ft")

BoxScores <- read.csv("../data/BoxScores.csv")
PlayerInfo <- BoxScores %>%
  distinct(idPlayer,Player,urlPlayerHeadshot)

# Player Com p Example
CompPlayers <- tibble(
  idPlayer = c(203507,201572,	201143,	203954,1628389),
  Rk = c(1,2,3,4,5),
  Player = c("Giannis Antetokounmpo","Brook Lopez","Al Horford","Joel Embiid","Bam Adebayo"),
  SimilarityScore = c(89,75,66,52,48)
)


# Static Filters
distance_list <- c("0-4ft","5-9ft","10-14ft","15-19ft","20-24ft","25-29ft")

## Functions
rolling <- rollify(mean,window = 5,na_value = 0)

## Color Palette
BlueSeqColors <- c( #light to dark blue
  "#f1eef6",
  "#bdc9e1",
  "#74a9cf",
  "#2b8cbe",
  "#045a8d"
)

QualColors <- c( #category/qualitative/groups --> full opacity
  '#386cb0',
  "#fdc086",
  "#7fc97f",
  "#beaed4",
  "#ffff99"
)

ScatterOppacity <- c(#opacity adjusted blue & orange
  "rgba(255,127,0,.85)",
  "rgba(55,126,184,.70)"
)

ScatterOppacity2 <- c(#opacity adjusted blue & orange
  "rgba(166,206,227,.5)",
  "rgba(55,126,184,.5)"
)