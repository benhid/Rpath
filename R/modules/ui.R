# Load modules
source('modules/search/searchPanel.R', local = TRUE)
source('modules/user_manual/userManualPanel.R', local = TRUE)
source('modules/data_summary/analysisPanel.R', local = TRUE)
source('modules/visualization/visualizationPanel.R', local = TRUE)

app.ui <-
  shinyUI(
    fluidPage(title = "RPath",
      theme = "css/bootstrap.min.css",
      # Bootstrap.js
      tags$script(src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"),
      tags$script(src="https://use.fontawesome.com/0e40b7473a.js"),
      tags$script("$(document).ready(function() { $(\"body\").tooltip({ selector: '[data-toggle=tooltip]' });});"),
      # Scripts for background
      tags$script(src="js/particles.min.js"),
      tags$script("particlesJS.load('particles-js', 'js/particles.json', function() {
                  console.log('callback - particles.js config loaded');
                  });"),
      tags$style(" #particles-js {
                 width: 100%; height: 100%; background-image: url(\"\");
                 position: fixed; z-index: -10; top: 0; left: 0; }"),
      tags$div(id="particles-js"),
      # Scripts for Visualization module
      tags$head( includeScript("https://d3js.org/d3.v3.min.js") ),
      useShinyjs(),

      # Page
      navbarPage(
        div(
          img(
            src = "logo_small.png",
            height = 30,
            width = "auto"
          )
        ),
        search.panel,
        analysis.panel,
        visualization.panel,
        user.panel
      )
    )
  )
