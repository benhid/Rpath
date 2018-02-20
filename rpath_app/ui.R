library(shiny)
library(DT)
library(shinyjs)
library(shinydashboard)
library(rlist)
library(V8)
source("FinalParseSif.R")
jsCode1 <- readLines("www/graph.js",180)
jsCode2 <- readLines("www/js/binaryGraph.js", 95)
code1 = ""
code2 = ""

for(i in 1:180){
  code1 = paste(code1,jsCode1[i], sep= '\n')
}
for(i in 1:95){
  code2 = paste(code2,jsCode2[i], sep= '\n')
}
shinyUI(
  
  fluidPage(theme = "css/bootstrap.min.css",
    tags$head( includeScript("https://d3js.org/d3.v3.min.js") ),
    useShinyjs(),
    extendShinyjs(text = code1),
    extendShinyjs(text = code2),
    tags$script(src="https://use.fontawesome.com/0e40b7473a.js"),
    # Bootstrap.js
    tags$script(src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"),
    tags$script("$(document).ready(function() { $(\"body\").tooltip({ selector: '[data-toggle=tooltip]' });});"),
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
    useShinyjs(),
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
                          ),
                          column(9,
                                 span("Search results:"),
                                 wellPanel(
                                   DT::dataTableOutput("searchResults")
                                 ),
                                 div(style="display:inline-block", actionButton("Plotme", "Select"), width=10),
                                 DT::dataTableOutput("Summary")
                          )
                        )),
               tabPanel("Visualization",
                        actionButton("buttonGraph", "VISUALIZATION GRAPH"),
                        tags$div(id="graph" ,class = "paintGraph"),
                        actionButton("deleteGraph","DeleteGraph")
               ),
               tabPanel(title = "Data Summarization", value = "dataTab",
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
                          column(12,
                            wellPanel(
                              DT::dataTableOutput("table")
                            )
                          )
                        )
               ),
              tabPanel("User Manual", 
                      navlistPanel("Table of contents", widths = c(3, 9),
                                   tabPanel(tags$p(span(class='glyphicon glyphicon-list-alt'),"Introduction"),  
                                     mainPanel(
                                       h4("What's it?"), 
                                       p("Rpath is a project of 'Estandares de datos y algoritmos' of fourth of 'Ingenieria de la Salud'.
                                        Specific subject of Bioinformatic of Malaga University."),
                                       h4("What's make?"), 
                                       p("We have:"), 
                                       tags$p(span(class='glyphicon glyphicon-ok'),strong("Search section"),span(class='glyphicon glyphicon-arrow-right'), "Responsible for allowing the search of the metabolic path through different data sources."),
                                       tags$p(span(class='glyphicon glyphicon-ok'),strong("Visualization section"), span(class='glyphicon glyphicon-arrow-right'), "Responsible for graphically representing the route as a directed graph."),
                                       tags$p(span(class='glyphicon glyphicon-ok'),strong("Data summarization section"), span(class='glyphicon glyphicon-arrow-right'), "Responsible for carrying out an analysis of the components of the route and showing the user its most characteristic elements."), 
                                       h4("Who are we?"), 
                                       tags$table(
                                         tags$tr(
                                           tags$th('Name'),tags$th('Email')),
                                         tags$tr(
                                           tags$td('Antonio Benitez Hidalgo'),tags$td('antonio.benitez@lcc.uma.es')),
                                         tags$tr(
                                           tags$td('Cesar Lobato Fernandez'),tags$td('ceslobfer95@uma.es')),
                                         tags$tr(
                                           tags$td('Daniel Torres Ramirez'),tags$td('dantorram@uma.es')),
                                         tags$tr(
                                           tags$td('Maria Jose Munoz Gonzalez'),tags$td('marmungon@uma.es')),
                                         class="table table-striped",
                                         width = 12
                                       ),
                                       width = 12
                                     )
                                   ),
                                   tabPanel(tags$p(span(class='glyphicon glyphicon-search'),"Search"), 
                                    mainPanel(
                                      h4("How to use?"),
                                      p("In this section we can perform searches. We enter the term we want to search. 
                                        If we don't have an exact term or we want searches for terms related to certain words, 
                                        we include the following characters:?, *, knowns as wildcard search. So if we perform 
                                        the default search we are really looking for:"),
                                      
                                      p(strong("gl (one letter) coly * (any word = sis) ->? 
                                        for a single character and * for 0 or more characters."), class= "text-center"),
                                      
                                      img(src="search_term_examples.PNG", class="img-responsive center-block manualR"),
                                      p("For more information you can consult", 
                                          a("Lucene query string.", href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html", target="_blank"), 
                                          "Some searches are included to copy and paste and view the functionality."),
                                      p("In the field Organism: we choose the organism on which we want to look for this term."),
                                      img(src="search_organism.PNG", class="img-responsive center-block manualR"),
                                      p("We can select the different BD in which we want to perform the search, although this is 
                                        optional.And finally we can choose the number of results we want. This one goes from 0 to 100."),
                                      img(src="search_data_source_num_search.PNG", class="img-responsive center-block manualR"),
                                      p("The result of the search is shown in a table. In it we can see the name of the search term, 
                                        the source in which it was searched, the number of participants in the reaction, the number 
                                        of processes in which it is involved, the size of the reaction and a button to access the URI 
                                        of the selected result"),
                                      img(src="search_results.PNG", class="img-responsive center-block manualR"),
                                      width = 12
                                    )
                                   ),
                                           
                                   tabPanel(tags$p(span(class='glyphicon glyphicon-picture'),"Visualization"), 
                                    mainPanel(
                                      h4("How to use?"), 
                                      p("If we don't select any pathway we can't see any information. So the first step is go to the",em("Search tab")," and do one search."),
                                      p("Once time selected the pathway in Search tab, we choose the", em("VISUALIZATION GRAPH"),"button in this tab."),
                                      img(src="graph_first_image.PNG", class="img-responsive center-block manualR"),
                                      p("And we obtain the graph:"),
                                      img(src="graph_visualization.PNG", class="img-responsive center-block manualR"),
                                      p(em("If you click once on any node, the node is fixed at that point. And if you double-click on the node, it becomes mobile again.")),
                                      p("For not see the graph, we selec the", em("DELETE GRAPH"), "button."),
                                      p("If the graph can't play display, a message will appear:"),
                                      img(src="graph_error.PNG", class="img-responsive center-block manualR"),
                                      p("Before the failure of some element that can not be processed as standard of the sif format, 
                                        it will paint a graph with binary relations of the sif."),
                                      h4("Type of relations"),
                                      tags$table(
                                        tags$tr(
                                          tags$th('Name of interaction'),tags$th('Description'),tags$th('Image')),
                                        tags$tr(
                                          tags$td('In-complex-with'),
                                          tags$td('ComponentA is in complex with ComponentB. So, they are members og the same complex.'),
                                          tags$td(img(src="graph_A_in_complex_with_B.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td('Interacts-with'),
                                          tags$td('ComponentA interacts with ComponentB. So, they are participants of the same interaction.'),
                                          tags$td(img(src="graph_A_interacts_with_B.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td('Control-of-expression'),
                                          tags$td('ComponentA control the expression of ComponentB.'),
                                          tags$td(img(src="graph_A_control_expression_of_B.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td('Control-of-fosforilation'),
                                          tags$td('ComponentA control the fosforilation of ComponentB.'),
                                          tags$td(img(src="graph_A_control_of_fosforilation_of_B.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td('Control-state-change'),
                                          tags$td('ComponentA control the state change of ComponentB.'),
                                          tags$td(img(src="graph_A_control_state_change_of_B.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td(p('Consumption-controlled-by'), p('Controls-production-of')),
                                          tags$td(p('The ComponentA (smallMolecule) is consumed by a reaction that is controled by a protein.'),
                                                  p('The protein controls a reaction of which the ComponentA is an output.')),
                                          tags$td(img(src="graph_A_two_relations_B_C_compuesto.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td('Chemical-affects'),
                                          tags$td('ComponentA (smallMolecule) has an effect on the ComponentB'),
                                          tags$td(img(src="graph_A_chemical_affects_B.PNG", class="img-responsive center-block manualR"))),
                                        tags$tr(
                                          tags$td('Neighbor-of'),
                                          tags$td('ProteinA is neighbor of ProteinB and they are participants / controllers of same interaction.'),
                                          tags$td(img(src="graph_A_neighbor_B.PNG", class="img-responsive center-block manualR"))),
                                                                                    class="table table-hover"), width = 12
                                      ),
                                    width = 12
                                    ),
                                   tabPanel(tags$p(span(class='glyphicon glyphicon-list'),"Data Summarization"), 
                                            mainPanel(
                                              h4("How to use?"), 
                                              p("If we don't select any pathway we can't see any information. So the first step is go to the
                                                Search tab and do one search."),
                                              p("Once time selected the pathway in Search tab, we choose the Select button."), 
                                              img(src="data_search_select_first_part.PNG", class="img-responsive center-block manualR"),
                                              img(src="data_select.PNG", class="img-responsive center-block manualR"),
                                              p("If the path can't play display, a message will appear:"),
                                              img(src="data_error.PNG", class="img-responsive center-block manualR"),
                                              p("In the lower part we see
                                                a table where we can see the nodes that interact and the interaction between them. Under the table 
                                                we can change the page so we can see the other interactions."),
                                              img(src="data_tab_reactions.PNG", class="img-responsive center-block manualR"),
                                              p("Afterwards, we go to the Data Summarization tab and choose the type. Depending on the selected type,
                                                we will obtain one information or another. We can download the file directly to our computer. It is download 
                                                with the name",  em("data-date_of_download"), "and the format is",  em(".owl.")),
                                              img(src="data_data_summary.PNG", class="img-responsive center-block manualR"),                                                
                                              p("We can also obtain information from the reaction participants by clicking on the", em("leftReference"), "and the", 
                                                em("rightReference"), "This brings us (in this example)",
                                                a("chEBI.", href="https://www.ebi.ac.uk/chebi/", target="_blank")
                                                ),
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
    
      )
)
