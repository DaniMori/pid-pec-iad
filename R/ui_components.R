# ==============================================================================
#
# FILE NAME:   ui_components.R
# DESCRIPTION: Additional custom user interface components for the "Dataset
#              generation" app.
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(bslib)


## ---- FUNCTIONS: -------------------------------------------------------------

email_input <- function(inputId, domain, label = NULL) {

  layout_columns(
    textInput(inputId, label = label),
    tags$p(domain, style = "padding-top:31px;")
  )
}
