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
ITEM_PREFFIX            <- "item_"
STUDENT_RESPONSE_SUFFIX <- "_student"
CORRECT_RESPONSE_SUFFIX <- "_correct"
SCORE_RESPONSE_SUFFIX   <- "_score"

# Response configuration objects:
N_DECIMALS <- 2L # Decimal places to use for rounding numeric responses


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

  output <- responses |>
    dplyr::select(-email_hash) |>
    dplyr::mutate(
      dplyr::across(
        tidyselect::where(are_whole_numbers),
        scales::label_number(accuracy = 1, decimal.mark = ',')
      ),
      dplyr::across(
        tidyselect::where(is.double),
        scales::label_number(accuracy = 0.01, decimal.mark = ',')
      )
    ) |>
    tidyr::pivot_longer(
      tidyselect::everything(),
      names_to      = c('item', '.value'),
      names_pattern = "(item_\\d+)_(.+)"
    ) |>
    dplyr::left_join(
      response_vars_labels,
      by   = c("item" = "variable"),
      copy = TRUE,
    ) |>
    dplyr::mutate(
      item  = item |> readr::parse_number() |> as.integer()
    )

  # Avoid warning when there are missing levels (e.g., all responses are
  #   correct)
  suppressWarnings(
    output <- output |> dplyr::mutate(
      valid = score |>
        as.character() |>
        forcats::fct_recode(!!!LOGICAL_VALUES),
      score = score |> as.integer()
    )
  )

  total_score <- output |> # Compute the student's total score
    dplyr::summarise(score = sum(score)) |>
    tibble::add_column(valid = TOTAL_SCORE)

  output <- output |> dplyr::bind_rows(total_score)

  output |> dplyr::select( # Assign labels and reorder
    !!ITEM_NUM_LABEL         := item,
    !!ITEM_LABEL             := label,
    !!STUDENT_RESPONSE_LABEL := student,
    !!CORRECT_RESPONSE_LABEL := correct,
    !!VALID_RESPONSE_LABEL   := valid,
    !!SCORE_LABEL            := score
  )
}

#' Tests whether a numeric vector contains whole numbers only. It accepts any
#' type of vector input, returning `FALSE` if the input is not a numeric vector.
#'
#' @param x   Input vector to test
#' @param tol Tolerance for the whole number test (defaults to
#'            `sqrt(.Machine$double.eps)`); see omnibus::is.wholeNumber() for
#'            details.
#'
#' @returns `TRUE` if `x` is a numeric vector containing whole numbers (or `NA`)
#'          only, `FALSE` otherwise.
are_whole_numbers <- function(x, tol = .Machine$double.eps^0.5) {

  if (!is.numeric(x)) return(FALSE)

  omnibus::is.wholeNumber(x, tol = tol) |> all(na.rm = TRUE)
}
