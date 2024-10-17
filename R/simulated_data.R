# ==============================================================================
#
# FILE NAME:   simulated_data.R
# DESCRIPTION: Functionality for creating and analyzing a simulated dataset for
#              the student's personal exercise
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-09
#
# ==============================================================================


## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R", encoding = 'UTF-8')

## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  set.seed(seed)

  slope       <- sample(-1:1, size = 1L) # Simulation regression coefficient
  sample_size <- sample(SAMPLE_SIZE, size = 1L) # Random sample size
  n_crit_vals <- length(CRITERION_SCORES) # Nº of values in the criterion scores

  tibble::tibble(
    predictor = sample(
      PREDICTOR_SCORES,
      size    = sample_size,
      replace = TRUE
    ),
    criterion = (slope * predictor + rnorm(sample_size)) |>
      dplyr::ntile(n_crit_vals)                          |>
      dplyr::recode(!!!CRITERION_SCORES |> setNames(1:n_crit_vals))
  ) |>
    setNames(SIM_VAR_NAMES)
}

get_model_params <- function(data) {

  ## Constant objects: ----
  INTERCEPT_TERM     <- "(Intercept)"
  INTERCEPT_VAR_NAME <- "intercept"
  SLOPE_VAR_NAME     <- "slope"

  ## Main: ----

  predictor_name <- SIM_VAR_NAMES['predictor']
  criterion_name <- SIM_VAR_NAMES['criterion']
  response_terms <- c(INTERCEPT_TERM, predictor_name)

  # Fit model and extract coefficients:
  model        <- glue::glue("{criterion_name} ~ {predictor_name}") # Formula
  fitted_model <- data         |> lm(formula = model)
  coefficients <- fitted_model |> broom::tidy()

  # Get exercise responses from the model results:
  responses <- coefficients                 |>
    dplyr::filter(term %in% response_terms) |>
    dplyr::mutate(
      estimate = estimate |> round(N_DECIMALS),
      term     = term     |> dplyr::case_match(
        INTERCEPT_TERM ~ INTERCEPT_VAR_NAME,
        SIM_VAR_NAMES['predictor'] ~ SLOPE_VAR_NAME
      )
    )                                       |>
    dplyr::select(term, estimate)           |>
    tidyr::pivot_wider(names_from = term, values_from = estimate)

  responses |> dplyr::mutate(relationship = sign(slope))
}

get_user_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> get_model_params()
}
