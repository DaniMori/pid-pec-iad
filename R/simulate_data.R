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


## ---- CONSTANTS: -------------------------------------------------------------

# <level_1_section>:

## <level_2_section>:


## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  set.seed(seed)

  tibble::tibble(
    predictor = rnorm(
      n    = sample(50:200, size = 1), # 50 to 200 cases (uniform sample)
      mean = runif(1, -10,  10),       # mean uniform from -10 to 10
      sd   = runif(1,    .5, 4)        # sd uniform from .5 to 4
    ),
    criterion = rnorm(
      n    = length(predictor),
      mean = runif(1, 10,  20), # mean uniform from 10 to 20
      sd   = runif(1,   .1, 2)  # sd uniform from .1 to 2
    ) +
      runif(1, -10, 10) * predictor # Regression coefficient
  )
}
