server <- function(input, output) {
  observeEvent(input$button, {
    sif<-toSif("www/file251c7b0510f5.owl")
    links<-parseSifToDataModel(sif)
    js$paintGraph(links)
    
  })
}
