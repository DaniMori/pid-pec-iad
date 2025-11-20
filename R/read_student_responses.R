# ==============================================================================
#
# FILE NAME:   read_student_responses.R
# DESCRIPTION: Functionality for reading the responses provided by the students
#              to the activity
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2025-11-20
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",   encoding = 'UTF-8')
source("R/hash_emails.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# File system objects:
RESPONSE_VARS_FILENAME <- "student_response_variables.csv"
response_vars_filepath <- here::here(DATA_DIR, RESPONSE_VARS_FILENAME)


# Constant objects for processing the student responses dataset:

## Variale parsing:
local_cdm <- readr::locale(decimal_mark = ',') # "comma-decimal-mark" locale

## Symbols for selecting and processing "numeric" items
num_items_selection <- rlangh::quo(
  tidyselect::all_of('item_' |> paste0(c(6, 8:9)))
)


## Variable values:
HELP_VALUES       <- c("1 - Nada", "2 - Un poco", "3 - Algo", "4 - Mucho")
USEFULNESS_VALUES <- c(
  "1 - Nada útiles",
  "2 - Poco útiles",
  "3 - Algo útiles",
  "4 - Muy útiles"
)
CLARITY_VALUES    <- c(
  "1 - Nada claras",
  "2 - Poco claras",
  "3 - Algo claras",
  "4 - Muy claras"
)

## e-mail domain for filtering out test responses:
PROFESSOR_EMAIL_DOMAIN <- "@psi.uned.es"

## Variable name objects:
response_vars_labels <- response_vars_filepath |>
  readr::read_csv(col_types = "c") |>
  tibble::deframe()

## ---- FUNCTIONS: -------------------------------------------------------------
read_student_responses <- function(filepath,
                                   test          = FALSE,
                                   filter_domain = PROFESSOR_EMAIL_DOMAIN,
                                   delete_ws     = FALSE) {

  responses <- readr::read_csv(filepath) |>
    dplyr::rename(!!!response_vars_labels) |>
    dplyr::mutate(
      email_hash = email_address |> purrr::map_int(hash_emails),
      date = date |>
        lubridate::parse_date_time(orders = "%d%B%Y %H%M") |>
        lubridate::force_tz(tzone = LOCAL_TIMEZONE)
    )

  # Ad-hoc whitespace deletion of some entries:
  if (delete_ws) {

    # TODO: Change input form fields to "numeric" for these items (instead of
    #       "text")
    responses <- responses |> dplyr::mutate(
      dplyr::across(!!num_items_selection, ~stringr::str_remove_all(., '\\h+'))
    )
  }

  responses <- responses |> dplyr::mutate(
    dplyr::across(
      !!num_items_selection,
      ~readr::parse_number(., locale = local_cdm)
    ),
    dplyr::across(
      tidyselect::starts_with("help"),
      ~ordered(., levels = HELP_VALUES)
    ),
    dplyr::across(usefulness_videos, ~ordered(., levels = USEFULNESS_VALUES)),
    dplyr::across(instructions,      ~ordered(., levels = CLARITY_VALUES)),
    nps = nps |> str_extract("^\\d*") |> as.integer()
  )

  if (!test) {

    # Filter out the teaching team emails (i.e. the ones that match the "professor
    #   domain").
    responses <- responses |> dplyr::filter(
      email_address |> stringr::str_detect(filter_domain, negate = TRUE)
    )
  }

  return(responses)
}
