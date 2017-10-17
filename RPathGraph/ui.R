library(shiny)
library(shinyjs)

ui <- fluidPage(
  theme = "Estilos.css",
  useShinyjs(),
  tags$head(
    includeScript("https://d3js.org/d3.v3.min.js")
  ),
  titlePanel("Prueba Grafos"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      actionButton("button", "Click me"),
      div(class="hola")
      
    )
  )

)