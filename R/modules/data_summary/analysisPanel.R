analysis.panel <- 
  tabPanel(title = "Data Summarization", value = "analysisTab",
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
  )