
# Packages ------------------------------

library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)
library(tidyr)
library(DT)



tables <- list.files(path = "./data", full.names = FALSE)


# Importing data ----------------------

data <- read.csv("./data/bladder.csv")




# Source everything on the code folder --------------------------


for (file in list.files("code", full.names = TRUE)){
  source(file, local = TRUE)
}
