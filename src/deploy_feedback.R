# ==============================================================================
#
# FILE NAME:   deploy_feedback.R
# DESCRIPTION: Script for deploying the Feedback app to Posit Connect Cloud
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2026-07-13
#
# ==============================================================================


## ---- SOURCES: ---------------------------------------------------------------

source("R/deploy_app.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# APPLICATION OBJECTS:
APP_MAIN <- "pid-iad-feedback.R"
APP_NAME <- "Feedback App"


## ---- MAIN: -------------------------------------------------------------

deploy_app(
  main      = APP_MAIN,
  app_files = c(
    ".Renviron",
    ".secrets/encrypted-oauth-token.rds",
    "feedback-res/student_response_variables.csv",
    "feedback-res/student_responses.csv",
    "R/constants.R",
    "R/hash_emails.R",
    "R/log.R",
    "R/read_student_responses.R",
    "R/score_responses.R",
    "R/simulated_data.R"
  ),
  app_name  = APP_NAME
)

