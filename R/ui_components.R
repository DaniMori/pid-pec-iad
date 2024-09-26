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


## ---- CONSTANTS: -------------------------------------------------------------

# Shiny component identifiers:
EMAIL_INPUT_ID_SUFFIX <- "-input"

## ---- FUNCTIONS: -------------------------------------------------------------

email_input_id <- function(inputId) inputId |> paste0(EMAIL_INPUT_ID_SUFFIX)

email_input <- function(inputId, domain, label = NULL) {

  email_inputId <- email_input_id(inputId)

  layout_columns(
    textInput(inputId, label = label),
    tags$p(domain, style = "padding-top:31px;")
  )
}
