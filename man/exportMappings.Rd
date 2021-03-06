% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exportMappings.R
\name{exportMappings}
\alias{exportMappings}
\title{Exports the Event-Form Mappings for a Project}
\usage{
exportMappings(
  url = getOption("redcap_bundle")$redcap_url,
  token = getOption("redcap_token"),
  arms = NULL,
  ...,
  error_handling = getOption("redcap_error_handling")
)
}
\arguments{
\item{url}{A url address to connect to the REDCap API}

\item{token}{A REDCap API token}

\item{arms}{A vector of arm numbers that you wish to pull events for (by default,
all events are pulled)}

\item{...}{Arguments to be passed to other methods}

\item{error_handling}{An option for how to handle errors returned by the API.
see \code{\link{redcap_error}}}
}
\description{
Retrieve a data frame giving the events-form mapping for a project.
}
\details{
The data frame that is returned shows the arm number, unique
event name, and forms mapped in a project.

When this function is called for a classic project, a character string is
returned giving the API error message, '400: You cannot export form-event
mappings for classic projects' but without casting an error in R. This is
by design and allows more flexible error checks in certain functions.

REDCap API Documentation:
This function allows you to export the instrument-event mappings for a project
(i.e., how the data collection instruments are designated for certain events in a
longitudinal project).

NOTE: this only works for longitudinal projects

REDCap Version:
5.8.2+ (and earlier, but we don't know how much earlier)

Known REDCap Limitations:
None
}
\references{
Please refer to your institution's API documentation.

Additional details on API parameters are found on the package wiki at
\url{https://github.com/nutterb/redcapAPI/wiki/REDCap-API-Parameters}
}
\author{
Benjamin Nutter
}
