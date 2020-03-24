library(tidyverse)
library(highcharter)
library(tibbletime)

## Data & Logic
GameLogs <- read.csv("C:/MAMP/htdocs/FinalGameLogs.csv")
GameLogs$Game_Date <- as.Date(GameLogs$Game_Date)
levels(GameLogs$Distance) <- c("0-4ft","10-14ft","15-19ft","20-24ft","25-29ft","5-9ft")

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

QualColors <- c( #category/qualitative/groups
  '#386cb0',
  "#fdc086",
  "#7fc97f",
  "#beaed4",
  "#ffff99"
)