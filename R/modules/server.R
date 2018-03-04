app.server <- shinyServer(function(input, output) {

  observe({
    # Hide at start-up
    if(length(input$searchResults_rows_selected) > 0){
      if (finalSearchResultsDf$numParticipants[input$searchResults_rows_selected] == 0){
        shinyjs::addClass(selector = ".navbar li a[data-value=visTab]", class = "disabledTab")
        shinyjs::addClass(selector = ".navbar li a[data-value=analysisTab]", class = "disabledTab")
        showNotification("The selected path is empty (no participants!); please, select another one", type="error")
      } else{
        shinyjs::removeClass(selector = ".navbar li a[data-value=visTab]", class = "disabledTab")
        shinyjs::removeClass(selector = ".navbar li a[data-value=analysisTab]", class = "disabledTab")
        shinyjs::show("downloadOWL")
      }
    } else if (!is.null(input$owlFile)){
      shinyjs::removeClass(selector = ".navbar li a[data-value=visTab]", class = "disabledTab")
      shinyjs::removeClass(selector = ".navbar li a[data-value=analysisTab]", class = "disabledTab")
    } else{
      shinyjs::addClass(selector = ".navbar li a[data-value=visTab]", class = "disabledTab")
      shinyjs::addClass(selector = ".navbar li a[data-value=analysisTab]", class = "disabledTab")
      shinyjs::hide("downloadOWL")
    }
  })

  # Search module
  source('modules/search/search.R', local = TRUE)

  output$searchResults <-  renderDataTable({
      return(getResultsDf())
    }, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )

  output$downloadOWL <- downloadHandler(
    filename = function() {
      paste('rpath-owl-', Sys.Date(), '.owl', sep='')
    },
    content = function(file) {
      showNotification("Downloading file...")
      URL <- getRowFromDf()
      owl <- getPc(URL)

      saveXML(owl, file)
    }
  )

  # Data summarization module
  source('modules/data_summary/analysis.R', local = TRUE)

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

  # Visualization module
  source('modules/visualization/parseSifInteractions.R', local = TRUE)
  
  output$binaryGraph <- renderVisNetwork({
    tryCatch({
      withProgress(message = 'Loading', value = 0, {
        incProgress(0.1, detail = paste("Getting binary SIF"))

        URL <- getRowFromDf()
        owl <- getPc(URL)

        incProgress(0.5, detail = paste("Parsing..."))

        edges <- toSif(owl)
        colnames(edges) <- c("from", "title", "to")

        incProgress(0.8, detail = paste("Parsing..."))

        sifnx <- toSifnx(owl)
        nodes <- sifnx$nodes[, 1:2]
        nodes$id <- nodes$PARTICIPANT
        colnames(nodes) <- c("label", "group", "id")
      })

      # Get summary
      #g <- loadSifInIgraph(edges, directed = TRUE)
      #showNotification(paste("Clustering coefficient:", transitivity(g)), type = "message", duration = 15)
      #showNotification(paste("Network density:", graph.density(g)), type = "message", duration = 15)
      #showNotification(paste("Network diameter:", diameter(g)), type = "message", duration = 15)
    }, error = function(e){
      print(e)
      showNotification("Sorry, your graph can not be displayed. The SIF file is empty or can not be extracted correctly.",
                       type = "error")
    })

    visNetwork(nodes, edges, width = "100%", directed = TRUE) %>%
      visEdges(arrows="to", smooth="false") %>%
      visGroups(groupname = "SmallMoleculeReference", shape = "square") %>%
      visGroups(groupname = "ProteinReference", shape = "dot") %>%
      visLayout(randomSeed = 12) %>%
      visPhysics(enabled=FALSE) %>%
      visOptions(nodesIdSelection = TRUE, highlightNearest = list(enabled = T, degree = 1, hover = T))
  })

  output$extendedGraph <- renderVisNetwork({
    tryCatch({
      withProgress(message = 'Loading', value = 0, {
        incProgress(0.1, detail = paste("Getting extended SIF"))
        
        URL <- getRowFromDf()
        owl <- getPc(URL)
        sifnx <- toSifnx(owl)
        
        incProgress(0.5, detail = paste("Parsing..."))
        
        links <- parseSifInteractionsVisNetwork(sifnx)

        edges <- data.frame(links$source, links$tipoLink, links$target)
        colnames(edges) <- c("from", "title", "to")
        
        incProgress(0.8, detail = paste("Parsing..."))
        
        nodes <- data.frame(links$nodos,links$tipoNodo)
        nodes <- nodes[!duplicated(nodes),]
        nodes$id <- nodes$links.nodos
        colnames(nodes) <- c("label", "group", "id")
      })
    }, error = function(e){
      print(e)
      showNotification("Sorry, your graph can not be displayed. The SIF file is empty or can not be extracted correctly.",
                       type = "error")
    })
    
    visNetwork(nodes, edges, width = "100%", directed = TRUE) %>%
      visEdges(arrows="to", smooth="false") %>%
      visGroups(groupname = "NProt", shape = "dot", color = "darkblue") %>%
      visGroups(groupname = "control", shape = "square", color = "purple") %>%
      visGroups(groupname = "chemical", shape = "dot", color = "grey") %>%
      visGroups(groupname = "state", shape = "dot", color = "darkred") %>%
      visGroups(groupname = "phospho", shape = "dot", color = "orange") %>%
      visGroups(groupname = "NSM", shape = "dot") %>%
      visLayout(randomSeed = 12) %>%
      visPhysics(enabled=FALSE) %>%
      visOptions(nodesIdSelection = TRUE, highlightNearest = list(enabled = T, degree = 1, hover = T))
  })
  
  
})
