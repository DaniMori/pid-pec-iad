# ==============================================================================
#
# FILE NAME:   deploy.R
# DESCRIPTION: Utility function for deploying app to Posit Connect Cloud
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
APP_MAIN <- "data-download.R"
APP_NAME <- "Data Download App"


## ---- MAIN: -------------------------------------------------------------

deploy_app(
  main      = APP_MAIN,
  app_files = c(
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

