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

# Sentiment distribution plot (Bar chart)
sentiment_distribution <- ggplot(data, aes(x = Sentiment)) +
  geom_bar(fill = "lightblue", color = "black") +
  labs(title = "Sentiment Distribution", x = "Sentiment", y = "Count") +
  theme_minimal()

# Show the sentiment distribution plot
print(sentiment_distribution)

# Sentiment distribution pie chart
sentiment_pie <- ggplot(data, aes(x = "", fill = Sentiment)) +
  geom_bar(stat = "count", width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Sentiment Distribution (Pie Chart)") +
  theme_minimal() +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

# Show sentiment pie chart
print(sentiment_pie)

# Rating distribution plot (Bar chart)
rating_distribution <- ggplot(data, aes(x = Rating)) +
  geom_bar(fill = "green", color = "black") +
  labs(title = "Rating Distribution", x = "Rating", y = "Count") +
  theme_minimal()

# Show the rating distribution plot
print(rating_distribution)

# Rating distribution histogram
rating_histogram <- ggplot(data, aes(x = Rating)) +
  geom_histogram(binwidth = 1, fill = "lightgreen", color = "black") +
  labs(title = "Rating Distribution (Histogram)", x = "Rating", y = "Count") +
  theme_minimal()

# Show rating histogram
print(rating_histogram)

# Feedback length histogram
data$FeedbackLength <- nchar(data$FeedbackText)
feedback_length_histogram <- ggplot(data, aes(x = FeedbackLength)) +
  geom_histogram(binwidth = 10, fill = "lightblue", color = "black") +
  labs(title = "Feedback Length Distribution (Histogram)", x = "Length of Feedback", y = "Count") +
  theme_minimal()

# Show feedback length histogram
print(feedback_length_histogram)

# Box plot for Rating by Product
rating_boxplot <- ggplot(data, aes(x = Product, y = Rating)) +
  geom_boxplot(fill = "lightyellow", color = "black") +
  labs(title = "Rating Distribution by Product (Box Plot)", x = "Product", y = "Rating") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal()

# Show box plot for rating by product
print(rating_boxplot)

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
