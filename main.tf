provider "aws" {
  region  = "us-west-1"
  profile = "personal"
}

provider "aws" {
  alias   = "acm"
  region  = "us-east-1"
  profile = "personal"
}

resource "aws_s3_bucket" "www" {
  acl    = "public-read"
  bucket = "www.zxjinn.com"
  policy = "${file("allow_all_get.json")}"

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
  acl          = "public-read"
  bucket       = "www.zxjinn.com"
  content_type = "text/plain"
  depends_on   = ["aws_s3_bucket.www"]
  etag         = "${md5(file("site/keybase.txt"))}"
  key          = "keybase.txt"
  source       = "site/keybase.txt"
}

data "aws_acm_certificate" "www" {
  provider = "aws.acm"
  domain   = "zxjinn.com"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "www" {
  aliases = ["www.zxjinn.com", "zxjinn.com"]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]
    compress        = true
    default_ttl     = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = "Custom-www.zxjinn.com.s3-website-us-west-1.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
  }

  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  origin {
    custom_origin_config = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "www.zxjinn.com.s3-website-us-west-1.amazonaws.com"
    origin_id   = "Custom-www.zxjinn.com.s3-website-us-west-1.amazonaws.com"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "${data.aws_acm_certificate.www.arn}"
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
  }
}
