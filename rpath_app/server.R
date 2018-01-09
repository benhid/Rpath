library(shiny)
library(DT)
library(plyr)
library(paxtoolsr)
library(SPARQL)
library(stringr)
# Define server logic

# Proxy settings

 #Sys.setenv(http_proxy="http://proxy.wifi.uma.es:3128/")
 



 
 createLink <- function(val) {
   sprintf('<a href="%s" target="_blank" class="btn btn-default">GO</a>', val)
 }

 
 createImg <- function(val) {
   db <- gsub("http://pathwaycommons.org/pc2/","",val)
   url_img <- paste(db, ".png", sep="")
   sprintf('<img src="%s" class="img-rounded" alt="%s"></img>', url_img, db)
 }

 shinyServer(function(input, output) {
   
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
       showNotification("No datasource selected. Searching on Reactome...", type="error")
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
                                 type = "Pathway", organism = organism)
       
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
  
  output$searchResults <-  renderDataTable({
    return(getResultsDf())
  }, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )
  
  getRowFromDf <- eventReactive(input$searchResults_rows_selected,{
    strsplit(as.character(finalSearchResultsDf$uri[input$searchResults_rows_selected]), "\"")[[1]][2]
  })
  
  output$selectedRow <- renderPrint(
    getRowFromDf()
    
  )
  
  #while you didn`t press the search button the button "Select" will be hide`
   
  hide("Plotme")
  observeEvent(input$searchButton, {
    toggle("Plotme")
    # toggle("plot") if you want to alternate between hiding and showing
  })
  
  
  Sif <- reactive({
    URI <- getRowFromDf()
    withProgress(message = 'Extracting SIF', value = 0, {
      incProgress(0.1, detail = paste('Path selected...'))
      sif <- getPc(URI,"BINARY_SIF")
      return(sif)
    })
  })
    
  #When you press the select button you are going to extract the sif file from the the row selected
  ExtractSif <- eventReactive(input$Plotme,{
    return(Sif())
  })

  output$Summary <-  renderDataTable({
    return(ExtractSif())
  }, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )
  
  
  #ANALYSIS PART
  
  endpoint <- "http://rdf.pathwaycommons.org/sparql/"
  BiochemicalReactions <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    BiochemicalReaction <- sprintf('select ?nameReaction ?nleft ?nright ?leftReference ?rightReference  where {\n
    %s bp:pathwayComponent ?s.\n
                               ?s a bp:BiochemicalReaction.\n
                               ?s bp:left ?left.\n
                               ?s bp:right ?right.\n
                               ?s bp:displayName ?nameReaction.\n
                               ?left bp:displayName ?nleft.\n
                               ?right bp:displayName ?nright.\n
                                ?left   <http://www.biopax.org/release/biopax-level3.owl#entityReference> ?leftReference.\n
                                ?right <http://www.biopax.org/release/biopax-level3.owl#entityReference> ?rightReference.\n
                               }',URL)
    
    BiochemicalReaction <- str_replace_all(BiochemicalReaction, "[\r\n]" , "")
    BiochemicalReaction <- SPARQL(url=endpoint, BiochemicalReaction)$results
    BiochemicalReaction$leftReference <- gsub("<|>","",BiochemicalReaction$leftReference)
    BiochemicalReaction$rightReference <- gsub("<|>","",BiochemicalReaction$rightReference)
    BiochemicalReaction$leftReference <- createLink(BiochemicalReaction$leftReference)
    BiochemicalReaction$rightReference <- createLink(BiochemicalReaction$rightReference)
    
    })
    return(BiochemicalReaction)
  })
  
  CatalysisReactions <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    Catalysis <- sprintf('select  ?nameController ?reference  ?nameControlled where {\n
                    %s bp:pathwayComponent ?Catalysis.\n
                    ?Catalysis a bp:Catalysis .\n
                    
    ?Catalysis bp:controller ?controller.\n
                    
                     ?Catalysis bp:controlled ?controlled.\n
                     ?controller bp:entityReference ?reference.\n
                     ?controller bp:standardName ?nameController.\n
                     ?controlled bp:standardName ?nameControlled.\n
                     }',URL)
    Catalysis <- str_replace_all(Catalysis, "[\r\n]" , "")
    Catalysis <- SPARQL(url=endpoint, Catalysis)$results
    Catalysis$reference <- gsub("<|>","",Catalysis$reference)
    Catalysis$reference <- createLink(Catalysis$reference)
    })
    return(Catalysis)
    
  })
  ControlReactions <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    Control <- sprintf('select  ?nameController ?reference  ?nameControlled where {\n
                      %s bp:pathwayComponent ?ReactionControl.\n
                      ?ReactionControl a bp:Control .\n
                      ?ReactionControl bp:controller ?controller.\n
                      ?ReactionControl bp:controlled ?controlled.\n
                      ?controller bp:standardName ?nameController.\n
                      ?controlled bp:standardName ?nameControlled.\n
                      ?controller bp:entityReference ?reference. \n
                      }',URL)
    Control <- str_replace_all(Control, "[\r\n]" , "")
    Control <- SPARQL(url=endpoint, Control)$results
    Control$reference <- gsub("<|>","",Control$reference)
    Control$reference <- createLink(Control$reference)
    })
    return(Control)
  })
  TemplateReactions <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    TemplateReaction <-sprintf('select * where {\n
                            %s bp:pathwayComponent ?TemplateReaction.\n
                            ?TemplateReaction a bp:TemplateReaction.\n
                            ?TemplateReaction bp:product ?product. \n
                            ?product bp:displayName ?name.\n
                            ?product  bp:entityReference ?reference.\n
                            }',URL)
    
    
    TemplateReaction <- str_replace_all(TemplateReaction, "[\r\n]" , "")
    TemplateReaction <- SPARQL(url=endpoint, TemplateReaction)$results
    TemplateReaction$TemplateReaction <-  gsub("<|>","",TemplateReaction$TemplateReaction)
    TemplateReaction$TemplateReaction <- createLink(TemplateReaction$TemplateReaction)
    TemplateReaction$product <-  gsub("<|>","",TemplateReaction$product)
    TemplateReaction$product <- createLink(TemplateReaction$product)
    TemplateReaction$reference <-  gsub("<|>","",TemplateReaction$reference)
    TemplateReaction$reference <- createLink(TemplateReaction$reference)
    })
    return(TemplateReaction)
    
  })
  TemplateReactionRegulations <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    TemplateReactionRegulation <- sprintf('select ?nameController ?reference ?controller where {\n
                            %s bp:pathwayComponent ?TemplateReactionRegulation.\n
                            ?TemplateReactionRegulation a bp:TemplateReactionRegulation.\n
                            ?TemplateReactionRegulation bp:controlled ?controlled.\n
                            ?TemplateReactionRegulation bp:controller ?controller.\n
                            ?controller bp:displayName ?nameController.\n
                            ?controller bp:entityReference ?reference.\n
                            }',URL)
    TemplateReactionRegulation <- str_replace_all(TemplateReactionRegulation, "[\r\n]" , "")
    TemplateReactionRegulation <- SPARQL(url=endpoint, TemplateReactionRegulation)$results
    TemplateReactionRegulation$reference <- gsub("<|>","",TemplateReactionRegulation$reference)
    TemplateReactionRegulation$reference <- createLink(TemplateReactionRegulation$reference)
    TemplateReactionRegulation$controller <- gsub("<|>","",TemplateReactionRegulation$controller)
    TemplateReactionRegulation$controller <- createLink(TemplateReactionRegulation$controller)
    })
    return(TemplateReactionRegulation)
  })
  DegradationReactions <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    Degradation <- sprintf('select * where {\n
                      %s bp:pathwayComponent ?Degradation.\n
                           ?Degradation a bp:Degradation .\n
                           ?Degradation bp:displayName ?name. \n
     }',URL)
    Degradation <- str_replace_all(Degradation, "[\r\n]" , "")
    Degradation <- SPARQL(url=endpoint, Degradation)$results
    Degradation$Degradation <- gsub("<|>","",Degradation$Degradation)
    Degradation$Degradation <- createLink(Degradation$Degradation)
    })
    return(Degradation)
  })
  ModulationReactions <- reactive({
    withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    Modulation <- sprintf('select ?nameController ?reference ?nameControlled where {\n
                      %s bp:pathwayComponent ?Modulation.\n
                      ?Modulation a bp:Modulation.\n
                      ?Modulation bp:controller ?controller.\n
                      ?controller bp:displayName ?nameController.\n
                      ?controller bp:entityReference  ?reference.\n
                      ?Modulation bp:controlled ?controlled.\n
                      ?controlled bp:displayName ?nameControlled.\n
                       }',URL)
    Modulation <- str_replace_all(Modulation, "[\r\n]" , "")
    Modulation <- SPARQL(url=endpoint, Modulation)$results
    Modulation$reference <- gsub("<|>","",Modulation$reference)
    Modulation$reference <- createLink(Modulation$reference)
    })
    return(Modulation)
  })
  output$table <- DT::renderDataTable(DT::datatable({
    
    if (input$dataset =="Biochemical Reaction") {
      data <- BiochemicalReactions()
    }
    else if (input$dataset =="Catalysis") {
      data <- CatalysisReactions()
    }
    else if(input$dataset=="Control"){
      data <- ControlReactions()
    }
    else if(input$dataset=="Template Reaction"){
      data <- TemplateReactions()
    }
    else if(input$dataset=="Template Reaction Regulation"){
      data <- TemplateReactionRegulations()
    }
    else if(input$dataset=="Degradation"){
      data <- DegradationReactions()
    }
    else if(input$dataset=="Modulation"){
      data <- ModulationReactions()
    }
    
    
   
  },escape = FALSE
  ))
  
  GetOwl <- reactive({
    URL <- getRowFromDf()
    getPc(URL)
  })
   output$downloadData <- downloadHandler(
    filename = function() {
       paste('data-', Sys.Date(), '.owl', sep='')
     },
     content = function(file) {
      
       a <- saveXML(GetOwl(), file)
     }
  )
})
