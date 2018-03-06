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