#! /usr/bin/env Rscript

# Toot a random instance name
library(jsonlite)
library(dplyr)
library(readr)
library(stringr)
library(mastodon) # devtools::install_github('ThomasChln/mastodon')
library(ggplot2)
library(tadaatoolbox) # Only for the plot theme

mastodon <- read_rds("data/mastodon.rds")

instance <-  mastodon %>%
  filter(time == max(time, na.rm = TRUE)) %>%
  select(instance, users, toots, open_reg)

diceroll <- ceiling(as.numeric(format(Sys.time(), "%s"))/60) %% nrow(instance)
instance <- instance %>% slice(sample(diceroll, 1))

toot <- paste0(instance$instance,
               "\n", instance$users, " User(s), ",
               instance$toots, " Toots\n…is currently ",
               str_to_upper(instance$open_reg), "!")

mastodon %>%
  filter(instance == instance$instance) %>%
  ggplot(data = ., aes(x = time, y = users, fill = open_reg)) +
  geom_path() +
  geom_point(shape = 21, colour = "black", size = 2, stroke = .5) +
  labs(title = "Instance User History",
       subtitle = instance$instance,
       x = "Date", y = "User #", fill = "Registrations",
       caption = format(Sys.time(), '%F %H:%M (%Z)')) +
  tadaatoolbox::theme_readthedown() +
  theme(legend.position = "top") -> plot

## Toot stuff out
# Using devtools::install_github('ThomasChln/mastodon')

credentials <- jsonlite::fromJSON("~/.config/mastodon-rstats.json")

token <- login(credentials$url, credentials$user, credentials$pass)

#post_status(token, toot)

post_ggplot(token, toot, plot)
