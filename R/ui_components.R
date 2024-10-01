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
EMAIL_LABEL_ID_SUFFIX <- "-label"
EMAIL_CHECK_ID_SUFFIX <- "-checkmark"

# Shiny component verbatim:
EMAIL_PLACEHOLDER <- "Nombre de usuario"

## ---- FUNCTIONS: -------------------------------------------------------------

email_input_id <- function(inputId) inputId |> paste0(EMAIL_INPUT_ID_SUFFIX)
email_label_id <- function(inputId) inputId |> paste0(EMAIL_LABEL_ID_SUFFIX)
email_check_id <- function(inputId) inputId |> paste0(EMAIL_CHECK_ID_SUFFIX)

# Adapter from (nonexposed) `shiny:::shinyInputLabel()`
email_label <- function(inputId, label = NULL) {

  htmltools::tags$label(
    label,
    class = "control-label",
    class = if (is.null(label)) "shiny-label-null",
    id    = email_label_id(inputId),
    `for` = email_input_id(inputId)
  )
}

email_input <- function(inputId,
                        domain,
                        label       = NULL,
                        placeholder = EMAIL_PLACEHOLDER) {

  value <- shiny::restoreInput(id = inputId, default = "")

  htmltools::tags$div(
    class = "form-group shiny-input-container",
    style = NULL,
    email_label(inputId, label = label),
    bslib::layout_columns(
      htmltools::tags$input(
        id          = email_input_id(inputId),
        type        = "text",
        class       = "shiny-input-text form-control",
        value       = value,
        placeholder = placeholder
      ),
      htmltools::tags$p(domain, style = "padding-top:6px; margin-left:-8px;"),
      shiny::imageOutput(email_check_id(inputId), height = '40px', width = '40px')
    )
  )
}
