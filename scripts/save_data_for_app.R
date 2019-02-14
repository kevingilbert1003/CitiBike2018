library(magrittr)
library(data.table)

#' Load Data
#' =======================
raw =
  list.files('data/cleaned/') %>%
  file.path('data/cleaned', .) %>%
  lapply(., fread) %>%
  rbindlist() 

set.seed(124)
index = sample.int(n = nrow(raw), size = 50000)

saveRDS(raw[index], file = 'citibike2018/data/raw.Rds')
