
# Packages used by the app
packages <- c("shiny", "arsenal", "readr", "survminer", "survival", "dplyr", "tidyr", "DT")


# Install the packages if not installed
if (!require(packages)){
  install.packages(packages)
}