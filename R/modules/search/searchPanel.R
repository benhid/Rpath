search.panel <-
  tabPanel("Search",
         fluidRow(
           column(3,
                  span("Search box:"),
                  wellPanel(
                    textInput("term", "Term:",
                              placeholder = "name:gl?coly*"),
                    helpText("Consider using a", a("Lucene query", href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html", target="_blank"),
                             "string. Here you have some ",
                             HTML('<a data-toggle="collapse" data-target="#ex">examples</a>.'),
                             tags$div(id = 'ex',  class="collapse",
                                      tags$li(a(id="example1","gly*",  `data-toggle`="tooltip", `data-placement`="right", title="Search in KEGGs all the pathways that start with gly- followed by whatever")),
                                      tags$li(a(id="example2", "met?b*",  `data-toggle`="tooltip", `data-placement`="right", title="Search in KEGGs all the pathways that start with met- followed by whatever")),
                                      tags$li(a(id="example3", "gluc*",`data-toggle`="tooltip", `data-placement`="right", title="Search in KEGGs all the pathways that start with gluc- followed by whatever"))
                             )
                    ),
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
