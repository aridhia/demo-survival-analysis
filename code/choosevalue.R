
# Chose value UI
chooseValueUI <- function(id){
  ns <- NS(id)
  
  uiOutput(ns("choose_value_ui"))
}


# Returns the value chosen for the filter
chooseValue <- function(input, output, session, values, label = "Select a value") {
  ns <- session$ns
  
  r_values <- reactive({
    values()
  })
  
  output$choose_value_ui <- renderUI({
    
    validate(need(r_values(), "Please select characteristics to compare"))
    
    v <- r_values()

    if (is.numeric(v)){
      sliderInput(ns("choose_value"), label = label, 
                  min = round(min(v)), max = round(max(v)), value = round(max(v)))

    } else {
      selectInput(ns("choose_value"), 
                  label = label, 
                  choices = v)
    }
    
  })
  
  value <- reactive({
    input$choose_value
  })
  
  return(value)
}

