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
SIM_VARIABLES <- c("var_1",                "var_2")
SIM_VAR_NAMES <- c("Horas sueno promedio", "Satisfaccion vital") |>
  setNames(SIM_VARIABLES)

## Model parameters:
INTERCEPT_VAR_NAME    <- "intercept"
SLOPE_VAR_NAME        <- "slope"
RELATIONSHIP_VAR_NAME <- "relationship"

## Variable data:
SAMPLE_SIZE       <- 300:500  # Uniformly random sample size of 300-500
VAR_1_SCORES  <-  40:100 / 10 # Possible scores in `var_1`
VAR_2_SCORES  <-   1:  5      # Possible scores in `var_2`

## Modeling variables:
REL_LEVS <- c(-1L, 1L) # Levels for the "relationship" item response


## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  set.seed(seed)

  slope       <- sample(REL_LEVS, size = 1L) # Simulated regression coefficient
  sample_size <- sample(SAMPLE_SIZE, size = 1L) # Random sample size
  n_crit_vals <- length(VAR_2_SCORES) # Nº of values in `var_2`

  output <- tibble::tibble(
    var_1 = sample(
      VAR_1_SCORES,
      size    = sample_size,
      replace = TRUE
    ),
    # Preliminary "continuous version" of `var_2`
    var_2 = slope * var_1 + rnorm(sample_size)
  )

  # Random cut points for `var_2` (to avoid a "flat" barplot)
  rel_cut_props <- runif(n_crit_vals, min = .2, max = 1) |> cumsum()
  cut_props     <- c(0, rel_cut_props / max(rel_cut_props)) # Normalize
  cut_quantiles <- output |> dplyr::pull(var_2) |> quantile(cut_props)

  # Recode `var_2` into discrete values using the cut points:
  output |>
    dplyr::mutate(
      var_2 = var_2 |> cut(
        breaks         = cut_quantiles,
        labels         = VAR_2_SCORES,
        include.lowest = TRUE
      )
    ) |>
    setNames(SIM_VAR_NAMES)
}
