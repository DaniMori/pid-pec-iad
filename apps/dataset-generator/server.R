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

  disable(DOWNLOAD_BUTTON_ID) # Disable download button (until a valid email
                              #   is input and confirmed)

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

  # Enable the download button when the email is valid
  observeEvent(
    email_valid(),
    if (email_valid()) enable(DOWNLOAD_BUTTON_ID)
    else               disable(DOWNLOAD_BUTTON_ID)
  )
    {
      # Create unique hash for the student email:
      hashed_email <- email_input()$email |> hash_emails()

      # Generate simulated data with the hashed email as seed:
      simulated_data(simulate_data(hashed_email))
    }
  )
}
