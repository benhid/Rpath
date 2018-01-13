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
                                     tabPanel(tags$p(span(class='glyphicon glyphicon-list-alt'),"Introduction"),  
                                               mainPanel(
                                                         h4("What's it?", span(class="label label-info", "Revisar texto en ingles")), 
                                                         p("This is a project of Estandares de Datos"),
                                                         h4("What's make?"), 
                                                         p("We have:"),
                                                         tags$p(span(class='glyphicon glyphicon-ok'),"Search section", class="lead text-center"),
                                                         tags$p(span(class='glyphicon glyphicon-ok'),"Visualization section", class="lead text-center"),
                                                         tags$p(span(class='glyphicon glyphicon-ok'),"Summary section", class="lead text-center"), 
                                                         h4("Who are we?"), 
                                                         tags$table(
                                                           tags$tr(
                                                             tags$th('Name'),tags$th('Description'),tags$th('Email')),
                                                           tags$tr(
                                                             tags$td('Antonio Benitez Hidalgo'),tags$td(''),tags$td('antonio.b@uma.es')),
                                                           tags$tr(
                                                             tags$td('Cesar Lobato Fernandez'),tags$td(''),tags$td('ceslobfer95@gmail.com')),
                                                           tags$tr(
                                                             tags$td('Daniel Torres Ramirez'),tags$td(''),tags$td()),
                                                           tags$tr(
                                                             tags$td('Maria Jose Munoz Gonzalez'),tags$td(''),tags$td('marmungon@uma.es')),
                                                           class="table table-striped",
                                                           width = 12
                                                         ),
                                                         width = 12
                                                       )
                                              ),
                                     tabPanel(tags$p(span(class='glyphicon glyphicon-search'),"Search"), 
                                              mainPanel(
                                                h4("How to use?", span(class="label label-info",`background-color`= "#ffff", "Corregir color")),
                                                p("In this section we can perform searches. We enter the term we want to search. 
                                                  If we don't have an exact term or we want searches for terms related to certain words, 
                                                  we include the following characters:?, *, knowns as wildcard search. So if we perform 
                                                  the default search we are really looking for:"),
                                                
                                                p(strong("gl (one letter) coly * (any word = sis) ->? 
                                                  for a single character and * for 0 or more characters."), class= "text-center"),
                                                
                                                #HTML('<center><img src="search_term_examples.PNG"></center>'),
                                                img(src="search_term_examples.PNG", class="img-responsive center-block manualR"),
                                                p("For more information you can consult Lucene query string. Some searches are included to 
                                                  copy and paste and view the functionality."),
                                                p("In the field Organism: we choose the organism on which we want to look for this term."),
                                                #HTML('<center><img src="search_organism.PNG"></center>'),
                                                img(src="search_organism.PNG", class="img-responsive center-block manualR"),
                                                p("We can select the different BD in which we want to perform the search, although this is 
                                                  optional.And finally we can choose the number of results we want. This one goes from 0 to 100."),
                                                #HTML('<center><img src="search_data_source_num_search.PNG"></center>'),
                                                img(src="search_data_source_num_search.PNG", class="img-responsive center-block manualR"),
                                                p("The result of the search is shown in a table. In it we can see the name of the search term, 
                                                  the source in which it was searched, the number of participants in the reaction, the number 
                                                  of processes in which it is involved, the size of the reaction and a button to access the URI 
                                                  of the selected result"),
                                                #HTML('<center><img src="search_results.PNG"></center>')
                                                img(src="search_results.PNG", class="img-responsive center-block manualR"),
                                                width = 12
                                                
                                              )
                                     ),
                                             
                                     tabPanel(tags$p(span(class='glyphicon glyphicon-picture'),"Graphs"), 
                                              mainPanel(
                                                h4("How to use?", span(class="label label-info", "Falta TEXTO, IMG")), 
                                                p("txt"),
                                                p("Hola, esta es la parte de visualizacion de grafos"),
                                                tags$table(
                                                  tags$tr(
                                                    tags$th('Name of interaction'),tags$th('Description'),tags$th('Image')),
                                                  tags$tr(
                                                    tags$td('In-complex-with'),tags$td('ComponentA is in complex with ComponentB'),tags$td(img(src="graph_A_in_complex_with_B.PNG", class="img-responsive center-block manualR"))),
                                                  tags$tr(
                                                    tags$td('Interacts-with'),tags$td('ComponentA interacts with ComponentB'),tags$td(img(src="graph_A_interacts_with_B.PNG", class="img-responsive center-block manualR"))),
                                                  tags$tr(
                                                    tags$td('Control-of-expression'),tags$td('ComponentA control the expression of ComponentB'),tags$td(img(src="graph_A_control_expression_of_B.PNG", class="img-responsive center-block manualR"))),
                                                  tags$tr(
                                                    tags$td('Control-of-fosforilation'),tags$td('ComponentA control the fosforilation of ComponentB'),tags$td(img(src="graph_A_control_of_fosforilation_of_B.PNG", class="img-responsive center-block manualR"))),
                                                  tags$tr(
                                                    tags$td('Control-state-change'),tags$td('ComponentA control the state change of ComponentB'),tags$td(img(src="graph_A_control_state_change_of_B.PNG", class="img-responsive center-block manualR"))),
                                                 
                                                   class="table table-hover"), width = 12

                                                ),
                                              width = 12
                                              
                                              ),
                                     tabPanel(tags$p(span(class='glyphicon glyphicon-list'),"Data Summarization"), 
                                              mainPanel(
                                                h4("How to use?", span(class="label label-info", "Revisar Ingles, IMG")), 
                                                p("If we don't select any pathway we can't see any information. So the first step is go to the
                                                  Search tab and do one search."),
                                                #falta imagen inicial sin nada en la pestana Data summarization
                                                p("Once time selected the pathway in Search tab, we choose the Select button."), 
                                                img(src="data_search_select_first_part.PNG", class="img-responsive center-block manualR"),
                                                img(src="data_select.PNG", class="img-responsive center-block manualR"),
                                                p("In the lower part we see
                                                  a table where we can see the nodes that interact and the interaction between them. Under the table 
                                                  we can change the page so we can see the other interactions."),
                                                img(src="data_tab_reactions.PNG", class="img-responsive center-block manualR"),
                                                p("Afterwards, we go to the Data Summarization tab and choose the type. Depending on the selected type,
                                                  we will obtain one information or another. We can download the file directly to our computer. It is download 
                                                  with the name data-date_of_download and the format is .owl."),
                                                #falta imagen download
                                                p("We can also obtain information from the reaction participants by clicking on the leftReference and the 
                                                  rightReference. This brings us www.ebi.ac.uk/chebi/."),
                                                img(src="data_search_select_table_reactions.PNG", class="img-responsive center-block manualR"),
                                                p("We can make a search about one term. For example : we are a lot of results and we can search only the results
                                                  that contain the word UTP. If we delete the word write, we return to the previous table."),
                                                img(src="data_filter_data_summary.PNG", class="img-responsive center-block manualR"),
                                                width = 12
                                                
                                                
                                              )
                                     )
               )
    )

  )
))
