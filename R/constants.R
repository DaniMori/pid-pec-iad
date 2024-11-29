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
ASSETS_DIR <- here::here("www")


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
DATASET_FILENAME    <- "regresion_lineal.csv" # Name of downloaded dataset

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
CONFIG_FILEPATH <- here::here(ASSETS_DIR, CONFIG_FILENAME)


# Feedback app:

## User interface objects:

### Shiny component identifiers:
RESPONSE_TABLE_ID <- "responses"

### Interface verbatim:

#### Static components:
FEEDBACK_APP_TITLE  <- "Respuetas de la actividad optativa con Jamovi"


# Simulated data objects:

## Variable names:
SIM_VARIABLES <- c("predictor",         "criterion")
SIM_VAR_NAMES <- c("autonomia_laboral", "satisfaccion_laboral") |>
  setNames(SIM_VARIABLES)

## Variable data:
SAMPLE_SIZE       <- 50:200 # Uniformly random sample size of 50-200 cases
PREDICTOR_SCORES  <-  0: 10 # Possible scores in the predictor variable
CRITERION_SCORES  <-  1:  5 # Possible scores in the criterion variable

## Response configuration data:
N_DECIMALS     <- 2L # Decimal places to use for rounding numeric results
