
########################
####### PACKAGES #######
########################


library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)
library(tidyr)


##############################
####### IMPORTING DATA #######
##############################

source("./data.R")



##################
####### UI #######
##################


ui <- 
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
                             label = "Choose variables: ",
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
                          
                          sliderInput('xvalue', 'Survival Years =', min = min(data$time), max = max(data$time), value = min(data$time))
                          
                          
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
                          
                          p(textOutput(outputId = "caption", container = span)),
                          textOutput("condition")
         ),
         
         # Will appear when there is no filter applied
         
         conditionalPanel(condition = "input.filtering == 0",
                          
                          # Will print if no filter is applied
                          
                          p(textOutput(outputId = "notfilter", container = span)),
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
                              h3("Data Preview"),
                              dataTableOutput(
                                 outputId = "data_table"
                                 
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
                              
                              p(textOutput(outputId = "surv_caption")),
                              
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
                     )
         )
      )
   )
)



######################
####### SERVER #######
######################

server <- function(input, output, session) {
   
   # Written statements   
   local({
      output$caption <- renderText({
         "Subgroup being used: "
      })
      
      output$notfilter <- renderText({
         "Data not filtered"
      })
      
      output$surv_caption <- renderText({
         "Survival Probability: "
      })
   })
   
   # Tab 1 - ANALYSIS SET UP ----------------------------------------------------------------------
   
   
   # DataTable to Preview Data
   
   output$data_table <- renderDataTable(
      data,
      options = list(
         pageLength = 5,
         dom = 'ltp',
         autoWidth = TRUE,
         scrollX = TRUE
      )
   )

   # Options for filtering depending on the column chosen
   output$col_value <- renderUI({
      x <- as.data.frame(data %>% select(input$column)) # Select only the column chosen to apply the filter
      class <- sapply(x, class)
      # If the column selected is not a character, a sliderInput will appear to choose the limits of the filter
      if (class == "factor" | class == "character"){
         selectInput("value", "Value", choices = x, selected = x[1])
      # If the column is a character, the choices will be the unique elements of the column
      } else{
         x <- na.omit(x)
         sliderInput("value", "Value", min = round(min(x)), max = round(max(x)), value = round(max(x)))
      }
   })
   
   # String made to subset the subjects and display in the sidebar    
   filtering_string <- reactive({
      x <- as.data.frame(data %>% select(input$column))
      class  <- sapply(x, class)
     if (class == "factor" | class == "character"){
         paste0(input$column, " ", input$condition, "\ '", input$value, "\'")
      }else{
         paste0(input$column, " ", input$condition, " ", input$value)   # If the variable is numeric we do not want ""
      }
   })
   
   # Text in the sidebar showing population subset 
   output$condition <- renderText({
      filtering_string()
   })
   
   
   # Subsetting the dataset according to the condition
   subset_data <- reactive({
      if (input$filtering == 0){ # If user does not want to subset, the complete dataset is used
         return(data)
      } else {
         filtered_data <- filter_(data, filtering_string())
         return(filtered_data)
      }      
   })
   
   
   # Tab 2 - TABLE OF CHARACTERISTICS ----------------------------------------------------------------------
   
   
   # Starting to elaborate the table of characteristics  
   tb <- reactive({
      validate(need(input$variables, "Please select characteristics to compare")) # Message if the user does not chose characteristics to compare
      
      if (input$p == "Yes"){                                                      # If the user wants the p value this code will be active
         tableby(formulize(input$stratification, x = input$variables), data = subset_data())
      } else {
         my_controls <- tableby.control(test = FALSE)
         tableby(formulize(input$stratification, x=input$variables), data = subset_data(), control = my_controls)
      }        
   })
   
   # Create the final table that will be displayed at the second tab
   output$tab <- renderTable({
      as.data.frame(summary(tb(), text = "html"))
      
   }, sanitize.text.function = identity
   )
   
   
   # Tab 3 - KEPLAN-MEIER ----------------------------------------------------------------------
   
   
   # Construct the Keplan-Meier plot 
   output$kep <- renderPlot({
      
      
      # Survival function - for ggsurvplot has to be inside the renderPlot function
      kmdata <- surv_fit(as.formula(paste('Surv(', input$time, ',', input$endpoint, ') ~ ',input$stratification_kep)),data=subset_data())
      
      # Plotting the survival curves
      ggsurvplot(kmdata, pval = TRUE,
                 risk.table = TRUE,
                 xlab = "Time",
                 ylab = "Survival",
                 legend = "bottom",
                 censor = FALSE,
                 tables.y.text = FALSE,
                 risk.table.height = 0.2)
      
      
   })
   
   # Survival function outside renderPlot function
   runSur <- reactive({
      survfit(as.formula(paste('Surv(', input$time, ',', input$endpoint, ') ~ ', input$stratification_kep)), data=subset_data())
   })
   
   # Survival table
   output$survprob <- renderTable({
      
      table <- as.data.frame(summary(runSur(), times = input$xvalue)[c("surv", "time", "strata")]) 
      table
   })
   
   # Tab 4 - COX MODEL ----------------------------------------------------------------------
   
   
   cox_fit_text <- reactive({
      
      #Create the strings that will be used to generate the cox model
      adjs_variables <- paste0(input$cox_variables, collapse = " + ")   
      strat_variables <- paste0("strata(", input$cox_strata, ")", collapse = " + ")
      
      #To add stratification variables to the model
      if(!is.null(input$cox_strata)){
         
         paste0('Surv(', input$time, ',', input$endpoint, ') ~ ', adjs_variables, " + ", strat_variables)
         
      } else{
         
         paste0('Surv(', input$time, ',', input$endpoint, ') ~ ', adjs_variables )
      }
      
   })
   
   #Printing the cox model in text
   output$cox_model <- renderText({
      validate(need(input$cox_variables, ""))    # A variable has to be selected
      cox_fit_text()
   })
   
   #Building the cox table
   output$cox <- renderTable({
      #There has to be a variable selected
      validate(need(input$cox_variables, "Please select variables to add to the model"))
      
      cox_fit <- coxph(as.formula(cox_fit_text()), data = subset_data())
      
      #Extracting HR from the model
      HR <- round(exp(coef(cox_fit)), 2)
      
      #Extracting CI from the model
      CI <- round(exp(confint(cox_fit)), 2)
      #Column names for CI
      colnames(CI) <- c("Lower_CI","Higher_CI")
      
      #Extracting p value from the model
      p <- round(coef(summary(cox_fit))[,5], 3)
      
      #Putting everything together to a dataframe
      cox_model <- as.data.frame(cbind(HR, CI, p), col.names = c("HR", "95% CI", "p value"))
      
      #CI in the same column
      cox_model$a <- "("; cox_model$b <- "-"; cox_model$c <- ")"
      cox_model <- cox_model[,c("HR", "a", "Lower_CI", "b", "Higher_CI", "c", "p")]
      cox_model <- unite(cox_model, "95%_CI", "a":"c", sep = "")
      
      #Adding row names of the variables
      Variables <- row.names(cox_model)
      cox_model <- cbind(Variables, cox_model)
      
      #Printing cox_model
      cox_model
   })
   
}


shinyApp(ui, server)

