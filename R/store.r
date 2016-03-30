#' A reference class to abstract a Gcs Store 
#'
#' @field bucket Google Cloud Storage Bucket
#' 
#' @examples
#' store <- gcs_store$new("my_bucket")
#'
#' files <- store$list_files() 
#'
#' file <- store$download_file("path/to/my/file.csv")
#'
#' store$upload_file("path/to/my/file.csv", mtcars)
#' 
#' @exportClass gcs_store
#' @export gcs_store

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
			plyr::rbind.fill(lapply(items, as.data.frame, row.names = 1L))
		},
		download_file = function(query = list()) {
			stopifnot(is.list(query))
			stopifnot(!is.null(query$prefix))

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
		upload_file = function(name, data = list()) {
			stopifnot(is.character(name))
			stopifnot(is.list(data))
			
			# write dataframe to tmp file
			tmp.file <- sprintf("/tmp/rgcs_%d", sample(100000:999999, 1))
			tf = file(tmp.file, "w+")
			write.csv(data, tf)

			# set uploadType to "media"
			params = list(bucket = .self$bucket, uploadType = "media", name = name)

			# uplaod to gcs
			req <- POST(gcs_post_url, config(token = get_access_cred()), body = upload_file(tmp.file), query = params, add_headers("Content-Type" = "text/csv"))
			resp <- process(req, as = "parsed")

			# remove tmp file
			file.remove(tmp.file)
			return (resp)
		}
	)
)