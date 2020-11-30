

# Choose column UI function
chooseColumnUI <- function(id){
  ns <- NS(id)
  
  uiOutput(ns("choose_column_ui"))
}


# Returns the UI select input and the chosen column
choosenColumn <- function(input, output, session, data, label = "Choose a column", multiple = FALSE){
  ns <- session$ns
  
   columns <- reactive({
    names(data())
  })
  
  output$choose_column_ui <- renderUI({
    selectInput(ns("choose_column"), 
                choices = columns(),
                label = label,
                multiple = multiple)
  })
  
  column <- reactive({
    input$choose_column
  })
  

  return(column)
  
}

# Returns the values of the chosen column
columnValues <- function(input, output, session, data, column){
  ns <- session$ns
          
  values <- reactive({
    if (is.null(data())){
      return(NULL)
    } else {
      data()[, column()]
    }
  })
    
  
  return(values)
}

