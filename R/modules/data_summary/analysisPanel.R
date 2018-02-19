analysis.panel <-
  tabPanel(title = "Data Summarization", value = "analysisTab",
         fluidRow(
           column(12,
                  tabsetPanel(type = "tabs",
                              tabPanel("Summary",
                                       wellPanel(
                                         actionButton("showSIFFButton", "Show SIF", class="btn-primary")
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
                                         textAreaInput("customQuery", "Custom SPARQL query:",
                                                       value="SELECT ?name, ?organism WHERE {
 %s rdf:type bp:Pathway .
 ?pathway bp:pathwayComponent ?c .
 ?pathway bp:organism ?organism .
 ?c bp:name ?name .
 ?c rdf:type bp:BiochemicalReaction
} LIMIT 20"),
                                         actionButton("queryButton", "Perform custom query", class="btn-primary")
                                       ),
                                       wellPanel(
                                         dataTableOutput("customQueryDf")
                                       ))
                              )
           )
         )
  )
