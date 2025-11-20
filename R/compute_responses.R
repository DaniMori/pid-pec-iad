# ==============================================================================
#
# FILE NAME:   compute_responses.R
# DESCRIPTION: Functionality for creating and analyzing a simulated dataset for
#              the student's personal exercise
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2025-10-29
#
# ==============================================================================


## ---- SOURCES: ---------------------------------------------------------------

source("R/simulated_data.R", encoding = 'UTF-8')


## ---- CONSTANTS: -------------------------------------------------------------

# Response parameters:

## Headers:
ITEM_NUM_LABEL <- "Nº"
ITEM_LABEL     <- "Pregunta"
RESPONSE_LABEL <- "Respuesta"

## Item value labels:
ITEM_5_VALUES <- c(TRUE, FALSE)
ITEM_5_LABELS <- c("Sí", "No") |> setNames(ITEM_5_VALUES)
ITEM_7_VALUES <- c(1, -1, 0)
ITEM_7_LABELS <- c(
  "Las variables  tienen una relación directa",
  "Las variables  tienen una relación indirecta",
  "Las variables tienen una relación nula (exactamente igual a cero)"
) |>
  setNames(ITEM_7_VALUES)

## Response configuration data:
N_DECIMALS <- 2L   # Decimal places to use for rounding numeric results


## ---- FUNCTIONS: -------------------------------------------------------------

compute_user_responses <- function(data) {

  ## Constant objects: ----

  # Linear regression model objects:
  INTERCEPT_TERM <- "(Intercept)"
  criterion_name <- SIM_VAR_NAMES['var_1'] |> glue::backtick()
  predictor_name <- SIM_VAR_NAMES['var_2'] |> glue::backtick()

  # Data objects:
  CAT_LS_ITEM_1 <- 2L


  ## Main: ----

  # Transform `var_2` to integer to use it a "linear term" in the regression
  data <- data |> dplyr::mutate(
    `Satisfaccion vital` = `Satisfaccion vital` |>
      as.character() |>
      as.integer()
  )

  # Fit model and extract coefficients:
  model       <- glue::glue("{criterion_name} ~ {predictor_name}") # Formula
  fitted_model <- data         |> lm(formula = model)
  coefficients <- fitted_model |> broom::tidy()

  # Compute responses:

  computed_responses <- data |> dplyr::summarize(
    item_1 = table(`Satisfaccion vital`)[CAT_LS_ITEM_1],
    item_2 = median(`Horas sueno promedio`),
    item_3 = sd(`Horas sueno promedio`) |> round(N_DECIMALS),
    item_4 = quantile(`Horas sueno promedio`, .34),
    item_5 = boxplot.stats(`Horas sueno promedio`)$out |>
      length() |>
      as.logical() |>
      as.character() %>%
      magrittr::extract(ITEM_5_LABELS, .),
    item_6 = cor(`Satisfaccion vital`, `Horas sueno promedio`) |>
      round(N_DECIMALS),
    item_7 = item_6 |>
      sign() |>
      as.character() %>%
      magrittr::extract(ITEM_7_LABELS, .),
    item_8 = coefficients |>
      dplyr::filter(term == INTERCEPT_TERM) |>
      dplyr::pull(estimate) |>
      round(N_DECIMALS),
    item_9 = coefficients |>
      dplyr::filter(term == predictor_name) |>
      dplyr::pull(estimate) |>
      round(N_DECIMALS),
    item_10 =
  )

    dplyr::mutate(relationship = slope |> sign() |> factor(levels = REL_LEVELS))
}

get_user_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> compute_user_responses()
}

format_responses <- function(responses) {

  relationship_levels <- REL_LEVELS |>
    as.character() |>
    setNames(RELATIONSHIP_LABELS)

  params_varnames    <- c(
    INTERCEPT_VAR_NAME,
    SLOPE_VAR_NAME,
    RELATIONSHIP_VAR_NAME
  )
  params_labels      <- c(INTERCEPT_LABEL, SLOPE_LABEL, RELATIONSHIP_LABEL)
  params_vars_labels <- params_varnames |>
    setNames(params_labels) |>
    tibble::enframe(name = ITEM_LABEL)

  responses |>
    dplyr::mutate(
      relationship = relationship |>
        forcats::fct_recode(!!!relationship_levels),
      dplyr::across(dplyr::everything(), as.character)
    ) |>
    tidyr::pivot_longer(
      cols      = dplyr::everything(),
      values_to = RESPONSE_LABEL
    ) |>
    dplyr::full_join(params_vars_labels, by = c(name = "value")) |>
    dplyr::select(dplyr::all_of(c(ITEM_LABEL, RESPONSE_LABEL))) |>
    tibble::rownames_to_column(ITEM_NUM_LABEL)
}
