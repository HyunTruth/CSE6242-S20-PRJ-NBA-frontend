## Description & Methodology

The **NBA Player Defensive Comparisons** package is an interactive application that allows NBA fans to explore and visualize defensive performance of specific players. The application has two main components: (1) Player Comparisons and (2) Player Stats. The Player Comparisons tabs allows the user to select a player from the 2019-20 season and view their top 4 player comparisons in a table and a scatterplot. The Player Stats tab has two separate visualization - one of which is a shot-zone map that shows the player's Defensive Field Goal Percentage (DFGP) league percentile by "shot-zone." The second chart is a scatterplot of DFGP vs shots defended per 36 minutes played.

To come up with the top 4 player comparisons for each player, a k-nearest-neighbors (knn) model was used on defensive statistics for all players that played in the 2019-20 season. The dataset consisted of a robust set of statistics, including primary shot-contests by distance, box-outs, rebounds, steals, and many other features (all on a per 36-minute basis). After building the knn model, a technique called t-Distributed Stochastic Neighbor Embedding (t-SNE) was used to do dimensionality reduction on the data. Using t-SNE, we created a 2-D scatterplot that allows for visualizing the player comparisons in a lower dimensional space. This lower-dimensional scatterplot is the main plot on the Player Comparisons tab - this allows for quick exploration of not only the top 4 player comparisons for a specific player, but also other players that are in the same "neighborhood", but fall outside of the top 4.

For a more detailed analysis on the statistical methods and testing that was performed, please read our full project report available here:

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
