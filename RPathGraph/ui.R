library(shiny)
library(shinyjs)
library(paxtoolsr)


jsCode <- readLines("www/graph.js",91)
code = ""
for(i in 1:91){
  code = paste(code,jsCode[i], sep= '\n')
  
}
cat(code)
ui <- fluidPage(
  theme = "Estilos.css",

  tags$head(
    includeScript("https://d3js.org/d3.v3.min.js")
  ),
  useShinyjs(),
  extendShinyjs(text = code),
  titlePanel("Prueba Grafos"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      actionButton("button", "Click me"),
      div(class="hola")
      
    )
  )
)