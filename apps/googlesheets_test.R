# Example adapted from
# https://shiny.posit.co/r/articles/build/persistent-data-storage/

library(shiny)

# Define the fields we want to save from the form
fields <- c("name", "used_shiny", "r_num_years")

library(googlesheets4)

# Authentication steps (may be wrong or incomplete):
# gs4_auth() # Authenticates interactively through the browser
doc_url <- "https://docs.google.com/spreadsheets/d/1jzpIEa_h9AOyNSkJU80x4IFbAKj9AOkREwHmpbcPVyM"
file_link <- gs4_get(doc_url)
# gs_token <- gs4_token()
# save(gs_token, file = "dat/token.Rdata")

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
