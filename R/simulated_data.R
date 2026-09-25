# ==============================================================================
#
# FILE NAME:   simulated_data.R
# DESCRIPTION: Functionality for creating a simulated dataset for the student's
#              personal exercise and the exercise correct responses
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-09
#
# ==============================================================================


## ---- SOURCES: ---------------------------------------------------------------

source("R/sim_functions.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# Simulated data objects:

## Dataset properties:
SAMPLE_SIZE_MIN <- 100L
SAMPLE_SIZE_MAX <- 500L


## Variable properties:

SIM_VAR_NAMES <- c( # Variable names
  "ID",
  "Inteligencia",
  "Responsabilidad",
  "Nota",
  "Salario_deseado",
  "Formacion"
)

SIM_VARIABLES <- "var_" |> # Variable identifiers
  paste0(seq_along(SIM_VAR_NAMES)) |>
  setNames(SIM_VAR_NAMES)


## Variable values:

### Objects for simulating IQ-metric variables:
IQ_METRIC_MEAN_CENTER      <- 100L
IQ_METRIC_MEAN_HALF_RANGE  <-  10L
IQ_METRIC_SD_CENTER        <-  15L
IQ_METRIC_SD_HALF_RANGE    <-   3L

### Categories in `var_4` ("Nota"):
VAR_4_CATS <- c("Suspenso", "Aprobado", "Notable", "Sobresaliente")

### Values in `var_5` ("Salario_deseado"):
VAR_5_VALUES <- c(15:30, 35L, 40L, 45L, 50L, 60L) * 1000L
VAR_5_SCALE  <-  2500L # These values give a proper range from 15K to 60K
VAR_5_SHIFT  <- 15000L

### Categories in `var_6` ("Formacion"):
VAR_6_CATS <- c("No", "Sí")


## Variable minimum proportions:
VAR_4_MIN_PROP  <-    .12           # `var_4` ("Nota")
VAR_6_MIN_PROPS <- c(0, .2, .5, .5) # `var_6` == "Sí" in each `var_4` value


## Bivariate variable properties:

# Correlation ranges (among generating variables):
CORR_LIMS_VARS_2_3 <- c(-0.8, 0.8) # "Inteligencia"    - "Responsabilidad"
CORR_LIMS_VARS_2_4 <- c( 0,   0.6) # "Inteligencia"    - "Nota"
CORR_LIMS_VARS_2_5 <- c(-0.5, 0.5) # "Inteligencia"    - "Salario_deseado"
CORR_LIMS_VARS_3_5 <- c(-0.5, 0.5) # "Responsabilidad" - "Salario_deseado"


## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  ## Constant objects: ----

  # Correlations among generating variables:
  gen_vars      <- SIM_VARIABLES[2:5] # Names for the correlation matrix
  corr_dimnames <- list(gen_vars, gen_vars)
  corr_inf_lims <- c(
    NA,
    CORR_LIMS_VARS_2_3[1],
    CORR_LIMS_VARS_2_4[1],
    CORR_LIMS_VARS_2_5[1],
    NA |> rep(3),
    CORR_LIMS_VARS_3_5[1],
    NA |> rep(8)
  ) |>
    matrix(nrow = 4L, byrow = TRUE, dimnames = corr_dimnames)
  corr_sup_lims <- c(
    NA,
    CORR_LIMS_VARS_2_3[2],
    CORR_LIMS_VARS_2_4[2],
    CORR_LIMS_VARS_2_5[2],
    NA |> rep(3),
    CORR_LIMS_VARS_3_5[2],
    NA |> rep(8)
  ) |>
    matrix(nrow = 4L, byrow = TRUE, dimnames = corr_dimnames)


  ## Main: ----

  set.seed(seed) # Ensure the reproducibility


  # Generate random parameters for the simulated variables:

  # Random sample size:
  sample_size <- generate_sample_size(SAMPLE_SIZE_MIN, SAMPLE_SIZE_MAX)

  # Correlation matrix for multivariate variables (`var_2` to `var_5`)
  corrs <- generate_corr_matrix(min = corr_inf_lims, max = corr_sup_lims)

  ## TODO: Decide whether to move the variable parameter generation to function
  # Random parameters for scaling variables:
  var_2_mean <- runif(
    1L,
    IQ_METRIC_MEAN_CENTER - IQ_METRIC_MEAN_HALF_RANGE,
    IQ_METRIC_MEAN_CENTER + IQ_METRIC_MEAN_HALF_RANGE
  )
  var_2_sd   <- runif(
    1L,
    IQ_METRIC_SD_CENTER - IQ_METRIC_SD_HALF_RANGE,
    IQ_METRIC_SD_CENTER + IQ_METRIC_SD_HALF_RANGE
  )
  var_3_mean <- runif(
    1L,
    IQ_METRIC_MEAN_CENTER - IQ_METRIC_MEAN_HALF_RANGE,
    IQ_METRIC_MEAN_CENTER + IQ_METRIC_MEAN_HALF_RANGE
  )
  var_3_sd   <- runif(
    1L,
    IQ_METRIC_SD_CENTER - IQ_METRIC_SD_HALF_RANGE,
    IQ_METRIC_SD_CENTER + IQ_METRIC_SD_HALF_RANGE
  )

  # Random cut points for categorical variables (to avoid "flat" barplots)
  var_4_props <- VAR_4_CATS |>
    generate_category_proportions(min_prop = VAR_4_MIN_PROP)
  ## TODO: Function for simulating "conditional probabilities"?
  var_6_props <- VAR_6_MIN_PROPS |> # Probability of "Sí" for each `var_4` value
    purrr::map_dbl(runif, n = 1L) |>
    setNames(VAR_4_CATS)


  # Generate data:

  ## Generate standardized variables:
  std_vars <- mvtnorm::rmvnorm(sample_size, sigma = corrs) |>
    tibble::as_tibble(.name_repair = "minimal") |>
    setNames(gen_vars)

  ## Transform standardized variables to the target distribution:
  transformed_vars <- std_vars |> dplyr::mutate(
    var_2 = (var_2_mean + var_2 * var_2_sd) |> as.integer(),
    var_3 = (var_3_mean + var_3 * var_3_sd) |> as.integer(),
    var_4 = var_4 |> quantitative_2_categorical(var_4_props),
    var_5 = (VAR_5_SHIFT + VAR_5_SCALE * exp(var_5)) |>
      round_quant_2_set(VAR_5_VALUES),
    var_6 = (var_6_props[as.character(var_4)] > runif(sample_size)) |>
      dplyr::if_else(true = VAR_6_CATS[2], false = VAR_6_CATS[1])
  )

  output <- tibble::tibble(var_1 = 1:sample_size) |>
    dplyr::bind_cols(transformed_vars)

  # Assign variable names:
  output |> dplyr::rename(!!!SIM_VARIABLES)
}
