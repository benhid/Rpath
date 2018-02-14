source('modules/data_summary/queries.R', local = TRUE)

getSIF <- function(){
  if (finalSearchResultsDf$numParticipants[input$searchResults_rows_selected] == 0){
    showNotification("The selected path is empty (no participant found!), please use another one", type="error")
    return(NULL)
  }

  URL <- getRowFromDf()

  withProgress(message = 'Extracting SIF', value = 0, {
    incProgress(0.1, detail = paste('Path selected...'))
    sif <- getPc(URL, "BINARY_SIF")

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
    CustomQx <- sprintf(input$customQuery, URL)

    tryCatch({
      CustomQx <- SPARQL(url=endpoint, CustomQx)$results
      print(CustomQx)
    }, error = function(e){
      showNotification("Not a SPARQL statement", type = "error")
    })
  })

  if(!is.data.frame(CustomQx)){
    # Error in statement; replace with empty dataframe
    CustomQx <- data.frame()
  }

  return(CustomQx)
})

BiochemicalReactions <- reactive({
  withProgress(message = 'Extracting information', value = 0, {
    URL <- getRowFromDf()
    URL <- paste0('<',URL,'>')
    BiochemicalReaction <- sprintf(query.biochemicalreactions, URL)
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
    Catalysis <- sprintf(query.catalysisreactions,URL)
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
    Control <- sprintf(query.controlreactions, URL)
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
    TemplateReaction <-sprintf(query.templatereactions,URL)
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
    TemplateReactionRegulation <- sprintf(query.templatereactionsregulations,URL)
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
    Degradation <- sprintf(query.degradationreactions,URL)
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
    Modulation <- sprintf(query.modulationreactions,URL)
    Modulation <- str_replace_all(Modulation, "[\r\n]" , "")
    Modulation <- SPARQL(url=endpoint, Modulation)$results
    Modulation$reference <- gsub("<|>","",Modulation$reference)
    Modulation$reference <- createLink(Modulation$reference)
  })

  return(Modulation)
})
