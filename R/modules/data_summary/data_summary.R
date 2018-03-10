source('modules/data_summary/queries.R', local = TRUE)

output$downloadSIFF <- downloadHandler(
  filename = function() {
    paste('rpath-sif-', Sys.Date(), '.sif', sep='')
  },
  content = function(file) {
    showNotification("Downloading file as XML...")
    URL <- getRowFromDf()
    sif <- getPc(URL, "BINARY_SIF")

    xml <- xmlTree()
    xml$addTag("document", close=FALSE)
    for (i in 1:nrow(sif)) {
      xml$addTag("row", close=FALSE)
      for (j in names(sif)) {
        xml$addTag(j, sif[i, j])
      }
      xml$closeTag()
    }
    xml$closeTag()

    saveXML(xml, file)
  }
)

output$queryResult <- renderDataTable(datatable({
  if (input$exampleQuery =="Biochemical Reaction") {
    data <- BiochemicalReactions()
  }
  else if (input$exampleQuery =="Catalysis") {
    data <- CatalysisReactions()
  }
  else if(input$exampleQuery=="Control"){
    data <- ControlReactions()
  }
  else if(input$exampleQuery=="Template Reaction"){
    data <- TemplateReactions()
  }
  else if(input$exampleQuery=="Template Reaction Regulation"){
    data <- TemplateReactionRegulations()
  }
  else if(input$exampleQuery=="Degradation"){
    data <- DegradationReactions()
  }
  else if(input$exampleQuery=="Modulation"){
    data <- ModulationReactions()
  }
}, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
escape=FALSE, selection = 'single'
))

output$customQueryDf <- renderDataTable(datatable({
  data <- CustomQuery()
}, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
selection = 'single'
))

output$pathwaySummary <- renderDataTable({
  return(extractSIF())
}, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
escape=FALSE, selection = 'single'
)

getSIF <- function(){
  withProgress(message = 'Extracting SIF', value = 0, {
    incProgress(0.1, detail = paste('Path selected...'))
    sif <- data.frame()

    tryCatch({
      URL <- getRowFromDf()
      sif <- getPc(URL, "BINARY_SIF")
    }, error = function(e){
      showNotification("SIF couldn't be extracted from pathway.", type = "error")
    })

    return(sif)
  })
}

extractSIF <- eventReactive(input$showSIFFButton, {
  return(getSIF())
})

CustomQuery <- eventReactive(input$queryButton, {
  withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    CustomQx <- data.frame()

    tryCatch({
      CustomQx <- sprintf(input$customQuery, URL)
      CustomQx <- SPARQL(url=input$customEndpoint, CustomQx)$results
    }, error = function(e){
      showNotification("Not a SPARQL statement or endpoint not valid.", type = "error")
    })
  })

  return(CustomQx)
})

BiochemicalReactions <- reactive({
  withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    BiochemicalReaction <- sprintf(query.biochemicalreactions, URL)
    BiochemicalReaction <- str_replace_all(BiochemicalReaction, "[\r\n]" , "")
    BiochemicalReaction <- SPARQL(url=pw.endpoint, BiochemicalReaction)$results
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
    Catalysis <- sprintf(query.catalysisreactions,URL)
    Catalysis <- str_replace_all(Catalysis, "[\r\n]" , "")
    Catalysis <- SPARQL(url=pw.endpoint, Catalysis)$results
    Catalysis$reference <- gsub("<|>","",Catalysis$reference)
    Catalysis$reference <- createLink(Catalysis$reference)
  })

  return(Catalysis)
})

ControlReactions <- reactive({
  withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    Control <- sprintf(query.controlreactions, URL)
    Control <- str_replace_all(Control, "[\r\n]" , "")
    Control <- SPARQL(url=pw.endpoint, Control)$results
    Control$reference <- gsub("<|>","",Control$reference)
    Control$reference <- createLink(Control$reference)
  })

  return(Control)
})

TemplateReactions <- reactive({
  withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    TemplateReaction <-sprintf(query.templatereactions,URL)
    TemplateReaction <- str_replace_all(TemplateReaction, "[\r\n]" , "")
    TemplateReaction <- SPARQL(url=pw.endpoint, TemplateReaction)$results
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
    TemplateReactionRegulation <- sprintf(query.templatereactionsregulations,URL)
    TemplateReactionRegulation <- str_replace_all(TemplateReactionRegulation, "[\r\n]" , "")
    TemplateReactionRegulation <- SPARQL(url=pw.endpoint, TemplateReactionRegulation)$results
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
    Degradation <- sprintf(query.degradationreactions,URL)
      Degradation <- str_replace_all(Degradation, "[\r\n]" , "")
      Degradation <- SPARQL(url=pw.endpoint, Degradation)$results
      Degradation$Degradation <- gsub("<|>","",Degradation$Degradation)
      Degradation$Degradation <- createLink(Degradation$Degradation)
  })

  return(Degradation)
})

ModulationReactions <- reactive({
  withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    Modulation <- sprintf(query.modulationreactions,URL)
    Modulation <- str_replace_all(Modulation, "[\r\n]" , "")
    Modulation <- SPARQL(url=pw.endpoint, Modulation)$results
    Modulation$reference <- gsub("<|>","",Modulation$reference)
    Modulation$reference <- createLink(Modulation$reference)
  })

  return(Modulation)
})
