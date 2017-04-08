#! /usr/bin/env Rscript

# Scraping list of instances

library(tidyverse)
library(stringr)
library(lubridate)

mastodon <- jsonlite::fromJSON("https://instances.mastodon.xyz/instances.json") %>%
  rename(instance = name,
         tootls = statuses,
         interconnectivity = connections) %>%
  mutate(date = lubridate::today("UTC"),
         time = lubridate::now("UTC"))

## Read old data, append new data

if (!file.exists("data")) {dir.create("data")}
if (file.exists("data/mastodon.rds")) {

old <- read_rds("data/mastodon.rds")
new <- bind_rows(old, mastodon)

## Write new, full data
write_rds(new, path = "data/mastodon.rds")
rm(old, new)

} else {
  write_rds(mastodon, path = "data/mastodon.rds")
}
