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


## ---- GLOBAL OPTIONS: --------------------------------------------------------

setwd(here::here())


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs)
library(readr)

## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",     encoding = 'UTF-8')
source("R/simulate_data.R", encoding = 'UTF-8')
source("R/hash_emails.R",   encoding = 'UTF-8')


## ---- MAIN: ------------------------------------------------------------------

## ----create-server-logic------------------------------------------------------

server <- function(input, output, session) {

  email <- reactiveVal()          # Email read from the session query
  simulated_data <- reactiveVal() # Simulated dataset

  observe(
    {
      # Get email from query:
      email(parseQueryString(session$clientData$url_search)$email)

      # Generate the personal student dataset:

      ## Create unique hash for the student email:
      hashed_email <- email() |> hash_emails()

      ## Generate simulated data with the hashed email as seed:
      simulated_data(simulate_data(hashed_email))

      # Run download automatically on loading app:
      shinyjs::runjs(
        glue::glue(
          "setTimeout(
            function(){
              document.getElementById('[DOWNLOAD_LINK_ID]').click();
            },
            200
          );",
          .open = '[', .close = ']'
        )
      )
    }
  )

  ## File download handler (activated when the email is valid)
  output[[DOWNLOAD_BUTTON_ID]] <- downloadHandler(
    filename = "regresion_lineal.csv",
    content  = function(file) simulated_data() |> write_csv(file),
    contentType = "text/csv"
  )
}
