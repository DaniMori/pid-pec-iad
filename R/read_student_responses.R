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

source("R/constants.R",      encoding = 'UTF-8')
source("R/hash_emails.R",    encoding = 'UTF-8')
source("R/simulated_data.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# Constant objects for processing the student responses dataset:

## Symbols for selecting and processing "numeric" items
num_items_selection <- rlang::quo(
  tidyselect::all_of('item_' |> paste0(c(1:4, 6L, 8:9)))
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


## ---- FUNCTIONS: -------------------------------------------------------------
read_student_responses <- function(filepath,
                                   test          = FALSE,
                                   filter_domain = PROFESSOR_EMAIL_DOMAIN,
                                   correct_num   = FALSE) {

  # Convert response variable labels to a named vector to use for relabelling:
  response_vars_labels <- response_vars_labels |> tibble::deframe()

  responses <- readr::read_csv(
    filepath,
    col_types = readr::cols(.default = readr::col_character())
  ) |>
    dplyr::rename(!!!response_vars_labels) |>
    dplyr::mutate(
      !!EMAIL_HASH_VAR := email_address |> purrr::map_int(hash_emails),
      date = date |>
        lubridate::parse_date_time(orders = "%d%B%Y %H%M") |>
        lubridate::force_tz(tzone = LOCAL_TIMEZONE)
    )

  if (!test) {

    # Filter out the teaching team emails (i.e. the ones that match the
    #   "professor domain").
    responses <- responses |> dplyr::filter(
      email_address |> stringr::str_detect(filter_domain, negate = TRUE)
    )
  }

  if (correct_num) {

    responses <- responses |> dplyr::mutate(
      # Ad-hoc whitespace deletion of some entries:
      dplyr::across(
        !!num_items_selection,
        ~stringr::str_remove_all(., pattern = '\\h+')
      ),
      # Ad-hoc correction of decimal marks:
      dplyr::across(
        !!num_items_selection,
        ~stringr::str_replace(., pattern = ',', replacement = '.')
      )
    )
  }

  suppressWarnings( # Avoid warning when there is a non-numeric response
    responses <- responses |>
      dplyr::mutate(dplyr::across(!!num_items_selection, readr::parse_number))
  )

  responses <- responses |> dplyr::mutate(
    item_5  = item_5  |> factor(levels = LOGICAL_LABELS),
    item_7  = item_7  |> factor(levels =  ITEM_7_LABELS),
    item_10 = item_10 |> factor(levels = ITEM_10_LABELS),
    dplyr::across(
      tidyselect::starts_with("help"),
      ~ordered(., levels = HELP_VALUES)
    ),
    dplyr::across(usefulness_videos, ~ordered(., levels = USEFULNESS_VALUES)),
    dplyr::across(instructions,      ~ordered(., levels = CLARITY_VALUES)),
    nps = nps |> stringr::str_extract("^\\d*") |> as.integer()
  )

  responses
}
