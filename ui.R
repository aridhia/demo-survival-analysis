

##################
####### UI #######
##################


  fluidPage(
    
    #####################
    ####### TITLE #######
    #####################
    
    titlePanel("Survival Analysis"),
    
    
    ########################
    ####### SIDE BAR #######
    ########################
    
    
    sidebarLayout(
      
      sidebarPanel(
        
        # Tab 2 TABLE OF CHARACTERISTICS -------------------------------------
        
        conditionalPanel(condition = "input.tabs == 2",
                         
                         # Select the stratification variable
                         
                         selectInput(
                           inputId = "stratification",
                           label = "Choose a stratification variable",
                           choices = names(data),
                           selected = "treatment"
                         ),
                         
                         # Select the variables included in the table
                         
                         selectInput(
                           inputId = "variables",
                           label = "Choose variables to compare: ",
                           choices = names(data),
                           multiple = TRUE
                         ),
                         
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
                         
                         selectInput(
                           inputId = "stratification_kep",
                           label = "Choose a stratification variable",
                           choices = names(data),
                           selected = "treatment"
                         ),
                         
                         # Select years to get survival probability
                         
                         sliderInput('xvalue', 'Select a time: ', min = min(data$time), max = max(data$time), value = min(data$time))
                         
                         
        ),
        
        # Tab 4  COX ANALYSIS -------------------------------------
        
        conditionalPanel(condition = "input.tabs == 4",
                         
                         # Select variables to add to the model
                         
                         selectInput(
                           inputId = "cox_variables",
                           label = "Choose variables to add to the model",
                           choices = names(data),
                           multiple = TRUE
                         ),
                         
                         # Select stratas to add to the model
                         
                         selectInput(
                           inputId = "cox_strata",
                           label = "Choose variables to add as strata for the model",
                           choices = names(data),
                           multiple = TRUE
                         )
                         
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
                             div(
                               style = "width: 70%; font-size : 80%",
                               dataTableOutput("data_table")
                             ),
                             
                             
                             # Choose the variable describing whether the participant suffered an outcome or not
                             selectInput(
                               inputId = "endpoint",
                               label = "Select variable with survival outcome information",
                               choices = names(data),
                               multiple = FALSE,
                               selected = "recurrence"
                             ),
                             
                             
                             # Choose variable containing the time object for the survival analysis
                             selectInput(
                               inputId = "time",
                               label = "Select variable with survival time information",
                               choices = names(data),
                               multiple = FALSE,
                               selected = "time"
                             ),
                             
                             # Lets the user choose if they want to filter the dataset 
                             radioButtons(
                               inputId = "filtering",
                               label = "Do you want filter the dataset?",
                               choices = list("Yes" = 1, "No" = 0),
                               selected = 0
                               
                             ),
                             
                             # The Panel will only be visible if the user decides to filter the dataset
                             conditionalPanel(condition = "input.filtering == 1",
                                              column(4, selectInput("column", "Filter By:", choices = names(data))),
                                              column(4, selectInput("condition", "Boolean", choices = c("==", "!=", ">", "<"))),
                                              column(4, uiOutput("col_value"))
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
