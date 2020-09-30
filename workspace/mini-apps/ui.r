
# The dataset has to be in the datafiles directory
dataset <- "lung"

project_path <- function(){
  rprojroot::find_root(rprojroot::is_rstudio_project)
}

readtable <- function(datatable){
  proj_path <- project_path()
  csv_name <- paste0(file.path(proj_path, "workspace", "datafiles", datatable), ".csv")
  data <- read.csv(csv_name)
  data
}

data <- readtable(dataset)


ui <- fluidPage(
  # The title panel is displayed in the top left hand corner by default
  titlePanel("Survival Analysis"),
  
  # Sidebar panel
  sidebarLayout(
    sidebarPanel(
      
      # Will only appear when the user decides to subset a part of the population
      conditionalPanel (condition = "input.filtering == 1",
                        p(textOutput(outputId = "caption", container = span)),
                        textOutput("condition")
                        ),
      
      # Will only appear when there is no filter applied to the dataset
      conditionalPanel(condition = "input.filtering == 0",
                       p(textOutput(outputId = "nonfilter", container = span)),
                       textOutput("condition0")
                       ),
      
     # Only appear in the tab 2 (table tab)
     conditionalPanel(condition = "input.tabs == 2",
                      
                      # Select stratification variable
                      selectInput(
                        inputId = "stratification",
                        label = "Choose a stratification variable",
                        choices = names(data)
                      ),
                      
                      # Select the variables included in the table
                      selectInput(
                        inputId = "variables",
                        label = "Choose variables: ",
                        choices = names(data),
                        multiple = TRUE
                      ),
                      
                      # p value as a last column
                      radioButtons(
                        inputId = "p",
                        label = "Show p-value?",
                        choices = c("Yes", "No"),
                        selected = "No"
                      )
       ),
     
     # Only appear in tab 3 (Keplan-Meier)
     conditionalPanel(condition = "input.tabs == 3",
                      
                      # Select stratification variable
                      selectInput(
                        inputId = "stratification_kep",
                        label = "Choose a stratification variable",
                        choices = names(data)
                      ),
                      
                      # Slider to get the survival probability
                      sliderInput(
                        inputId = "xvalue",
                        label = "Survival Years = ",
                        min = min(data),
                        max = max(data),
                        value = 0,
                        round = TRUE
                      )
       
     ),
     
     # Only appear in tab 4 (cox analysis)
     conditionalPanel(condition = "input.tabs == 4",
                      
                      selectInput(
                        inputId = "cox_variables",
                        label = "Choose variables to add to the model",
                        choices = names(data),
                        multiple = TRUE
                      ),
                      
                      selectInput(
                        inputId = "cox_strata",
                        label = "Choose variables to add as strata for the model",
                        choices = names(data),
                        multiple = TRUE
                      )
    )
      
    ),
    
    # Main Panel
    
    mainPanel(
      
      # It will have different tbs
      tabsetPanel(id = "tabs",
                  
                  # First tab, set up the analysis
                  tabPanel(
                    title = "Analysis set up",
                    value = 1,
                    
                    # Text
                    h4(textOutput(
                      outputId = "table_text",
                      container = span,
                    )),
                    
                    # Print head of the data set
                    tableOutput(
                      outputId = "data_head"
                    ),
                    
                    
                    # Select Variable with outcome information
                    selectInput(
                      inputId = "endpoint",
                      label = "Select variable with survival outcome information",
                      choices = names(data),
                      multiple = FALSE
                    ),
                    
                    # Select variable with time information
                    selectInput(
                      inputId = "time",
                      label = "Select variable with survival time information",
                      choices = names(data),
                      multiple = FALSE
                    ),
                    
                    # Option to filter the dataset
                    radioButtons(
                      inputId = "filtering",
                      label = "Do you want to filter the dataset?",
                      choices = list("Yes" = 1, "No" = 0),
                      selected = 0
                    ),
                    
                    # If they want to filter the dataset this panel will show
                    conditionalPanel(condition = "input.filtering == 1",
                                     
                                     #Will show 3 columns
                                     column(4, selectInput("column", "Filter By:", choices = names(data))),
                                     column(4, selectInput("condition", "Boolean", choices = c("==", "!=", ">", "<"))),
                                     column(4, uiOutput("col_value"))
                      
                    )
                  ),
                  
                  # Second tab - table comparing characteristics
                  tabPanel(
                    title = "Table",
                    value = 2,
                    
                    # Table
                    tableOutput(
                      outputId = "tab"
                    )
                    
                  ),
                  
                  # Third tab - Keplan Meier
                  tabPanel(
                    title = "Keplan-Meier",
                    value = 3,
                    
                    # Text before table
                    p(textOutput(outputId = "surv_caption")),
                    
                    # Table with survival probability
                    tableOutput(outputId = "survprob"),
                    
                    # Plot
                    plotOutput(
                      outputId = "kep",
                      height = "600px" # Make the graph bigger
                    )
                  ),
                  
                  # Fourth tab - Cox analysis
                  tabPanel(
                    title = "Cox Model",
                    value = 4,
                    
                    tableOutput(
                      outputId = "cox"
                    ),
                    
                    verbatimTextOutput(
                      outputId = "cox_model"
                    )
                    
              )
        )
    
    )
    
  )

)