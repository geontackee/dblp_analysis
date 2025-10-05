--Pub: k = key, p = publication type
--Field: k = key, i = ?, p = value type (title, ee, year, author, title, booktitle, etc.), v = value

--1. For each type of publication, count the total number of publications of that type. Your query should
--return a set of (publication-type, count) pairs. For example (article, 20000), (inproceedings, 30000),
--... (not the real answer) [2 points].

select p, count(*) from Pub group by p;

/*        p       |  count  
---------------+---------
 article       | 4009299
 book          |   21224
 data          |   17131
 incollection  |   70988
 inproceedings | 3755518
 mastersthesis |      27
 phdthesis     |  148592
 proceedings   |   62629
 www           | 3891152
(9 rows)

Time: 758.994 ms */ 

/* We say that a field ‘occurs’ in a publication type, if there exists at least one publication of that type
having that field. For example, ‘publisher occurs in incollection’, but ‘publisher does not occur in
inproceedings’ (because no inproceedings entry has a publisher field). Find the fields that occur in
all publications types. Your query should return a set of field names: for example it may return title,
if title occurs in all publication types (article, inproceedings, etc. notice that title does not have to
occur in every publication instance, only in some instance of every type), but it should not return
publisher (since the latter does not occur in any publication of type inproceedings) */

select T.field 
from (
    select distinct Pub.p as pub_type, Field.p as field --inner query: selecting the distinct fields.
    from Pub, Field 
    where Pub.k = Field.k and Field.v is not null) 
as T 
group by T.field having count(*) = (select count(distinct p) from Pub); --checking whether all the publication type has that field

/*  field  
--------
 author
 ee
 title
 year
(4 rows)

Time: 23199.045 ms (00:23.199) */

/*3. Your two queries above may be slow. Speed them up by creating appropriate indexes, using the
CREATE INDEX statement. You also need indexes on Pub and Field for the next question; create all
indices you need on RawSchema at this point */

create index idx_pub_k on Pub(k);

create index idx_pub_p on Pub(p);

create index idx_field_k on Field(k);

create index idx_field_i on Field(i);

create index idx_field_p on Field(p);

create index idx_field_v on Field(v);
