visualization.panel <-
  tabPanel("Visualization", value = "visTab",
         actionButton("buttonGraph", "Display graph", class="btn-primary"),
         actionButton("deleteGraph", "Delete all graphs", class="btn-primary"),
         tags$div(id="graph" , class = "paintGraph")
  )
