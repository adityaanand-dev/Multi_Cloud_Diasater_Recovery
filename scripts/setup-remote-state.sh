#!/bin/bash
# =============================================================================
# Setup Terraform Remote State Backend (S3 + DynamoDB)
# Run this ONCE before using the project
# =============================================================================

set -euo pipefail

BUCKET_NAME="multicloud-dr-terraform-state"
DYNAMO_TABLE="terraform-state-lock"
REGION="ap-south-1"

echo "🔧 Setting up Terraform remote state backend..."
echo ""

# Create S3 bucket
echo "📦 Creating S3 bucket: ${BUCKET_NAME}"
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" \
    2>/dev/null || echo "  Bucket already exists"

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms"
            }
        }]
    }'

# Block public access
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

echo "  ✅ S3 bucket configured"

# Create DynamoDB table for state locking
echo "🔒 Creating DynamoDB table: ${DYNAMO_TABLE}"
aws dynamodb create-table \
    --table-name "$DYNAMO_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION" \
    2>/dev/null || echo "  Table already exists"

echo "  ✅ DynamoDB table configured"
echo ""
echo "🎉 Remote state backend ready!"
echo "   Bucket: s3://${BUCKET_NAME}"
echo "   Lock Table: ${DYNAMO_TABLE}"
