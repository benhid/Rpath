library(shiny)
library(DT)
library(shinyjs)
library(shinydashboard)
shinyUI(
  
  fluidPage(theme = "css/bootstrap.min.css",
            tags$script(src="https://use.fontawesome.com/0e40b7473a.js"),
            # Bootstrap.js
            tags$script(src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"),
            # Scripts for background
            tags$script(src="js/particles.min.js"),
            tags$script("particlesJS.load('particles-js', 'js/particles.json', function() {
                        console.log('callback - particles.js config loaded');
                        });"),
    tags$style(" #particles-js { 
               width: 100%; height: 100%; background-image: url(\"\"); 
               position: fixed; z-index: -10; top: 0; left: 0; }"),
    tags$div(id="particles-js"),
    # Script for tooltip
    tags$script("$(document).ready(function() { $(\"body\").tooltip({ selector: '[data-toggle=tooltip]' });});"),
    
    # Page
    navbarPage(title="rPath",
               tabPanel("Search",
                        fluidRow(
                          column(3,
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
                                 #wellPanel(
                                 # fileInput("fileToUpload", "Or, alternativity, upload a file:",
                                 #           multiple = FALSE,
                                 #           accept = c(".owl")),
                                 # div(class="text-center", actionButton("uploadButton", "Upload", class="btn-primary"))
                                 #)
                          ),
                          column(9,
                                 span("Search results:"),
                                 wellPanel(
                                   DT::dataTableOutput("searchResults")
                                 ),
                                 span("Selected:"),
                                 wellPanel(
                                   verbatimTextOutput("selectedRow")
                                 ),
                                 useShinyjs(),
                                 
                                 #actionButton("Plotme", "Select"),
                                 div(style="display:inline-block",actionButton("Plotme", "Select"),width=10),
                                
                                 
                                 
                                 DT::dataTableOutput("Summary")
                                 
                                 
                                 
                                 
                                 
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
               tabPanel("Data Summarization",
                        
                        sidebarPanel(
                          
                          # Input: Text for providing a caption ----
                          # Note: Changes made to the caption in the textInput control
                          # are updated in the output area immediately as you type
                          
                          
                          # Input: Selector for choosing dataset ----
                          selectInput(inputId = "dataset",
                                      label = "Choose a type:",
                                      choices = c("Biochemical Reaction", "Catalysis", "Control","Modulation","Template Reaction","Degradation","Template Reaction Regulation")),
                          downloadButton('downloadData', 'Download')
                          # Input: Numeric entry for number of obs to view ----
     
                        ),
                        
                        fluidRow(
                          DT::dataTableOutput("table")
                        )
                        
                        
                        
                        ),
                        
               

               tabPanel("User Manual")
    )
    
  )
)