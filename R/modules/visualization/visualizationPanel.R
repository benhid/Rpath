visualization.panel <-
  tabPanel("Visualization", value = "visTab",
           tabsetPanel(type = "tabs",
                       tabPanel("Extended graph (with D3js)",
                                wellPanel(
                                  actionButton("buttonGraph", "View", class="btn-primary"),
                                  actionButton("deleteGraph", "Clear", class="btn-primary")
                                ),
                                wellPanel(
                                  tags$div(id="graph", class="paintGraph")
                                )),
                       tabPanel("Extended graph",
                                wellPanel(
                                  visNetworkOutput("extendedGraph", height = "600px")
                                )),
                       tabPanel("Binary SIF graph",
                                #absolutePanel(class="controls panel panel-default draggable ui-draggable ui-draggable-handle",
                                #              style="background-color: white; padding: 0 20px 20px 20px; cursor: move;
                                #      opacity: 0.65; zoom: 0.9; transition: opacity 500ms 1s;", fixed = TRUE,
                                #              draggable = TRUE, top = 80, left = "auto", right = 20, bottom = "auto",
                                #              width = 330, height = "auto",
                                #              sliderInput("binaryDegree", "Degree of depth:",
                                #                          min = 1, max = 20, value = 4
                                #              )
                                #),
                                wellPanel(
                                  visNetworkOutput("binaryGraph", height = "600px")
                                ))
           )
  )

