#' A reference class to abstract a Gcs Store 
#'
#' @field bucket Google Cloud Storage Bucket
#' 
#' @examples
#' store <- gcs_store$new("my_bucket")
#' files <- store$list_files() 
#' file <- store$download_file("path/to/my/file.csv")
#' store$upload_file("path/to/my/file.csv", mtcars)
#' 
#' @export 

gcs_store <- setRefClass("gcs_store", 
	fields = list(
		bucket = "character"
	),
	methods = list(
		list_files = function(query=list()) {
			params = list(bucket = .self$bucket)
			if (!is.null(query$delimiter)) params$delimiter = query$delimiter
			if (!is.null(query$prefix)) params$prefix = query$prefix
			if (!is.null(query$versions)) params$versions = query$versions

			resp <- exec(gcs_bucket_url, params = params)
			items <- resp$items
			do.call("rbind", lapply(items, as.data.frame, row.names = 1L))
		},
		download_file = function(query = list()) {
			stopifnot(is.list(query))

			files <- .self$list_files(query)
			if (nrow(files) < 1) {
				stop(sprintf("no files found with query %s", query))
			}

			if (nrow(files) != 1) {
				stop(sprintf("too many files found with query %s: %s", query, files))
			}

			# download files in parallel
			file = files[1, ]
			url <- as.character(file$mediaLink)
			resp = exec(url, as = "text")
			tc <- textConnection(resp)
			df <- read.csv(tc)
			if (isIncomplete(tc)) stop("text connection is incomplete")
			close(tc)
			df
		},
		upload_file = function(name, df) {
			stopifnot(is.character(name))
			stopifnot(is.data.frame(df))

			# write dataframe to tmp file
			tmp.file <- sprintf("/tmp/%s", name)
			tf = file(tmp.file, "w+")
			write.csv(df, tf)

			# set uploadType to "media"
			params = list(bucket = .self$bucket, uploadType = "media", name = name)

			# uplaod to gcs
			req <- POST(gcs_post_url, config(token = cred), body = upload_file(tmp.file), query = params, add_headers("Content-Type" = "text/csv"))
			resp <- process(req, as = "parsed")

			# remove tmp file
			file.remove(tmp.file)
			return (resp)
		}
	)
)

#' A helper funciton to list the GCS buckets specific to a project 
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