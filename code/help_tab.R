documentation_tab <- function() {
  tabPanel("Help",
           fluidPage(width = 12,
                     fluidRow(column(
                       6,
                       h3("Survival Analysis"), 
                       p("This mini-app allows you to perform a survival analysis. In a survival analysis, two or more groups are compared with respoect to the time of a specific event. In some cases,
                         the event may not occur during the observation period, then the time object is called the censored time."),
                       p("Survival analyses use the following methods:"),
                       tags$ol(
                         tags$li(strong("Keplan-Meier plots "), "are used to visualize the probability of survival in each of the time intervals."),
                         tags$li(strong("Cox Proportional Hazards Regression "), "describes the effect of continuous or categorical predictors on survival, this method 
                                 considers one or more than one covariates when considering survival of patients. This regression gives the Hazard Ratio (HR) of Experimental Vs.
                                 Control, if the HR is less than one, the hazard decreases (favouring the experimental group)")
                       ),
                       h4("Mini-app layout"),
                       p("The mini-app contains three tabs; this help tab gives you an overview of the mini-app itself."),
                       
                       h5("To use the mini-app"),
                       p("The data being used by the app is the bladder dataset from the survimer R package, to use a different dataset you should store the 
                         csv file in the data folder" ),
                       
                       
                       tags$ol(
                         tags$li("The first tab is used for ", strong("Setting up the analysis."), " The user has to select the variable containing the information of 
                                 whether the event took place or not and the time variable. It also allows to filter the dataset, the filter applied in this step will 
                                 be used in the rest of the analyses."), 
                         
                         tags$li("The second tab prints a ", strong("Table of characteristics"), 
                                 "you have to choose the stratification variable, the variables shown in the table and whether to show the p-value or not from the
                                 left-hand menu"),
                         tags$li("In the third tab builds a ", strong("Keplan-Meier graph "), 
                                 "using the variables selected in the analysis set up tab. It allows to choose the stratification variable and the slinding bar controls
                                 the table containing the survival probability at the chosen timek"), 
                         tags$li("Finally, the fourth tab build the ", strong("Cox Model "), "you can add variables and stratas to the model by selecting the different 
                        variables from the left-hand menu")
                       ),
                       p("You can experiment with any number of combinations, selecting different outcome variables, stratification variables or adding different variables 
                         to the Cox Model."),
                       br()
                     ),
                     column(
                       6,
                       h3("Walkthrough video"),
                       HTML('<iframe width="100%" height="300" src="//www.youtube.com/embed/8JESp8J33XU" frameborder="0"></iframe>'),
                       p(class = "nb", "NB: This mini-app is for provided for demonstration purposes, is unsupported and is utilised at user's 
                       risk. If you plan to use this mini-app to inform your study, please review the code and ensure you are 
                       comfortable with the calculations made before proceeding. ")
                       
                     ))
                     
                     
                     
                     
           ))
}