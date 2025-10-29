# ==============================================================================
#
# FILE NAME:   simulated_data.R
# DESCRIPTION: Functionality for creating a simulated dataset for the student's
#              personal exercise
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-09
#
# ==============================================================================


## ---- CONSTANTS: -------------------------------------------------------------

# Simulated data objects:

## Variable names:
SIM_VARIABLES <- c("predictor",         "criterion")
SIM_VAR_NAMES <- c("autonomia_laboral", "satisfaccion_laboral") |>
  setNames(SIM_VARIABLES)

## Model parameters:
INTERCEPT_VAR_NAME    <- "intercept"
SLOPE_VAR_NAME        <- "slope"
RELATIONSHIP_VAR_NAME <- "relationship"

## Variable data:
SAMPLE_SIZE       <- 300:500 # Uniformly random sample size of 300-600 cases
PREDICTOR_SCORES  <-   0: 10 # Possible scores in the predictor variable
CRITERION_SCORES  <-   1:  5 # Possible scores in the criterion variable

## Response configuration data:
REL_LEVELS <- -1:1 # Levels for the "relationship" item response


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
