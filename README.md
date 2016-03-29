## R GCS 

The Rgcs package provides an R interface to [Google Cloud Storage](https://cloud.google.com/storage/) . Currently it supports functionality for listing, downloading, and uploading files to/from GCS. 

## Installation 

Not on CRAN/MRAN yet - please install via `devtools::install_github` via : 

```R
devtools::install_github("lytics/Rgcs")
```

## Authentication 

Before doing anything fun, you must authorize GCS from your browser. Like the [R BigQuery](https://github.com/rstats-db/bigrquery) pacakge, `httr` caches the OAUTH access and refresh tokens for easy access. 

## Usage

```R
library(Rgcs)

# get all GCS buckets that belong to a project
buckets <- list_buckets(project = "my-project")

# get all files in a GCS Bucket
store <- gcs_store$new(bucket = buckets[1])

files <- store$list_files()

prefixed.files <- store$list_files(list(prefix = "mtcars"))

# download a file to a GCS bucket
store$download_file(list(prefix = "mtcars.csv"))

# upload a file from a GCS bucket
store$upload_file(name = "destination.csv", df = mtcars)
``` 
