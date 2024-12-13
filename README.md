
# Customer Feedback Data Generation Script

This script generates a synthetic dataset of customer feedback, including randomly generated customer information, product reviews, ratings, and other relevant details. The data is generated using the Python libraries `faker`, `random`, `datetime`, and `multiprocessing` for efficient parallel data generation. The dataset is saved as a CSV file, which can be used for various purposes such as analysis, training machine learning models, or simulating real-world customer interactions.

## Features

- Generates a customizable number of synthetic customer feedback entries.
- Randomizes customer names, feedback text, sentiment, product names, and other details.
- Supports parallel data generation for faster processing on multi-core systems.
- Saves the generated dataset to a CSV file.
- Handles large datasets by writing in chunks to avoid memory overload.

## Prerequisites

Before running the script, ensure that the following Python libraries are installed:

- `pandas`
- `faker`
- `tqdm`

You can install the necessary libraries using pip:

```bash
pip install pandas faker tqdm
```

Additionally, ensure that you have the following CSV files in the `Data-Sets` directory:

- `positive.csv`: Contains sample positive feedback texts.
- `neutral.csv`: Contains sample neutral feedback texts.
- `negative.csv`: Contains sample negative feedback texts.
- `products.csv`: Contains sample product names.

## How It Works

### 1. Data Loading:
The script loads sample data from CSV files (`positive.csv`, `neutral.csv`, `negative.csv`, `products.csv`) and stores them in memory.

### 2. Data Generation:
- A random sentiment (positive, neutral, or negative) is chosen for each feedback entry.
- Depending on the sentiment, the corresponding feedback text is selected from the appropriate file (`positive.csv`, `neutral.csv`, or `negative.csv`).
- A random product name is selected from the `products.csv` file.
- Additional customer details (name, location, email, etc.) are randomly generated using the `Faker` library.

### 3. Parallel Processing:
The script uses Python's `multiprocessing` module to divide the data generation into chunks, which are processed in parallel using multiple CPU cores. This speeds up the data generation process.

### 4. Data Writing:
The generated data is written to a CSV file (`customer_feedback_{num_rows}.csv`), which includes the following columns:

- `CustomerName`: Randomly generated customer name.
- `FeedbackID`: Random unique ID for each feedback entry.
- `Product`: Randomly selected product name.
- `FeedbackText`: Feedback text corresponding to the sentiment.
- `Sentiment`: Sentiment of the feedback (positive, neutral, negative).
- `Rating`: Random rating (1 to 5).
- `PurchaseDate`: Random purchase date between 2015 and 2023.
- `Location`: Random city name.
- `CustomerEmail`: Random email address.
- `OrderID`: Random order ID.

## Configuration

### Number of Rows:
The number of feedback entries to generate is specified by the `num_rows` variable. You can modify this to generate more or fewer rows.

```python
num_rows = 1000  # Adjust as needed
```

### Number of Chunks:
The script divides the data generation into multiple chunks for parallel processing. The number of chunks is specified by the `chunks` variable. Increasing the number of chunks can improve performance on multi-core systems.

```python
chunks = 10  # Adjust as needed
```

### Output File Path:
The generated CSV file will be saved in the `Data-Sets` directory with the name `customer_feedback_{num_rows}.csv`. The path is dynamically constructed based on the `num_rows` value.

```python
output_file = os.path.join(os.getcwd(), f"Data-Sets/customer_feedback_{num_rows}.csv")
```

## Running the Script

To run the script, execute it in a Python environment:

```bash
python generate_customer_feedback.py
```

Once the script finishes execution, you will see a message indicating the file location:

```
Data saved to /path/to/current/directory/Data-Sets/customer_feedback_1000.csv
```

The generated dataset will be saved to the `Data-Sets` directory as a CSV file.

## Example CSV Structure

The resulting CSV file will look like this:

| CustomerName | FeedbackID | Product   | FeedbackText                          | Sentiment | Rating | PurchaseDate | Location   | CustomerEmail           | OrderID |
|--------------|------------|-----------|---------------------------------------|-----------|--------|--------------|------------|-------------------------|---------|
| John Doe     | 1234       | Product A | Great product! Highly recommend it.   | positive  | 5      | 2022-03-01   | New York   | john.doe@example.com     | 123456  |
| Jane Smith   | 5678       | Product B | It's okay, could be improved.         | neutral   | 3      | 2021-06-15   | Los Angeles| jane.smith@example.com   | 654321  |
| Bob Johnson  | 9101       | Product C | Terrible, broke after one use.        | negative  | 1      | 2020-09-10   | Chicago    | bob.johnson@example.com  | 987654  |

--

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
