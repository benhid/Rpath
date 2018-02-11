library(shiny)

source('modules/ui.R', local = TRUE)
source('modules/server.R', local = TRUE)

# Proxy settings
#Sys.setenv(http_proxy="http://proxy.wifi.uma.es:3128/")

shinyApp(
  ui = app.ui,
  server = app.server
)