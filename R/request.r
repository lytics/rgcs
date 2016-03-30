library(httr)
library(plyr)

#' Execute a GET request with the given URL and query params
#' 
#' @field path The URL to GET
#' @field params The URL parameters
#' @field as The type of the response

exec <- function(path, params = list(), as = "parsed", token = get_access_cred()) {
	stopifnot(is.character(path))
	req <- GET(path, config(token = token), query = params)
	return (process(req, as = as))
}

#' Execute a POST request with the given URL and request body
#'
#' @field url The URL to POST to 
#' @field body The json-able Request Body 
#' @param params The query parameters

post <- function(url, body, params = list(), token = get_access_cred()) {
 	stopifnot(is.character(path))
	json <- jsonlite::toJSON(body)
  	req <- POST(url, body = json, config(token = token), query = params)
	return (process(req, as = "parsed"))
}


process <- function(req, as) {
	# no content with a 204
	status = status_code(req)
	if (status == 204)  return (TRUE)

	if (!(200 <= status && status < 300)) {
		stop(sprintf("HTTP error. Code: %d", status))
	}

	response <- content(req, as = as, type = "application/json")
	return (response)	
}
