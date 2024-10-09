# ==============================================================================
#
# FILE NAME:   hash_emails.R
# DESCRIPTION: Encrypts emails using a hash function
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-09
#
# ==============================================================================


## ---- CONSTANTS: -------------------------------------------------------------

# <level_1_section>:

## <level_2_section>:


## ---- FUNCTIONS: -------------------------------------------------------------

hash_emails <- function(emails) {

  emails |> digest::digest() |> digest::digest2int()
}
