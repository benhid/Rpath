library(shiny)
library(DT)
library(plyr)
library(paxtoolsr)
library(XML)
library(shinyjs)
library(igraph)
library(shinyFiles)
# Define server logic

# Proxy settings
 Sys.setenv(http_proxy="http://proxy.wifi.uma.es:3128/")


#createLink <- function(val) {
 # sprintf('<a href="%s" target="_blank" class="btn btn-default">GO</a>', val)
#}

createImg <- function(val) {
  url_img <- paste(gsub("http://pathwaycommons.org/pc2/","",val), ".png", sep="")
  sprintf('<img src="%s" class="img-responsive"></img>', url_img)
}

shinyServer(function(input, output) {
  
  getResultsDf <- eventReactive(input$searchButton,{
    # Check if input is empty
    if (is.null(input$term) | is.null(input$dataSources)) return()
    if (input$numberOfResults<0 | input$numberOfResults>100) return()
    
    # Loading bar
    withProgress(message = 'Loading', value = 0, {
      incProgress(0.1, detail = paste("Searching on selected databases..."))
      searchResults <- searchPc(q = input$term, 
                                datasource = paste(input$dataSources, sep="&"), 
                                type = "Pathway", organism = input$organism)
      
      incProgress(0.5, detail = paste("Parsing results..."))
      searchResultsDf <- ldply(xmlToList(searchResults), data.frame) 
      
      incProgress(0.8, detail = paste("Simplifying results..."))
      searchResultsDf <- subset(searchResultsDf, .id=="searchHit") # we only keep searchHits (NOT .attrs)
      headSearchResultsDf <- head(searchResultsDf,  input$numberOfResults) 
    
      # If we have searchHit>=1 then create links, images and 
      # return a subset of the original dataframe
      if("uri" %in% colnames(headSearchResultsDf))
      {
        #headSearchResultsDf$uri <- createLink(headSearchResultsDf$uri)
        headSearchResultsDf$dataSource <- createImg(headSearchResultsDf$dataSource)
        headSearchResultsDf <- headSearchResultsDf[, c("name", "dataSource", "numParticipants", "numProcesses", "size", "uri")]
      }
      
      incProgress(1.0, detail = paste("Done!"))
      finalSearchResultsDf <<- headSearchResultsDf # global variable
    })
    
    return(finalSearchResultsDf)
  })
  
  output$searchResults <-  renderDataTable({
    return(getResultsDf())
  }, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )
  
  getRowFromDf <- eventReactive(input$searchResults_rows_selected,{
    
    as.character(finalSearchResultsDf$uri[input$searchResults_rows_selected])
    
  })
  
  
  
  
  output$selectedRow <- renderPrint(
    
    
    getRowFromDf()
  )
  
    
   
  hide("Plotme")
  observeEvent(input$searchButton, {
    toggle("Plotme")
    # toggle("plot") if you want to alternate between hiding and showing
  })
  
 
  ExtractSif <- eventReactive(input$Plotme,{
    URI <- as.factor(finalSearchResultsDf$uri[input$searchResults_rows_selected])
    withProgress(message = 'Extracting information', value = 0, {
      
      incProgress(0.1, detail = paste("ploting..."))
      #OWL <- getPc(URI,"BIOPAX")
      biopaxFile <- tempfile(tmpdir = getwd(),fileext = ".owl")
      saveXML(getPc(URL), biopaxFile)
      
      
      
      sif <- toSif("prueba3.owl")
      #g <- graph.edgelist(as.matrix(sif[, c(1, 3)]), directed = FALSE)
    })
    
    return("OWL")
    
  })
  
  output$roto2 <- renderPrint(
    
    
   ExtractSif()
    
  )
  
  
  
})