resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }

}


resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.this.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.this.id
  acl    = "public-read"
}

resource "aws_s3_object" "s3BucketObject" {
    bucket     = aws_s3_bucket.this.id
  key        = "index.html"
  source     = "./index.html"
  content_type = "text/html"

}



resource aws_s3_bucket_website_configuration hosting_bucket_configuration {
  bucket = aws_s3_bucket.this.id # Reference to the hosting bucket

  index_document {
    suffix = "index.html" # Default document served by the website
  }

 
}




resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_read_only_access.json
}

data "aws_iam_policy_document" "allow_read_only_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    
    actions = [
      "s3:*",
      
    ]
  
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}