#' @importFrom httr oauth_endpoint oauth_app oauth2.0_token

gcs_post_url <- "https://www.googleapis.com/upload/storage/v1/b/bucket/o"
gcs_bucket_url <- "https://www.googleapis.com/storage/v1/b/bucket/o"
gcs_url <- "https://www.googleapis.com/storage/v1/b"


# Configuration and Oauth related variables
# VERY IMPORTANT!!
Sys.setenv("HTTR_SERVER_PORT" = "1410/")


gcs_env <- new.env(parent = emptyenv())
google <- oauth_endpoint(NULL, "auth", "token", base_url = "https://accounts.google.com/o/oauth2")
tim_app <- oauth_app("google", "823346042553-gi1k1u3i7o4m9123f1p11k6ho83q20r3.apps.googleusercontent.com", "Fqgw94UnA5JCDZJThrRoIrYd")
scopes <- c("https://www.googleapis.com/auth/devstorage.full_control", "https://www.googleapis.com/auth/bigquery")

get_access_cred <- function() {
  cred <- gcs_env$access_cred
  if (is.null(cred)) {
    cred <- oauth2.0_token(google, tim_app, scope =  scopes)
    # Stop if unsuccessful
    gcs_env$access_cred = cred
  }
  cred
}


