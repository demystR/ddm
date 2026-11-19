# Shared set-up, run before every chapter (see before_chapter_script in _bookdown.yml).

options(width = 80, digits = 3)

knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.width = 7,
  fig.height = 4,
  out.width = "100%"   # scale every figure to the width of the page
)

set.seed(1)

suppressPackageStartupMessages(library(tidyverse))
theme_set(theme_minimal(base_size = 13))

# The book's functions: the DDM itself, and plotting helpers for the figures.
source("R/ddm_functions.R")
source("R/ddm_plots.R")

# rtdists is optional: chapters use it only to check our own functions.
has_rtdists <- requireNamespace("rtdists", quietly = TRUE)

# webexercises is optional too; without it, quiz boxes show as plain fields.
if (requireNamespace("webexercises", quietly = TRUE)) {
  library(webexercises)
} else {
  fitb <- function(answer, width = "10em", ...) {
    paste0("<input type=\"text\" disabled=\"disabled\" placeholder=\"answer\" style=\"width:",
           width, ";\">")
  }
  mcq <- function(answer, ...) {
    options <- paste0("<option>", as.character(answer), "</option>", collapse = "")
    paste0("<select disabled=\"disabled\"><option></option>", options, "</select>")
  }
  hide <- function(button_text = "Solution") paste0("<details><summary>", button_text, "</summary>")
  unhide <- function() "</details>"
}

# Copy the data and functions into docs/ so the book can link to them.
for (folder in c("data", "R")) {
  dir.create(file.path("docs", folder), recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(folder, full.names = TRUE), file.path("docs", folder), overwrite = TRUE)
}

# Copy the browser widgets into docs/ (edit the files in apps/, not the copies).
for (widget in c("rdm")) {
  dir.create(file.path("docs", "apps", widget), recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path("apps", widget, "embed.html"), file.path("docs", "apps", widget, "embed.html"),
            overwrite = TRUE)
}
