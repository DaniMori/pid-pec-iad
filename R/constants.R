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

# Common objects (used by more than one component):

## File system objects:

### Directories:
DOCS_DIR <- here::here("doc")
DATA_DIR <- here::here("dat")
FAR_DIR  <- here::here("feedback-res") # "Feedback app" resources directory

### Variable names:
RESPONSE_VARS_FILENAME <- "student_response_variables.csv"
response_vars_filepath <- here::here(FAR_DIR, RESPONSE_VARS_FILENAME)

### Student responses file:
STUDENT_RESPONSES_FILENAME <- "student_responses.csv" # File name
student_responses_filepath <- here::here(FAR_DIR, STUDENT_RESPONSES_FILENAME)


# Event related constants:

## Variable values:
EVENT_TYPES <- c("Access", "Download") |> setNames(nm = _)

## Time and date configuration:
TIMESTAMP_FORMAT <- "%Y-%Om-%d %H:%M:%OS3 %Z" # With time zone at the end
LOCAL_TIMEZONE   <- "Europe/Madrid" # Local timezone for the event timestamps

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

### Variable names:
EMAIL_HASH_VAR <- "email_hash" # Variable for storing the hashed emails


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

## Additional values for score computing:
BONUS_MAX <- 0.5 # Maximum grading bonus (if responding all the items correctly)


## User interface objects:

### Shiny component identifiers:
RESPONSE_TABLE_ID <- "responses"
BONUS_OUTPUT_ID   <- "bonus"

### Interface verbatim:

#### Static components:
FEEDBACK_APP_TITLE <- "Respuestas de la actividad optativa con Jamovi"
BONUS_OUTPUT_LABEL <- "Tu bonificación en la nota:"

#### Response output table headers & labels:
ITEM_NUM_LABEL         <- "Nº"
ITEM_LABEL             <- "Pregunta"
STUDENT_RESPONSE_LABEL <- "Tu respuesta"
CORRECT_RESPONSE_LABEL <- "Respuesta correcta"
VALID_RESPONSE_LABEL   <- "Acierto"
SCORE_LABEL            <- "Puntuación"
TOTAL_SCORE_LABEL      <- htmltools::strong("TOTAL:") |> as.character()
