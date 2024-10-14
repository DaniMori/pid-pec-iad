# Example adapted from
# https://shiny.posit.co/r/articles/build/persistent-data-storage/

library(shiny)
library(googlesheets4)


# Define the fields we want to save from the form
fields <- c("name", "used_shiny", "r_num_years")

# Non-interactive auth setup:
# https://gargle.r-lib.org/articles/non-interactive-auth.html#project-level-oauth-cache

## Step 1: Obtain token and cache in hidden directory in current project
## (do once per project)

# designate project-specific cache
# options(gargle_oauth_cache = here::here(".secrets"))

# trigger auth on purpose --> store a token in the specified cache
# gs4_auth()

## Step 2: Announce cache location and pre-authorize token use
## (do once per script/service; maybe in ".Rprofile"?)

# Service account token setup:
# https://gargle.r-lib.org/articles/non-interactive-auth.html#provide-a-service-account-token-directly

## First create "Service Account Token" (SAT) in Google Cloud Platform:
## https://gargle.r-lib.org/articles/get-api-credentials.html#service-account-token
##
## When trying to access Google Sheets (i.e. calling `gs4_get()`), prompted with
## "enabling the Google Sheets API"; just using the link provided and enabling
## the API works.
##
## Use token:
gs4_auth(path = ".secrets/<token_filename>.json")

options(
  gargle_oauth_cache = here::here(".secrets"),
  gargle_oauth_email = "danielmorillo.ac@gmail.com"
)

# now "do anything" that triggers authentication
doc_url <- "https://docs.google.com/spreadsheets/d/1jzpIEa_h9AOyNSkJU80x4IFbAKj9AOkREwHmpbcPVyM"
file_link <- gs4_get(doc_url)


# TODO: Encrypting token: https://gargle.r-lib.org/articles/managing-tokens-securely.html
KEY_NAME   <- "PID-PEC-IAD_KEY"
secret_key <- gargle::secret_make_key()


saveData <- function(data) {
  # The data must be a dataframe rather than a named vector
  data <- data %>% as.list() %>% data.frame()
  # Add the data as a new row
  sheet_append(file_link, data)
}

loadData <- function() {
  # Read the data
  read_sheet(file_link)
}

# Shiny app with 3 fields that the user can submit data for
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput("responses", width = 300), tags$hr(),
    textInput("name", "Name", ""),
    checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
    sliderInput("r_num_years", "Number of years using R",
                0, 25, 2, ticks = FALSE),
    actionButton("submit", "Submit")
  ),
  server = function(input, output, session) {

    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })

    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })

    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData()
    })
  }
)
