# Survival Analysis 

This Shiny App was developed to easily visualize a survival analysis. 

**Survival analyses** use a set of statistical approaches to investigate the time it takes for an event of interest to occur. The event of interest can be recurrence, remission, progression or death, among others. In Survival studio, two or more groups are compared with respect to the time to this specific event. 
In some cases, the event may not be observed in some individuals within the study time period, then, this observation would be “censored” and survival time would be the last known time the patient or participant was known  not to suffer the event. 

Survival analysis use the following methods:

1. **Keplan-Meier plots**: The Kaplan-Meier plot and it is used to visualize the probability of survival in each of the time intervals.
2. **Log-Rank Test**: The log-rank test compares the Kaplan-Meier survival curves of both groups. Its H<sub>0</sub> is that survival curves of two populations do not differ. It is not suitable for continuous predictors. 
3. **Cox Proportional Hazards Regression**: Describes the effect of continuous or categorical predictors on survival. Whereas the log-rank test compares two Kaplan-Meier survival curves (i.e. splitting the population into treatment groups), the Cox proportional hazards models considers other covariates when comparing survival of patients groups. 

## About the Survival Analysis App

The app has four tabs:

1. Analysis set up
2. Table of statistics
3. Keplan-Meier Plot
4. Cox Model

This R Shiny mini-app reads the data from the `data` directory. If you want to work with your own data, just add the desired CSV file to the `data` folder and choose it in the app.

### Checkout and run

You can clone this repository by using the command:

```clone
git clone https://github.com/aridhia/demo-survival-analysis
```
Open the .Rproj file in RStudio, source the script `dependencies.R` to install all the packages required by the app, and run `runApp()` to start the app.

### Deploying to the workspace

1. Create a new mini-app in the workspace called "survival-app" and delete the folder created for it
2. Download this GitHub repo as a .ZIP file, or zip all the files
3. Upload the .ZIP file to the workspace and upzip it inside a folder called "survival-app"
4. Run the `dependencies.R` script to install all the packages that the app requires
5. Run the app in your workspace

For more information visit https://knowledgebase.aridhia.io/article/how-to-upload-your-mini-app/
