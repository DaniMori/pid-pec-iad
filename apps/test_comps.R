library(shiny)
library(shinyjs)

# Define the UI
ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("
      .email-input-container {
        display: flex;
        align-items: center;
      }
      .email-input-container > * {
        margin-right: 5px;
      }
      .domain {
        font-weight: bold;
      }
      .verification-mark {
        width: 20px;
        height: 20px;
      }
    "))
  ),

  div(class = "email-input-container",
      textInput("username", label = NULL, placeholder = "Enter username"),
      span(class = "domain", "@example.com"),
      uiOutput("verificationMark")
  )
)

# Define the server logic
server <- function(input, output, session) {
  # Reactive value to store email validation state
  email_state <- reactiveVal("blank")

  # Observe changes in the username input
  observeEvent(input$username, {
    if (input$username == "") {
      email_state("blank")
    } else {
      email_state("processing")
      # Simulate email verification process
      invalidateLater(1000)

      # Email validation logic (simple example)
      valid_email <- grepl("^[a-zA-Z0-9._%+-]+$", input$username)

      if (valid_email) {
        email_state("valid")
      } else {
        email_state("invalid")
      }
    }
  })

  # Render the verification mark
  output$verificationMark <- renderUI({
    switch(email_state(),
           "blank" = img(src = "https://example.com/blank.png", class = "verification-mark"),
           "processing" = tags$img(src = "https://example.com/processing.gif", class = "verification-mark"),
           "valid" = img(src = "https://example.com/valid.png", class = "verification-mark"),
           "invalid" = img(src = "https://example.com/invalid.png", class = "verification-mark")
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
