import pandas as pd
import boto3
from botocore.exceptions import NoCredentialsError

# Extract
df = pd.read_csv('NYC_air_bnb_dataset.csv')

# Transform (for simplicity, just basic data type conversions)
df['price'] = df['price'].str.replace('$', '').str.replace(',', '').astype(float)
##########


# Convert price column from string to numeric
df['price'] = df['price'].str.replace('$', '').str.replace(',', '').astype(float)

# Convert last_review to datetime and handle missing values
df['last_review'] = pd.to_datetime(df['last_review'], format='%Y-%m-%d', errors='coerce')
df['last_review'].fillna(pd.to_datetime('2023-01-01'), inplace=True)

# Handle missing values in reviews_per_month
df['reviews_per_month'].fillna(0.0, inplace=True)

# Calculate the total price for each listing based on minimum nights
df['total_price'] = df['price'] * df['minimum_nights']

# Step 3: Data Quality Checks

# Check for duplicate records and remove them
df.drop_duplicates(subset=['id', 'name'], keep='first', inplace=True)

# Check for invalid prices and set a default value
df.loc[df['price'] <= 0, 'price'] = 0



##########
# Load into AWS (e.g., S3)
bucket_name = 'your-aws-bucket'
file_name = 'cleaned_data.csv'
df.to_csv(file_name, index=False)

# Upload to S3
s3 = boto3.client('s3')
try:
    s3.upload_file(file_name, bucket_name, file_name)
except NoCredentialsError:
    print("AWS credentials not available")

# Automate the ETL pipeline and scheduling
# You can use AWS Lambda, Glue, or other services for automation
