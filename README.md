# Netflix Movies & TV Shows Data Analysis (PostgreSQL)

![Netflix logo](netflix_logo.jpg)

## 📌 Overview
This project analyzes Netflix’s Movies and TV Shows catalog using PostgreSQL to extract meaningful business insights from a messy, real-world dataset.
The dataset contains several unnormalized, multi-valued columns (genres, countries, cast, directors) and inconsistent date formats, making it ideal for demonstrating practical SQL analytics skills rather than textbook queries.
The analysis focuses on content mix, growth trends, genre dominance, country contribution, metadata quality, and basic content classification.

## 🎯 Business Questions Addressed
This project answers the following questions using SQL only:
1. What is the total size of Netflix’s content catalog, and how is it split between Movies and TV Shows?
2. How are titles distributed across release years and Netflix addition years?
3. Which genres dominate Netflix’s catalog, and how does genre diversity change over time?
4. Which countries contribute the most content to Netflix’s platform?
5. What ratings, durations, and season patterns are most common?
6. Which actors and directors appear most frequently (with a focus on Indian content)?
7. How complete is Netflix’s metadata (director, cast, country)?
8. Can content be classified using simple keyword-based rules from descriptions?

## 📊 Analysis Breakdown
1. Catalog Overview: Total titles, Movies vs TV Shows split
2. Time Trends: Release year distribution and Netflix addition patterns
3. Genre Analysis: Genre frequency, diversity, and yearly dominance
4. Country Analysis: Top contributing countries and catalog share
5. Ratings & Duration: Rating distribution, movie length buckets, TV show seasons
6. Talent Insights: Actor and director analysis with regional focus
7. Data Quality: Missing metadata detection and percentage calculation
8. Content Classification: Rule-based tagging using description keywords

## 🛠 Tools & Skills
- PostgreSQL
- CTEs & Window Functions (RANK, FILTER)
- String parsing (UNNEST, STRING_TO_ARRAY, SPLIT_PART)
- Date casting and extraction
- Conditional logic (CASE WHEN)

## Skills demonstrated
- Handling unnormalized, multi-valued datasets
- Translating business questions into SQL analysis
- Writing structured, readable, and scalable queries
- Applying analytical thinking beyond basic querying

## Use Cases
- Content portfolio analysis
- Regional content investment insights
- Genre diversification assessment
- Metadata quality evaluation
- Basic content moderation logic

## ✅ Notes
All insights are derived strictly from SQL analysis. No data preprocessing or external tools were used.

## 📂 Dataset
The data for this project is sourced from the Kaggle dataset\
Link: [Netflix Shows Dataset on Kaggle](https://www.kaggle.com/datasets/shivamb/netflix-shows)

> **Disclaimer**  
> This project is for learning and portfolio demonstration purposes only and does not represent internal Netflix business data.
