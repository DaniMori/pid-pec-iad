# ==============================================================================
#
# FILE NAME:   server.R
# DESCRIPTION: Server logic of the "Dataset generation" app for teaching
#              innovation project in "Introduction to Data Analysis".
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

setwd(here::here())


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs)
library(stringr)
library(tibble)
library(broom)
library(dplyr)
library(readr)

## ---- SOURCES: ---------------------------------------------------------------

source("R/email_input_component.R", encoding = 'UTF-8')
source("R/constants.R",             encoding = 'UTF-8')
source("R/simulate_data.R",         encoding = 'UTF-8')
source("R/hash_emails.R",           encoding = 'UTF-8')


## ---- MAIN: ------------------------------------------------------------------

## ----create-server-logic------------------------------------------------------

server <- function(input, output) {

  # Initial server configuration:

  email_valid    <- reactiveVal(FALSE) # Whether the email has been validated
  simulated_data <- reactiveVal()      # Simulated dataset

  ## File download handler (activated when the email is valid)
  output[[DOWNLOAD_BUTTON_ID]] <- downloadHandler(
    filename = "regresion_lineal.csv",
    content  = function(file) simulated_data() |> write_csv(file),
    contentType = "text/csv"
  )

  # Enable/disable the download button when the email is valid/invalid
  observeEvent( ## FIXME: Make button "unclickable"!
    email_valid(),
    toggleState(DOWNLOAD_BUTTON_ID, condition = email_valid())
  )

  email_input <- validateEmail(
    input, output,
    inputId       = EMAIL_INPUT_ID,
    domain        = UNED_STUDENT_EMAIL_DOMAIN,
    validate_func = is_valid_email
  )

  email_check <- validateEmail(
    input, output,
    inputId       = EMAIL_CHECK_ID,
    domain        = UNED_STUDENT_EMAIL_DOMAIN,
    validate_func = double_check_email,
    check_value   = reactive(email_input()$email)
  )

  # Validate email when both the input and the "double check" are valid
  observeEvent(
    email_input()$valid & email_check()$valid,
    email_valid(email_input()$valid & email_check()$valid)
  )

  observeEvent(
    email_valid(),
    {
      # Create unique hash for the student email:
      hashed_email <- email_input()$email |> hash_emails()

      # Generate simulated data with the hashed email as seed:
      simulated_data(simulate_data(hashed_email))
    }
  )
}
