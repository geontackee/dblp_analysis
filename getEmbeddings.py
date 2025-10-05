from sentence_transformers import SentenceTransformer #pip install sentence_transformer (easier than huggingface)
from pgvector.psycopg2 import register_vector #pip install pgvector. importing register vector so psycopg2 can handle vector.
import psycopg2
import torch

try: #conenct to database
    conn = psycopg2.connect(dbname="dblp", user="chatsign", host="localhost", port = 5432)
except psycopg2.Error as e:
    print("I am unable to connect to the database")

device = "mps" if torch.backends.mps.is_available() else "cpu" #setting mps since I am using m1 pro chipset 
print(f'current device is {device}') #check what device I have been connected to
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2') #declare all-MiniLM-L6-v2 model
register_vector(conn) #register vector
cur = conn.cursor()

cur.execute("select * from Arxiv_july;") #getting all the arxiv papers published in july

rows = cur.fetchall() #fetching and storing the results in rows.

for row in rows: #for each record in Arxiv_july relation
    pubid = row[0]
    abstract = row[-2]
    embedding = model.encode(abstract)
    cur.execute("""
            UPDATE Arxiv_july
            SET embedding = %s
            WHERE pubid = %s;
        """, (embedding, pubid)) #update record's embedding where pubid = current article's pubid.
    conn.commit() #commit the changes to postgre

print("DONE!!")