# Survival Analysis App

This Shiny App was developed to easily visualise a survival analysis. 

It has 4 tabs, each one performing a different step of the survival analysis:

1. **Fist tab** is the analysis set up. The user has to select the variable containing the information of whether the event took place or not and the time variable. It also allows to filter the dataset, the filter applied in this step will be used in the rest of the analyses.

2. **Second tab** is used to develop a characteristics table comparing two populations of the study. It allows the user to choose:
    * The stratification variable to set up the populations to compare
    * The variables shown in the table
    * Whether to show the p-value or not
  
3. **Third tab** builds a Keplan-Meier graph with the variables selected in the first tab. It allows to choose the stratification variable and a sliding bar controls the table containing the survival probability at the chosen time. 

4. **Fourth tab** builds a Cox Model; the user can easily add variables and strata to the model by selecting different variables.

