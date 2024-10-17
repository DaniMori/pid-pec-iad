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

## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",     encoding = 'UTF-8')
source("R/simulate_data.R", encoding = 'UTF-8')
source("R/hash_emails.R",   encoding = 'UTF-8')
source("R/data_storage.R",  encoding = 'UTF-8')

## ---- CONSTANTS: -------------------------------------------------------------

# Server configuration objects:

## Auto-download javascript code:
AUTO_DOWNLOAD_JS_FUN  <- "setTimeout(
  function(){
    document.getElementById('[DOWNLOAD_LINK_ID]').click();
  },
  [AUTO_DOWNLOAD_TIMEOUT]
);"

auto_download_code <- glue::glue(
  AUTO_DOWNLOAD_JS_FUN,
  .open = '[', .close = ']'
)


## ---- MAIN: ------------------------------------------------------------------

## ----create-server-logic------------------------------------------------------

server <- function(input, output, session) {

  # Reactive values:
  email          <- reactiveVal() # Email read from the session query
  hashed_email   <- reactiveVal() # Hashed email for logging and random seed
  simulated_data <- reactiveVal() # Simulated dataset

  observe(
    {
      # Get email from query:
      email(parseQueryString(session$clientData$url_search)$email)

      validate_email(email()) # Check that email is valid in the first place
      print("Email valid")

      ## Create unique hash for the user email:
      hashed_email(email() |> hash_emails())
      print("Email hash created")

      # Log access to the app:
      write_event(hash = hashed_email(), event = "Access")

      # Generate simulated data with the hashed email as seed:
      simulated_data(simulate_data(hashed_email()))
      print("Dataset generated")

      # Run download automatically on loading app:
      shinyjs::runjs(auto_download_code)
      print("Automatic download on loading run")
    }
  )

  ## File download handler (activated when the email is valid)
  output[[DOWNLOAD_LINK_ID]] <- downloadHandler(
    filename = DATASET_FILENAME,
    content  = function(file) {

      validate_email(email())

      print("Download granted")

      # Log download attempt:
      write_event(hash = hashed_email(), event = "Download")

      simulated_data() |> readr::write_csv(file)
    },
    contentType = "text/csv"
  )
}
