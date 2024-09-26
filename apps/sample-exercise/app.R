# ==============================================================================
#
# FILE NAME:   app.R
# DESCRIPTION: Shiny app for testing a sample exercise
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-05-22
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(digest)
library(stringr)
library(tibble)
library(broom)
library(dplyr)
library(readr)


## ---- MAIN: ------------------------------------------------------------------

## ----create-user-interface----------------------------------------------------

ui <- fluidPage(

  # Application title
  titlePanel("Ejercicio: Regresión lineal en Jamovi"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      downloadButton("download", "Descargar archivo de datos")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      fluidRow(
        textInput("intercept", "Intersección (con 1 decimal):"),
        textOutput("intercept_result")
      ),
      fluidRow(
        textInput("slope", "Pendiente (con 1 decimal):"),
        textOutput("slope_result")
      ),
    )
  )
)


## ----create-server-logic------------------------------------------------------

server <- function(input, output) {

  user_email <- "email@domain.com"

  # Create unique hash for each user email and use it to generate the unique
  #   dataset and results:
  hashed_email <- user_email |> digest()

  # Generate user data:
  user_email |> digest2int() |> set.seed()

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


## ----run-shiny-app------------------------------------------------------------

# Run the application
shinyApp(ui, server)
