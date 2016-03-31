context("List Buckets")

test_that("test bad auth", {

	expect_error(list_buckets(123), "project is not a string")
})