
# Packages ------------------------------

library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)
library(tidyr)

# Path to the data

tables <- list.files(path = "./data", full.names = FALSE)

# Source everything on the code folder --------------------------


for (file in list.files("code", full.names = TRUE)){
  source(file, local = TRUE)
}
