--Filling in Author Table
--Approach: insert Author first, then insert homepages of authors that have a homepage.

create sequence q;

insert into Author(id, name)
select nextval('q') as id, T.author_name as name
from (select distinct on (v) v as author_name from Field where Field.p = 'author') as T;

drop sequence q;

--adding hompages for authors that do have a homepage. if they don't it will be left null.
update Author
set homepage = T.homepage
from (
    select distinct on (a.v) a.v as name, c.v as homepage from Pub x, Field a, Field b, Field c
    where x.k=a.k and a.k=b.k and b.k = c.k
    and x.p='www' and a.p='author' and b.p = 'title' and b.v = 'Home Page' and c.p = 'url'
) as T
where Author.name = T.name;

--Filling in Publications Table
--Approach: using left join since there are publications with no title or no year.
create sequence q;

insert into Publication(pubid, pubkey, title, year)
select distinct on (x.k) nextval('q') as pubid, x.k, a.v, cast(b.v as int)
from Pub x
left join Field a on x.k = a.k and a.p = 'title'
left join Field b on x.k = b.k and b.p = 'year';

drop sequence q;

create index idx_publication_pubid on Publication(pubid);
create index idx_publication_pubkey on Publication(pubkey);

--Filling in Subclassses (Tables)
--Filling in Article Table
--Approach: using left join since there are articles with no number, journal, month, or volume.
insert into Article(pubid, number, journal, month, volume)
select x.pubid as pubid, a.v as number, b.v as journal, c.v as month, d.v as volume
from Publication x
join Pub y on x.pubkey = y.k and y.p = 'article'
left join Field a on a.k = x.pubkey and a.p = 'number'
left join Field b on b.k = x.pubkey and b.p = 'journal'
left join Field c on c.k = x.pubkey and c.p = 'month'
left join Field d on d.k = x.pubkey and d.p = 'volume';


--Filling in Book Table
--Approach: using left join since there are books with no publisher or isbn.
insert into Book(pubid, publisher, isbn)
select distinct on (x.pubid) x.pubid as pubid, a.v as publisher, b.v as isbn
from Publication x
join Pub y on x.pubkey = y.k and y.p = 'book'
left join Field a on a.k = x.pubkey and a.p = 'publisher'
left join Field b on b.k = x.pubkey and b.p = 'isbn';

--Filling Incollection Table
--Approach: using left join since there are incollections with no booktitle, publisher, or isbn.
insert into Incollection(pubid, booktitle, publisher, isbn)
select distinct on (x.pubid) x.pubid as pubid, a.v as booktitle, b.v as publisher, c.v as isbn
from Publication x
join Pub y on x.pubkey = y.k and y.p = 'incollection'
left join Field a on a.k = x.pubkey and a.p = 'booktitle'
left join Field b on b.k = x.pubkey and b.p = 'publisher'
left join Field c on c.k = x.pubkey and c.p = 'isbn';

--Filling Inproceedings Table
--Apporach: using left join since there are inproceedings with no booktitle or editor.
insert into Inproceedings(pubid, booktitle, editor)
select distinct on (x.pubid) x.pubid as pubid, a.v as booktitle, b.v as editor
from Publication x
join Pub y on x.pubkey = y.k and y.p = 'inproceedings'
left join Field a on a.k = x.pubkey and a.p = 'booktitle'
left join Field b on b.k = x.pubkey and b.p = 'editor';

--Filling Authored_From Table
--Approach: to connect id with pubid, connecting id with name in field, connecting pubkey with k in field, then outputting (id, pubid)
insert into Authored_From(id, pubid)
select distinct on (x.id, y.pubid) x.id as id, y.pubid as pubid
from Author x, Publication y, Field z
where z.p = 'author' and x.name = z.v and z.k = y.pubkey;


--Altering table at last to add foreign key
alter table Article
add constraint article_pubid_fkey
foreign key (pubid) references Publication(pubid)
on delete cascade;

alter table Book
add constraint book_pubid_fkey
foreign key (pubid) references Publication(pubid)
on delete cascade;

alter table Incollection
add constraint incollection_pubid_fkey
foreign key (pubid) references Publication(pubid)
on delete cascade;

alter table Inproceedings
add constraint inproceedings_pubid_fkey
foreign key (pubid) references Publication(pubid)
on delete cascade;

alter table Authored_from
add constraint authored_from_pubid_fkey
foreign key (pubid) references Publication(pubid)
on delete cascade;

alter table Authored_from
add constraint authored_from_id_fkey
foreign key (id) references Author(id)
on delete cascade;