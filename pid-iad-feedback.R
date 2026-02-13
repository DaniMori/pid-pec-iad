# ==============================================================================
#
# FILE NAME:   pid-iad-feedback.R
# DESCRIPTION: "Feedback" app for teaching innovation project in the
#              "Introduction to Data Analysis" course.
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-11-29
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

setwd(here::here())


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(htmltools)


## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",              encoding = 'UTF-8')
source("R/read_student_responses.R", encoding = 'UTF-8')
source("R/score_responses.R",        encoding = 'UTF-8')
source("R/hash_emails.R",            encoding = 'UTF-8')
source("R/log.R",                    encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# Constant objects for handling the student responses:

## File system objects for processing the student responses dataset:

data_student_responses <- student_responses_filepath |> readr::read_csv(
  col_types = readr::cols(
    email_hash = readr::col_integer(),
    item_5     = readr::col_factor(levels = LOGICAL_LABELS),
    item_7     = readr::col_factor(levels =  ITEM_7_LABELS),
    item_10    = readr::col_factor(levels = ITEM_10_LABELS),
    .default   = readr::col_double()
  )
)


## ---- FUNCTIONS: -------------------------------------------------------------

## ----create-user-interface----------------------------------------------------
ui <- fluidPage(

  # Application title
  titlePanel(FEEDBACK_APP_TITLE),

  fillPage(

    tags$br(),

    tags$p(
      tags$strong(BONUS_OUTPUT_LABEL),
      textOutput(BONUS_OUTPUT_ID, inline = TRUE)
    ),

    tags$br(),

    # Output table with the correct responses:
    tableOutput(RESPONSE_TABLE_ID)
  )
)

## ----create-server-logic------------------------------------------------------
server <- function(input, output, session) {

  # Reactive values:
  hashed_email <- reactiveVal() # Hashed email for logging and random seed
  bonus_output <- reactiveVal() # Bonus output to show in the UI

  observe(
    {
      # Get email from query:
      email <- parseQueryString(session$clientData$url_search)$email

      validate_email(email) # Check that email is valid in the first place
      record_log("Email valid")

      ## Create unique hash for the user email:
      hashed_email(email |> hash_emails())
      record_log("Email hash created")
    }
  )

  ## Table output (activated when the email is valid and the hash computed)
  output[[RESPONSE_TABLE_ID]] <- renderTable(
    {
      hash <- hashed_email()

      if (!is.null(hash)) {

        correct_responses <- hash |>
          get_correct_responses() |>
          tibble::add_column(email_hash = hash)

        student_responses <- data_student_responses |>
          filter_student(hash = hash)

        scored_responses <- score_student_responses(
          student_responses,
          correct_responses
        )

        bonus_output(scored_responses |> get_bonus())

        scored_responses |> format_responses()
      }
    },
    stripped = TRUE,
    bordered = TRUE,
    na       = '',
    sanitize.text.function = identity # Avoid escaping HTML tags in "TOTAL"
  )

  ## Bonus output (activated when the email is valid and the hash computed)
  output[[BONUS_OUTPUT_ID]] <- renderText(
    bonus_output() |>
      scales::number(accuracy =  .01, prefix = '+') # Format for putting out
  )
}


## ---- MAIN: ------------------------------------------------------------------

# Run the application
shinyApp(ui = ui, server = server)
