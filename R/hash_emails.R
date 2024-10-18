# ==============================================================================
#
# FILE NAME:   hash_emails.R
# DESCRIPTION: Encrypts emails using a hash function
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-09
#
# ==============================================================================


## ---- SOURCES: ---------------------------------------------------------------

source("R/log.R", encoding = 'UTF-8')


## ---- FUNCTIONS: -------------------------------------------------------------

hash_emails <- function(emails) {

  emails |> digest::digest() |> digest::digest2int()
}

validate_email <- function(email) {

  if (is.null(email)) shiny::validate("Email must not be empty.")

  validate <- shinyvalidate::sv_email() # Email validation function
  result   <- validate(email)           # Call validation function

  record_log(result) # Log the validation message

  shiny::validate(result)
}
