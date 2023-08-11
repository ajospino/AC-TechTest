resource "aws_s3_bucket" "ac_tt_state" {
  bucket = "ac-tt-tfstate"
  
  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_dynamodb_table" "ac_tt_statelock" {
  name = "ac-tt-dyn-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}



terraform {
  backend "s3"{
    bucket = aws_s3_bucket.ac_tt_state.name
    key = "main"
    region = var.region
    dynamodb_table = aws_dynamodb_table.ac_tt_statelock.name
  }
}