#! /usr/bin/env Rscript

# Toot a random instance name
library(jsonlite)
library(dplyr)
library(readr)
library(stringr)

instance <- read_rds("data/mastodon.rds") %>%
  filter(time == max(time, na.rm = TRUE)) %>%
  select(instance, users, toots, open_reg) %>%
  slice(sample(nrow(.), 1))

toot <- paste0(instance$instance,
               " (", instance$users, " User(s), ",
               instance$toots, " Toot(s), and currently ",
               str_to_upper(instance$open_reg), "!")
toot <- paste0("'", toot, "'")

system(command = paste("toot", toot))
