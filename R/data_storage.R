# ==============================================================================
#
# FILE NAME:   data_storage.R
# DESCRIPTION: Functionality to store the app data in a remote Google
#              Spreadsheets file
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-16
#
# ==============================================================================


## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R", encoding = 'UTF-8')

## ---- CONSTANTS: -------------------------------------------------------------

# Event related constants:

## Variable names:
VAR_NAMES <- c("email_hash", "timestamp", "event")

## Variable values:
EVENT_TYPES <- c("Access", "Download") |> setNames(nm = _)

## Time and date configuration:
SERVER_TIMEZONE  <- "Europe/Madrid"
TIMESTAMP_FORMAT <- "%Y-%Om-%d %H:%M %Z" # With time zone at the end

## ---- FUNCTIONS: -------------------------------------------------------------

# Function to create an event timestamp
timestamp <- lubridate::stamp(
  orders = TIMESTAMP_FORMAT,
  exact = TRUE,
  quiet = TRUE
)

connect_gs <- function(file_url, token_path, key_varname) {
  ## TODO: Parse arguments

  # Read & decrypt OAuth token
  gs_token <- gargle::secret_read_rds(
    path = token_path,
    key  = key_varname
  )

  # Grant access with OAuth token
  googlesheets4::gs4_auth(token = gs_token)

  # Get file link
  googlesheets4::gs4_get(file_url)
}

write_event <- function(hash,
                        event = EVENT_TYPES) {
  ## TODO: Parse arguments
  event <- match.arg(event)

  ## Main: ----

  timestamp <- lubridate::now()         |>
    lubridate::with_tz(SERVER_TIMEZONE) |>
    timestamp()

  event_data <- tibble::tibble(hash, timestamp, event) |>
    setNames(VAR_NAMES)

  suppressMessages( # Prevent logging
    googlesheets4::sheet_append(gs_file_link, event_data)
  )
}

## ---- CONFIGURATION: ---------------------------------------------------------

# Data storage configuration:
gs_file_link <- connect_gs( # Google Spreadsheets file connection
  FILE_URL,
  token_path  = TOKEN_FILEPATH,
  key_varname = KEY_VAR_NAME
)
