#--------------------------#
### Package Requirements ###
#--------------------------#

#shiny
#shinythemes
#reactable
#plotly
#tidyverse
#gghighlight
#glue
#extrafont
#scales
#htmltools
#ggtext

packages <- c("shiny","shinythemes","reactable","plotly",
              "tidyverse","gghighlight","glue","extrafont",
              "scales","htmltools")
installed.packages(packages)
remotes::install_github("wilkelab/ggtext")
font_import()
