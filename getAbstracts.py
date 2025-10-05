import psycopg2
import requests
import feedparser
import time

try: #conenct to database
    conn = psycopg2.connect(dbname="dblp", user="chatsign", host="localhost", port = 5432)
except psycopg2.Error as e:
    print("I am unable to connect to the database")


cur = conn.cursor()

cur.execute("select * from Arxiv_july;") #getting all the arxiv papers published in july

rows = cur.fetchall() #fetching and storing the results in rows.

curBatch = [] #array to store 50 records per batch

for row in rows: #for each record in Arxiv_july relation
    if len(curBatch) < 50: #collect 50 papers
        curBatch.append(row)

    else: #do get request of 50 papers
        query = "+OR+".join([f"id:{paper[1]}" for paper in curBatch])
        url = f"https://export.arxiv.org/api/query?search_query={query}&max_results={len(curBatch)}" #getting 50 articles at once using +OR+.
        response = requests.get(url)
        feed = feedparser.parse(response.text) #parsing the xml output

        if response.status_code == 200:
            for entry in feed.entries:
                curId = entry.id
                curId = curId.split('/')
                curId = curId[-1][:-2] #getting the arxiv_id fron entry id string e.g. http://arxiv.org/abs/2507.02901v2, get 2507.02901.
                cur.execute("""
                        UPDATE Arxiv_july
                        SET abstract = %s
                        WHERE arxiv_id = %s;
                    """, (entry.summary, curId)) #update record's abstract where arxiv_id = curId
                conn.commit() #commit the changes to postgres
        else:
            print(f"failed for this batch: {curBatch}")
        time.sleep(3) #arxiv's api limit is no more than one request every second.
        curBatch = [] #empty curBatch