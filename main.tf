provider "aws" {
  region     = "us-west-1"
}

resource "aws_s3_bucket" "www" {
  acl    = "public-read"
  bucket = "www.zxjinn.com"
  policy ="${file("allow_all_get.json")}"
  website {
    error_document = "index.html"
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  acl          = "public-read"
  bucket       = "www.zxjinn.com"
  content_type = "text/html"
  depends_on   = ["aws_s3_bucket.www"]
  etag         = "${md5(file("site/index.html"))}"
  key          = "index.html"
  source       = "site/index.html"
}
resource "aws_s3_bucket_object" "keybase" {
  acl        = "public-read"
  bucket     = "www.zxjinn.com"
  content_type = "text/plain"
  depends_on = ["aws_s3_bucket.www"]
  etag       = "${md5(file("site/keybase.txt"))}"
  key        = "keybase.txt"
  source     = "site/keybase.txt"
}
