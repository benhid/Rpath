server <- function(input, output) {
  observeEvent(input$button, {
    #sif<-toSif("www/file251c7b0510f5.owl")
    #sif <- rbind(sif,c("hello","in-complex-with", "quease"))
    links<-parseSifToDataModel(sif)
    js$paintGraph(links)
    
  })
}
