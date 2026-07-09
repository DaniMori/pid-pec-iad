library(rsconnect)

file.copy("data-download.R", "app.R")

deployApp(
  appFiles      = c(
    "app.R",
    ".Renviron",
    ".secrets/encrypted-oauth-token.rds",
    "doc/gsheets_config.yml",
    "feedback-res/student_response_variables.csv",
    "R/_disable_autoload.R",
    "R/constants.R",
    "R/data_storage.R",
    "R/hash_emails.R",
    "R/log.R",
    "R/simulated_data.R"
  ),
  appName       = "Data Download App",
  appPrimaryDoc = "app.R",
  account       = "iad-psi-uned",
  server        = "connect.posit.cloud",
  forceUpdate   = TRUE
)

file.remove("app.R")
