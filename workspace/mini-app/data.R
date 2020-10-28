
# Modified the dataset bladder1 to better fit the survival app purposes

data <- bladder1 %>%

  # Avoid repeated id rows
  subset(start == 0) %>%
  # Remove columns that will not be used
  subset(select = -c(start, enum)) %>%
  # Rename columns to make understanding of the info easier
  rename(
    initial_number = number,
    num_recurrence = recur,
    num_tumor = rtumor,
    size_tumor = rsize,
    time = stop
  ) %>%
  # Created columns needed for the analysis
  mutate(
    num_tumor = ifelse(num_tumor == ".", 0, num_tumor),
    size_tumor = ifelse(size_tumor == ".", 0, size_tumor),
    recurrence = ifelse(num_recurrence == 0, 0, 1),
    status = factor(status, levels = c(0, 1, 2, 3), labels = c("censored", "recurrence", "death from bladder disease", "death other/unknown cause"))
  )
