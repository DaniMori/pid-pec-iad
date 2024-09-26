# ==============================================================================
#
# FILE NAME:   ui.R
# DESCRIPTION: User interface of the "Dataset generation" app for teaching
#              innovation project in "Introduction to Data Analysis".
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)

## ---- MAIN: ------------------------------------------------------------------

## ----create-user-interface----------------------------------------------------

ui <- fluidPage(

  # Application title
  # TODO: Decide title & add logos (if necessary)
  titlePanel("Ejercicio: Regresión lineal en Jamovi"),

  sidebarLayout(

    # Sidebar with the email input:
    sidebarPanel(
      downloadButton("download", "Descargar archivo de datos")
    ),

    # Main page with the download button:
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
