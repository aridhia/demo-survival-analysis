data <- bladder1 %>%
  subset(start == 0) %>%
  subset(select = -c(start, enum)) %>%
  rename(
    initial_number = number,
    num_recurrence = recur,
    num_tumor = rtumor,
    size_tumor = rsize,
    time = stop
  ) %>%
  mutate(
    num_tumor = ifelse(num_tumor == ".", 0, num_tumor),
    size_tumor = ifelse(size_tumor == ".", 0, size_tumor),
    recurrence = ifelse(status == 0, 0, 1),
    status = factor(status, levels = c(0,1,2,3), labels = c("censored", "recurrence", "death from bladder disease", "death other/unknown cause"))
  )
  

