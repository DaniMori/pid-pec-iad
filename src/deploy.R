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
  appName = "Data Download App",
  account = "iad-psi-uned",
  server  = "connect.posit.cloud"
)
