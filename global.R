
# Packages ------------------------------

library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)
library(tidyr)
library(DT)



# Importing data ----------------------

data <- read.csv("./data/bladder.csv")




# Help tab --------------------------

source("./code/help_tab.R")