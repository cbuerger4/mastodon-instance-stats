# Scraping list of instances

library(rvest)
library(tidyverse)
library(stringr)
library(purrr)
library(lubridate)

instances <- read_html("https://github.com/tootsuite/mastodon/blob/master/docs/Using-Mastodon/List-of-Mastodon-instances.md") %>%
               html_nodes("td:nth-child(1)") %>%
  html_text()


# Get instance stats

get_instance_stats <- function(instance_url) {

  instance_page <- paste0("https://", instance_url, "/about/more")

  raw_html <- tryCatch(read_html(instance_page), error = function(e) return(NA), finally = NA)
  if (is.na(raw_html)) {
    return(tibble(instance = instance_url,
                  users = NA,
                  toots = NA,
                  interconnectivity = NA))
  }

  users <- raw_html %>%
    html_node(".section:nth-child(1) strong") %>%
    html_text() %>%
    str_replace_all(",", "") %>%
    as.numeric()

  toots <- raw_html %>%
    html_node(".section:nth-child(2) strong") %>%
    html_text() %>%
    str_replace_all(",", "") %>%
    as.numeric()

  interconnect <- raw_html %>%
    html_node(".section~ .section+ .section strong") %>%
    html_text() %>%
    str_replace_all(",", "") %>%
    as.numeric()

  result <- tibble(instance = instance_url,
                   users = users,
                   toots = toots,
                   interconnectivity = interconnect)
  return(result)
}


## Aggregate list of per-instance stats

mastodon <- purrr::map_df(instances, function(x) {print(x); return(get_instance_stats(x))})

## Append timestamps
mastodon %<>%
  mutate(date = lubridate::today("UTC"),
         time = lubridate::now("UTC"))

## Read old data, append new data
old <- read_rds("data/mastodon.rds")
new <- bind_rows(old, mastodon)

## Write new, full data
write_rds(new, path = "data/mastodon.rds")
