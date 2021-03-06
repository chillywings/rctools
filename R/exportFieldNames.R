#' @name exportFieldNames
#' @title Export the Export Field Names for a Project
#' 
#' @description Retrieve a data frame giving the original (as defined in REDCap)
#'   field name, choice values (for checkboxes), and the export field name.
#'
#' @param url A url address to connect to the REDCap API
#' @param token A REDCap API token
#' @param fields Field name to be returned.  If \code{NULL}, all fields are returned.
#' @param bundle A \code{redcapProject} object as created by \code{redcapProjectInfo}.
#' @param ... Arguments to be passed to other methods.
#' @param error_handling An option for how to handle errors returned by the API.
#'   see \code{\link{redcap_error}}
#'
#' 
#' @details REDCap API Documentation:
#' This function returns a list of the export/import-specific version of field names for 
#' all fields (or for one field, if desired) in a project. This is mostly used for 
#' checkbox fields because during data exports and data imports, 
#' checkbox fields have a different variable name used than the exact one 
#' defined for them in the Online Designer and Data data_dictionary, in which 
#' *each checkbox option* gets represented as its own export field name in the 
#' following format: field_name + triple underscore + converted coded value for the 
#' choice. For non-checkbox fields, the export field name will be exactly the same 
#' as the original field name. Note: The following field types will be automatically 
#' removed from the list returned by this method since they cannot be utilized during 
#' the data import process: "calc", "file", and "descriptive".
#'
#' The list that is returned will contain the three following attributes for each 
#' field/choice: "original_field_name", "choice_value", and "export_field_name". 
#' The choice_value attribute represents the raw coded value for a checkbox choice. 
#' For non-checkbox fields, the choice_value attribute will always be blank/empty. 
#' The export_field_name attribute represents the export/import-specific version of 
#' that field name.
#' 
#' REDCap Version:
#' 6.5.0+ (perhaps earlier; need to confirm its introduction)
#' 
#' Known REDCap Limitations: 
#' In 6.5.0, it has been observed that "slider" fields are not returned.  
#' 
#' Signature fields are also not included, but these are effectively the same as 
#' "file" fields.  This isn't a true limitation, but is documented here just to
#' avoid confusion.
#' 
#' @return
#' A data frame containing three fields: 
#' \itemize{
#'   \item{\code{original_field_name} }{The field name as recorded in the 
#'        data data_dictionary}
#'   \item{\code{choice_value} }{represents the raw coded value for a checkbox 
#'        choice. For non-checkbox fields, this will always be \code{NA}.}
#'   \item{\code{export_field_name} }{The field name specific to the field.
#'        For non-checkbox fields, this is the same as \code{original_field_name}.
#'        For checkbox fields, it is the field name appended with 
#'        \code{___[choice_value]}.}
#' }
#'
#' @author Stephen Lane
#'
#' @references
#' Please refer to your institution's API documentation
#' (https://YOUR_REDCAP_URL/redcap/api/help)
#'
#' Additional details on API parameters are found on the package wiki at
#' \url{https://github.com/nutterb/redcapAPI/wiki/REDCap-API-Parameters}


exportFieldNames <- function(url = getOption("redcap_bundle")$redcap_url,
token = getOption("redcap_token"),
 fields = NULL, 
                                   bundle = NULL, ...,
                                   error_handling = getOption("redcap_error_handling"))
{
 
  coll <- checkmate::makeAssertCollection()
  
  massert(~ url + token + bundle,
          fun = checkmate::assert_class,
          classes = list(url = "character", token = "character",
                         bundle = "redcapBundle"),
          null.ok = list(url = FALSE, token = FALSE,
                         bundle = TRUE))
  
  checkmate::assert_character(x = fields,
                              null.ok = TRUE,
                              add = coll)
  
  error_handling <- checkmate::matchArg(x = error_handling,
                                        choices = c("null", "error"),
                                        add = coll)
  
  checkmate::reportAssertions(coll)
  
  ##* parameters for the Field Names Export
  body <- list(token = token, 
               content = 'exportFieldNames', 
               format = 'csv',
               returnFormat = 'csv')
  
  ## Get project metadata
  data_dict <- 
    if(is.null(bundle$data_dict))
      exportMetaData(url, token) 
    else 
      bundle$data_dict

  ## Field was provided
  if(!is.null(fields)){
    ## verify field exists
    if(is.character(fields) && all((fields %in% data_dict$field_name)))
    {
      if (length(fields) == 1)
        body[['field']] <- paste0(fields, collapse = ",")
      else
        message("Due to a bug in the REDCap API, the 'fields' argument ",
                "cannot be honored when it has length greater than 1. ",
                "The result for all fields will be returned")
    } 
    else 
    {
      bad_fields <- fields[!fields %in% data_dict$field_name]
      stop(message("Non-existent field(s): ", 
                   paste0(bad_fields, collapse = ", ")))
    }
  }
  
  ##* Export Users file and convert to data frame
  x <- httr::POST(url = url, 
                  body = body)
  
  if (x$status_code != 200) redcap_error(x, error_handling)
  
  utils::read.csv(text = as.character(x), 
                  stringsAsFactors = FALSE,
                  na.strings = "")
}