generate_random_username <- function(length = 8) {
  # Caratteri validi per il nome utente
  valid_chars <- c(0:9, letters, LETTERS)

  # Genera un nome utente casuale di lunghezza specificata
  random_username <- paste0(sample(valid_chars, length, replace = TRUE), collapse = "")

  return(random_username)
}

