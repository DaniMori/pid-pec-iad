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


## ---- CONSTANTS: -------------------------------------------------------------

# Simulated data objects:

## Dataset properties:
SAMPLE_SIZE  <- 300:500  # Uniformly random sample size of 300-500


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

# Categories in `var_4` ("Nota"):
VAR_4_CATS <- C("Suspenso", "Aprobado", "Notable", "Sobresaliente")

# Values in `var_5` ("Salario_deseado"):
VAR_5_VALUES <- c(15:30, 35, 40, 45, 50, 60) * 1000

# Categories in `var_6` ("SES"):
VAR_6_CATS <- C("Bajo", "Medio", "Alto")

# Categories in `var_7` ("Curso"):
VAR_6_CATS <- C("No", "Sí")


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

  set.seed(seed)

  ## TODO: Decide whether to move the correlation construction to a function

  # Correlations among generating variables:
  gen_vars <- SIM_VARIABLES[2:5] # Variable names for the correlation matrix
  corrs <- matrix(nrow = 4L, ncol = 4L, dimnames = list(gen_vars, gen_vars))
  diag(corrs) <- 1L
  corrs[upper.tri(corrs)] <- c(
    runif(1L, CORR_LIMS_VARS_2_3[1], CORR_LIMS_VARS_2_3[2]),
    runif(1L, CORR_LIMS_VARS_2_4[1], CORR_LIMS_VARS_2_4[2]),
    NA,
    runif(1L, CORR_LIMS_VARS_2_5[1], CORR_LIMS_VARS_2_5[2]),
    runif(1L, CORR_LIMS_VARS_3_5[1], CORR_LIMS_VARS_3_5[2]),
    NA
  )

  ## Determine missing correlations to make matrix positive definite:

  ### Correlations among variables 3 and 4:

  corr_matrix_2_4 <- corrs[SIM_VARIABLES[2:4], SIM_VARIABLES[2:4]]
  corrs_2_4       <- corr_matrix_2_4[upper.tri(corr_matrix_2_4)]
  corr_lims_3_4   <- faux::pos_def_limits(corrs_2_4)

  corrs[SIM_VARIABLES[3], SIM_VARIABLES[4]] <- runif( # Assign correlation
    1L,
    corr_lims_3_4$min,
    corr_lims_3_4$max
  )


  ### Correlations among variables 4 and 5:
  corrs_4_5                                 <- corrs[upper.tri(corrs)]
  corr_lims_4_5                             <- faux::pos_def_limits(corrs_4_5)
  corrs[SIM_VARIABLES[4], SIM_VARIABLES[5]] <- runif( # Assign correlation
    1L,
    corr_lims_4_5$min,
    corr_lims_4_5$max
  )

  ## Complete correlation matrix:
  corr_vector             <- corrs[upper.tri(corrs)]
  corrs                   <- t(corrs)
  corrs[upper.tri(corrs)] <- corr_vector

  # Generate data:
  sample_size <- sample(SAMPLE_SIZE, size = 1L) # Random sample size

  output <- tibble::tibble(
    var_1    = 1:sample_size,
    std_vars = faux::rnorm_multi(sample_size, r = corrs)
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
