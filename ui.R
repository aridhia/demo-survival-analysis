

##################
####### UI #######
##################


  fluidPage(
    theme = "style.css",
    
    #####################
    ####### TITLE #######
    #####################
    
    titlePanel(h1("Survival Analysis")),
    
    
    ########################
    ####### SIDE BAR #######
    ########################
    
    
    sidebarLayout(
      
      sidebarPanel(
        
        # Tab 3 ANALYSIS SET UP --------------------------------------------
        
        conditionalPanel(condition = "input.tabs == 1",

                         # Select data
                         selectInput(
                           inputId = "choose_data",
                           label = "Choose data",
                           choices = tables,
                           selected = NULL
                         )

          ),
        
        
        
        
        # Tab 2 TABLE OF CHARACTERISTICS -------------------------------------
        
        conditionalPanel(condition = "input.tabs == 2",
                         
                         # Select the stratification variable
                         
                         chooseColumnUI("stratification"),
                         
                         # Select the variables included in the table
                         
                         chooseColumnUI("variables"),
                         
                         # p value optional
                         
                         radioButtons(
                           inputId = "p",
                           label = "Show p-value?",
                           choices = c("Yes", "No"),
                           selected = "No"
                         )      
        ),
        
        
        # Tab 3 KEPLAN-MEIER -------------------------------------
        
        conditionalPanel(condition = "input.tabs == 3",
                         
                         # Select stratification of variable
                         
                         chooseColumnUI("stratification_kep"),
                         
                         # Select years to get survival probability
                         
                         uiOutput('xvalue')
                         
                         
        ),
        
        # Tab 4  COX ANALYSIS -------------------------------------
        
        conditionalPanel(condition = "input.tabs == 4",
                         
                         # Select variables to add to the model
                         
                         chooseColumnUI("cox_variables"),
                         
                         # Select stratas to add to the model
                         
                         chooseColumnUI("cox_strata")
                         
        ),
        
        
        # Filter statement -------------------------------------
        
        conditionalPanel(condition = "input.filtering == 1",
                         
                         # Will print the applied filter
                         
                         p("Subgroup being used: "),
                         textOutput("condition")
        ),
        
        # Will appear when there is no filter applied
        
        conditionalPanel(condition = "input.filtering == 0",
                         
                         # Will print if no filter is applied
                         
                         p("The data is not filtered"),
                         textOutput("condition0")
        )
        
        
      ),
      
      
      
      ##########################
      ####### MAIN PANEL #######
      ##########################
      
      
      mainPanel(
        
        # The main panel is divided in tabs
        
        tabsetPanel(id = "tabs",
                    
                    # Tab 1 - ANALYSIS SET UP ----------------------------------------------------------------------
                    
                    tabPanel("Analysis set up", 
                             value = 1,
                             
                             
                             # Data Preview
                             h4(strong("Data Preview")),
                             tags$table(
                               dataTableOutput("data_table")
                             ),
                             
                             
                             # Choose the variable describing whether the participant suffered an outcome or not
                             chooseColumnUI("endpoint"),
                             
                             
                             # Choose variable containing the time object for the survival analysis
                             chooseColumnUI("time"),
                             
                             # Lets the user choose if they want to filter the dataset 
                             radioButtons(
                               inputId = "filtering",
                               label = "Do you want filter the dataset?",
                               choices = list("Yes" = 1, "No" = 0),
                               selected = 0
                               
                             ),
                             
                             # The Panel will only be visible if the user decides to filter the dataset
                             conditionalPanel(condition = "input.filtering == 1",
                                              column(4, chooseColumnUI("column")),
                                              column(4, selectInput("condition", "Boolean", choices = c("==", "!=", ">", "<"))),
                                              column(4, chooseValueUI("col_value"))
                                              # column(4, uiOutput("col_value"))
                             ),
                             
                    ),
                    
                    # Tab 2 - TABLE OF CHARACTERISTICS ----------------------------------------------------------------------
                    
                    tabPanel("Table", 
                             value = 2,
                             
                             # Table output
                             tableOutput(
                               outputId = "tab"
                             )
                    ),
                    
                    # Tab 3 - KEPLAN-MEIER ----------------------------------------------------------------------
                    
                    tabPanel("Keplan-Meier", 
                             value = 3,
                             
                             p("This table will show the survival probability on the selected time in the slider."),
                             # Table with survival probability
                             tableOutput(outputId = "survprob"),
                             
                             # The output is a plot
                             plotOutput(
                               outputId = "kep",
                               height = "600px"    # Make the graph bigger
                               
                             )
                    ),
                    
                    # Tab 4 - COX MODEL ----------------------------------------------------------------------
                    
                    tabPanel("Cox Model", value = 4,
                             
                             # Cox model table
                             tableOutput(
                               outputId = "cox"
                             ),
                             
                             # Print the model in text
                             verbatimTextOutput(
                               outputId = "cox_model"
                             )
                    ),
                    
                    # Tab 5 - HELP --------------------------------------------------------------------
                    
                    documentation_tab()
        )
      )
    )
  )
