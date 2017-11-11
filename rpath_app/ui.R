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
               tabPanel("User Manual", navlistPanel(
                 "Index",
                 tabPanel("Introduction",  fluidRow( column(9,
                                                      span("What is it?")
                 ))),
                 tabPanel("Search",  fluidRow( column(9,
                                                      span("How to use?")
                 ))),
                 tabPanel("Viewer",  fluidRow( column(9,
                                                      span("How to paint a graph?")
                 ))
               )
    )

  )
)))