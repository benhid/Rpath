analysis.panel <-
  tabPanel(title = "Data Summarization", value = "analysisTab",
          fluidRow(
            column(4,
              wellPanel(
               selectInput(inputId = "exampleQuery",
                           label = "Choose a pre-defined query:",
                           choices = c("Biochemical Reaction",
                                       "Catalysis",
                                       "Control",
                                       "Modulation",
                                       "Template Reaction",
                                       "Degradation",
                                       "Template Reaction Regulation")),
               actionButton("showSIFFButton", "Show SIF", class="btn-primary")
             )
            ),
            column(8,
              wellPanel(
                   textAreaInput("customQuery", "Custom SPARQL query:",
                                 value="select ?Provenance where {?Provenance a bp:Provenance}"),
                   actionButton("queryButton", "Perform custom query", class="btn-primary")
              )
            )
         ),
         fluidRow(
           column(12,
                  wellPanel(
                    dataTableOutput("customQueryDf")
                  ),
                  wellPanel(
                    dataTableOutput("pathwaySummary")
                  ),
                  wellPanel(
                    dataTableOutput("queryResult")
                  )
           )
         )
  )
