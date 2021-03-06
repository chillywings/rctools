#' @name rc_format
#'
#' @title Format records data
#' @description  Uses REDCap project metadata to format records data.
#' @details This function takes raw REDCap data and adds column labels, converts
#' columns to numeric/character/factor as appropriate, and applies factor and 
#' checkbox labels. Formatting details of the returned dataframe can be found
#' via attributes(record_data)$redcap_formatting.
#' 
#' @param record_data Dataframe. Record data export from REDCap
#' @param data_dict Dataframe. REDCap project data data_dictionary. By default, 
#' this will be fetched from the REDCap bundle option, as created by \code{rc_bundle}.
#' Otherwise, a data.frame containing the project data dictionary must be supplied.
#' 
#' @param factors Logical.  Determines if categorical data from the database is 
#'   returned as numeric codes or labelled factors. See 'Checkbox Variables'
#'   for more on how this interacts with the \code{checkbox_labels} argument.
#' @param labels Logical.  Determines if the variable labels are applied to 
#'   the data frame.
#' @param dates Logical. Determines if date variables are converted to POSIXct 
#'   format during the download.
#' @param checkbox_labels Logical. Determines the format of labels in checkbox 
#'   variables.  If \code{FALSE} labels are applies as "Unchecked"/"Checked".  
#'   If \code{TRUE}, they are applied as ""/"[field_label]" where [field_label] 
#'   is the label assigned to the level in the data data_dictionary. 
#'   This option is only available after REDCap version 6.0.  See Checkbox Variables
#'   for more on how this interacts with the \code{factors} argument.
#' @param event_names Set to 'label' to apply event labels to redcap_event_name 
#'   column or 'raw' to invert the operation. If \code{NULL} (Default) no operations
#'   will be performed.
#' @param strip Logical. If \code{TRUE}, empty rows and columns will be removed from
#' record_data. See \code{rc_strip} for more information or call seperately for more
#' options. 
#'   
#' 
#' Checkbox Variables:
#' 
#' There are four ways the data from checkbox variables may be 
#' represented depending on the values of \code{factors} and 
#' \code{checkbox_labels}. The most common are the first and third 
#' rows of the table below.  When \code{checkbox_labels = TRUE}, either 
#' the coded value or the labelled value is returned if the box is 
#' checked, or an empty string if it is not.
#' 
#' \tabular{lll}{
#' \code{factors} \tab \code{checkbox_labels} \tab Output \cr
#' \code{FALSE}   \tab \code{FALSE}          \tab 0 / 1 \cr
#' \code{FALSE}   \tab \code{TRUE}           \tab "" / value \cr
#' \code{TRUE}    \tab \code{FALSE}          \tab Unchecked / Checked \cr
#' \code{TRUE}    \tab \code{TRUE}           \tab "" / label 
#' }
#' 
#' @importFrom magrittr '%>%'
#' 
#' @author Marcus Lehr
#' @author Benjamin Nutter
#'
#' @export

rc_format <- function(record_data, data_dict = getOption("redcap_bundle")$data_dict,
                      event_data = getOption("redcap_bundle")$event_data,
                      factors = TRUE, labels = TRUE, dates = TRUE,
                      checkbox_labels = FALSE, event_names = NULL, strip = FALSE)
{
  
  validate_args(required = c('record_data','data_dict'),
                record_data = record_data, data_dict = data_dict,
                factors = factors, labels = labels, dates = dates,
                checkbox_labels = checkbox_labels, event_names = event_names,
                event_data = event_data, strip = strip)

  
  #* for purposes of the export, we don't need the descriptive fields. 
  #* Including them causes errors in checkbox_suffixes
  data_dict <- data_dict[!data_dict$field_type %in% "descriptive",]
  
  # Apply formatting/type conversions
  record_data <- fieldToVar(records = record_data, 
                            data_dict = data_dict, 
                            factors = factors, 
                            dates = dates, 
                            checkbox_labels = checkbox_labels)
  
  # All NA cols are formatted as logical and cause join issues
  if ('redcap_repeat_instrument' %in% names(record_data))
    record_data$redcap_repeat_instrument = as.character(record_data$redcap_repeat_instrument)
  if ('redcap_repeat_instance' %in% names(record_data))
    record_data$redcap_repeat_instance = as.character(record_data$redcap_repeat_instance)
  
  if (labels){
    # Get field names
    fields = names(record_data)[names(record_data) %in% data_dict$field_name]
    
    # Currently generating labels for all fields
    col_labels = checkbox_suffixes(field_names = data_dict$field_name,
                                   data_dict = data_dict)
    
    # Apply column labels
    Hmisc::label(record_data) = as.list(col_labels[match(names(record_data),names(col_labels))])
    
    # Hmisc inserts 'labelled' into the column classes
    # Removing the labelled class to prevent downstream issues
    for (col in seq_along(record_data)) {
      class(record_data[[col]]) <- setdiff(class(record_data[[col]]), 'labelled')
    }
  }
  else {
    # Remove column labels
    # https://stackoverflow.com/questions/2394902/remove-variable-labels-attached-with-foreign-hmisc-spss-import-functions
    for (col in seq_along(record_data)) {
      class(record_data[[col]]) <- setdiff(class(record_data[[col]]), 'labelled')
      attr(record_data[[col]],"label") <- NULL
    }
  }
  
  if (!is.null(event_names)) {
    # Move check to beginning of function?
    if (is.null(event_data)) 
      stop("bundle$event_data must be provided to label redcap_event_name")
    
    # Check for previous labeling of events. Using any() is less strict than all() and will introduce NAs for event names not in metadata
    if (any(record_data$redcap_event_name %in% event_data$event_name))
        levels = event_data$event_name
    else levels = event_data$unique_event_name # Default assumption. Could be better to explicitly check
    
    if (event_names == 'label')
      # Convert to labeled values
      record_data$redcap_event_name = factor(record_data$redcap_event_name, 
                                             levels = levels, 
                                             labels = event_data$event_name)
    else if (event_names == 'raw')
      # Undo if labeled
      record_data$redcap_event_name = factor(record_data$redcap_event_name,
                                             levels = levels,
                                             labels = event_data$unique_event_name)
  }
  
  if (strip) record_data = rc_strip(record_data)
  
  # Append formatting details to df attributes
  format_record = c(factors,labels,dates,checkbox_labels)
  names(format_record) = c('factors','labels','dates','checkbox_labels')
  attr(record_data, 'redcap_formatting') = format_record
  
  return(record_data)
}