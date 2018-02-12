# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE, quiet = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipak(c('shiny', 'shinyjs', 'DT'))
ipak(c('paxtoolsr')) # Search module
ipak(c('SPARQL', 'stringr')) # Analysis module
ipak(c('V8')) # Visualization module

# Load modules
source('modules/ui.R', local = TRUE)
source('modules/server.R', local = TRUE)

# Proxy settings
#Sys.setenv(http_proxy="http://proxy.wifi.uma.es:3128/")

# Run app
shinyApp(
  ui = app.ui,
  server = app.server
)
