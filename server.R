

######################
####### SERVER #######
######################


function(input, output, session) {

   # Tab 1 - ANALYSIS SET UP ----------------------------------------------------------------------
   
   data <- reactive({
      if (input$choose_data == "") {
         return(NULL)
      }

      # table_name <- input$choose_data

      file <- file.path("data", paste(input$choose_data))
      read.csv(file)
   })

   # DataTable to Preview Data
   
   output$data_table <- renderDataTable(
      data(), options = list(scrollX = TRUE, pageLength = 5, dom = 't', searching = FALSE)
   )
   

   # Filter options

   filter_column <- callModule(choosenColumn, "column", data, label = "Choose column to filter by:")    # Choose Column of the dataset
   filter_values <- callModule(columnValues, "column_value", data, column = filter_column)              # Extract all the chosen column values
   filter_value <- callModule(chooseValue, "col_value", values = filter_values)                         # Different UI according to chosen column type

   # String made to subset the subjects and display in the sidebar    
   filtering_string <- reactive({
      # If condition is numeric
      if (is.numeric(filter_value())){
         paste0(filter_column(), " ", input$condition, " ", filter_value()) 
      # If condition uses a string  
      }else{
         paste0(filter_column(), " ", input$condition, "\ '", filter_value(), "\'")
      }
   })
   
   # Text in the sidebar showing population subset
   output$condition <- renderText({
      filtering_string()
   })
   
   
   # Subsetting the dataset according to the condition
   subset_data <- reactive({
      # If no filters are applied - All the dataset is used
      if (input$filtering == 0){
         return(data())
      # When a filter is applied
      } else {
         filtered_data <- filter_(data(), filtering_string())
         return(filtered_data)
      }      
   })
   
   
   # Tab 2 - TABLE OF CHARACTERISTICS ----------------------------------------------------------------------
   
   stratification_table <- callModule(choosenColumn, "stratification", data, label = "Choose the stratification variable:")                # Display columns of the chosen dataset
   variables_table <- callModule(choosenColumn, "variables", data, label = "Choose variables to add to the table:", multiple = TRUE)       # Display columns of the chosen dataset
   
   # Starting to elaborate the table of characteristics  
   tb <- reactive({
      
      # Message if the user does not chose characteristics to compare
      validate(need(variables_table(), "Please select characteristics to compare"))
      
      # If the user wants the p value this code will be active
      if (input$p == "Yes"){                                                      
         tableby(formulize(stratification_table(), x = variables_table()), data = subset_data())
      # Hide p-value
      } else {
         my_controls <- tableby.control(test = FALSE)
         tableby(formulize(stratification_table(), x=variables_table()), data = subset_data(), control = my_controls)
      }        
   })
   
   # Create the final table 
   output$tab <- renderTable({
      as.data.frame(summary(tb(), text = "html"))
   }, sanitize.text.function = identity)
   
   
   # Tab 3 - KAPLAN-MEIER ----------------------------------------------------------------------
   
   
   endpoint <- callModule(choosenColumn, "endpoint", data, label = "Choose column that contains endpoint information:")          # Display columns of the chosen dataset
   time <- callModule(choosenColumn, "time", data, label = "Choose column that contains survival time information:")             # Display columns of the chosen dataset
   time_values <- callModule(columnValues, "time_values", data, column = time)                                                   # Different UI according to chosen column type

   stratification_kep <- callModule(choosenColumn, "stratification_kep", data, label = "Choose the stratification variable:")    # Display columns of the chosen dataset
   

   # Construct slider input 
   
   output$xvalue <- renderUI({
      
       sliderInput('xvalue',
                   'Select a time: ',
                   min = min(time_values()),
                   max = max(time_values()),
                   value = min(time_values()))
   })
   
   # Construct the Kaplan-Meier plot 
   output$kep <- renderPlot({
      
      # Need the stratification variable to build the Kaplan-Meier graph
      validate(need(stratification_kep(), "Please select stratification variable"))
      
      # Survival function - for ggsurvplot has to be inside the renderPlot function
      kmdata <- surv_fit(as.formula(paste('Surv(', time(), ',', endpoint(), ') ~ ',stratification_kep())),data=subset_data())
      
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
      # Need the stratification variable to build the kaplan meier graph, no message is passed to avoid having multiple messages on the screen
      validate(need(stratification_kep(), ""))
      survfit(as.formula(paste('Surv(', time(), ',', endpoint(), ') ~ ', stratification_kep())), data=subset_data())
   })
   
   # Survival table
   output$survprob <- renderTable({
      # Need the stratification variable to build the table, no message is passed to avoid having multiple messages on the screen
      validate(need(stratification_kep(), ""))
      
      table <- as.data.frame(summary(runSur(), times = input$xvalue, extend = TRUE)[c("surv", "time", "strata")]) 
      table
   })
   
   # Tab 4 - COX MODEL ----------------------------------------------------------------------
   
   
   cox_variables <- callModule(choosenColumn, "cox_variables", data, label = "Choose variables to add to the model:", multiple = TRUE)    # Display columns of the chosen dataset
   cox_strata <- callModule(choosenColumn, "cox_strata", data, label = "Choose strata to add to the model:", multiple = TRUE)             # Display columns of the chosen dataset
   
   
   cox_fit_text <- reactive({
      
      #Create the strings that will be used to generate the cox model
      adjs_variables <- paste(cox_variables(), collapse = " + ")   
      strat_variables <- paste("strata(", cox_strata(), ")", collapse = " + ")
      
      #To add stratification variables to the model
      if(!is.null(cox_strata())){
         
         paste('Surv(', time(), ',', endpoint(), ') ~ ', adjs_variables, " + ", strat_variables)
         
      } else{
         
         paste('Surv(', time(), ',', endpoint(), ') ~ ', adjs_variables )
      }
      
   })
   
   #Printing the cox model in text
   output$cox_model <- renderText({
      validate(need(cox_variables(), ""))    # A variable has to be selected
      cox_fit_text()
   })
   
   #Building the cox table
   output$cox <- renderTable({
      #There has to be a variable selected
      validate(need(cox_variables(), "Please select variables to add to the model"))
      
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

