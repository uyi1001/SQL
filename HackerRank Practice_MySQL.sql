/*
Query a list of CITY names from STATION for cities that have an even ID number.
Print the results in any order, but exclude duplicates from the answer.
*/
select distinct city
from station
where id%2 = 0;


/*
Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths
(i.e.: number of characters in the name).
If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
*/
(select city, length(city)
from station
order by length(city), city
limit 1)
union
(select city, length(city)
from station
order by length(city) desc, city
limit 1);


/*
Write a query identifying the type of each record in the TRIANGLES table using its three side lengths.
Output one of the following statements for each record in the table:

Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.
*/
select
    case
        when A+B<=C or A+C<=B or B+C<=A then 'Not A Triangle'
        when A=B and B=C then 'Equilateral'
        when A=B or A=C or B=C then 'Isosceles'
        when A<>B and B<>C and A<>C then 'Scalene'
    end
from triangles;


/*
Generate the following two result sets:

Query an alphabetically ordered list of all names in OCCUPATIONS,
immediately followed by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses).
For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).
Query the number of ocurrences of each occupation in OCCUPATIONS.
Sort the occurrences in ascending order, and output them in the following format:

There are a total of [occupation_count] [occupation]s.
where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name.
If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.
Note: There will be at least two entries in the table for each type of occupation.
*/
select concat(name, '(', mid(occupation,1,1), ')')
from occupations
order by name;
select concat('There are a total of ',count(occupation), ' ', lower(occupation), 's.')
from occupations
group by occupation
order by count(occupation), occupation;


/******
Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. The output column headers should be Doctor, Professor, Singer, and Actor, respectively.

Note: Print NULL when there are no more names corresponding to an occupation.

Input Format

The OCCUPATIONS table is described as follows:

