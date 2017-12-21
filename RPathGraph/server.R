server <- function(input, output) {
  observeEvent(input$button, {
    #sif<-toSif("www/prueba3.owl")
    links<-parseSifToDataModel(sif)
    js$paintGraph(links)
    
  })
}
