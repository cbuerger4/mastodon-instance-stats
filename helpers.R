# Helpers
library(rvest)
library(stringr)
library(magrittr)

## Domain categorization/parsing

wiki <- read_html("https://en.wikipedia.org/wiki/List_of_Internet_top-level_domains") %>%
  html_table(fill = TRUE)

originalTLD <-
  wiki[[2]] %>%
  select(1, 2) %>%
  set_colnames(c("tld", "description")) %>%
  mutate(type = "originalTLD")

ccTLD <-
  wiki[[5]] %>%
  select(1, 2) %>%
  set_colnames(c("tld", "description")) %>%
  mutate(type = "ccTLD")

genericTLD <-
  bind_rows(wiki[7:15]) %>%
  select(1, 2) %>%
  set_colnames(c("tld", "description")) %>%
  mutate(type = "genericTLD")

geographicTLD <-
  bind_rows(wiki[20:25]) %>%
  select(1, 2) %>%
  set_colnames(c("tld", "description")) %>%
  mutate(type = "geographicTLD")

brandTLD <-
  bind_rows(wiki[27]) %>%
  select(1, 2) %>%
  set_colnames(c("tld", "description")) %>%
  mutate(type = "brandTLD")


TLDs <- bind_rows(originalTLD, ccTLD, genericTLD, geographicTLD, brandTLD) %>%
  mutate(type = factor(type, levels = c("originalTLD", "ccTLD",
                                        "genericTLD", "geographicTLD",
                                        "brandTLD"), ordered = T))

rm(originalTLD, ccTLD, genericTLD, geographicTLD, brandTLD)

write_rds(TLDs, "TLDs.rds")
