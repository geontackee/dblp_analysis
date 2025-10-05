--1. Find the top 20 authors with the largest number of publications. Runtime: under 15s 
select y.name, count(*) as pub_count from Authored_from x, Author y
where x.id = y.id
group by y.name
order by pub_count desc limit 20;

/*          name         | pub_count 
----------------------+-----------
 H. Vincent Poor      |      3150
 Philip S. Yu         |      2432
 Yang Liu             |      2277
 Dacheng Tao          |      2270
 Zhu Han 0001         |      2224
 Mohamed-Slim Alouini |      2208
 Wei Wang             |      2172
 Dusit Niyato         |      2136
 Wei Zhang            |      2058
 Yu Zhang             |      1996
 Witold Pedrycz       |      1911
 Lajos Hanzo          |      1905
 Lei Wang             |      1881
 Hai Jin 0001         |      1788
 Luca Benini          |      1780
 Mohsen Guizani       |      1762
 Lei Zhang            |      1759
 Wei Li               |      1751
 Xin Wang             |      1750
 Victor C. M. Leung   |      1747
(20 rows)

Time: 7592.605 ms (00:07.593) */

/* 2. Find the top 20 authors with the largest number of publications in STOC. Repeat this for two more
conferences, of your choice (suggestions: top 20 authors in SOSP, or CHI, UIST, or SIGMOD, VLDB,
or SIGGRAPH; note that you need to do some digging to find out how DBLP spells the name of your
conference). Runtime: under 5s */

--Top 20 authors for STOC conference
select a.name, count(*) as pub_count from Author a, Authored_from b, Inproceedings c
where a.id = b.id and b.pubid = c.pubid and c.booktitle = 'STOC'
group by a.name
order by pub_count desc limit 20;

/*            name            | pub_count 
---------------------------+-----------
 Avi Wigderson             |        59
 Venkatesan Guruswami      |        36
 Robert Endre Tarjan       |        33
 Ran Raz                   |        32
 Santosh S. Vempala        |        30
 Noam Nisan                |        29
 Uriel Feige               |        29
 Moni Naor                 |        29
 Mikkel Thorup             |        28
 Mihalis Yannakakis        |        28
 Rafail Ostrovsky          |        27
 Madhu Sudan 0001          |        26
 Sanjeev Khanna            |        26
 Yin Tat Lee               |        26
 David P. Woodruff         |        25
 Oded Goldreich 0001       |        25
 Moses Charikar            |        25
 Frank Thomson Leighton    |        25
 Rocco A. Servedio         |        24
 Christos H. Papadimitriou |        24
(20 rows)

Time: 1275.120 ms (00:01.275) */


--Top 20 authors for SOSP
select a.name, count(*) as pub_count from Author a, Authored_from b, Inproceedings c
where a.id = b.id and b.pubid = c.pubid and c.booktitle = 'SOSP'
group by a.name
order by pub_count desc limit 20;

/*           name           | pub_count 
--------------------------+-----------
 M. Frans Kaashoek        |        27
 Nickolai Zeldovich       |        19
 Roger M. Needham         |        13
 Henry M. Levy            |        12
 Gregory R. Ganger        |        12
 Haibo Chen 0001          |        10
 Gerald J. Popek          |        10
 Andrea C. Arpaci-Dusseau |        10
 Remzi H. Arpaci-Dusseau  |        10
 David Mazires            |         9
 Matei Zaharia            |         9
 Sanidhya Kashyap         |         9
 Thomas E. Anderson       |         9
 Brian N. Bershad         |         9
 Emmett Witchel           |         9
 Ion Stoica               |         9
 Barbara Liskov           |         9
 Amin Vahdat              |         9
 Eddie Kohler             |         9
 Yuanyuan Zhou 0001       |         9
(20 rows)

Time: 1164.032 ms (00:01.164) */

--Top 20 authors for UIST
select a.name, count(*) as pub_count from Author a, Authored_from b, Inproceedings c
where a.id = b.id and b.pubid = c.pubid and c.booktitle = 'UIST'
group by a.name
order by pub_count desc limit 20;

/*          name          | pub_count 
-----------------------+-----------
 Tovi Grossman         |        46
 Scott E. Hudson       |        43
 Chris Harrison 0001   |        35
 Patrick Baudisch      |        34
 George W. Fitzmaurice |        31
 Maneesh Agrawala      |        31
 Ravin Balakrishnan    |        31
 Christian Holz 0001   |        24
 Daniel Vogel 0001     |        23
 Bjrn Hartmann         |        23
 Brad A. Myers         |        22
 Hrvoje Benko          |        22
 Bing-Yu Chen 0004     |        22
 Pedro Lopes 0001      |        21
 Shahram Izadi         |        21
 Takeo Igarashi        |        21
 Daniel Wigdor         |        20
 Hiroshi Ishii 0001    |        20
 Franois Guimbretire   |        20
 Xing-Dong Yang        |        20 */

/* 3. Two of the major database conferences are ‘PODS’ (theory) and ‘VLDB’ (systems). Find (a) all authors
who published at least 10 VLDB papers but never published a PODS paper, and (b) all authors who
published at least 5 PODS papers but never published a VLDB paper. Runtime: under 10s */
select x.name, count(*) as pub_count from Author x, Authored_from y, Inproceedings z
where not exists (select a.name from Author a, Authored_from b, Inproceedings c
where x.id = a.id and a.id = b.id and b.pubid = c.pubid and (c.booktitle = 'PODS' or c.booktitle = 'SIGMOD Conference')
)
and x.id = y.id and y.pubid = z.pubid and z.booktitle = 'VLDB'
group by x.name
having count(*) >= 10
order by count(*) desc;

/*  name | pub_count 
------+-----------
(0 rows) */


select x.name, count(*) as pub_count from Author x, Authored_from y, Inproceedings z
where not exists (select a.name from Author a, Authored_from b, Inproceedings c
where x.id = a.id and a.id = b.id and b.pubid = c.pubid and c.booktitle = 'VLDB'
)
and x.id = y.id and y.pubid = z.pubid and (z.booktitle = 'PODS' or z.booktitle = 'SIGMOD Conference')
group by x.name
having count(*) >= 5
order by count(*) desc;

/*             name             | pub_count 
-----------------------------+-----------
 Leonid Libkin               |        48
 Guoliang Li 0001            |        42
 Moshe Y. Vardi              |        32
 Stratos Idreos              |        30
 Carsten Binnig              |        29
 Anastasia Ailamaki          |        24
 Magdalena Balazinska        |        24
 Christos H. Papadimitriou   |        22
 Jan Van den Bussche         |        22
 Ashwin Machanavajjhala      |        22
 Nan Tang 0001               |        21
 Sudeepa Roy 0001            |        21
 Andrew Pavlo                |        20
 David P. Woodruff           |        18
 Wim Martens                 |        18
 Paraschos Koutris           |        18
 Andreas Pieris              |        17
 Arun Kumar 0001             |        17
 Barzan Mozafari             |        17
 Jiannan Wang 0001           |        17
 Paris C. Kanellakis         |        16
Cancel request sent
Time: 2554.714 ms (00:02.555) MORE THAN THIS!! */


/* 4. A decade is a sequence of ten consecutive years, e.g. 1982, 1983, ..., 1991. For each decade, compute
the total number of publications in DBLP in that decade. Hint: for this and the next query you may
want to compute a temporary table with all distinct years. Runtime: under 10s */

select (a.year / 10) * 10 as decade, count(*) as pub_count from Publication a
where a.year is not null
group by (a.year / 10) * 10
order by (a.year / 10) * 10;

/*  decade | pub_count 
--------+-----------
   1930 |        57
   1940 |       192
   1950 |      2677
   1960 |     13718
   1970 |     49313
   1980 |    144422
   1990 |    477206
   2000 |   1480588
   2010 |   3090159
   2020 |   2825658
(10 rows)

Time: 1143.956 ms (00:01.144) */

/* 5. Find the top 20 most collaborative authors. That is, for each author determine its number of collab-
orators, then find the top 20. Hint: for this and some question below you may want to compute a
temporary table of coauthors. Runtime: a couple of minutes [2 points]. */
select c.name, count(distinct b.id) from Authored_from a, Authored_from b, Author c
where a.id != b.id and a.pubid = b.pubid and a.id = c.id
group by c.name
order by count(distinct b.id) desc limit 20;

/*
     name     | count 
--------------+-------
 Yang Liu     |  6940
 Wei Wang     |  6622
 Wei Zhang    |  6283
 Yu Zhang     |  6007
 Lei Wang     |  5625
 Wei Li       |  5488
 Wei Liu      |  5382
 Lei Zhang    |  5365
 Yang Li      |  5308
 Xin Wang     |  5266
 Xin Li       |  4997
 Yan Wang     |  4894
 Hao Wang     |  4778
 Jing Wang    |  4773
 Yi Zhang     |  4710
 Jing Zhang   |  4611
 Jing Li      |  4569
 Xiang Li     |  4554
 Radu Timofte |  4509
 Hao Zhang    |  4507
(20 rows)

Time: 55876.474 ms (00:55.876) */

/* 6. For each decade, find the most prolific author in that decade. Hint: you may want to first compute a
temporary table, storing for each decade and each author the number of publications of that author
in that decade. Runtime: a minute or so. */

create table Pubs_by_decade as
select b.id as id, b.name as name, (a.year / 10) * 10 as decade, count(*) as pub_count from Publication a, Author b, Authored_from c
where b.id = c.id and c.pubid = a.pubid and a.year is not null
group by b.id, b.name, (a.year / 10) * 10;

select decade, name, pub_count
from (select p.*, row_number() over (partition by p.decade order by p.pub_count desc, id) as rn
from Pubs_by_decade p) t
where rn = 1
order by decade;

/* SELECT 5551454
Time: 23900.375 ms (00:23.900)
 decade |          name           | pub_count 
--------+-------------------------+-----------
   1930 | Willard Van Orman Quine |         7
   1940 | Willard Van Orman Quine |        10
   1950 | Hao Wang 0001           |        14
   1960 | Henry C. Thacher Jr.    |        41
   1970 | Azriel Rosenfeld        |        83
   1980 | Azriel Rosenfeld        |       174
   1990 | Toshio Fukuda           |       269
   2000 | H. Vincent Poor         |       585
   2010 | H. Vincent Poor         |      1220
   2020 | Dusit Niyato            |      1540
(10 rows)

Time: 3727.731 ms (00:03.728) */

-- 7. For each decade, find the second most prolific author in that decade. Runtime: a minute or so

select decade, name, pub_count
from (select p.*, row_number() over (partition by p.decade order by p.pub_count desc, id) as rn
from Pubs_by_decade p) as t
where rn = 2
order by decade;

/*  decade |          name          | pub_count 
--------+------------------------+-----------
   1930 | J. Barkley Rosser      |         6
   1940 | Frederic Brenton Fitch |         9
   1950 | Alston S. Householder  |        11
   1960 | Bernard A. Galler      |        35
   1970 | Grzegorz Rozenberg     |        82
   1980 | Harold Joseph Highland |       129
   1990 | David J. Evans 0001    |       251
   2000 | Wen Gao 0001           |       567
   2010 | Mohamed-Slim Alouini   |      1217
   2020 | Yang Liu               |      1496
(10 rows)

Time: 3482.546 ms (00:03.483) */

