library(plumber)
PORTEnv <- Sys.getenv("PORT")
PORT <- strtoi(PORTEnv, base = 0L)
if(is.na(PORT)) PORT <- 5000

message(paste0("Launching server listening on :", PORT, "...\n"))

pr("R/goffman.R") %>%
  pr_run(port=PORT, host="0.0.0.0")
