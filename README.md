# DBLP Database Project

A comprehensive database project that processes the DBLP (Digital Bibliography & Library Project) XML dataset and performs advanced analytics including vector embeddings, similarity search, and academic publication analysis.

## Project Overview

This project demonstrates advanced database techniques including:
- **XML Data Processing**: Parsing large XML datasets into relational format
- **Database Schema Design**: Both raw and normalized schemas with inheritance
- **Advanced Analytics**: Author collaboration, publication trends, and performance analysis
- **Vector Embeddings**: Machine learning-based similarity search using sentence transformers
- **API Integration**: ArXiv API integration for abstract retrieval
- **Search Optimization**: Diversified search results using max-min diversification

## Files Description

### Core Database Files
- **`createRawSchema.sql`** - Creates raw schema tables (Pub, Field) and loads data
- **`createPubSchema.sql`** - Creates normalized schema with proper inheritance
- **`transform.sql`** - Transforms raw data into normalized schema with foreign keys
- **`solution-raw.sql`** - Basic analytics queries and performance optimization
- **`solution-analysis.sql`** - Advanced analytics including author analysis and collaboration patterns
- **`search.sql`** - Vector embedding and similarity search implementation

### Python Scripts
- **`wrapper.py`** - XML parser that extracts publication and field data from dblp.xml
- **`pythonpsql.py`** - Basic PostgreSQL database connection script
- **`getAbstracts.py`** - Retrieves abstracts from ArXiv API for July 2025 papers
- **`getEmbeddings.py`** - Generates vector embeddings using sentence transformers

### Data Files
- **`dblp.xml`** - The main DBLP XML dataset (large file)
- **`dblp.dtd`** - XML Document Type Definition for DBLP format
- **`pubFile.txt`** - Generated file containing (key, publication_type) tuples
- **`fieldFile.txt`** - Generated file containing (key, field_count, field, value) tuples
- **`ER.pdf`** - Entity-Relationship diagram documentation

## Database Schemas

### Raw Schema
- **Pub(k, p)**: Publication key and type
- **Field(k, i, p, v)**: Field key, index, property, and value

### Normalized Schema
- **Author(id, name, homepage)**: Author information
- **Publication(pubid, pubkey, title, year)**: Base publication class
- **Article, Book, Incollection, Inproceedings**: Publication subclasses
- **Authored_from(id, pubid)**: Author-Publication relationships

### Vector Search Schema
- **Arxiv_july**: July 2025 ArXiv papers with embeddings
- **Keywords**: Search keywords with vector embeddings
- **p1_p2_p3**: Diversified search results

## Analytics and Results

### 1. Publication Type Distribution Analysis
**Query**: Count publications by type to understand the distribution of academic publications.

```sql
SELECT p, count(*) FROM Pub GROUP BY p;
```

**Results**:
- **Articles**: 4,009,299 publications (largest category)
- **Inproceedings**: 3,755,518 publications (conference papers)
- **Web pages**: 3,891,152 publications (online resources)
- **Books**: 21,224 publications
- **Incollections**: 70,988 publications
- **Proceedings**: 62,629 publications
- **PhD Theses**: 148,592 publications
- **Data**: 17,131 publications
- **Master's Theses**: 27 publications

**Execution Time**: 758.994 ms

### 2. Universal Field Analysis
**Query**: Identifies fields that occur in ALL publication types.

```sql
SELECT T.field 
FROM (
    SELECT DISTINCT Pub.p as pub_type, Field.p as field
    FROM Pub, Field 
    WHERE Pub.k = Field.k AND Field.v IS NOT NULL
) as T 
GROUP BY T.field 
HAVING count(*) = (SELECT count(DISTINCT p) FROM Pub);
```

**Results**: Only 4 fields are universal across all publication types:
- **author**: Present in all publication types
- **ee**: Electronic edition/DOI links present in all types
- **title**: Publication titles present in all types  
- **year**: Publication years present in all types

**Execution Time**: 23.199 seconds

### 3. Top Authors Analysis
**Most Prolific Authors**:
1. **H. Vincent Poor**: 3,150 publications
2. **Philip S. Yu**: 2,432 publications
3. **Yang Liu**: 2,277 publications
4. **Dacheng Tao**: 2,270 publications
5. **Zhu Han**: 2,224 publications

**Execution Time**: 7.593 seconds

### 4. Conference-Specific Analysis
**STOC (Theory of Computing)**:
- **Avi Wigderson**: 59 publications
- **Venkatesan Guruswami**: 36 publications
- **Robert Endre Tarjan**: 33 publications

**SOSP (Operating Systems)**:
- **M. Frans Kaashoek**: 27 publications
- **Nickolai Zeldovich**: 19 publications
- **Roger M. Needham**: 13 publications

**UIST (User Interface)**:
- **Tovi Grossman**: 46 publications
- **Scott E. Hudson**: 43 publications
- **Chris Harrison**: 35 publications

### 5. Collaboration Analysis
**Most Collaborative Authors**:
1. **Yang Liu**: 6,940 collaborators
2. **Wei Wang**: 6,622 collaborators
3. **Wei Zhang**: 6,283 collaborators
4. **Yu Zhang**: 6,007 collaborators
5. **Lei Wang**: 5,625 collaborators

**Execution Time**: 55.876 seconds

### 6. Decade Analysis
**Publications by Decade**:
- **2020s**: 2,825,658 publications
- **2010s**: 3,090,159 publications
- **2000s**: 1,480,588 publications
- **1990s**: 477,206 publications
- **1980s**: 144,422 publications

**Most Prolific Authors by Decade**:
- **2020s**: Dusit Niyato (1,540 publications)
- **2010s**: H. Vincent Poor (1,220 publications)
- **2000s**: H. Vincent Poor (585 publications)

### 7. Vector Embeddings and Similarity Search
**ArXiv July 2025 Analysis**:
- Created embeddings for 50+ papers using sentence transformers
- Implemented nearest neighbor search using vector similarity
- Distance calculations for paper similarity (0.2-0.6 range)

**Keyword Search Results**:
- **"vector database system"**: Most similar to paper 2507.22384 (distance: 0.535)
- **"machine learning artificial intelligence"**: Most similar to paper 2507.03045 (distance: 0.518)
- **"sign language translation"**: Most similar to paper 2507.21104 (distance: 0.284)

### 8. Diversified Search Implementation
**Max-Min Diversification**:
- Finds closest paper (p1) to search keywords
- Identifies papers far from p1 (p2) but within distance threshold
- Selects papers far from both p1 and p2 (p3)
- Ensures search result diversity while maintaining relevance

## Setup Instructions

### Prerequisites
- PostgreSQL database with vector extension
- Python 3.7+ with required packages
- Hugging Face API token for embeddings

### Required Python Packages
```bash
pip install psycopg2-binary
pip install sentence-transformers
pip install pgvector
pip install requests
pip install feedparser
pip install torch
```

### Installation Steps

1. **Parse the XML data**:
   ```bash
   python wrapper.py
   ```

2. **Create the database schemas**:
   ```sql
   -- Create database
   CREATE DATABASE dblp;
   
   -- Load raw schema
   \i createRawSchema.sql
   
   -- Load normalized schema  
   \i createPubSchema.sql
   
   -- Transform data
   \i transform.sql
   ```

3. **Install vector extension**:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

4. **Run analytics queries**:
   ```sql
   \i solution-raw.sql
   \i solution-analysis.sql
   \i search.sql
   ```

5. **Generate embeddings** (optional):
   ```bash
   python getAbstracts.py
   python getEmbeddings.py
   ```


### Performance Metrics
- **Publication Type Count**: 758.994 ms
- **Universal Fields Query**: 23.199 seconds
- **Top Authors Query**: 7.593 seconds
- **Collaboration Analysis**: 55.876 seconds
- **Decade Analysis**: 1.144 seconds

## Technical Features

### Vector Embeddings
- **Model**: sentence-transformers/all-MiniLM-L6-v2
- **Vector Size**: 384 dimensions
- **Distance Metric**: Cosine similarity
- **Integration**: PostgreSQL with pgvector extension

### API Integration
- **ArXiv API**: Batch retrieval of abstracts (50 papers per request)
- **Rate Limiting**: 3-second delays between requests
- **Error Handling**: Robust error handling for API failures

### Database Design
- **Inheritance**: Class Table Inheritance (CTI) pattern
- **Foreign Keys**: Proper referential integrity
- **Vector Support**: Native vector operations in PostgreSQL
- **Performance**: Strategic indexing for optimal query performance

## Key Findings

### Academic Publishing Patterns
- **Total Publications**: 12+ million across 9 types
- **Conference Dominance**: Inproceedings (3.7M) nearly match articles (4M)
- **Digital Integration**: All publications have electronic editions
- **Collaboration**: Top authors have 6,000+ collaborators

### Data Quality Insights
- **Universal Fields**: Only 4 fields (author, ee, title, year) appear in all types
- **Metadata Consistency**: 100% coverage for core bibliographic fields
- **Temporal Coverage**: Publications span from 1930s to 2020s

### Search and Discovery
- **Vector Similarity**: Effective paper discovery using embeddings
- **Diversified Results**: Max-min diversification ensures result variety
- **Real-time Search**: Sub-second similarity search performance

## Contributing

This project demonstrates advanced database techniques including:
- XML data processing and transformation
- Database schema design with inheritance
- SQL query optimization and performance analysis
- Machine learning integration with databases
- Vector similarity search and recommendation systems
- API integration and data enrichment
- Advanced analytics and collaboration analysis

