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

## Variable values:
EVENT_TYPES <- c("Access", "Download") |> setNames(nm = _)

## Time and date configuration:
TIMESTAMP_FORMAT <- "%Y-%Om-%d %H:%M:%OS3 %Z" # With time zone at the end
LOCAL_TIMEZONE   <- "Europe/Madrid" # Local timezone for the event timestamps

## ---- FUNCTIONS: -------------------------------------------------------------

# Function to create an event timestamp
timestamp <- lubridate::stamp(
  orders = TIMESTAMP_FORMAT,
  exact  = TRUE,
  quiet  = TRUE
)

# Function to parse stored timestamps
parse_timestamp <- function(timestamp) {

  time_zones <- timestamp |> stringr::str_extract(pattern = '(?<=\\s)[A-Z]+$')

  # The following parser will work as long as the timestamp format matches the
  #   value of `TIMESTAMP_FORMAT` in line 26.
  timestamp |>
    lubridate::ymd_hms() |>
    lubridate::force_tzs(tzones = time_zones, tzone_out = LOCAL_TIMEZONE)
}

get_storage_url <- function(config_filepath, field = "file_id") {

  # Constant objects: ----
  GS_BASE_URL <- "https://docs.google.com/spreadsheets/d"
  URL_SEP     <- '/'

  # Main: ----
  file_id <- yaml::read_yaml(config_filepath)[[field]]
  paste(GS_BASE_URL, file_id, sep = URL_SEP)
}

connect_gs <- function(file_url, token_path, key_varname) {

  ## TODO: Parse arguments

  # Main: ----

  ## Read & decrypt OAuth token
  gs_token <- gargle::secret_read_rds(
    path = token_path,
    key  = key_varname
  )

  ## Grant access with OAuth token
  googlesheets4::gs4_auth(token = gs_token)

  ## Get file link
  googlesheets4::gs4_get(file_url)
}

write_event <- function(hash, event = EVENT_TYPES) {

  # Constant objects: ----

  ## Time and date configuration:
  SERVER_TIMEZONE  <- "Europe/Madrid"

  ## Variable names:
  LOG_VAR_NAMES <- c(EMAIL_HASH_VAR, "timestamp", "event")


  # Argument parsing and formatting: ----
  ## TODO: Parse arguments
  event <- match.arg(event)

  # Main: ----

  timestamp <- lubridate::now()         |>
    lubridate::with_tz(SERVER_TIMEZONE) |>
    timestamp()

  event_data <- tibble::tibble(hash, timestamp, event) |>
    setNames(LOG_VAR_NAMES)

  suppressMessages( # Prevent logging
    googlesheets4::sheet_append(gs_file_link, event_data)
  )
}


## ---- MAIN: ---------------------------------------------------------

# Data storage configuration:
gs_file_link <- get_storage_url(CONFIG_FILEPATH) |> # Storage file URL
  connect_gs(                                       # Storage file connection
    token_path  = TOKEN_FILEPATH,
    key_varname = KEY_VAR_NAME
  )
