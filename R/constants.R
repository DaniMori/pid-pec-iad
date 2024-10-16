# ==============================================================================
#
# FILE NAME:   constants.R
# DESCRIPTION: Constant objects for the "Dataset generation" app.
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- CONSTANTS: -------------------------------------------------------------

# Shiny component identifiers:
DOWNLOAD_LINK_ID <- "download"

# Interface verbatim:
APP_TITLE           <- "Descarga de datos para actividad optativa con Jamovi"
DOWNLOAD_LINK_LABEL <-
  "Haz click aquí si la descarga no se inicia automáticamente"
CLOSE_WINDOW_MSG    <- paste(
  "(Cierra esta ventana cuando acabe la descarga",
  "para volver al curso virtual y continuar con la actividad)"
)
DATASET_FILENAME    <- "regresion_lineal.csv" # Name of downloaded dataset

# Server logic objects:

## Auto download configuration:
AUTO_DOWNLOAD_TIMEOUT <- 200L # Timeout (to start download) in milliseconds

## Google Spreadsheets authentication:
OAUTH_CACHE_PATH <- here::here(".secrets")
TOKEN_FILENAME   <- "encrypted-oauth-token.rds"
TOKEN_FILEPATH   <- here::here(OAUTH_CACHE_PATH, TOKEN_FILENAME)
KEY_VAR_NAME     <- "PID_PEC_IAD_KEY"

## Google Spreadsheets storage:
GS_BASE_URL <- "https://docs.google.com/spreadsheets/d"
FILE_ID_URL <- "1S-yq7bgqncOL83IHFVII5ufgygYSpU8-Kv-2BWk-pCc"
FILE_URL    <- paste(GS_BASE_URL, FILE_ID_URL, sep = '/')


# Simulated data objects:

## Variable names:
SIM_VAR_NAMES <- c("autonomia_laboral", "satisfaccion_laboral")
