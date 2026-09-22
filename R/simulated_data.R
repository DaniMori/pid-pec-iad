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
SAMPLE_SIZE_MIN <- 300L
SAMPLE_SIZE_MAX <- 500L


## Variable properties:

SIM_VARIABLES <- "var_" |> paste0(1:7) # Variable identifiers

SIM_VAR_NAMES <- c( # Variable names
  "ID",
  "Inteligencia",
  "Responsabilidad",
  "Nota",
  "Salario_deseado",
  "SES",
  "Curso"
) |>
  setNames(SIM_VARIABLES)


## Variable values:

### Objects for simulating IQ-metric variables:
IQ_METRIC_MEAN_CENTER      <- 100L
IQ_METRIC_MEAN_HALF_RANGE  <-  10L
IQ_METRIC_SD_CENTER        <-  15L
IQ_METRIC_SD_HALF_RANGE    <-   3L

### Maximum nº of outliers in var_3:
MAX_OUTLIERS <- 20L

### Categories in `var_4` ("Nota"):
VAR_4_CATS <- c("Suspenso", "Aprobado", "Notable", "Sobresaliente")

### Values in `var_5` ("Salario_deseado"):
VAR_5_VALUES <- c(15:30, 35, 40, 45, 50, 60) * 1000

### Categories in `var_6` ("SES"):
VAR_6_CATS <- c("Bajo", "Medio", "Alto")

### Categories in `var_7` ("Curso"):
VAR_6_CATS <- c("No", "Sí")


## Bivariate variable properties:

# Correlation ranges (among generating variables):
CORR_LIMS_VARS_2_3 <- c(-0.8, 0.8) # "Inteligencia"    - "Responsabilidad"
CORR_LIMS_VARS_2_4 <- c( 0,   0.6) # "Inteligencia"    - "Nota"
CORR_LIMS_VARS_2_5 <- c(-0.5, 0.5) # "Inteligencia"    - "Salario_deseado"
CORR_LIMS_VARS_3_5 <- c(-0.5, 0.5) # "Responsabilidad" - "Salario_deseado"


# Response generation objects:

## TODO: Pending (to complete when the items are complete)


## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  ## Constant objects: ----

  set.seed(seed)

  # Random sample size:
  sample_size <- generate_sample_size(SAMPLE_SIZE_MIN, SAMPLE_SIZE_MAX)

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


  ## Main: ----

  # Correlations among generating variables:
  gen_varnames  <- SIM_VAR_NAMES[2:5] # Names for the correlation matrix
  corr_dimnames <- list(gen_varnames, gen_varnames)
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

  corrs <- generate_corr_matrix(min = corr_inf_lims, max = corr_sup_lims)

  # Generate data:

  std_vars <- faux::rnorm_multi(sample_size, r = corrs) |> tibble::as_tibble()

  transformed_vars <- std_vars |> dplyr::mutate(
    !!SIM_VAR_NAMES["var_2"] := !!rlang::sym(SIM_VAR_NAMES["var_2"]) *
      var_2_sd + var_2_mean,
    !!SIM_VAR_NAMES["var_3"] := !!rlang::sym(SIM_VAR_NAMES["var_3"]) *
      var_3_sd + var_3_mean
  )
  ## TODO: Code additional transformations

  output <- tibble::tibble(!!SIM_VAR_NAMES["var_1"] := 1:sample_size) |>
    dplyr::bind_cols(transformed_vars)

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

compute_correct_responses <- function(data) {
  ## Constant objects: ----

  # Linear regression model objects:
  INTERCEPT_TERM <- "(Intercept)"
  criterion_name <- SIM_VAR_NAMES['var_1'] |> glue::backtick()
  predictor_name <- SIM_VAR_NAMES['var_2'] |> glue::backtick()


  ## Main: ----

  # Transform `var_2` to integer to use it as a "linear term" in the regression
  data <- data |> dplyr::mutate(`Satisfaccion vital` = `Satisfaccion vital` |>
                                  as.character() |>
                                  as.integer())

  # Fit model and extract coefficients:
  model       <- glue::glue("{criterion_name} ~ {predictor_name}") # Formula
  fitted_model <- data         |> lm(formula = model)
  coefficients <- fitted_model |> broom::tidy()

  # Compute responses:

  # Correct numeric responses are computed with machine precision, to take into
  #   account the possibility of accepting (incorrectly) truncated (instead of
  #   rounded) values as correct.
  computed_responses <- data |> dplyr::summarize(
    item_1 = table(`Satisfaccion vital`)[ITEM_1_LS_CAT],
    item_2 = median(`Horas sueno promedio`),
    item_3 = sd(`Horas sueno promedio`),
    item_4 = quantile(`Horas sueno promedio`, .34),
    item_5 = boxplot.stats(`Horas sueno promedio`)$out |>
      length() |>
      as.logical() |>
      as.character(),
    item_6 = cor(`Satisfaccion vital`, `Horas sueno promedio`),
    item_7 = item_6 |> sign() |> as.character(),
    item_8 = coefficients |>
      dplyr::filter(term == INTERCEPT_TERM) |>
      dplyr::pull(estimate),
    item_9 = coefficients |>
      dplyr::filter(term == predictor_name) |>
      dplyr::pull(estimate),
    item_10 = item_9 |> sign() |> as.character(),
  )

  # Capture warning when factor levels are missing in the data (they will!)
  suppressWarnings(
    computed_responses <- computed_responses |> dplyr::mutate(
      item_5  = item_5 |>
        readr::parse_factor(levels = LOGICAL_VALUES) |>
        forcats::fct_recode(!!!LOGICAL_VALUES),
      item_7  = item_7 |>
        readr::parse_factor(levels = ITEM_7_VALUES) |>
        forcats::fct_recode(!!!ITEM_7_VALUES),
      item_10 = item_10 |>
        readr::parse_factor(levels = ITEM_10_VALUES) |>
        forcats::fct_recode(!!!ITEM_10_VALUES)
    )
  )

  computed_responses
}
