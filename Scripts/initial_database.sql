/*
Create a database and layers
Scripts: Creating a database and then creating a subdatabase inside it, since it's not possible to do that in MySQL, 
I create a table, and then I'll use it as a sub-database.
*/


Create database Datawarehouse;
use datawarehouse;
create table bronze(
name varchar(100)
);
create table Sliver(
name varchar(100)
);
create table Golden(
name varchar(100)
);
