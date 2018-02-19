app.server <- shinyServer(function(input, output) {

  observe({
    # Hide at start-up
    if(length(input$searchResults_rows_selected) > 0){
      shinyjs::removeClass(selector = ".navbar li a[data-value=visTab]", class = "disabledTab")
      shinyjs::removeClass(selector = ".navbar li a[data-value=analysisTab]", class = "disabledTab")
      shinyjs::show("downloadOWL")
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
      paste('data-', Sys.Date(), '.owl', sep='')
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
  observeEvent(input$buttonGraph, {
    tryCatch({
      # Extract SIF from OWL
      owl <- getRowFromDf()
      print(owl)

      # Convert a BioPAX OWL file to a binary SIF file
      sif <- toSif(owl)
    }, error = function(e){
      showNotification("Sorry, your graph can not be displayed. The sif file is empty or can not be extracted correctly.",
                       type = "error")
    })

    tryCatch({
      insertUI(
        selector = "#graph",
        where = "afterEnd",
        ui = tags$div(id="graph", class = "paintGraph")
      )

      # Paint graph
      links <- parseSifToDataModel(sif)
      js$paintGraph(links)

      showNotification("Graph displayed")
    }, warning = function(w) {
      warning-handler-code
    }, error = function(e) {
      tryCatch({
        # Paint graph
        js$paintBinaryGraph(sif)

        showNotification("We continue working on the visualization of graphs.
                         The current graph is represented directly from the binary file.
                         We hope to show you the rendered graph as soon as possible. Thanks for using Rpath.", duration = 10,
                         type = "warning")
        } ,error=function(e){})
    })
  })

  observeEvent(input$deleteGraph, {
    removeUI(
      selector = "div#graph"
    )
  })

})
