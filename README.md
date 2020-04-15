# NBA Player Defensive Comparisons

## Description

The **NBA Player Defensive Comparisons** package is an interactive application that allows NBA fans to explore and visualize defensive performance of specific players. The application has two main components: (1) Player Comparisons and (2) Player Stats. The Player Comparisons tabs allows the user to select a player from the 2019-20 season and view their top 4 player comparisons in a table and a scatterplot. The Player Stats tab has two separate visualization - one of which is a shot-zone map that shows the player's Defensive Field Goal Percentage (DFGP) league percentile by "shot-zone." The second chart is a scatterplot of DFGP vs shots-defended/36 minutes.

To come up with the top 4 player comaprisons for each player, a k-nearest-neighbors (knn) model was used on defensive statistics for all players that played in the 2019-20 season. The dataset consisted of a robust set of statistics, including: primary shot-contests by distance, box-outs, rebounds, steals, and many other features (all on a per 36-minute basis). After building the knn model, a technique called t-Distributed Stochastic Neighbor Embedding (t-SNE) was used to do dimensionality reduction on the data. Using t-SNE, we created a 2-D scatterplot that allows for visualizing the player comparisons in a lower dimensional space. This lower-dimensional scatterplot is the main plot on the Player Comparisons tab - this allows for quick exploration of not only the top 4 player comparisons for a specific player, but also other players that are in the same "neighborhood", but fall outside of the top 4. 


Here is the live version of the Application: https://spelkofer.shinyapps.io/DefensivePlayerComparisons

_Data is updated through the end of the 2019-20 NBA season_

## Installation

Installing the application locally can be completed through the following steps:

1. Go to https://github.com/HyunTruth/CSE6242-S20-PRJ-NBA-frontend
2. Copy the link to clone the repository https://github.com/HyunTruth/CSE6242-S20-PRJ-NBA-frontend.git
3. Navigate to the local location where you want to store the application
4. From your local command prompt, run the following command
   ```
   git clone https://github.com/HyunTruth/CSE6242-S20-PRJ-NBA-frontend.git
   ```
5. The entire repository will now be stored in the folder location from step (3)

## Execution

Before you can execute the app, you need to have the following software downloaded:

1. R (version 3.5.3 or newer): https://www.r-project.org/
2. RStudio (free version): https://rstudio.com/products/rstudio/download/
3. Open up the Dependencies.R file and run it - this will install all the packages you need to run the app

Executing and running the application can be completed through the following steps:

1. Complete the Installation steps from above
2. Navigate to the relative folder location: ..\CSE6242-S20-PRJ-NBA-frontend\NBADefensiveAnalytics\App
3. Click on the ui.R file to open it in RStudio
4. Click 'Run App' in the top right corner of the RStudio application

## Data Source

All data was scraped from the following source:

- https://stats.nba.com/


### Authors

This application analysis was completed by a team of four M.S. in Analytics students at the Georgia Institute of Technology.

- Hyun Jin Lee
- Matt Luppi
- Richard Reasons
- Stephen Pelkofer
- Tim Kim
