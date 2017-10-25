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
    
    # Page
    navbarPage(title="rPath",
               tabPanel("Search",
                        fluidRow(
                          column(3,
                                 wellPanel( # Search panel
                                   textInput("term", "Term:",
                                             placeholder = "name:gl?coly*"),
                                   helpText("Consider using a", a("Lucene query string", href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html", target="_blank")),
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
                                 )
                          ),
                          column(9,
                                 span("Search results:"),
                                 wellPanel(
                                   DT::dataTableOutput("searchResults")
                                 )
                                 #,
                                 #span("Selected:"),
                                 #wellPanel(
                                 #  verbatimTextOutput("selectedRow")
                                 #)
                          )
                        )),
               tabPanel("Visualization",
                        absolutePanel(class="controls panel panel-default draggable ui-draggable ui-draggable-handle", 
                                      style="background-color: white; padding: 0 20px 20px 20px; cursor: move;
                                      opacity: 0.65; zoom: 0.9; transition: opacity 500ms 1s;", fixed = TRUE,
                                      draggable = TRUE, top = 80, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h2("Example"),
                                      
                                      textInput("a", "A"),
                                      textInput("b", "B")
                        )),
               tabPanel("Analysis")
    )

  )
)