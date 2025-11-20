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

# File system objects:
DOCS_DIR <- here::here("doc")
DATA_DIR <- here::here("dat")


# Dataset generation app:

## User interface objects:

### Shiny component identifiers:
DOWNLOAD_LINK_ID <- "download"

### Interface verbatim:
GEN_DATA_APP_TITLE  <- "Descarga de datos para actividad optativa con Jamovi"
DOWNLOAD_LINK_LABEL <-
  "Haz click aquí si la descarga no se inicia automáticamente"
CLOSE_WINDOW_MSG    <- paste(
  "(Cierra esta ventana cuando acabe la descarga",
  "para volver al curso virtual y continuar con la actividad)"
)
DATASET_FILENAME    <- "datos_IAD.csv" # Name of downloaded dataset

## Server logic objects:

### Auto download configuration:
AUTO_DOWNLOAD_TIMEOUT <- 200L # Timeout (to start download) in milliseconds

### Google Spreadsheets configuration:

#### Authentication:
OAUTH_CACHE_PATH <- here::here(".secrets")
TOKEN_FILENAME   <- "encrypted-oauth-token.rds"
TOKEN_FILEPATH   <- here::here(OAUTH_CACHE_PATH, TOKEN_FILENAME)
KEY_VAR_NAME     <- "PID_PEC_IAD_KEY"

#### Storage file:
CONFIG_FILENAME <- "gsheets_config.yml"
CONFIG_FILEPATH <- here::here(DOCS_DIR, CONFIG_FILENAME)


# Feedback app:

## User interface objects:

### Shiny component identifiers:
RESPONSE_TABLE_ID <- "responses"

### Interface verbatim:

#### Static components:
FEEDBACK_APP_TITLE  <- "Respuestas de la actividad optativa con Jamovi"
