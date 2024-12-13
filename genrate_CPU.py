import pandas as pd
import random
import faker
from datetime import datetime, timedelta
from multiprocessing import Pool, cpu_count
from tqdm import tqdm
import csv
import os

# Initialize the Faker library
fake = faker.Faker()

# Define the number of rows you want in your dataset
num_rows = 1000  # Adjust as needed

# Number of chunks for parallel processing
chunks = 10  # Adjust as needed

# Output file path (local directory)
output_file = os.path.join(os.getcwd(), f"Data-Sets/customer_feedback_{num_rows}.csv")

# Function to load data from CSV files into lists
def load_data_from_csv(file_name):
    with open(file_name, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        return [row[0] for row in reader]

# Load sample data from CSV files
positive_feedback = load_data_from_csv("Data-Sets/positive.csv")
neutral_feedback = load_data_from_csv("Data-Sets/neutral.csv")
negative_feedback = load_data_from_csv("Data-Sets/negative.csv")
products = load_data_from_csv("Data-Sets/products.csv")

# Function to generate random customer feedback
def generate_feedback():
    sentiment = random.choice(['positive', 'neutral', 'negative'])
    if sentiment == 'positive':
        feedback = random.choice(positive_feedback)
    elif sentiment == 'neutral':
        feedback = random.choice(neutral_feedback)
    else:
        feedback = random.choice(negative_feedback)
    return feedback, sentiment

# Function to generate a random date within a specific range
def generate_date(start_year=2015, end_year=2023):
    start_date = datetime(year=start_year, month=1, day=1)
    end_date = datetime(year=end_year, month=12, day=31)
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    random_date = start_date + timedelta(days=random_days)
    return random_date.strftime('%Y-%m-%d')

# Function to generate a chunk of data
def generate_chunk(chunk_size):
    local_fake = faker.Faker()  # Create a new instance of Faker for thread safety
    chunk_data = []
    for _ in range(chunk_size):
        customer_name = local_fake.name()
        product = random.choice(products)
        feedback_text, sentiment = generate_feedback()
        feedback_id = random.randint(1000, 9999)
        rating = random.randint(1, 5)
        purchase_date = generate_date()
        location = local_fake.city()
        customer_email = local_fake.email()
        order_id = random.randint(100000, 999999)
        chunk_data.append([customer_name, feedback_id, product, feedback_text, sentiment,
                           rating, purchase_date, location, customer_email, order_id])
    return chunk_data

# Main function to parallelize data generation
def generate_data(num_rows, chunks):
    chunk_size = num_rows // chunks
    with Pool(cpu_count()) as pool:  # Use all available CPU cores
        results = list(tqdm(pool.imap(generate_chunk, [chunk_size] * chunks),
                            total=chunks, desc="Generating data", ncols=100))
    return [row for chunk in results for row in chunk]

# Generate data and save locally
if __name__ == "__main__":
    data = generate_data(num_rows, chunks)

    # Write to CSV in chunks to avoid memory overload
    with open(output_file, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['CustomerName', 'FeedbackID', 'Product', 'FeedbackText', 'Sentiment',
                         'Rating', 'PurchaseDate', 'Location', 'CustomerEmail', 'OrderID'])
        for row in tqdm(data, desc="Writing data", ncols=100):
            writer.writerow(row)

    print(f"Data saved to {output_file}")
