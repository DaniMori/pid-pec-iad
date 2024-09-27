# ==============================================================================
#
# FILE NAME:   ui.R
# DESCRIPTION: User interface of the "Dataset generation" app for teaching
#              innovation project in "Introduction to Data Analysis".
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs)
library(bslib)

## ---- SOURCES: ---------------------------------------------------------------

source("../../R/ui_components.R", encoding = 'UTF-8')
source("../../R/constants.R",     encoding = 'UTF-8')


## ---- MAIN: ------------------------------------------------------------------

## ----create-user-interface----------------------------------------------------

ui <- fluidPage(

  shinyjs::useShinyjs(), # Used to disable the download button

  # Application title
  # TODO: Decide title & add logos (if necessary)
  titlePanel(APP_TITLE),

  sidebarLayout(

    # Sidebar with the email input:
    sidebarPanel(
      email_input(
        EMAIL_INPUT_ID,
        domain = UNED_STUDENT_EMAIL_DOMAIN,
        label  = EMAIL_INPUT_LABEL
      ),
      email_input(
        EMAIL_CHECK_ID,
        domain = UNED_STUDENT_EMAIL_DOMAIN,
        label  = EMAIL_CHECK_LABEL
      ),
      width = 6
    ),

    # Main page with the download button:
    mainPanel(
      downloadButton(DOWNLOAD_BUTTON_ID, DOWNLOAD_BUTTON_LABEL),
      width = 6
    )
  )
)
