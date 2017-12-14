library(shiny)
library(DT)

shinyUI(
  fluidPage(theme = "css/bootstrap.min.css",
    # Scripts for background
    tags$script(src="js/particles.min.js"),
    tags$script("particlesJS.load('particles-js', 'js/particles.json', function() {
                  console.log('callback - particles.js config loaded');
                });"),
    tags$style(" #particles-js { 
               width: 100%; height: 100%; background-image: url(\"\"); 
               position: fixed; z-index: -10; top: 0; left: 0; }"),
    tags$div(id="particles-js"),
    tags$script(" $(document).ready(function(){$('[data-toggle=\"tooltip\"]').tooltip();}); "),
    
    # Page
    navbarPage(title="rPath",
               tabPanel("Search",
                        fluidRow(
                          column(3,
                                 wellPanel(
                                   textInput("term", "Term:",
                                             value = "name:gl?coly*"),
                                   helpText("Term can be a", a("Lucene query string", href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html", target="_blank")),
                                   helpText("You can copy and paste an ",
                                            HTML('<a data-toggle="collapse" data-target="#demo">example</a>'),
                                            tags$div(id = 'demo',  class="collapse",
                                                     tags$li(a(id="example1","gly*",  `data-toggle`="tooltip", `data-placement`="right", `title`="Search in KEGGs all the pathways that start with gly- followed by whatever")),
                                                     tags$li(a(id="example2", "met?b*",  `data-toggle`="tooltip", `data-placement`="right", `title`="Search in KEGGs all the pathways that start with met- followed by whatever")),
                                                     tags$li(a(id="example3", "gluc*",`data-toggle`="tooltip", `data-placement`="right", `title`="Search in KEGGs all the pathways that start with gluc- followed by whatever")),
                                                     verbatimTextOutput('summary'))),
                                   textInput("organism", "Organism",
                                             value = "9606"),
                                   helpText("e.g. \"homo sapiens\", \"9606\""),
                                   checkboxGroupInput("dataSources", "Data source:",
                                                      choices = c("KEGG" = "kegg",
                                                                  "WikiPathways" = "wp",
                                                                  "Reactome" = "reactome",
                                                                  "Panther" = "panther",
                                                                  "SMPDB" = "smpdb",
                                                                  "MSigDB" = "msigdb",
                                                                  "DrugBank" = "drugbank",
                                                                  "INOH" = "inoh"),
                                                      selected = c("kegg", "reactome", "panther", "inoh")),
                                   numericInput("numberOfResults", "No. of results:", 
                                                value = 10),
                                   helpText("Minimum 0, maximum 100"),    

                                   div(class="text-center", actionButton("searchButton", "Search", class="btn-primary"))
                                 ),
                                 wellPanel(
                                   fileInput("fileToUpload", "Or, alternativity, upload a file:",
                                             multiple = FALSE,
                                             accept = c(".owl")),
                                   div(class="text-center", actionButton("uploadButton", "Upload", class="btn-primary"))
                                 )
                          ),
                          column(9,
                                 span("Search results:"),
                                 wellPanel(
                                   DT::dataTableOutput("searchResults")
                                 ),
                                 span("Selected:"),
                                 wellPanel(
                                   verbatimTextOutput("selectedRow")
                                 )
                          )
                        )),
               tabPanel("tab2"),
               tabPanel("User Manual", 
                        navlistPanel("Table of contents", widths = c(3, 9),
                                     tabPanel("Introduction",  
                                               mainPanel(
                                                         h5("What's it?", span(class="label label-info", "Revisar texto en ingles")), 
                                                         p("This is a project of Estandares de Datos"),
                                                         h5("What's make?"), 
                                                         p("We have: "),
                                                         tags$p(span(class='glyphicon glyphicon-ok'),"Search section"),
                                                         tags$p(span(class='glyphicon glyphicon-ok'),"Visualization section"),
                                                         tags$p(span(class='glyphicon glyphicon-ok'),"Summary section")
                                                       )
                                              ),
                                     tabPanel("Search", 
                                              mainPanel(
                                                h5("How to use?", span(class="label label-info", "Corregir color")),
                                                p("In this section we can perform searches. We enter the term we want to search. 
                                                  If we don't have an exact term or we want searches for terms related to certain words, 
                                                  we include the following characters:?, *, knowns as wildcard search. So if we perform 
                                                  the default search we are really looking for:"),
                                                p(span(class="alert alert-info", "gl (one letter) coly * (any word = sis) ->? 
                                                  for a single character and * for 0 or more characters.")),
                                                img(src="search_term_examples.PNG", align = "center"),
                                                p("For more information you can consult Lucene query string. Some searches are included to 
                                                  copy and paste and view the functionality."),
                                                p("In the field Organism: we choose the organism on which we want to look for this term."),
                                                img(src="search_organism.PNG"),
                                                p("We can select the different BD in which we want to perform the search, although this is 
                                                  optional.And finally we can choose the number of results we want. This one goes from 0 to 100."),
                                                img(src="search_data_source_num_search.PNG"),
                                                p("The result of the search is shown in a table. In it we can see the name of the search term, 
                                                  the source in which it was searched, the number of participants in the reaction, the number 
                                                  of processes in which it is involved, the size of the reaction and a button to access the URI 
                                                  of the selected result"),
                                                img(src="search_results.PNG")
                                              )
                                     ),
                                             
                                     tabPanel("Visualization", 
                                              mainPanel(
                                                h5("How to use?", span(class="label label-info", "Falta TEXTO, IMG")), 
                                                p("txt"),
                                                p("txt")
                                                )
                                              ),
                                     tabPanel("Summary", 
                                              mainPanel(
                                                h5("How to use?", span(class="label label-info", "Falta TEXTO, IMG")), 
                                                p("txt"),
                                                p("txt")
                                              )
                                     )
               )
    )

  )
))
