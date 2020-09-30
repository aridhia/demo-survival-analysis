#To Use in the workspace

# .libPaths("/home/workspace/R/3.5.0")

# Libraries

library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)
library(tidyr)


server <- function(input, output, session) {
  
  #Text shown before printed condition in the sidebar panel
  output$caption <- renderText({
      "Subgroup being used: "
    })
    #Text only shown if the data is not filtered
    output$notfilter <- renderText({
      "Data not filtered"
    })
    
    output$surv_caption <- renderText({
      "Survival Probability: "
    })

    output$data_head <- renderTable(head(data))
    
  
  #The values shown in the third column of the filtering depend on the column chosen, according to the column the options vary
  output$col_value <- renderUI({
    #Select only the column choosen to apply the filter
    x <- as.data.frame(data %>% select_(input$column))
    #If the column selected is not a character, a sliderInput will appear to choose the limits of the filter
    if (!is.character(x[1,])){
      x <- na.omit(x)
      sliderInput("value", "Value", min = round(min(x)), max = round(max(x)), value = round(max(x)))
      #If the column is a character, the choices will be the unique elements of the column
    } else{
      selectInput("value", "Value", choices = x, selected = x[1])
    }
  })
  
  #String made to subset the subjects and display in the sidebar    
  filtering_string <- reactive({
    x <- as.data.frame(data %>% select(input$column))
    #If the variable is numeric we do not want "" 
    if (is.numeric(x[1, ])){
      paste0(input$column, " ", input$condition, input$value)
    }else{
      paste0(input$column, " ", input$condition, "\ '", input$value, "\'")
    }
  })
  
  #Text in the sidebar showing population subset 
  output$condition <- renderText({
    filtering_string()
  })
  
  
  #Subsetting the dataset according to the condition
  subset_data <- reactive({
    #If user does not want to subset, the complete dataset is used
    if (input$filtering == 0){
      return(data)
    } else {
      data <- filter_(data, filtering_string())
      return(data)
    }      
  })
  
  #Starting to elaborate the table of characteristics  
  tb <- reactive({
    #Message if the user does not chose characteristics to compare
    validate(need(input$variables, "Please select characteristics to compare"))
    #If the user wants the p value this code will be active
    if (input$p == "Yes"){
      tableby(formulize(input$stratification, x = input$variables), data = subset_data())
      #When the user does not want the p value the table is coded as test=FALSE
    } else {
      my_controls <- tableby.control(test = FALSE)
      tableby(formulize(input$stratification, x=input$variables), data = subset_data(), control = my_controls)
    }        
  })
  
  #Create the final table that will be displayed at the second tab
  output$tab <- renderTable({
    as.data.frame(summary(tb(), text = "html"))
    
  }, sanitize.text.function = identity
  )
  
  
  #Construct the Keplan-Meier plot 
  output$kep <- renderPlot({
    
    
    #Survival function - for ggsurvplot has to be inside the renderPlot function
    kmdata <- surv_fit(as.formula(paste('Surv(', input$time, ',', input$endpoint, ') ~ ',input$stratification_kep)),data=subset_data())
    
    #Plotting the survival curves
    ggsurvplot(kmdata, pval = TRUE,
               risk.table = TRUE,
               xscale = "d_y",
               break.time.by = 365.25,
               xlab = "Time since randomisation (years)",
               #This can be changed according to what the analysis is measuring
               ylab = "Without clinical recurrence(%)",
               legend = "bottom",
               censor = FALSE,
               tables.y.text = FALSE,
               risk.table.height = 0.2)
    
    
  })
  
  #Survival function outside renderPlot function
  runSur <- reactive({
    survfit(as.formula(paste('Surv(', input$time, ',', input$endpoint, ') ~ ', input$stratification_kep)), data=subset_data())
  })
  
  #Survival table
  output$survprob <- renderTable({
    
    table <- as.data.frame(summary(runSur(), times = input$xvalue*365.25)[c("surv", "time", "strata")]) %>%
      mutate(time = time/365.25)
    table
  })
  
  #Cox Analysis fit
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
    #There has to be a variable sected
    validate(need(input$cox_variables, ""))
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