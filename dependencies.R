#--------------------------#
### Package Requirements ###
#--------------------------#

packages <- c("shiny","shinythemes","reactable","plotly",
              "tidyverse","gghighlight","glue","extrafont",
              "scales","htmltools","remotes","devtools","markdown")

install.packages(packages)
library(remotes)
remotes::install_github("wilkelab/ggtext")
font_import()
