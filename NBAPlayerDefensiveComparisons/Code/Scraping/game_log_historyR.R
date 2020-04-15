# Game Box Scores from 2018-2020
library(nbastatR)
library(future)
plan(multiprocess) 
game_log_history <- game_logs(seasons = 2018:2020,season_types = c("Regular Season"))
write.csv(game_log_history,"game_logs.csv")