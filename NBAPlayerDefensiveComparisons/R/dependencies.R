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

packages <- c("shiny","shinythemes","reactable","plotly",
              "tidyverse","gghighlight","glue","extrafont",
              "scales","htmltools")
installed.packages(packages)
font_import()
