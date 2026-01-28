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


## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",              encoding = 'UTF-8')
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

    # Output table with the correct responses:
    tableOutput(RESPONSE_TABLE_ID)
  )
)

## ----create-server-logic------------------------------------------------------

server <- function(input, output, session) {

  # Reactive values:
  email        <- reactiveVal() # Email read from the session query
  hashed_email <- reactiveVal() # Hashed email for logging and random seed

  observe(
    {
      # Get email from query:
      email(parseQueryString(session$clientData$url_search)$email)

      validate_email(email()) # Check that email is valid in the first place
      record_log("Email valid")

      ## Create unique hash for the user email:
      hashed_email(email() |> hash_emails())
      record_log("Email hash created")
    }
  )

  ## File download handler (activated when the email is valid)
  output[[RESPONSE_TABLE_ID]] <- renderTable(

    if (!is.null(hashed_email())) {

      correct_responses <- hashed_email() |> get_correct_responses()

        student_responses <- data_student_responses |>
        filter(email_hash == hashed_email())
      }
  )
}


## ---- MAIN: ------------------------------------------------------------------

# Run the application
shinyApp(ui = ui, server = server)
