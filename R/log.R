# ==============================================================================
#
# FILE NAME:   logs.R
# DESCRIPTION: Utility for logging messages in Shiny apps
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-18
#
# ==============================================================================


## ---- CONSTANTS: -------------------------------------------------------------

# Log output objects:
NEW_LINE <- '\n'

## ---- FUNCTIONS: -------------------------------------------------------------

record_log <- function(message) {

  if (!is.null(message)) cat(file = stderr(), message, NEW_LINE)
}
