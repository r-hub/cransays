library(tidyverse)

raw <- map_dfr(dir(pattern = "*.csv"), vroom::vroom, col_types = list())

tidy <- raw %>%
  filter(!is.na(version)) %>%
  transmute(package = paste0(package, "-", version), folder, snapshot_time) %>%
  arrange(package, snapshot_time)

# Remove packages that appear in multiple folders
dups <- tidy %>% count(package, snapshot_time) %>% filter(n > 1)
tidy <- tidy %>% anti_join(dups, by = c("package", "snapshot_time"))

# remove all entries that didn't change
state <- tidy %>%
  group_by(package) %>%
  filter(row_number() == 1 | folder != dplyr::lag(folder)) %>%
  mutate(elapsed = as.numeric(snapshot_time - dplyr::lag(snapshot_time), units = "hours")) %>%
  ungroup()
state %>% count(folder)

state %>%
  mutate(folder = fct_relevel(as.factor(folder), "pretest", "newbies", "inspect")) %>%
  group_by(package) %>%
  mutate(cur = folder, prev = dplyr::lag(folder)) %>%
  ungroup() %>%
  filter(!is.na(prev)) %>%
  group_by(prev, cur) %>%
  summarise(n = n(), elapsed = mean(elapsed), .groups = "drop")
