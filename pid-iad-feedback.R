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
library(shinyjs, warn.conflicts = FALSE)
library(readr)
library(dplyr)


## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",      encoding = 'UTF-8')
source("R/simulated_data.R", encoding = 'UTF-8')
source("R/hash_emails.R",    encoding = 'UTF-8')
source("R/log.R",            encoding = 'UTF-8')

## ---- CONSTANTS: -------------------------------------------------------------

## ---- FUNCTIONS: -------------------------------------------------------------

## ----create-user-interface----------------------------------------------------

ui <- fluidPage(

  shinyjs::useShinyjs(), # Used to disable the download button

  # Application title
  titlePanel(FEEDBACK_APP_TITLE),

  fillPage(

    # Output table with the correct responses:
    tableOutput(RESPONSE_TABLE_ID)
  )
)

## ----create-server-logic------------------------------------------------------

server <- function(input, output, session) {

  # Read student responses
  responses <- read_csv(
    "dat/student_responses.csv",
    col_types = cols(
      email_hash   = col_integer(),
      relationship = col_character()
    )
  )

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

  ## Output renderer (activated when the email is valid)
  output[[RESPONSE_TABLE_ID]] <- renderTable(

    if (!is.null(hashed_email())) {

      solutions <- hashed_email() |>
        get_user_responses() |>
        format_responses(response_label = "Soluciones")

      responses <- responses |>
        filter(email_hash == hashed_email()) |>
        select(intercept, slope, relationship) |>
        format_responses(response_label = "Tus respuestas")

      full_join(responses, solutions, by = c(ITEM_NUM_LABEL, ITEM_LABEL))
    }
  )
}


## ---- MAIN: ------------------------------------------------------------------

# Run the application
shinyApp(ui = ui, server = server)
