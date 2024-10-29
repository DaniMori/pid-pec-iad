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
