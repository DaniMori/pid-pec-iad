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
SIM_VARIABLES <- c("predictor",            "criterion")
SIM_VAR_NAMES <- c("Horas sueno promedio", "Satisfaccion vital") |>
  setNames(SIM_VARIABLES)

## Model parameters:
INTERCEPT_VAR_NAME    <- "intercept"
SLOPE_VAR_NAME        <- "slope"
RELATIONSHIP_VAR_NAME <- "relationship"

## Variable data:
SAMPLE_SIZE       <- 300:500      # Uniformly random sample size of 300-500
PREDICTOR_SCORES  <-  40:100 / 10 # Possible scores in the "predictor" variable
CRITERION_SCORES  <-   1:  5      # Possible scores in the "criterion" variable

## Modeling variables:
REL_LEVS <- c(-1L, 1L) # Levels for the "relationship" item response


## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  set.seed(seed)

  slope       <- sample(REL_LEVS, size = 1L) # Simulated regression coefficient
  sample_size <- sample(SAMPLE_SIZE, size = 1L) # Random sample size
  n_crit_vals <- length(CRITERION_SCORES) # Nº of values in the criterion scores

  output <- tibble::tibble(
    predictor = sample(
      PREDICTOR_SCORES,
      size    = sample_size,
      replace = TRUE
    ),
    # Preliminary "continuous version" of the criterion variable
    criterion = slope * predictor + rnorm(sample_size)
  )

  # Random cut points for the criterion variable (to avoid a "flat" barplot)
  rel_cut_props <- runif(n_crit_vals, min = .2, max = 1) |> cumsum()
  cut_props     <- c(0, rel_cut_props / max(rel_cut_props)) # Normalize
  cut_quantiles <- output |> pull(criterion) |> quantile(cut_props)

  # Recode the criterion variable into discrete values using the cut points:
  output |>
    mutate(
      criterion = criterion |> cut(
        breaks         = cut_quantiles,
        labels         = CRITERION_SCORES,
        include.lowest = TRUE
      )
    ) |>
    setNames(SIM_VAR_NAMES)
}
