exportArms <- function(rcon, arms, ...) UseMethod("exportArms")

exportArms.redcapDbConnection <- function(rcon, arms, ...){
  message("Please accept my apologies.  The exportUsers method for redcapDbConnection objects\n",
          "has not yet been written.  Please consider using the API.")
}

exportArms.redcapApiConnection <- function(rcon, arms, ...){
  .params <- list(token=rcon$token, content='arm', format='csv', returnFormat='csv')
  if (!missing(arms)) .params[['arms']] <- paste(arms, collapse=',')
  x <- httr::POST(url=rcon$url, body=.params)
  
  if (x$status_code == "200")
    return(read.csv(textConnection(as.character(x)), stringsAsFactors=FALSE))
  else stop(paste(x$status_code, ": ", as.character(x), sep=""))
}