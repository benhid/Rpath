user.panel <-
  tabPanel("User Manual",
         navlistPanel("Table of contents", widths = c(3, 9),
                      tabPanel(tags$p(span(class='glyphicon glyphicon-list-alt')," About RPath"),
                               mainPanel(
                                 wellPanel(
                                   h4("What's RPath?"),
                                   p("RPath is a shiny application for biologic pathway exploration.

                                     Shiny is an R package used to build web applications with R. A user opens the app on their browser, specifies a given set of inputs, these
                                     are transmitted to an R session where some code is evaluated and output is produced and transmitted
                                     back to the browser."),
                                   h4("Modules"),
                                   p("RPath consists of 4 modules:"),
                                   tags$ul(
                                     tags$li(
                                       strong("Search module."),
                                       "Responsible for allowing the search of the biologic pathway through different data sources."
                                     ),
                                     tags$li(
                                       strong("Visualization module."),
                                       "Responsible for graphically representing the newtork."
                                     ),
                                     tags$li(
                                       strong("Data summarization (or analysis) module."),
                                       "Responsible for carrying out an analysis of the components of the route and showing the user its most characteristic elements."
                                     )
                                   ),
                                   h4("Development team"),
                                   p("Active development team:"),
                                   tags$table(
                                     tags$tr(tags$th('Name'),tags$th('Email')),
                                     tags$tr(tags$td('Antonio Benítez Hidalgo'),tags$td('antonio.benitez@lcc.uma.es')),
                                     tags$tr(tags$td('Cesar Lobato Fernandez'),tags$td('ceslobfer95@uma.es')),
                                     class="table table-striped",
                                     width = 12
                                   ),
                                   p("Thanks to:"),
                                   tags$table(
                                     tags$tr(tags$th('Name'),tags$th('Email')),
                                     tags$tr(tags$td('Daniel Torres Ramirez'),tags$td('dantorram@uma.es')),
                                     tags$tr(tags$td('Maria José Muñoz Gonzalez'),tags$td('marmungon@uma.es')),
                                     class="table table-striped",
                                     width = 12
                                   )
                                )
                               )
                      ),
                      tabPanel(tags$p(span(class='glyphicon glyphicon-search')," Search module"),
                               mainPanel(
                                 wellPanel(
                                   h4("Searching on Pathway Commons"),
                                   p("RPath has a build-in search engine. We can perform searches across multiple databases
                                     using Pathway Commons' API (a member within the BioPAX community aimed at collecting biological pathway data represented in the BioPAX standard).
                                     Search term supports Lucene query syntax, making easy to search for pathways related to certain words."),
                                   p("For example, we can include the '?' or '*' characters to search for pathways whose name start with
                                     'gl' followed by a character + 'coly' followed by any word:"),
                                   img(src="img/usermanual/search_term_examples.PNG", class="img-responsive center-block manualR"),
                                   p("For more information about Lucene query syntax refer to the ",
                                     a("official documentation", href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html", target="_blank"),
                                     "."),
                                   p("In the Organism field we can type the organism on which we want to get the pathway for:"),
                                   img(src="img/usermanual/search_organism.PNG", class="img-responsive center-block manualR"),
                                   p("We can also specify on which database(s) we want to perform the search on (default is 'Reactome') along with
                                     the numbers of results we want to get:"),
                                   img(src="img/usermanual/search_data_source_num_search.PNG", class="img-responsive center-block manualR"),
                                   p("The results will be shown in a table:"),
                                   img(src="img/usermanual/search_results.PNG", class="img-responsive center-block manualR"),
                                   p("After selecting one row, you will be able to download the pathway in .OWL format (BioPAX standard) by pressing the button 'Download OWL'.")
                               ))
                      ),
                      tabPanel(tags$p(span(class='glyphicon glyphicon-list')," Data Summarization"),
                               mainPanel(
                                 h4("Exploring the pathway"),
                                 p("Note that this panel is only accesible after selecting a pathway."),
                                 p("This module allow us to explore every single component of the pathway using SPARQL queries."),
                                 p("With SPARQL, we are able to query data stored in Pathway Commons without storing on our local machines using Pathway Commons' endpoint and
                                   perform complex queries which involves several databases."),
                                 img(src="img/usermanual/data_tabs.PNG", class="img-responsive center-block manualR"),
                                 p("On the first tab (", em("Summary"), ") we can download (or show) the Simple Interaction Format file (SIF) directly to our computer. It contains pairwise
                                   interactions between physical entities of our pathway. This format was first stablished by Cytoscape, a bioinformatics tool for pathway visualization."),
                                 img(src="img/usermanual/data_tab_reactions.PNG", class="img-responsive center-block manualR"),
                                 p("On the second tab (", em("Example queries"), ") there are six different queries which gives information about, for example,
                                   the biochemical reactions that takes place on our pathway."),
                                 img(src="img/usermanual/data_example_bioreac.PNG", class="img-responsive center-block manualR"),
                                 p("The last tab (", em("Custom query"), ") allow scientists to compose their custom query. Note that the string '%s' will be replaced with the
                                   identifier (URI) of the selected pathway."),
                                 img(src="img/usermanual/data_custom_query.PNG", class="img-responsive center-block manualR")
                               )
                      ),
                      tabPanel(tags$p(span(class='glyphicon glyphicon-picture')," Visualization"),
                               mainPanel(
                                 h4("How to use?"),
                                 p("If we don't select any pathway we can't see any information. So the first step is go to the",em("Search tab")," and do one search."),
                                 p("Once time selected the pathway in Search tab, we choose the", em("VISUALIZATION GRAPH"),"button in this tab."),
                                 img(src="img/usermanual/graph_first_image.PNG", class="img-responsive center-block manualR"),
                                 p("And we obtain the graph:"),
                                 img(src="img/usermanual/graph_visualization.PNG", class="img-responsive center-block manualR"),
                                 p(em("If you click once on any node, the node is fixed at that point. And if you double-click on the node, it becomes mobile again.")),
                                 p("For not see the graph, we selec the", em("DELETE GRAPH"), "button."),
                                 p("If the graph can't play display, a message will appear:"),
                                 img(src="img/usermanual/graph_error.PNG", class="img-responsive center-block manualR"),
                                 p("Before the failure of some element that can not be processed as standard of the sif format,
                                   it will paint a graph with binary relations of the sif."),
                                 h4("Type of relations"),
                                 tags$table(
                                   tags$tr(
                                     tags$th('Name of interaction'),tags$th('Description'),tags$th('Image')),
                                   tags$tr(
                                     tags$td('In-complex-with'),
                                     tags$td('ComponentA is in complex with ComponentB. So, they are members og the same complex.'),
                                     tags$td(img(src="img/usermanual/graph_A_in_complex_with_B.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td('Interacts-with'),
                                     tags$td('ComponentA interacts with ComponentB. So, they are participants of the same interaction.'),
                                     tags$td(img(src="img/usermanual/graph_A_interacts_with_B.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td('Control-of-expression'),
                                     tags$td('ComponentA control the expression of ComponentB.'),
                                     tags$td(img(src="img/usermanual/graph_A_control_expression_of_B.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td('Control-of-fosforilation'),
                                     tags$td('ComponentA control the fosforilation of ComponentB.'),
                                     tags$td(img(src="img/usermanual/graph_A_control_of_fosforilation_of_B.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td('Control-state-change'),
                                     tags$td('ComponentA control the state change of ComponentB.'),
                                     tags$td(img(src="img/usermanual/graph_A_control_state_change_of_B.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td(p('Consumption-controlled-by'), p('Controls-production-of')),
                                     tags$td(p('The ComponentA (smallMolecule) is consumed by a reaction that is controled by a protein.'),
                                             p('The protein controls a reaction of which the ComponentA is an output.')),
                                     tags$td(img(src="img/usermanual/graph_A_two_relations_B_C_compuesto.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td('Chemical-affects'),
                                     tags$td('ComponentA (smallMolecule) has an effect on the ComponentB'),
                                     tags$td(img(src="img/usermanual/graph_A_chemical_affects_B.PNG", class="img-responsive center-block manualR"))),
                                   tags$tr(
                                     tags$td('Neighbor-of'),
                                     tags$td('ProteinA is neighbor of ProteinB and they are participants / controllers of same interaction.'),
                                     tags$td(img(src="img/usermanual/graph_A_neighbor_B.PNG", class="img-responsive center-block manualR"))),
                                   class="table table-hover"), width = 12
                                 ),
                               width = 12
                      )
               )
  )
