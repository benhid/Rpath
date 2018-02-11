library(shiny)
library(plyr)
library(stringr)

app.server <- shinyServer(function(input, output) {
  
  # Search module
  source('modules/search/search.R', local = TRUE)
  
  output$searchResults <-  renderDataTable({
    return(getResultsDf())
  }, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )
  
  output$selectedRow <- renderPrint(
    getRowFromDf()
  )
  
  # Data summarization module
  source('modules/data_summary/analysis.R', local = TRUE)

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
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('data-', Sys.Date(), '.owl', sep='')
    },
    content = function(file) {
      a <- saveXML(GetOwl(), file)
    }
  )
  
  observe({
    # While you didn`t press the search button the button "Select" will be hide`
    hide("Plotme")
    observeEvent(input$searchButton, {
      shinyjs::show("Plotme")
    })
  })
  
  ExtractSif <- eventReactive(input$Plotme,{
    # When you press the select button you are going to extract the sif file from the the row selected
    if(is.null(input$Plotme)){
      stop()
    }else{
      return(Sif())
    }
  })
  
  output$Summary <-  renderDataTable({
    return(ExtractSif())
  }, options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE), escape=FALSE, selection = 'single'
  )

  # Visualization module
  observeEvent(input$buttonGraph, {
    tryCatch({
      sif<-toSif(GetOwl())
    },error = function(e){
      showNotification("Sorry, your graph can not be displayed. The sif file is empty or can not be extracted correctly.",
                       type = "error")
    })
   
    tryCatch({
      insertUI(
        selector = "#graph",
        where = "afterEnd",
        ui = tags$div(id="graph" ,class = "paintGraph")
      )
      links<-parseSifToDataModel(sif)
      js$paintGraph(links)
      showNotification("Graph displayed")
    }, warning = function(w) {
      warning-handler-code
    }, error = function(e) {
      tryCatch({ js$paintBinaryGraph(sif)
        showNotification("We continue working on the visualization of graphs. 
                         The current graph is represented directly from the binary file.
                         We hope to show you the rendered graph as soon as possible. Thanks for using Rpath.", duration = 10, 
                         type = "warning")}
        ,error=function(e){
          
        })
    })
  })
  
  observeEvent(input$deleteGraph, {
    removeUI(
      selector = "div#graph"
    )
  })

})