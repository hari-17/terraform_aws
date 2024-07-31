output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "s3_website_url" {
  value = aws_s3_bucket.this.website_endpoint
}