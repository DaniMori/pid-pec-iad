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

source("R/simulated_data.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# Response computation helper objects:
ITEM_PREFFIX            <- "item_"
STUDENT_RESPONSE_SUFFIX <- "_student"
CORRECT_RESPONSE_SUFFIX <- "_correct"
SCORE_RESPONSE_SUFFIX   <- "_score"

# Response configuration objects:
N_DECIMALS <- 2L # Decimal places to use for rounding numeric responses


# Response output parameters:

## Headers:
ITEM_NUM_LABEL <- "Nº"
ITEM_LABEL     <- "Pregunta"
RESPONSE_LABEL <- "Respuesta"


## ---- FUNCTIONS: -------------------------------------------------------------

get_correct_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> compute_correct_responses()
}

#' Title
#'
#' @param student_responses `tibble` with the responses given by the students.
#' @param correct_responses `tibble` with the correct responses generated from
#'                                   the simulated datasets.
#' @param trunc_accept Boolean indicating whether to accept truncated values
#'                     (i.e., incorrectly rounding "towards 0") as correct.
#'
#' @returns `tibble` with the two input datasets collapsed (matched by
#'          `"email_hash"`, and an additional boolean column per item indicating
#'          whether the student response is correct (`TRUE`) or
#'          incorrect/missing (`FALSE`).
#' @export
score_student_responses <- function(student_responses,
                                    correct_responses,
                                    trunc_accept = TRUE) {
  ## Constant objects: ----
  score_response <- function(response, correct_response) {

    test_correct <- if (is.numeric(correct_response)) {

      if (!is.numeric(correct_response)) {

        stop (
          "The student and the correct response are not",
          "both of the 'numeric' type."
        )
      }

      correct_response |> round(digits = N_DECIMALS)

    } else {

      correct_response
    }

    if (trunc_accept && is.numeric(correct_response)) {

      truncated_correct <- correct_response |>
        trunc_prec(precision = N_DECIMALS)

      if (truncated_correct != test_correct) {

        # Make sure the condition is `FALSE` if `response` is `NA`
        if (roperators::`%~=%`(response, truncated_correct)) {

          response <- test_correct # Change the student response to the "valid"
                                   #   one, if the conditions are met.
        }
      }
    }

    roperators::`%~=%`(response, test_correct)
  }

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
          score_response
        )
      )
    }
  )

  scored_responses
}

#' Truncate numeric value to certain number of decimal places.
#'
#' @param x         Numeric vector to truncate
#' @param precision Number of decimal places to keep (default: `0L`)
#'
#' @returns The values in `x`, truncated to `precision` decimals
trunc_prec <- function(x, precision = 0L) {

  factor    <- 10^precision
  truncated <- trunc(x * factor) / factor

  return(truncated)
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
