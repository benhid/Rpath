app.server <- shinyServer(function(input, output) {

  # Load helper
  source('modules/modules.R', local = TRUE)
  
  observe({
    # Hide at start-up
    if(length(input$searchResults_rows_selected) > 0){
      if (finalSearchResultsDf$numParticipants[input$searchResults_rows_selected] == 0){
        for(m in modules.hidden.tabs){
          shinyjs::addClass(selector = paste(".navbar li a[data-value=", m, "]", sep=''), class = "disabledTab")
        }
        showNotification("The selected path is empty (no participants!); please, select another one", type="error")
      } else{
        for(m in modules.hidden.tabs){
          shinyjs::removeClass(selector = paste(".navbar li a[data-value=", m, "]", sep=''), class = "disabledTab")
        }
        shinyjs::show("downloadOWL")
      }
    } else if (!is.null(input$owlFile)){
      for(m in modules.hidden.tabs){
        shinyjs::removeClass(selector = paste(".navbar li a[data-value=", m, "]", sep=''), class = "disabledTab")
      }
    } else{
      for(m in modules.hidden.tabs){
        shinyjs::addClass(selector = paste(".navbar li a[data-value=", m, "]", sep=''), class = "disabledTab")
      }
      shinyjs::hide("downloadOWL")
    }
  })

  # Load modules
  for(m in modules.tabs){
    print(paste("Loading server module: ", m, sep=''))
    source(paste("modules/", m, "/", m, ".R", sep=''), local = TRUE)
  }

})
