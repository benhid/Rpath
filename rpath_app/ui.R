library(shiny)
library(shinyjs)
library(paxtoolsr)
library("rlist")
source("FinalParseSif.R")

jsCode2 <- readLines("www/graph.js",179)

code2 = ""

for(i in 1:179){
  code2 = paste(code2,jsCode2[i], sep= '\n')
  
}

ui <- fluidPage(
  theme = "Estilos.css",
  
  tags$head(
    includeScript("https://d3js.org/d3.v3.min.js")
  ),
  useShinyjs(),
  extendShinyjs(text = code2),
  titlePanel("Prueba Grafos"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      actionButton("button", "Click me"),
      div(class="hola")
      
    )
  )
)