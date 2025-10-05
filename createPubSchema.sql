create table Author(
    id int primary key,
    name text,
    homepage text
);

create table Publication( --superclass
    pubid int primary key,
    pubkey text unique not null,
    title text,
    year int
);

--subclass: using CTI (class table inheritance)
create table Article(
    pubid int primary key,
    number text,
    journal text,
    month text,
    volume text
);

create table Book(
    pubid int primary key,
    publisher text,
    isbn text
);

create table Incollection(
    pubid int primary key,
    booktitle text,
    publisher text,
    isbn text
);

create table Inproceedings(
    pubid int primary key,
    booktitle text,
    editor text
);

--relationship between Author and Publication
create table Authored_from(
    id int,
    pubid int,
    primary key (id, pubid)
);