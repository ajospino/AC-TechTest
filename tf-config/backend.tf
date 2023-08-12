/* resource "aws_s3_bucket" "ac_tt_state" {
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
} */



terraform {
  backend "s3"{
    bucket = "ac-tt-tfstate"
    key = "main"
    region = "us-east-2"
    dynamodb_table = "ac-tt-dyn-table"
  }
}
