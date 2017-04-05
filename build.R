#! /usr/bin/env Rscript

# Get data
source("get_instance_data.R")

# Render analysis
rmarkdown::render("analysis.Rmd")
