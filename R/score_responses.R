# ==============================================================================
#
# FILE NAME:   score_responses.R
# DESCRIPTION: Functionality for assessing and scoring the student responses
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2025-11-26
#
# ==============================================================================


# ## ---- PACKAGES: --------------------------------------------------------------
#
# library(roperators)
#
#
## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",      encoding = 'UTF-8')
source("R/simulated_data.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# Response computation helper objects:
ITEM_PREFFIX <- "item_"
STUDENT_RESPONSE_SUFFIX <- "_student"
CORRECT_RESPONSE_SUFFIX <- "_correct"
SCORE_RESPONSE_SUFFIX   <- "_score"


## ---- FUNCTIONS: -------------------------------------------------------------

get_correct_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> compute_correct_responses()
}

score_student_responses <- function(student_responses, correct_responses) {

  ## Argument checking and formatting: ----
  item_vars <- student_responses |>
    dplyr::select(starts_with(ITEM_PREFFIX)) |>
    colnames()

  ## Main: ----

  scored_responses <- student_responses |>
    dplyr::left_join(
      correct_responses,
      by     = EMAIL_HASH_VAR,
      suffix = c(STUDENT_RESPONSE_SUFFIX, CORRECT_RESPONSE_SUFFIX)
    )

  purrr::walk(
    item_vars,
    ~{
      score_var        <- paste0(., SCORE_RESPONSE_SUFFIX)
      student_item_var <- paste0(., STUDENT_RESPONSE_SUFFIX) |> rlang::sym()
      correct_item_var <- paste0(., CORRECT_RESPONSE_SUFFIX) |> rlang::sym()

      scored_responses <<- scored_responses |> dplyr::mutate(
        !!score_var := purrr::map2_lgl(
          !!student_item_var,
          !!correct_item_var,
          roperators::`%~=%`
        )
      )
    }
  )

  scored_responses
}

format_responses <- function(responses) {

  relationship_levels <- REL_LEVELS |>
    as.character() |>
    setNames(RELATIONSHIP_LABELS)

  params_varnames    <- c(
    INTERCEPT_VAR_NAME,
    SLOPE_VAR_NAME,
    RELATIONSHIP_VAR_NAME
  )
  params_labels      <- c(INTERCEPT_LABEL, SLOPE_LABEL, RELATIONSHIP_LABEL)
  params_vars_labels <- params_varnames |>
    setNames(params_labels) |>
    tibble::enframe(name = ITEM_LABEL)

  responses |>
    dplyr::mutate(
      relationship = relationship |>
        forcats::fct_recode(!!!relationship_levels),
      dplyr::across(dplyr::everything(), as.character)
    ) |>
    tidyr::pivot_longer(
      cols      = dplyr::everything(),
      values_to = RESPONSE_LABEL
    ) |>
    dplyr::full_join(params_vars_labels, by = c(name = "value")) |>
    dplyr::select(dplyr::all_of(c(ITEM_LABEL, RESPONSE_LABEL))) |>
    tibble::rownames_to_column(ITEM_NUM_LABEL)
}
