library(DT)
library(plyr)
library(paxtoolsr)

createLink <- function(val) {
  sprintf('<a href="%s" target="_blank" class="btn btn-default">GO</a>', val)
}

createImg <- function(val) {
  db <- gsub("http://pathwaycommons.org/pc2/","",val)
  url_img <- paste(db, ".png", sep="")
  sprintf('<img src="img/search/%s" class="img-rounded" alt="%s"></img>', url_img, db)
}

getRowFromDf <- eventReactive(input$searchResults_rows_selected,{
  strsplit(as.character(finalSearchResultsDf$uri[input$searchResults_rows_selected]), "\"")[[1]][2]
})

getResultsDf <- eventReactive(input$searchButton,{
  term <- input$term 
  dataSources <- input$dataSources
  organism <- input$organism
  numberOfResults <- input$numberOfResults
  
  # Validation
  if (term == ""){
    showNotification("No term provided. Executing example query...", type="error")
    term <- "name:gl?coly*"
  }
  if (is.null(dataSources)){
    showNotification("No datasource selected. Searching on Reactome only...", type="error")
    dataSources <- "reactome"
  }
  if (numberOfResults<0 || numberOfResults>100){
    showNotification("No valid number of results range (1:100). Showing 10 results...", type="error")
    numberOfResults <- 10
  }
  
  # Loading bar
  withProgress(message = 'Loading', value = 0, {
    incProgress(0.1, detail = paste("Searching on selected databases..."))
    searchResults <- searchPc(q = term, 
                              datasource = paste(dataSources, sep="&"), 
                              type = "Pathway", organism = organism, verbose = TRUE)
    
    incProgress(0.5, detail = paste("Parsing results..."))
    searchResultsDf <- ldply(xmlToList(searchResults), data.frame) 
    
    incProgress(0.8, detail = paste("Simplifying results..."))
    searchResultsDf <- subset(searchResultsDf, .id=="searchHit") # we only keep searchHits (NOT .attrs)
    headSearchResultsDf <- head(searchResultsDf,  numberOfResults) 
    
    # If we have searchHit>=1 then create links, images and 
    # return a subset of the original dataframe
    if("uri" %in% colnames(headSearchResultsDf))
    {
      headSearchResultsDf$uri <- createLink(headSearchResultsDf$uri)
      headSearchResultsDf$dataSource <- createImg(headSearchResultsDf$dataSource)
      headSearchResultsDf <- headSearchResultsDf[, c("name", "dataSource", "numParticipants", "numProcesses", "size", "uri")]
    }
    
    incProgress(1.0, detail = paste("Done!"))
    finalSearchResultsDf <<- headSearchResultsDf # global variable
  })
  
  return(finalSearchResultsDf)
})