# ==============================================================================
#
# FILE NAME:   simulate_data.R
# DESCRIPTION: Create a simulated dataset for the student's personal exercise
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

  tibble::tibble(
    predictor = sample(
      0:10,                               # Integer score uniform from 0 to 10
      size    = sample(50:200, size = 1), # 50 to 200 cases (uniform sample)
      replace = TRUE
    ),
    criterion = rnorm(
      n    = length(predictor),
      mean = runif(1, 10,  20), # mean uniform from 10 to 20
      sd   = runif(1,   .1, 2)  # sd uniform from .1 to 2
    ) +
      runif(1, -10, 10) * predictor # Regression coefficient
  ) |>
    setNames(SIM_VAR_NAMES)
}
