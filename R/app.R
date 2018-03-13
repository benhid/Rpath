# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE, quiet = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipak(c('shiny', 'shinyjs', 'DT'))
ipak(c('plyr')) # Search module
ipak(c('SPARQL', 'stringr', 'XML')) # Analysis module
ipak(c('igraph', 'visNetwork', 'rlist', 'V8')) # Visualization module

source("https://bioconductor.org/biocLite.R")
if (!require("paxtoolsr")) biocLite("paxtoolsr")

# Load modules
source('modules/ui.R', local = TRUE)
source('modules/server.R', local = TRUE)

# Run app
shinyApp(
  ui = app.ui,
  server = app.server
)
