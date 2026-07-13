# ==============================================================================
#
# FILE NAME:   deploy_app.R
# DESCRIPTION: Utility function for deploying app to Posit Connect Cloud
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2026-07-13
#
# ==============================================================================


## ---- CONSTANTS: -------------------------------------------------------------

# UI OBJECTS:
ACCOUNT_PROMPT <- "Enter the publication account: "

# POSIT CONNECT PUBLICATION OBJECTS:
PCC_SERVER  <- "connect.posit.cloud"

## ---- FUNCTIONS: -------------------------------------------------------------

deploy_app <- function(main,
                       app_files,
                       app_name,
                       account = readline(prompt = ACCOUNT_PROMPT),
                       server = PCC_SERVER) {
  ## Constants: ----
  PCC_MAIN <- "app.R" # File name for every Shiny app entry point R script

  ## Argument checking and formatting: ----

  ## Main: ----
  withr::local_file(PCC_MAIN)

  file.copy(main, PCC_MAIN)

  rsconnect::deployApp(
    appFiles      = app_files,
    appName       = app_name,
    appPrimaryDoc = PCC_MAIN,
    account       = account,
    server        = server,
    forceUpdate   = TRUE
  )
}
