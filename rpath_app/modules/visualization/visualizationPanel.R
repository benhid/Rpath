library(V8)

visualization.panel <- 
  tabPanel("Visualization",
         actionButton("buttonGraph", "VISUALIZATION GRAPH"),
         tags$div(id="graph" ,class = "paintGraph"),
         actionButton("deleteGraph","DeleteGraph")
  )