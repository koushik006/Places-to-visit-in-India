# 🇮🇳 Indian Tourism SQL Analysis

## Project Overview

This project analyses a dataset of **325 tourist attractions across India** using **PostgreSQL**. The goal is to demonstrate a practical data-analyst workflow: understanding the dataset, designing a SQL table, checking data quality, answering progressively more complex analytical questions, and translating raw tourism data into useful insights.

The analysis moves from basic `SELECT`, filtering and sorting to aggregation, conditional logic, Common Table Expressions (CTEs), benchmarking, window functions and a transparent multi-factor recommendation score.

> **Portfolio note:** The dataset was provided as `Top Indian Places to Visit.csv`. The original external source/provenance was not included with the file, so this repository does not claim an external data source.

---

## Business Context

A travel platform, tourism analyst or trip-planning team could use this dataset to explore questions such as:

- Which destinations are the highest rated?
- Where can travellers find highly rated free attractions?
- Which states and cities have the broadest tourism offering?
- Which attraction categories generate the most public engagement?
- How accessible are destinations from nearby airports?
- Which locations are more popular than their local benchmark?
- What are the top attractions within each geographic zone?
- Which places balance **quality, popularity and affordability**?

---

## Dataset Summary

| Metric | Value |
|---|---:|
| Rows | 325 |
| Columns | 16 |
| Geographic zones | 6 |
| States / territories represented | 33 |
| Cities represented | 214 |
| Attraction types | 78 |
| Significance categories | 25 |
| Minimum Google rating | 1.4 |
| Maximum Google rating | 4.9 |
| Average Google rating | 4.49 |
| Minimum entrance fee | ₹0 |
| Maximum entrance fee | ₹7,500 |
| Average visit duration | 1.81 hours |

### Dataset Fields

| Original field | SQL field | Description |
|---|---|---|
| `Unnamed: 0` | `place_id` | Row identifier in the source CSV |
| `Zone` | `zone` | Geographic zone of India |
| `State` | `state` | State or territory |
| `City` | `city` | City/location |
| `Name` | `place_name` | Tourist attraction name |
| `Type` | `attraction_type` | Attraction category |
| `Establishment Year` | `establishment_year` | Year established; stored as text because the source also contains `Unknown` |
| `time needed to visit in hrs` | `visit_duration_hours` | Estimated visit duration in hours |
| `Google review rating` | `google_review_rating` | Google review rating |
| `Entrance Fee in INR` | `entrance_fee_inr` | Entrance fee in Indian rupees |
| `Airport with 50km Radius` | `airport_within_50km` | Whether an airport is within 50 km |
| `Weekly Off` | `weekly_off` | Weekly closing day where supplied |
| `Significance` | `significance` | Main tourism significance/category |
| `DSLR Allowed` | `dslr_allowed` | Whether DSLR photography is permitted |
| `Number of google review in lakhs` | `google_reviews_lakhs` | Google review volume measured in lakhs |
| `Best Time to visit` | `best_time_to_visit` | Suggested time of day / general visit time |

---

## Data Quality Observations

A data analyst should document source limitations before interpreting results.

- `Weekly Off` is missing for **293 of 325 rows**. This is treated as an unknown/missing value rather than automatically interpreted as “open every day”.
- `Establishment Year` contains non-numeric values such as `Unknown`, so it is intentionally stored as `VARCHAR` instead of forcing invalid values into an integer field.
- `Best Time to visit` contains closely related labels such as `All`, `All ` and `Anytime`. A production workflow would standardise these values before dashboarding or modelling.
- The source field `Unnamed: 0` behaves like an exported row index and is retained as `place_id` for reproducibility.
- Review counts are represented in **lakhs**, not as raw individual-review counts.
- Google ratings and review volumes are treated as snapshot values from the supplied dataset; no collection date was included.

---

## Tools & SQL Concepts

**Database:** PostgreSQL  
**Language:** SQL  
**Portfolio concepts demonstrated:**

- `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`
- Aggregations: `COUNT`, `AVG`, `SUM`, `MIN`, `MAX`
- `GROUP BY` and `HAVING`
- `COUNT(DISTINCT ...)`
- Conditional aggregation with `CASE WHEN`
- Common Table Expressions (`WITH`)
- Benchmarking against group averages
- `JOIN` and `CROSS JOIN`
- Window functions
- `DENSE_RANK()`
- Min-max normalisation
- Derived analytical metrics
- Data-quality validation

---

## Analytical Questions — Easy to Hard

The SQL file contains **10 portfolio questions** in increasing difficulty:

1. **Top-rated attractions** — Which 10 attractions have the highest ratings?
2. **Highly rated free attractions** — Which destinations rated 4.5+ have no entrance fee?
3. **Tourism concentration by state** — Which states contain the most listed attractions?
4. **Significance performance** — How do average rating and entrance fee vary by significance category?
5. **City variety and quality** — Which cities combine multiple attractions, diverse types and high ratings?
6. **Public engagement by attraction type** — Which categories generate the greatest review volume?
7. **Accessibility and photography by zone** — What percentage of each zone is both airport-accessible and DSLR-friendly?
8. **State benchmark analysis** — Which attractions are more popular than the average attraction in their own state?
9. **Top 3 per zone** — Which attractions rank highest within each geographic zone?
10. **Multi-factor recommendation model** — Which attractions best balance quality, popularity and affordability?

---

## Selected Dataset Insights

A few useful observations visible in the supplied data:

- The **Southern zone** has the largest representation, with **98 attractions**, followed by the Northern zone with 89.
- **Uttar Pradesh** has the highest number of listed attractions (**23**) in this dataset.
- The most common attraction category is **Temple (59)**, followed by **Beach (25)** and **Fort (22)**.
- The most common significance categories are **Historical (78)** and **Religious (75)**.
- **227 of 325** attractions are marked as having an airport within a 50 km radius.
- **265 of 325** attractions allow DSLR photography.
- The dataset’s average Google rating is approximately **4.49 / 5**.
- **Golden Temple (Harmandir Sahib)**, **Pangong Tso**, and **Rann Utsav** have the dataset’s maximum Google rating of **4.9**; review volume can be used to distinguish popularity among equally rated places.
- Entrance fees range from **₹0 to ₹7,500**, making affordability an important dimension when ranking destinations.

These results describe only the supplied dataset and should not be interpreted as a complete ranking of all tourism destinations in India.

---

## Recommendation Score Methodology

Question 10 creates a portfolio-style recommendation score to demonstrate how SQL can combine multiple business dimensions.

The score is intentionally transparent:

```text
Recommendation Score =
    50% × Normalised Google Rating
  + 30% × Normalised Review Popularity
  + 20% × Normalised Affordability
```

Each component is min-max normalised between 0 and 1. Affordability is reversed so that lower entrance fees receive a higher value.

This score is **created for the analysis project** and does not exist in the original dataset. The weighting is a modelling assumption, not an objective tourism ranking.

---

## Repository Structure

```text
indian-tourism-sql-analysis/
│
├── README.md
├── indian_tourism_analysis.sql
└── top_indian_places_to_visit.csv
```

---

## How to Run the Project

### 1. Create a PostgreSQL database

```sql
CREATE DATABASE indian_tourism;
```

Connect to the database using pgAdmin, DBeaver, DataGrip, VS Code, or `psql`.

### 2. Run the table-creation section

Open:

```text
indian_tourism_analysis.sql
```

Run the `CREATE TABLE tourist_places` statement.

### 3. Import the CSV

The SQL file contains a PostgreSQL `\copy` template. Update the file path:

```sql
\copy tourist_places (
    place_id,
    zone,
    state,
    city,
    place_name,
    attraction_type,
    establishment_year,
    visit_duration_hours,
    google_review_rating,
    entrance_fee_inr,
    airport_within_50km,
    weekly_off,
    significance,
    dslr_allowed,
    google_reviews_lakhs,
    best_time_to_visit
)
FROM '/your/path/top_indian_places_to_visit.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
```

> In **pgAdmin**, you can alternatively right-click the table → **Import/Export Data** → choose the CSV → enable **Header** → use comma delimiter.

### 4. Validate the import

```sql
SELECT COUNT(*)
FROM tourist_places;
```

Expected row count:

```text
325
```

### 5. Run the 10 analysis questions

Execute each numbered query separately and inspect the output.

---

## Suggested GitHub Presentation

For a stronger portfolio repository:

- Keep the repository name short, for example **`indian-tourism-sql-analysis`**.
- Add the topics `sql`, `postgresql`, `data-analysis`, `portfolio-project`, `tourism-data`.
- Add screenshots of 2–4 query outputs later if you want a more visual README.
- Avoid uploading database passwords, local connection files or environment secrets.
- Keep the original CSV alongside the SQL so the analysis is reproducible.

### Suggested GitHub Description

> SQL portfolio project analysing 325 tourist attractions across India using PostgreSQL, from exploratory queries and aggregations to CTEs, benchmarking, window functions and multi-factor destination ranking.

---

## Skills Demonstrated to Recruiters

This project provides evidence of:

- Translating a raw CSV dataset into a relational SQL table
- Inspecting and documenting data-quality limitations
- Writing business-oriented analytical questions
- Performing descriptive and comparative analysis
- Using SQL aggregation and conditional logic
- Applying CTEs and window functions to ranking problems
- Building a transparent derived metric rather than relying only on raw fields
- Communicating assumptions and findings clearly

---

## Potential Future Improvements

Possible extensions without changing the core SQL project:

- Standardise inconsistent categorical values such as `All`, `All ` and `Anytime`
- Convert valid establishment years into a cleaned numeric column
- Analyse historical attractions by century
- Create a Power BI or Tableau dashboard
- Add geographic coordinates and build map-based analysis
- Compare tourism accessibility across states
- Create traveller personas such as budget, photography, cultural or nature-focused itineraries
- Build a cleaned staging table before loading the final analytical table

---

## Author Notes

This repository is designed as a **data analyst portfolio project**, with emphasis on reproducibility, SQL progression and business interpretation rather than simply displaying isolated queries.

If this project is used on a CV, a concise description could be:

> **Indian Tourism SQL Analysis — PostgreSQL:** Analysed 325 tourist attractions across 33 Indian states/territories using SQL; developed 10 business-focused queries covering aggregation, conditional analysis, CTEs, benchmarking and window functions, and created a transparent multi-factor ranking of destinations by rating, popularity and affordability.

---

## Licence / Data Attribution

No licence or original external data-source attribution was included with the supplied CSV. Before redistributing the dataset publicly, confirm that its original source and licence permit publication. The SQL code and analysis structure can be published independently.
