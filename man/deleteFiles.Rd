% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deleteFiles.R
\name{deleteFiles}
\alias{deleteFiles}
\title{Delete a File attached to a Record}
\usage{
deleteFiles(
  url = getOption("redcap_bundle")$redcap_url,
  token = getOption("redcap_token"),
  record = NULL,
  field = NULL,
  event = NULL,
  ...,
  bundle = getOption("redcap_bundle"),
  error_handling = getOption("redcap_error_handling")
)
}
\arguments{
\item{url}{A url address to connect to the REDCap API}

\item{token}{A REDCap API token}

\item{record}{The record ID in which the desired file is stored. Must be length 1.}

\item{field}{The field name in which the file is stored. Must be length 1.}

\item{event}{The event name for the file.  Must be length 1.
This applies only to longitudinal projects.  If the event is not
supplied for a longitudinal project, the API will return an error message.}

\item{...}{Arguments to be passed to other methods}

\item{bundle}{A \code{redcapBundle} object as created by \code{rc_bundle}.}

\item{error_handling}{An option for how to handle errors returned by the API.
see \code{\link{redcap_error}}}
}
\description{
This function allows you to remove a document that has been
attached to an individual record
}
\references{
Please refer to your institution's API documentation.

Additional details on API parameters are found on the package wiki at
\url{https://github.com/nutterb/redcapAPI/wiki/REDCap-API-Parameters}
}
\author{
Benjamin Nutter
}
