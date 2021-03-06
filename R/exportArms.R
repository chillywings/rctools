#' @name exportArms
#'
#' @title Export the Arms for a Project
#' @description This function allows you to export the Arms for a project
#'   Note: this only works for longitudinal projects
#'
#' @param url A url address to connect to the REDCap API
#' @param token A REDCap API token
#' @param arms A numeric vector or arm numbers to retrieve. In REDCap 6.5.0, 
#'   using this argument results in an empty data frame being returned.
#' @param error_handling An option for how to handle errors returned by the API.
#'   see \code{\link{redcap_error}}
#' @param ... Arguments to be passed to other methods.
#' 
#' @details
#' It is not sufficient to make the project a longitudinal project. The
#' project must satisfy one of two conditions: 1) have at least two arms and
#' one event defined in each arm; or 2) have one arm and at least two events defined. If 
#' neither of these conditions are satisfied, the API will return a message
#' such as \code{ERROR: You cannot export arms for classic projects}, an 
#' error message that isn't as descriptive of the nature of the problem as 
#' we might like.
#' 
#' REDCap API Documentation:
#' This function allows you to export the Arms for a project
#' 
#' NOTE: this only works for longitudinal projects.
#' 
#' REDCap Version:
#' 5.8.2+ 
#' 
#' Known REDCap Limitations:
#' In versions earlier than 5.9.15, providing a value to the \code{arms} argument
#' had no effect and the entire data frame of arms is returned.
#' 
#' This was fixed in version 5.9.15.  Sometime before 6.5.0, using the \code{arms}
#' argument resulted in empty data frames being returned.
#' 
#' In most cases, the number or arms is fairly small, so there is no real performance 
#' benefit to only selecting a subset of the arms.  The safest course of action is 
#' to export all of the arms (the default behavior)  
#'
#' @return 
#' Returns a data frame with two columns
#' 
#' \itemize{
#'   \item{\code{arm_num} }{The arm number}
#'   \item{\code{name} }{The arm's descriptive name}
#' }
#'
#' @author Benjamin Nutter
#'
#' @references
#' Please refer to your institution's API documentation.
#'
#' Additional details on API parameters are found on the package wiki at
#' \url{https://github.com/nutterb/redcapAPI/wiki/REDCap-API-Parameters}


exportArms <- function(url = getOption("redcap_bundle")$redcap_url,
token = getOption("redcap_token"),
 arms = NULL, ...,
                        error_handling = getOption("redcap_error_handling"))
{
  coll <- checkmate::makeAssertCollection()

  checkmate::assert_character(x = url,
                          add = coll)
						  
  checkmate::assert_character(x = token,
                          add = coll)
  
  checkmate::assert_character(x = arms,
                              null.ok = TRUE,
                              add = coll)
  
  error_handling <- checkmate::matchArg(x = error_handling, 
                                        choices = c("null", "error"),
                                        add = coll)
  
  checkmate::reportAssertions(coll)
  
  #* parameters for the Users File Export
  body <- list(token = token, 
               content = 'arm', 
               format = 'csv', 
               returnFormat = 'csv')
  
  if (!is.null(arms)) body[['arms']] <- paste0(arms, collapse = ",")
  
  #* Export Users file and convert to data frame
  x <- httr::POST(url = url, 
                  body = body)
  
  if (x$status_code != 200) return(redcap_error(x, error_handling))
  
  utils::read.csv(text = as.character(x),
                  stringsAsFactors = FALSE,
                  na.strings = "")
}
