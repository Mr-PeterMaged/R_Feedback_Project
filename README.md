
# Customer Feedback Data Generation Script

This script generates a synthetic dataset of customer feedback, including randomly generated customer information, product reviews, ratings, and other relevant details. The data is generated using the Python libraries `faker`, `random`, `datetime`, and `multiprocessing` for efficient parallel data generation. The dataset is saved as a CSV file, which can be used for various purposes such as analysis, training machine learning models, or simulating real-world customer interactions.

[image alt](https://github.com/Mr-PeterMaged/R_Feedback_Project/blob/main/Data-Set/sentiment_pie_chart.png)]


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

---

# Customer Feedback Analysis in R

This R script performs text preprocessing, topic modeling, and data visualization on a customer feedback dataset. It includes data cleaning, sentiment analysis, and topic modeling using Latent Dirichlet Allocation (LDA). The results are visualized through various plots, and the data is saved to a new CSV file with assigned topics.

## Libraries Used
- `tm`: For text mining and preprocessing
- `topicmodels`: For Latent Dirichlet Allocation (LDA) topic modeling
- `ggplot2`: For data visualization
- `dplyr`, `tidyr`: For data manipulation and tidying
- `slam`: For row sums calculation

## Steps Performed

### 1. Data Loading and Preprocessing
```r
# Clear all previous variables
rm(list=ls()) # removes all variables stored previously

# Load necessary libraries
library(tm)
library(topicmodels)
library(ggplot2)
library(dplyr)
library(tidyr)
library(slam) # Added for row_sums functionality

# Load the dataset
data <- read.csv("customer_feedback_1000.csv", stringsAsFactors = FALSE)

# Inspect the dataset
head(data)

# Data Preprocessing
## Convert necessary columns to factors or appropriate types
data$Sentiment <- factor(data$Sentiment, levels = c("negative", "neutral", "positive"))
data$Product <- as.factor(data$Product)

# Preprocessing text data
## Create a corpus from the 'FeedbackText' column
corpus <- Corpus(VectorSource(data$FeedbackText))

## Convert text to lowercase
corpus <- tm_map(corpus, content_transformer(tolower))

## Remove punctuation, numbers, and whitespace
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)

## Remove stopwords (common words that don’t add much value to topic modeling)
corpus <- tm_map(corpus, removeWords, stopwords("english"))

## Stem the words (optional, but helps reduce words to their root form)
corpus <- tm_map(corpus, stemDocument)

# Create a Document-Term Matrix (DTM)
dtm <- DocumentTermMatrix(corpus)

# Check the structure of the DTM
inspect(dtm)

# Remove sparse terms (terms that appear in too few documents)
dtm <- removeSparseTerms(dtm, 0.99)

# Check the DTM after removing sparse terms
inspect(dtm)

# Set the number of topics for LDA (adjust as needed)
num_topics <- 5

# Check the DTM for rows with no terms
row_sums <- row_sums(dtm)
print(sum(row_sums == 0))  # Number of rows with all zero entries

# Remove rows with no terms
dtm_clean <- dtm[row_sums > 0, ]

# Fit the LDA model
lda_model <- LDA(dtm_clean, k = num_topics, control = list(seed = 1234))

# Summarize the LDA model
summary(lda_model)

# Get the top 10 terms for each topic
topics <- terms(lda_model, 10)

# Print the top terms for each topic
print(topics)

# Assign the most likely topic to each document (feedback text) for the cleaned DTM
topic_assignments <- posterior(lda_model)$topics

# Ensure that topic assignments match the number of rows in the original data
# We should only assign topics to rows that correspond to non-empty documents in dtm_clean
topic_assignments_full <- rep(NA, nrow(data))  # Create an NA vector for all rows
topic_assignments_full[row_sums > 0] <- apply(topic_assignments, 1, which.max)

# Assign the topics to the data
data$Topic <- topic_assignments_full

# Check the first few rows with assigned topics
head(data)
```

### 2. Data Visualization

#### Sentiment Distribution Plot (Bar chart)
```r
# Sentiment distribution plot (Bar chart)
sentiment_distribution <- ggplot(data, aes(x = Sentiment)) +
  geom_bar(fill = "lightblue", color = "black") +
  labs(title = "Sentiment Distribution", x = "Sentiment", y = "Count") +
  theme_minimal()

# Show the sentiment distribution plot
print(sentiment_distribution)
```

#### Sentiment Distribution Pie Chart
```r
# Sentiment distribution pie chart
sentiment_pie <- ggplot(data, aes(x = "", fill = Sentiment)) +
  geom_bar(stat = "count", width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Sentiment Distribution (Pie Chart)") +
  theme_minimal() +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

# Show sentiment pie chart
print(sentiment_pie)
```

#### Rating Distribution Plot (Bar chart)
```r
# Rating distribution plot (Bar chart)
rating_distribution <- ggplot(data, aes(x = Rating)) +
  geom_bar(fill = "green", color = "black") +
  labs(title = "Rating Distribution", x = "Rating", y = "Count") +
  theme_minimal()

# Show the rating distribution plot
print(rating_distribution)
```

#### Rating Distribution Histogram
```r
# Rating distribution histogram
rating_histogram <- ggplot(data, aes(x = Rating)) +
  geom_histogram(binwidth = 1, fill = "lightgreen", color = "black") +
  labs(title = "Rating Distribution (Histogram)", x = "Rating", y = "Count") +
  theme_minimal()

# Show rating histogram
print(rating_histogram)
```

#### Feedback Length Histogram
```r
# Feedback length histogram
data$FeedbackLength <- nchar(data$FeedbackText)
feedback_length_histogram <- ggplot(data, aes(x = FeedbackLength)) +
  geom_histogram(binwidth = 10, fill = "lightblue", color = "black") +
  labs(title = "Feedback Length Distribution (Histogram)", x = "Length of Feedback", y = "Count") +
  theme_minimal()

# Show feedback length histogram
print(feedback_length_histogram)
```

#### Box Plot for Rating by Product
```r
# Box plot for Rating by Product
rating_boxplot <- ggplot(data, aes(x = Product, y = Rating)) +
  geom_boxplot(fill = "lightyellow", color = "black") +
  labs(title = "Rating Distribution by Product (Box Plot)", x = "Product", y = "Rating") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal()

# Show box plot for rating by product
print(rating_boxplot)
```

#### Analysis of Sentiment by Product
```r
# Analysis of sentiment by product
sentiment_by_product <- data %>%
  group_by(Product, Sentiment) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = Product, y = count, fill = Sentiment)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Sentiment Distribution by Product", x = "Product", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal()

# Show sentiment by product plot
print(sentiment_by_product)
```

#### Topic Distribution by Sentiment
```r
# Topic distribution by sentiment
topic_by_sentiment <- data %>%
  group_by(Sentiment, Topic) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = Topic, y = count, fill = Sentiment)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Topic Distribution by Sentiment", x = "Topic", y = "Count") +
  theme_minimal()

# Show topic distribution by sentiment plot
print(topic_by_sentiment)
```

### 3. Saving Results
```r
# Save the results with assigned topics to a new CSV file
write.csv(data, "customer_feedback_with_topics.csv", row.names = FALSE)

# Save sentiment distribution plot as a PNG
ggsave("sentiment_distribution.png", sentiment_distribution)

# Save sentiment pie chart as a PNG
ggsave("sentiment_pie_chart.png", sentiment_pie)

# Save rating distribution plot as a PNG
ggsave("rating_distribution.png", rating_distribution)

# Save rating histogram as a PNG
ggsave("rating_histogram.png", rating_histogram)

# Save feedback length histogram as a PNG
ggsave("feedback_length_histogram.png", feedback_length_histogram)

# Save box plot for rating by product as a PNG
ggsave("rating_boxplot.png", rating_boxplot)

# Save sentiment by product plot as a PNG
ggsave("sentiment_by_product.png", sentiment_by_product)

# Save topic by sentiment plot as a PNG
ggsave("topic_by_sentiment.png", topic_by_sentiment)
```

## Final Output

- The dataset is saved as `customer_feedback_with_topics.csv` with assigned topics.
- Various visualizations are saved as PNG files, including:
  - `sentiment_distribution.png`
  - `sentiment_pie_chart.png`
  - `rating_distribution.png`
  - `rating_histogram.png`
  - `feedback_length_histogram.png`
  - `rating_boxplot.png`
  - `sentiment_by_product.png`
  - `topic_by_sentiment.png`
