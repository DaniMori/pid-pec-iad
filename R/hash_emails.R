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


## ---- FUNCTIONS: -------------------------------------------------------------

hash_emails <- function(emails) {

  emails |> digest::digest() |> digest::digest2int()
}

validate_email <- function(email) {

  validate <- shinyvalidate::sv_email()
  result <- validate(email)
  if (!is.null(result)) print(result)
  if (is.null(email)) shiny::validate("Email must not be empty.")

  shiny::validate(result)
}
