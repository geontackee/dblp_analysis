/* 1. Using only the data in the dblp database, create a table of arXiv articles from July 2025 with one
additional column for the abstract (empty for now) and an arXiv id column. Hint: ArXiv ids are of this
format 2507.00379 and you can lookup up an ArXiv article as follows https://arxiv.org/abs/2507.00379 */
create table Arxiv_july as
select b.pubid, substring(b.volume from 5 for 10) as arxiv_id from Publication a, Article b
where a.pubid = b.pubid and b.journal = 'CoRR' and volume like '%2507.%';

alter table Arxiv_july
add column abstract text;

--After run getAbstracts.py to get the abstracts for each article

--Create extension for vector datatype
create extension if not exists vector;

--Create embeddings column for question 3. 
alter table Arxiv_july
add column embedding vector(384); --The output of sentence transformer vector is size 384.

--Creating column to store nearest neighbor pubid and the calculated distance
alter table Arxiv_july
add column nn_pubid int;
alter table Arxiv_july
alter column nn_dist type real;

--Calculate the nearest neighbor per row and update the nn_pubid and nn_dist value
update Arxiv_july as a
set (nn_pubid, nn_dist) = ( --calculating nearest neighbor per row.
    select b.pubid, a.embedding <=> b.embedding --distance
    from arxiv_july as b
    where b.pubid != a.pubid
    order by b.embedding <=> a.embedding --order by distance
    limit 1 --get the closest one
);

/* dblp=# select pubid, nn_pubid, nn_dist from arxiv_july limit 10;
  pubid  | nn_pubid |  nn_dist   
---------+----------+------------
 9148739 |  9150526 | 0.37560347
 9152880 |  9146649 | 0.49041647
 9157565 |  9150250 | 0.25508264
 9152769 |  9148158 | 0.56330675
 9149346 |  9152357 | 0.32557467
 9150880 |  9153995 | 0.32023594
 9156814 |  9149066 | 0.41120163
 9151796 |  9147809 | 0.38861606
 9150791 |  9147628 | 0.22716376
 9147011 |  9151961 | 0.39584574 */

/* 5. For any set of keywords (e.g. ’vector database systems’) find the top-5 most similar papers to it
by converting the keywords to an embedding first. No external scripts allowed. Hint, install the
pgsl-http connection to make a call to your transformer using postgres functions */

create extension http;

create sequence q;

create table Keywords(
    id int primary key default nextval('q'),
    words text,
    embedding vector(384), --the embedding vector size of sentence-transformer is 384
    nn_arxiv_id text,
    nn_dist real
);

--insert keywords to the table
insert into Keywords (words)
values ('vector database system'),
('machine learning artificial intelligence'),
('sign language translation');

set hf.token = 'YOUR_HF_TOKEN';

set http.curlopt_timeout_msec = '15000';

update keywords
set embedding = T.embedding
from (
select a.id, a.words, (resp).status, (resp).content::jsonb::text::vector(384) as embedding --converting output json -> text -> vector(384)
from keywords a
cross join lateral
http((
'POST',
'https://router.huggingface.co/hf-inference/models/sentence-transformers/all-MiniLM-L6-v2/pipeline/feature-extraction',
http_headers(
    'Authorization', 'Bearer ' || current_setting('hf.token', true),
    'Accept',        'application/json'
),
'application/json',
jsonb_build_object('inputs', a.words)::text
)::http_request) as resp
) as T
where keywords.id = T.id;

--Calculate the nearest neighbor per row and update the nn_pubid and nn_dist value
update Keywords as a
set (nn_arxiv_id, nn_dist) = ( --calculating nearest neighbor per row.
    select b.arxiv_id, a.embedding <=> b.embedding --distance
    from Arxiv_july as b
    order by b.embedding <=> a.embedding --order by distance
    limit 1 --get the closest one
);

/* dblp=# select words, nn_arxiv_id, nn_dist from keywords;
                  words                   | nn_arxiv_id |  nn_dist   
------------------------------------------+-------------+------------
 vector database system                   | 2507.22384  |  0.5351555
 sign language translation                | 2507.21104  | 0.28413084
 machine learning artificial intelligence | 2507.03045  |  0.5182369 */


/* 6. You want your search results to have some diversity, so for an input set of keywords, find the closest
paper and then two papers that are far away from each other and the closest paper in the embedding
space but all within a distance of < 0.6 to the search keywords. (This query is often called max-min
diversification and finding a collection of things that satisfy a global constraint is called a package
query. This is an area of active research in our lab!)*/

--Approach: filter out papers with a distance of 0.6., then find closest paper p1.
--p2, p3 all within 0.6 distance, while p2 is farthest away from p1. p3 has to be far away from p1, p2, which is
--the same as maximize(min(dist(p1,p3), dist(p2,p3))).

create table keyword_candidates as
select a.id, a.words, b.pubid, b.arxiv_id, b.embedding, a.embedding <=> b.embedding as dist
from Keywords a, Arxiv_july as b
where a.embedding <=> b.embedding < 0.6;

create table p1_p2_p3(
    p_type text,
    words text,
    pubid int,
    arxiv_id text,
    embedding vector(384),
    dist real
);

insert into p1_p2_p3(p_type, words, pubid, arxiv_id, embedding, dist) --selecting p1
select 'p1', T.words, T.pubid, T.arxiv_id, T.embedding, T.dist
from(
    select distinct on (words) words, pubid, arxiv_id, embedding, dist
    from keyword_candidates
    order by words, dist
) as T;

insert into p1_p2_p3(p_type, words, pubid, arxiv_id, embedding, dist) --selecting p2
select 'p2', T.words, T.pubid, T.arxiv_id, T.embedding, T.dist
from(
    select distinct on (a.words) a.words, a.pubid, a.arxiv_id, a.embedding, a.dist
    from keyword_candidates a, p1_p2_p3 b
    where a.words = b.words and a.pubid != b.pubid and b.p_type = 'p1'
    order by a.words, a.embedding <=> b.embedding desc --order by dist desc because we want to select the paper that is the furthest away.
) as T;

insert into p1_p2_p3(p_type, words, pubid, arxiv_id, embedding, dist) --selecting p3
select 'p3', T.words, T.pubid, T.arxiv_id, T.embedding, T.dist
from(
    select distinct on (a.words) a.words, a.pubid, a.arxiv_id, a.embedding, a.dist
    from keyword_candidates a, p1_p2_p3 b, p1_p2_p3 c
    where a.words = b.words and b.words = c.words and a.pubid != b.pubid and b.pubid != c.pubId and a.pubid != c.pubid and b.p_type = 'p1' and c.p_type = 'p2'
    order by a.words, least(b.embedding <=> a.embedding, c.embedding <=> a.embedding) desc --a is p3, b is p1, c is p2. so min(dist(p1,p3), dist(p2,p3))
) as T;

/* select p_type, words, pubid, arxiv_id, dist from p1_p2_p3;
 p_type |                  words                   |  pubid  |  arxiv_id  |    dist    
--------+------------------------------------------+---------+------------+------------
 p1     | machine learning artificial intelligence | 9147970 | 2507.03045 |  0.5182369
 p1     | sign language translation                | 9157309 | 2507.21104 | 0.28413084
 p1     | vector database system                   | 9157965 | 2507.22384 |  0.5351555
 p2     | machine learning artificial intelligence | 9156784 | 2507.20114 | 0.59494436
 p2     | sign language translation                | 9151091 | 2507.09105 |  0.5570403
 p2     | vector database system                   | 9146579 | 2507.00379 | 0.55858475
 p3     | machine learning artificial intelligence | 9147407 | 2507.02005 |  0.5550569
 p3     | sign language translation                | 9148724 | 2507.04465 | 0.58853704
 p3     | vector database system                   | 9154711 | 2507.16089 | 0.55942523 */