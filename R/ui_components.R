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
library(here)


## ---- CONSTANTS: -------------------------------------------------------------

# Shiny component identifiers:
EMAIL_INPUT_ID_SUFFIX <- "-input"
EMAIL_LABEL_ID_SUFFIX <- "-label"
EMAIL_CHECK_ID_SUFFIX <- "-checkmark"

# Shiny component verbatim:
EMAIL_PLACEHOLDER <- "Nombre de usuario"

# Email validation values:
INPUT_EMPTY   <- ""
EMAIL_BLANK   <- "blank"
EMAIL_VALID   <- "valid"
EMAIL_INVALID <- "invalid"

# File system values:
ASSETS_DIR        <- here("www")
BLANK_ICON_PATH   <- here(ASSETS_DIR, "blank.png")
VALID_ICON_PATH   <- here(ASSETS_DIR, "valid.png")
INVALID_ICON_PATH <- here(ASSETS_DIR, "invalid.png")

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

emailInput <- function(inputId,
                       domain,
                       label       = NULL,
                       placeholder = EMAIL_PLACEHOLDER) {

  value <- shiny::restoreInput(id = inputId, default = INPUT_EMPTY)

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
      htmltools::tags$p(domain, style = "padding-top:6px; margin-left:-8px; padding-right:100px;"),
      shiny::imageOutput(email_check_id(inputId), height = '40px', width = '40px', inline = TRUE, fill = TRUE)
    )
  )
}

validateEmail <- function(input,
                          output,
                          # session,
                          inputId,
                          domain,
                          validate_function,
                          ...) { # Additional arguments to `validate_function()`
  # Reactive input values:
  email_value <- reactiveVal(INPUT_EMPTY)
  email_state <- reactiveVal(EMAIL_BLANK) # Email validation state

  # Compute reactive value with complete email address & validate it
  observeEvent(
    input[[email_input_id(inputId)]], # React to changes in email input
    {
      username <- input[[email_input_id(inputId)]]

      # Email validation logic:
      if (username == INPUT_EMPTY) {

        email_state(EMAIL_BLANK)

      } else {

        # Create complete email address:
        email_value(username |> paste0(domain))

        if (validate_function(email_value(), ...)) email_state(EMAIL_VALID)
        else                                       email_state(EMAIL_INVALID)
      }
    }
  )

  # Render verification mark
  output[[email_check_id(EMAIL_INPUT_ID)]] <- renderImage(
    {
      list(
        src = switch(
          email_state(),
          blank      = BLANK_ICON_PATH,
          valid      = VALID_ICON_PATH,
          invalid    = INVALID_ICON_PATH
        ),
        width  = '40px',
        height = '40px'
      )
    },
    deleteFile = FALSE
  )

  output[[text_id(inputId)]] <- shiny::renderText(
    paste0(select_path(), collapse = PATHS_COLLAPSE)
  )

  shiny::reactive(
    list(email = email_value(), valid = email_state() == EMAIL_VALID)
  )
}
