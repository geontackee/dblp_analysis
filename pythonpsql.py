#!/usr/bin/python
import psycopg2

def main():
	try:
	    conn = psycopg2.connect("dbname='dblp' user='<YOUR USER NAME>' host='localhost' password=''")
	except psycopg2.Error, e:
	    print "I am unable to connect to the database"

	cur = conn.cursor()

	cur.execute("SELECT * FROM author LIMIT 10")

	rows = cur.fetchall()

	print "Showing first 10 results:\n"

	for row in rows:
	    print row[0], row[1]

if __name__ == "__main__":
	main()
