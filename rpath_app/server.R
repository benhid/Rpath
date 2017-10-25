library(shiny)
library(DT)
library(plyr)
library(paxtoolsr)

# Proxy settings
#Sys.setenv(http_proxy="http://proxy.wifi.uma.es:3128/")

createLink <- function(val) {
  # Create the button "GO"
  sprintf('<a href="%s" target="_blank" class="btn btn-default">GO</a>', val)
}

createImg <- function(val) {
  # Display an image instead of the datasource's url
  db <- gsub("http://pathwaycommons.org/pc2/","",val) # get the datasource's name
  url_img <- paste(db, ".png", sep="") # add the extension
  sprintf('<img src="%s" class="img-rounded" alt="%s"></img>', url_img, db) # add the image
}

shinyServer(function(input, output) {
  
  getResultsDf <- eventReactive(input$searchButton,{
    # Only when searchButton is press (eventReactive), perform a search on Pathway Commons
    term <- input$term 
    dataSources <- input$dataSources
    organism <- input$organism
    numberOfResults <- input$numberOfResults
    
    # Validate the form and replace null values with examples
    if (term == ""){
      showNotification("No term provided. Executing example query...", type="error")
      term <- "name:gl?coly*"
    }
    if (is.null(dataSources)){
      showNotification("No datasource selected. Searching on Reactome...", type="error")
      dataSources <- "reactome"
    }
    if (numberOfResults<0 || numberOfResults>100){
      showNotification("No valid number of results range (1:100). Showing 10 results...", type="error")
      numberOfResults <- 10
    }
    
    # Loading bar
    withProgress(message = 'Loading', value = 0, {
      # Step 1. Search on pathway commons
      incProgress(0.1, detail = paste("Searching on selected databases..."))
      searchResults <- tryCatch({searchPc(q = term, 
                                          datasource = paste(dataSources, sep="&"), 
                                          type = "Pathway", organism = organism)
                                }, error = function(err) {
                                 stop("Couldn't perform search.")
                                })
      
      # Step 2. Transform XML data into a data.frame
      incProgress(0.5, detail = paste("Parsing results..."))
      searchResultsDf <- ldply(xmlToList(searchResults), data.frame) 
      
      # Step 3. We only keep the first N searchHits (NOT .attrs) with N being numberOfResults
      incProgress(0.8, detail = paste("Simplifying results..."))
      searchResultsDf <- subset(searchResultsDf, .id=="searchHit")
      headSearchResultsDf <- head(searchResultsDf,  numberOfResults) 
    
      # If we have searchHit>=1 then create links, images and 
      # return a subset of the original data.frame containing only a few columns
      if("uri" %in% colnames(headSearchResultsDf))
      {
        headSearchResultsDf$uri <- createLink(headSearchResultsDf$uri)
        headSearchResultsDf$dataSource <- createImg(headSearchResultsDf$dataSource)
        headSearchResultsDf <- headSearchResultsDf[, c("name", "dataSource", "numParticipants", "numProcesses", "size", "uri")]
      }
      
      # Step 4. Done! Return the results
      incProgress(1.0, detail = paste("Done!"))
      finalSearchResultsDf <<- headSearchResultsDf # global variable
    })
    
    return(finalSearchResultsDf)
  })
  
  output$searchResults <-  renderDataTable({
    # Display the results data.frame ONLY is data.frame is not empty
    results <- getResultsDf()
    if(nrow(results) == 0){ showNotification("No results!", type="warning") 
                            return(setNames(data.frame(matrix(ncol = 6, nrow = 0)),
                                            c("name", "dataSource", "numParticipants", "numProcesses", "size", "uri"))) }
    else{ return(getResultsDf()) }
  }, options = list(pageLength = 20, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )
  
  getURIFromDf <- eventReactive(input$searchResults_rows_selected,{
    # Only when a row is selected (eventReactive), return the URI of the selected result 
    return(strsplit(as.character(finalSearchResultsDf$uri[input$searchResults_rows_selected]), "\"")[[1]][2])
  })
  
  #output$selectedRow <- renderPrint(
    # Display the URI of the selected row (verbose)
  #  getURIFromDf()
  #)
  
})