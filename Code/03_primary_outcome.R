rm(list = ls())

pacman::p_load(
  here, DescTools, tidyverse, magrittr, janitor,
  knitr, survival, ggpubr, gt, gtsummary
)

here::i_am(
  "Code/03_primary_outcome.R"
)

active_config <- Sys.getenv("WHICH_CONFIG", unset = "default")
config_list <- config::get(config = active_config)
print(
  paste("The active config is", Sys.getenv("WHICH_CONFIG", unset = "default"), sep = " ")
  )

f75 <- readRDS(here::here("Data/f75.rds"))


## assume the censoring day is 10 day from birth 
f75 %<>%
  mutate(
    status = if_else(days_stable == 999, 0, 1),
    time = if_else(days_stable == 999, 10, days_stable)
  )

var_labels <- list(bfeeding = "Whether Breast Fed?",
                   sex = "Baby's Gender",
                   caregiver = "Baby's Primary Caregiver")

covar <- c(config_list$parameter1, config_list$parameter2, config_list$parameter3)
formula <- paste("Surv(time, status) ~", paste(covar, collapse = " + "))  


fit.cox <- coxph(as.formula(formula), data = f75)

p<- fit.cox %>%
  tbl_regression(exponentiate = TRUE, 
                 label = var_labels) %>%
  bold_labels() %>%
  add_global_p %>%
  bold_p() %>%
  modify_header(estimate = "**HR**") %>%
  as_gt()


saveRDS(p, paste0(here::here("Output/"), "primary_outcome_", active_config,".rds"))

