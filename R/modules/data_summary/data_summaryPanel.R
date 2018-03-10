source('modules/data_summary/queries.R', local = TRUE)

analysis.panel <-
  tabPanel(title = "Data Summarization", value = "analysisTab",
         fluidRow(
           column(12,
                  tabsetPanel(type = "tabs",
                              tabPanel("Summary",
                                       wellPanel(
                                         actionButton("showSIFFButton", "Show SIF", class="btn-primary"),
                                         downloadButton('downloadSIFF', 'Download SIF')
                                       ),
                                       wellPanel(
                                         dataTableOutput("pathwaySummary")
                                       )),
                              tabPanel("Example queries",
                                       wellPanel(
                                         selectInput(inputId = "exampleQuery",
                                                     label = "Choose a pre-defined query:",
                                                     choices = c("Biochemical Reaction",
                                                                 "Catalysis",
                                                                 "Control",
                                                                 "Modulation",
                                                                 "Template Reaction",
                                                                 "Degradation",
                                                                 "Template Reaction Regulation"))
                                       ),
                                       wellPanel(
                                         dataTableOutput("queryResult")
                                       )),
                              tabPanel("Custom query",
                                       wellPanel(
                                         textInput("customEndpoint", "Endpoint:", value = "http://rdf.pathwaycommons.org/sparql/"),
                                         textAreaInput("customQuery", "Custom SPARQL query:", value = query.custom),
                                         actionButton("queryButton", "Perform custom query", class="btn-primary")
                                       ),
                                       wellPanel(
                                         dataTableOutput("customQueryDf")
                                       ))
                              )
           )
         )
  )
