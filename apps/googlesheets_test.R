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

# ## Step 2: Announce cache location and pre-authorize token use
# ## (DO NOT perform this step. See "Encrypt token" below instead)
# options(
#   gargle_oauth_cache = here::here(".secrets"),
#   gargle_oauth_email = "danielmorillo.ac@gmail.com"
# )

# Encrypt token: https://gargle.r-lib.org/articles/managing-tokens-securely.html
KEY_NAME   <- "PID_PEC_IAD_KEY"

# Do this once:
# secret_key <- gargle::secret_make_key()
#
# Then write password to ".Renviron" as PID_PEC_IAD_KEY = <password>
#
# Restart R (so that the environment variable is loaded)
#
# Encrypt OAuth token:
# gargle::secret_write_rds(
#   gs4_token(),
#   ".secrets/gs4-oauth-token.rds",
#   key = KEY_NAME
# )
oauth_token <- gargle::secret_read_rds(
  path = here::here(".secrets/encrypted-oauth-token.rds"),
  key  = KEY_NAME
)
gs4_auth(token = oauth_token)

# now "do anything" that triggers authentication
doc_url <- "https://docs.google.com/spreadsheets/d/1oiOcp9sOD5_FTTgsnlZCmZNI0s5MM7tYiCvo7GER8Ww"
file_link <- gs4_get(doc_url)

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
