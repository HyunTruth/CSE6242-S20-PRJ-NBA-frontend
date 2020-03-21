library(tidyverse)
library(highcharter)

## Data & Logic
GameLogs <- read.csv("C:/MAMP/htdocs/FinalGameLogs.csv")
levels(GameLogs$Distance) <- c("0-5ft","10-14ft","15-19ft","20-24ft","25-29ft","5-9ft")
distance_list <- c("0-5ft","5-9ft","10-14ft","15-19ft","20-24ft","25-29ft")

## Color Palette
BlueSeqColors <- c( #light to dark blue
  "#f1eef6",
  "#bdc9e1",
  "#74a9cf",
  "#2b8cbe",
  "#045a8d"
)

QualColors <- c( #category/qualitative/groups
  '#386cb0',
  "#fdc086",
  "#7fc97f",
  "#beaed4",
  "#ffff99"
)