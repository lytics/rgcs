#' A helper function to list the GCS buckets specific to a project 
#'
#' @field project The GCS project name 
#' @field max_results The maximum number of buckets to return 
#' 
#' @export

list_buckets <- function(project, max_results = NULL) {
	stopifnot(is.character(project))
	if (!is.null(max_results)) stopifnot(is.numeric(max_results))

	params <- list("project" = project)	
	if (!is.null(max_results)) {
		params$maxResults = max_results
	}

	resp <- exec(gcs_url, params = params)

	items <- resp$items
	do.call("rbind", lapply(items, as.data.frame, row.names = 1L))
}