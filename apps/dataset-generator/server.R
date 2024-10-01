# ==============================================================================
#
# FILE NAME:   server.R
# DESCRIPTION: Server logic of the "Dataset generation" app for teaching
#              innovation project in "Introduction to Data Analysis".
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs)
library(shinyvalidate)
library(digest)
library(stringr)
library(tibble)
library(broom)
library(dplyr)
library(readr)

## ---- SOURCES: ---------------------------------------------------------------

source("../../R/ui_components.R", encoding = 'UTF-8')
source("../../R/constants.R", encoding = 'UTF-8')


## ---- MAIN: ------------------------------------------------------------------

## ----create-server-logic------------------------------------------------------

server <- function(input, output) {

  # Initial server configuration:

  email_validator <- sv_email() # Validator function for the email value

  disable(DOWNLOAD_BUTTON_ID) # Disable download button (until a valid email
                              #   is input and confirmed)


  # UI reactive input values:

  email_input <- reactiveVal()
  email_check <- reactiveVal()
  email_state <- reactiveVal("blank") # Email validation state

  # Server logic:

  # Render the verification mark
  output[[email_check_id(EMAIL_INPUT_ID)]] <- renderImage(
    {
      list(
        src = switch(
          email_state(),
          "blank" = '',
          "processing" = "../../www/round-segments-blue-loop.gif",
          "valid" = fontawesome::fa_png( # TODO: Create PNG files beforehand, use them after in app
            "check",
            fill = "#49e11e",
            width = 40L
            # vertical_align = '10px'
          ),
          "invalid" = fontawesome::fa(
            "cross",
            fill = "red",
            width = 40L
            # vertical_align = '10px'
          )
        ),
        width = '40px',
        height = '40px'
      )
    },
    deleteFile = FALSE
  )


  reactive({

    email_input(input[[email_input_id(EMAIL_INPUT_ID)]])
    email_check(input[[email_input_id(EMAIL_CHECK_ID)]])

    # Create unique hash for each user email and use it to generate the unique
    #   dataset and results:
    hashed_email <- email_input() |> digest()

    # Generate user data:
    user_email() |> digest2int() |> set.seed()

    user_data <- tibble(
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

    reg_fit <- user_data |> lm(formula = criterion ~ predictor)

    reg_fit_coefs <- reg_fit |> tidy()

    intercept <- reg_fit_coefs |>
      filter(term == "(Intercept)") |>
      pull(estimate) |>
      round(1)
    slope     <- reg_fit_coefs |>
      filter(term == "predictor") |>
      pull(estimate) |>
      round(1)
  })



  # UI logic:

  ## File download handler:
  output$download <- downloadHandler(
    filename = "regresion_lineal.csv",
    content  = function(file) {

      user_data |> write_csv(file)
    },
    contentType = "text/csv"
  )

  ## Result checkers:
  output$intercept_result <- renderText(
    if (input$intercept != "")
      if (input$intercept == intercept) "Correcto!" else "Incorrecto"
    else ""
  )
  output$slope_result <- renderText(
    if (input$slope != "")
      if (input$slope == slope) "Correcto!" else "Incorrecto"
    else ""
  )
}
