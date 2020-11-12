
packages <- c("shiny", "arsenal", "readr", "survminer", "survival", "dplyr", "tidyr", "DT")



if (!require(packages)){
  install.packages(packages)
}