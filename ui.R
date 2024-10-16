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


## ---- GLOBAL OPTIONS: --------------------------------------------------------

setwd(here::here())


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs)

## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R", encoding = 'UTF-8')


## ---- MAIN: ------------------------------------------------------------------

## ----create-user-interface----------------------------------------------------

ui <- fluidPage(

  shinyjs::useShinyjs(), # Used to disable the download button

  # Application title
  # TODO: Decide title & add logos (if necessary)
  titlePanel(APP_TITLE),

  fillPage(

    # Download link:
    downloadLink(DOWNLOAD_LINK_ID, DOWNLOAD_LINK_LABEL),

    tags$div(tags$p(CLOSE_WINDOW_MSG), style="margin-top:2em;")
  )
)
