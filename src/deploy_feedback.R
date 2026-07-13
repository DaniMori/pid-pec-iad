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
  app_files = c( # TODO: Update app files
    "app.R",
    ".Renviron",
    ".secrets/encrypted-oauth-token.rds",
    "doc/gsheets_config.yml",
    "feedback-res/student_response_variables.csv",
    "R/_disable_autoload.R",
    "R/constants.R",
    "R/data_storage.R",
    "R/hash_emails.R",
    "R/log.R",
    "R/simulated_data.R"
  ),
  app_name  = APP_NAME
)

