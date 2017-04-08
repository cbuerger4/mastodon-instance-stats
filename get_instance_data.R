#! /usr/bin/env Rscript

# Scraping list of instances

library(tidyverse)
library(stringr)
library(lubridate)

mastodon <- jsonlite::fromJSON("https://instances.mastodon.xyz/instances.json") %>%
  rename(instance = name,
         toots = statuses,
         interconnectivity = connections) %>%
  mutate(date = lubridate::today("UTC"),
         time = lubridate::now("UTC"))

mastodon$open_reg <- sapply(mastodon$openRegistrations, function(x) {
                                if(is.null(x[[1]])) {
                                  return(as.logical(NA))
                                } else {
                                  return(as.logical(x[[1]]))
                                }
                              }, simplify = T, USE.NAMES = F)

mastodon <- mastodon %>%
  mutate(open_reg = if_else(open_reg, "Open",
                            if_else(!open_reg, "Closed", "Unknown")))

## Read old data, append new data

if (!file.exists("data")) {dir.create("data")}
if (file.exists("data/mastodon.rds")) {

old <- read_rds("data/mastodon.rds") %>% select(-openRegistrations)
new <- bind_rows(old, mastodon)

## Write new, full data
write_rds(new, path = "data/mastodon.rds")
rm(old, new)

} else {
  write_rds(mastodon, path = "data/mastodon.rds")
}
