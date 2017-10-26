server <- function(input, output) {
  observeEvent(input$button, {
    sif<-toSif("www/prueba3.owl")
    js$paintGraph(sif)
  })
}