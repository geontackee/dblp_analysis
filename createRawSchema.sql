create table Pub (k text, p text);
create table Field (k text, i text, p text, v text);
copy Pub from './pubFile.txt';
copy Field from './fieldFile.txt';
