library(readr)
library(magrittr)
library(data.table)
library(argparse)
suppressMessages(library(lubridate))

#' Set-up Script Inputs
#' ==============================
parser <- ArgumentParser()
parser$add_argument("-m", "--month",
                    help="Month to process (e.g. 201801)")
parser$add_argument("-s", "--seed",
                    help="Random seed")
args <- parser$parse_args()

#' Parse Args
#' ==============================
set.seed(args$seed)
input_path = paste0('data/raw/', args$month, '-citibike-tripdata.csv')
output_path = paste0('data/cleaned/', args$month, '.csv')

#' Clean and Write Data
#' ==============================
cat(paste0('\n', input_path))

raw = input_path %>%
  fread

raw %>%
  .[sample.int(n = nrow(raw)
               , size = floor(nrow(raw) * 0.04))] %>%
  .[ , starttime := ymd_hms(starttime)] %>%
  .[ , list(ds = as.Date(starttime)
            , start_hour = hour(starttime)
            , day_of_week = wday(starttime, label = T)
            , start_lat = `start station latitude`
            , start_lng = `start station longitude`
            , end_lat = `end station latitude`
            , end_lng = `end station longitude`
            , age = floor(year(starttime) - `birth year`)
            , gender
            , usertype)] %>%
  write_csv(., path = output_path)
