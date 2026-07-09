# ==============================================================================
#
# FILE NAME:   data-download.R
# DESCRIPTION: "Dataset generation" app for teaching innovation project in the
#              "Introduction to Data Analysis" course.
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2026-07-08
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

setwd(here::here())


## ---- PACKAGES: --------------------------------------------------------------

library(shiny)
library(shinyjs, warn.conflicts = FALSE)


## ---- SOURCES: ---------------------------------------------------------------

source("R/constants.R",      encoding = 'UTF-8')
source("R/simulated_data.R", encoding = 'UTF-8')
source("R/hash_emails.R",    encoding = 'UTF-8')
source("R/data_storage.R",   encoding = 'UTF-8')
source("R/log.R",            encoding = 'UTF-8')


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


## ---- FUNCTIONS: -------------------------------------------------------------

## ----create-user-interface----------------------------------------------------
ui <- fluidPage(

  shinyjs::useShinyjs(), # Used to disable the download button

  # Application title
  # TODO: Decide title & add logos (if necessary)
  titlePanel(GEN_DATA_APP_TITLE),

  fillPage(

    # Download link:
    downloadLink(DOWNLOAD_LINK_ID, DOWNLOAD_LINK_LABEL),

    tags$div(tags$p(CLOSE_WINDOW_MSG), style="margin-top:2em;")
  )
)

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
      record_log("Email valid")

      ## Create unique hash for the user email:
      hashed_email(email() |> hash_emails())
      record_log("Email hash created")

      # Log access to the app:
      write_event(hash = hashed_email(), event = "Access")

      # Generate simulated data with the hashed email as seed:
      simulated_data(simulate_data(hashed_email()))
      record_log("Dataset generated")

      # Run download automatically on loading app:
      shinyjs::runjs(auto_download_code)
      record_log("Automatic download on loading run")
    }
  )

  ## File download handler (activated when the email is valid)
  output[[DOWNLOAD_LINK_ID]] <- downloadHandler(
    filename = DATASET_FILENAME,
    content  = function(file) {

      validate_email(email())

      record_log("Download started")

      # Record download attempt to users data file:
      write_event(hash = hashed_email(), event = "Download")

      simulated_data() |> readr::write_csv(file)
    },
    contentType = "text/csv"
  )
}


## ---- MAIN: ------------------------------------------------------------------

# Run the application
shinyApp(ui = ui, server = server)
