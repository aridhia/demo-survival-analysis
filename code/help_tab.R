documentation_tab <- function() {
  tabPanel("Help",
           fluidPage(width = 12,
                     fluidRow(column(
                       6,
                       h3("Survival Analysis"), 
                       p("This mini-app allows you to perform a survival analysis. The following tests are typically used in survival analysis: "),
                       tags$ol(
                         tags$li(strong("Keplan-Meier plots "), "are used to visualize the probability of survival in each of the time intervals."),
                         tags$li(strong("Cox Proportional Hazards Regression "), "describes the effect of continuous or categorical predictors on survival, this method 
                                 considers one or more than one covariates when considering survival of patients. This regression gives the Hazard Ratio (HR) of Experimental Vs.
                                 Control, if the HR is less than one, the hazard decreases (favouring the experimental group)")
                       ),
                       h4("To use the mini-app"),
                       p("The datasets available in the app are located in the 'data' folder, if you wish to a different dataset, you can save the CSV file in the 'data' folder." ),
                       tags$ol(
                         tags$li("The first tab is used for ", strong("Setting up the analysis."), " The user has to select the variable containing the endpoint information or not and the time variable. 
                         It also allows to filter the dataset, which will be applied the rest of the analyses."), 
                         tags$li("The second tab prints a ", strong("Table of characteristics"), 
                                 "you must choose a stratification variable, then you can add variables to the table; you can choose whether to show the p-value or not."),
                         tags$li("In the third tab builds a ", strong("Keplan-Meier graph. "), 
                                 "You can choose the stratification variablia and use the slinding bar to check the survival at any time point."), 
                         tags$li("Finally, the fourth tab builds the ", strong("Cox Model "), "it allows you to add variables and stratas to the model.")
                       ),
                       p("You can experiment with any number of combinations, selecting different outcome or stratification variables or adding different variables 
                         to the Cox Model."),
                       br()
                     ),
                     column(
                       6,
                       h3("Walkthrough video"),
                       tags$video(src="survival.mp4", type = "video/mp4", width="100%", height = "350", frameborder = "0", controls = NA),
                       p(class = "nb", "NB: This mini-app is for provided for demonstration purposes, is unsupported and is utilised at user's 
                       risk. If you plan to use this mini-app to inform your study, please review the code and ensure you are 
                       comfortable with the calculations made before proceeding. ")
                       
                     ))
                     
                     
                     
                     
           ))
}