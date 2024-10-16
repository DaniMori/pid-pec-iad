# ==============================================================================
#
# FILE NAME:   constants.R
# DESCRIPTION: Constant objects for the "Dataset generation" app.
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-09-26
#
# ==============================================================================


## ---- CONSTANTS: -------------------------------------------------------------

# Shiny component identifiers:
DOWNLOAD_LINK_ID <- "download"

# Interface verbatim:
APP_TITLE           <- "Descarga de datos para actividad optativa con Jamovi"
DOWNLOAD_LINK_LABEL <-
  "Haz click aquí si la descarga no se inicia automáticamente"
CLOSE_WINDOW_MSG    <- paste(
  "(Cierra esta ventana cuando acabe la descarga",
  "para volver al curso virtual y continuar con la actividad)"
)
DATASET_FILENAME    <- "regresion_lineal.csv" # Name of downloaded dataset

# Server logic objects:

## Auto download configuration:
AUTO_DOWNLOAD_TIMEOUT <- 200L # Timeout (to start download) in milliseconds

