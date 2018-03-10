search.panel <-
  tabPanel("Search",
         fluidRow(
           column(3,
                  span("Search box:"),
                  wellPanel(
                    textInput("term", "Term:",
                              placeholder = "name:gl?coly*"),
                    helpText("Consider using a", a("Lucene query", href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html", target="_blank")),
                    textInput("organism", "Organism",
                              placeholder = "9606"),
                    helpText("e.g. \"homo sapiens\", \"9606\""),
                    checkboxGroupInput("dataSources", "Data source:",
                                       choices = c("KEGG" = "kegg",
                                                   #"WikiPathways" = "wp",
                                                   "Reactome" = "reactome",
                                                   "Panther" = "panther",
                                                   "INOH" = "inoh"),
                                       selected = c("kegg", "reactome", "panther", "inoh")),
                    numericInput("numberOfResults", "No. of results:",
                                 value = 10),
                    helpText("Minimum 0, maximum 100"),
                    div(class="text-center", actionButton("searchButton", "Search", class="btn-primary"))
                  )
                  #,
                  #wellPanel(
                  #  fileInput("owlFile", "Or upload your own OWL file:",
                  #            multiple = FALSE,
                  #            placeholder = "  Select file",
                  #            accept = c(".owl")),
                  #  div(class="text-center", actionButton("uploadButton", "Upload", class="btn-primary"))
                  #)
           ),
           column(9,
                  span("Search results:"),
                  wellPanel(
                    dataTableOutput("searchResults"),
                    tableOutput('contents')
                  ),
                  downloadButton('downloadOWL', 'Download'),
                  dataTableOutput("Summary")
           )
         )
  )
