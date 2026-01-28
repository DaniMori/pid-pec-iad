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

## Variable names:
SIM_VARIABLES <- c("var_1",                "var_2")
SIM_VAR_NAMES <- c("Horas sueno promedio", "Satisfaccion vital") |>
  setNames(SIM_VARIABLES)

## Model parameters:
INTERCEPT_VAR_NAME    <- "intercept"
SLOPE_VAR_NAME        <- "slope"
RELATIONSHIP_VAR_NAME <- "relationship"

## Variable data:
SAMPLE_SIZE  <- 300:500  # Uniformly random sample size of 300-500
VAR_1_SCORES <-  40:100 / 10 # Possible scores in `var_1`
VAR_2_SCORES <-   1:  5      # Possible scores in `var_2`

## Modeling variables:
REL_LEVS <- c(-1L, 1L) # Levels for the "relationship" item response


# Response generation objects:

ITEM_1_LS_CAT <- 2L # Category "Insatisfecho" in "life satisfaction" variable
                    #   (for item 1).

## Item value labels:
SIGN_LEVELS    <- c(-1, 0, 1) |> as.character()
LOGICAL_LEVELS <- c(FALSE, TRUE) |> as.character()

LOGICAL_LABELS <- c("No", "Sí")
LOGICAL_VALUES <- LOGICAL_LEVELS |> setNames(LOGICAL_LABELS)

ITEM_7_LABELS <- c(
  "Las variables  tienen una relación indirecta",
  "Las variables  tienen una relación nula (exactamente igual a cero)",
  "Las variables  tienen una relación directa"
)
ITEM_7_VALUES <- SIGN_LEVELS |> setNames(ITEM_7_LABELS)

ITEM_10_LABELS <- c(
  paste(
    'A menos "satisfacción vital",',
    'mayor "promedio semanal de horas diarias de sueño"'
  ),
  paste(
    'La relación entre la "satisfacción vital" y el "promedio semanal',
    'de horas diarias de sueño" es nula (exactamente igual a cero)'
  ),
  paste(
    'A más "satisfacción vital",',
    'mayor "promedio semanal de horas diarias de sueño"'
  )
)
ITEM_10_VALUES <- SIGN_LEVELS |> setNames(ITEM_10_LABELS)


## Response configuration data:
N_DECIMALS <- 2L   # Decimal places to use for rounding numeric results


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
  computed_responses <- data |> dplyr::summarize(
    item_1 = table(`Satisfaccion vital`)[ITEM_1_LS_CAT],
    item_2 = median(`Horas sueno promedio`),
    item_3 = sd(`Horas sueno promedio`) |> round(N_DECIMALS),
    item_4 = quantile(`Horas sueno promedio`, .34),
    item_5 = boxplot.stats(`Horas sueno promedio`)$out |>
      length() |>
      as.logical() |>
      as.character(),
    item_6 = cor(`Satisfaccion vital`, `Horas sueno promedio`) |>
      round(N_DECIMALS),
    item_7 = item_6 |> sign() |> as.character(),
    item_8 = coefficients |>
      dplyr::filter(term == INTERCEPT_TERM) |>
      dplyr::pull(estimate) |>
      round(N_DECIMALS),
    item_9 = coefficients |>
      dplyr::filter(term == predictor_name) |>
      dplyr::pull(estimate) |>
      round(N_DECIMALS),
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
