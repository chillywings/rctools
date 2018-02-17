% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkbox_suffixes.R
\name{checkbox_suffixes}
\alias{checkbox_suffixes}
\title{Checkbox Suffixes}
\usage{
checkbox_suffixes(fields, meta_data, version)
}
\arguments{
\item{fields}{The current field names of interest}

\item{meta_data}{The meta data data frame.}

\item{version}{The REDCap version number.}
}
\description{
Checkbox variables return one vector of data for each option defined
  in the variable.  The variables are returned with the suffix \code{___[option]}.
  \code{exportRecords} needs these suffixes in order to retrieve all of the 
  variables and to apply the correct labels.
}