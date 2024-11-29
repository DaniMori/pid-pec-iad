# ==============================================================================
#
# FILE NAME:   ui.R
# DESCRIPTION: User interface of the "Feedback" app for teaching innovation
#              project in "Introduction to Data Analysis".
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-11-29
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

setwd(here::here())


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs, warn.conflicts = FALSE)


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

    # Output table with the correct responses:
    tableOutput(RESPONSE_TABLE_ID)
  )
)
