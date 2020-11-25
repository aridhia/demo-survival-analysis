

chooseValueUI <- function(id){
  ns <- NS(id)
  
  uiOutput(ns("choose_value_ui"))
}


chooseValue <- function(input, output, session, values, label = "Select a value") {
  ns <- session$ns
  
  output$choose_value_ui <- renderUI({
    v <- values()


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
