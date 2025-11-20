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

## Item labels:
INTERCEPT_LABEL    <- "Intersección"
SLOPE_LABEL        <- "Pendiente"
RELATIONSHIP_LABEL <- "Relación"

## Item values:
ITEM_5_LABELS     <- c("Sí", "No")
ITEM_6_VAL_LABELS <- c(
  "Las variables  tienen una relación directa",
  "Las variables  tienen una relación indirecta",
  "Las variables tienen una relación nula (exactamente igual a cero)"
)

## Response configuration data:
N_DECIMALS <- 2L   # Decimal places to use for rounding numeric results


## ---- FUNCTIONS: -------------------------------------------------------------

get_model_params <- function(data) {

  ## Constant objects: ----
  INTERCEPT_TERM     <- "(Intercept)"

  ## Main: ----

  predictor_name <- SIM_VAR_NAMES['predictor']
  criterion_name <- SIM_VAR_NAMES['criterion']
  response_terms <- c(INTERCEPT_TERM, predictor_name)

  # Fit model and extract coefficients:
  model        <- glue::glue("{criterion_name} ~ {predictor_name}") # Formula
  fitted_model <- data         |> lm(formula = model)
  coefficients <- fitted_model |> broom::tidy()

  # Get exercise responses from the model results:
  responses <- coefficients                 |>
    dplyr::filter(term %in% response_terms) |>
    dplyr::mutate(
      estimate = estimate |> round(N_DECIMALS),
      term     = term     |> dplyr::case_match(
        INTERCEPT_TERM ~ INTERCEPT_VAR_NAME,
        SIM_VAR_NAMES['predictor'] ~ SLOPE_VAR_NAME
      )
    )                                       |>
    dplyr::select(term, estimate)           |>
    tidyr::pivot_wider(names_from = term, values_from = estimate)

  responses |>
    dplyr::mutate(relationship = slope |> sign() |> factor(levels = REL_LEVELS))
}

get_user_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> get_model_params()
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
