library(V8)

visualization.panel <- 
  tabPanel("Visualization", value = "visTab",
         actionButton("buttonGraph", "VISUALIZATION GRAPH"),
         tags$div(id="graph" ,class = "paintGraph"),
         actionButton("deleteGraph","DeleteGraph")
  )