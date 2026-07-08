library(rsconnect)

deployApp(
  appFiles = c(
    "app.R",
    ".Renviron",
    ".secrets/encrypted-oauth-token.rds",
    "doc/gsheets_config.yml",
    "feedback-res/student_response_variables.csv",
    "R"
  ),
  appPrimaryDoc = "app.R",
  appName = "data-download",
  account = "iad-psi-uned"
)
