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
SIGN_LEVELS    <- c(-1, 0, 1) |> as.character()
LOGICAL_LEVELS <- c(FALSE, TRUE, NA) |> as.character()

ITEM_1_LS_CAT <- 2L # Category "Insatisfecho" in "life satisfaction" variable
                    #   (for item 1).

ITEM_5_LABELS <- c("No", "Sí", "(Sin respuesta)")
ITEM_5_VALUES <- LOGICAL_LEVELS |> setNames(ITEM_5_LABELS)

ITEM_7_LABELS <- c(
  "Las variables  tienen una relación inversa",
  "Las variables tienen una relación nula (exactamente igual a cero)",
  "Las variables  tienen una relación directa"
)
ITEM_7_VALUES <- SIGN_LEVELS |> setNames(ITEM_7_LABELS)

ITEM_10_LABELS <- c(
  paste(
    "A menos promedio semanal de horas diarias de sueño,",
    "mayor satisfacción vital."
  ),
  paste(
    "La relación entre promedio semanal de horas diarias de sueño y",
    "la satisfacción vital es nula (exactamente igual a cero)."
  ),
  "A más promedio semanal de horas diarias de sueño, mayor satisfacción vital."
)
ITEM_10_VALUES <- SIGN_LEVELS |> setNames(ITEM_10_LABELS)

## Response configuration data:
N_DECIMALS <- 2L   # Decimal places to use for rounding numeric results


## ---- FUNCTIONS: -------------------------------------------------------------

get_correct_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> compute_correct_responses()
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
