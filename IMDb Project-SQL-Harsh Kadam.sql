use imdb;
--  Segment 1: Database Columns, Tables and Relationships.

--  Q1. What are the different tables in the database and how are they connected to each other in the database?

--  ANS :- tables_in_imdb = [director mapping, genre, movie, names, rating, role_mapping]
          -- They are coonected with each other by ERD Diagram for IMDb.

--  Q2. Find the total number of rows in each table of the schema.

select count(*) from director_mapping;
	   -- director mapping = 3867
select count(*) from genre;
	   -- genre = 14662
select count(*) from movie;
	   -- movie = 7997
select count(*) from names;
	   -- names = 25735
select count(*) from ratings;
	   -- ratings = 7997
select count(*) from role_mapping;
       -- role_mapping = 15615
       
--  Q3. Identify which columns in the movie table have null values.

select 
    column_name
from information_schema.columns
where table_name = 'movie'
    and is_nullable = 'yes';

--  ANS :- column_list = country, date_published, duration, languages, production_company
          
----------------------------------------------------------------------------------------------------------------------------------------------------

--  Segment 2: Movie Release Trends.

--  Q1. Determine the total number of movies released each year and analyse the month-wise trend.

select 
    year(date_published) as release_year,
    month(date_published) as release_month,
    count(*) as movie_count
from
    movie
group by
    release_year, release_month
order by
    release_year, release_month;

--  ANS :- In 2017 there were 3052 movies released which was highest in 3 years. Majority of the movies are released in the months of Sept, Oct, Nov in 2018 & 2017.

--  Q2. Calculate the number of movies produced in the USA or India in the year 2019.

select count(id) as movie_count, country, year as year_of_release
from movie
where country = 'india' or country = 'usa'
group by country, year_of_release
having year_of_release = 2019;

-- ANS :- The number of movies produced in the USA and India in the year 2019 are 592 and 295 respectively.
	   -- USA = 592
       -- India = 295
       -- Total Movies = 887
       
----------------------------------------------------------------------------------------------------------------------------------------------------       
       
--  Segment 3: Production Statistics and Genre Analysis.

--  Q1. Retrieve the unique list of genres present in the dataset.

select genre from genre
group by genre;     

-- ANS :- The unique list of genres present in the dataset are as follows:-
	   -- 1.Drama  2.Fantasy  3.Thriller  4.Comedy 5.Horror 6.Family 
       -- 7.Romance 8.Adventure 9.Action 10.Sci-Fi 
       -- 11.Crime 12.Mystery 13.Others
       
--  Q2. Identify the genre with the highest number of movies produced overall.

select genre, count(*) as movie_count
from genre
group by genre
order by movie_count desc;
       
-- ANS :- The genre with the highest number of movies produced overall is Drama.
	   -- Drama Movies = 4285
       
-- Q3. Determine the count of movies that belong to only one genre.

select count(*) as movie_count
from (
    select movie_id
    from genre
    group by movie_id
    having count(*) = 1
) as single_genre_movies;

--  ANS :- The count of movies that belong to only one genre is 3289.

--  Q4. Calculate the average duration of movies in each genre.

select genre, avg(duration) as average_duration
from movie
join genre on movie.id = genre.movie_id
group by genre;

/* Ans:-  Genre	 	  Average_duration

		  Drama	 	    106.7746
		  Fantasy	 	105.1404
		  Thriller 	    101.5761
		  Comedy	 	102.6227
		  Horror	 	92.7243
		  Family	 	100.9669
		  Romance	 	109.5342
		  Adventure 	101.8714
		  Action	  	112.8829
		  Sci-Fi		97.9413
		  Crime		    107.0517
		  Mystery		101.8
		  Others		100.16
*/

--  Q5. Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.

select genre, movie_count, genre_rank
from (
    select genre, count(*) as movie_count,
           rank() over (order by count(*) desc) as genre_rank
    from genre
    group by genre
) as genre_counts
where genre = 'thriller';


-- ANS :- 'Thriller' Genre Rank = 3
	   -- 'Thriller' Genre movie_count = 1484

----------------------------------------------------------------------------------------------------------------------------------------------------

--  Segment 4: Ratings Analysis and Crew Members.

-- Q1. Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).

select min(avg_rating), max(avg_rating), min(total_votes), max(total_votes), min(median_rating), max(median_rating)
from ratings;

--  ANS :- Avg_rating   :  Min = 1.0 || Max = 10.0
		-- total_votes  :  Min = 100 || Max = 725138
        -- median_rating:  Min = 1   || Max = 10

-- Q2. Identify the top 10 movies based on average rating.

select movie.title, ratings.avg_rating
from movie inner join ratings
on movie.id = ratings.movie_id
group by movie.title, ratings.avg_rating
order by ratings.avg_rating desc
limit 10;

/* ANS :- The top 10 movies based on average rating are as follows:-
	    
             Movies Title                      Avg_Rating
        1.Love in Kilnerry                       10
        2.Kirket                                 10 
        3.Gini Helida Kathe                      9.8
        4.Runam                                  9.7
        5.Fan                                    9.6
        6.Android Kunjappan Version 5.25         9.6
        7.Safe                                   9.5
        8.The Brighton Miracle                   9.5
        9.Yeh Suhaagraat Impossible              9.5
        10.Zana                                  9.4
*/

-- Q3. Summarise the ratings table based on movie counts by median ratings.

select count(movie_id) as movie_count, median_rating
from ratings 
group by median_rating
order by median_rating desc;

/* ANS :-  The ratings table based on movie counts by median ratings is as follows:-

		     movie_count        median_rating
               346                   10
			   429                   9
               1030                  8
               2257                  7
               1975                  6
               985                   5
               479                   4
               283                   3
               119                   2
               94                    1
               
*/            
   
-- Q4. Identify the production house that has produced the most number of hit movies (average rating > 8).

select count(movie.id) as hit_movie_count, movie.production_company, avg(ratings.avg_rating) as average_rating
from movie
inner join ratings on movie.id = ratings.movie_id
where ratings.avg_rating > 8 and movie.production_company is not null
group by movie.production_company
order by hit_movie_count desc
limit 1;

-- ANS :- The production house that has produced the most number of hit movies is Dream Warrior Pictures with 3 hit movies with an avg-rating of 8.633.

-- Q5. Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

select genre.genre, count(movie.id) as movie_count
from movie
join genre on movie.id = genre.movie_id
join ratings on movie.id = ratings.movie_id
where movie.country = 'usa'
  and year(movie.date_published) = 2017
  and month(movie.date_published) = 3
  and ratings.total_votes > 1000
group by genre.genre
order by movie_count desc;

/* Ans:-  The number of movies released in each genre during March 2017 in the USA with more than 1,000 votes are as follows:-

		   Genre		movie_count
           Drama		    16
           Comedy		    8
           Crime		    5
           Horror		    5
           Action		    4
           Sci-Fi		    4 
           Thriller	        4
		   Romance		    3
           Fantasy		    2
           Mystery		    2
           Family		    1
*/

-- Q6. Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

select count(genre.movie_id), genre.genre
from genre inner join (
    select movie.id, movie.title, ratings.avg_rating
    from movie inner join ratings
    on movie.id = ratings.movie_id
    where ratings.avg_rating > 8 and movie.title like 'the%'
    group by movie.id
)as sub
on genre.movie_id = sub.id
group by genre.genre;

/* ANS :- The movies of each genre starting with the word 'The' and having an average rating > 8 are as follows:-

            Genre            movie_count
			Drama                 7
			Horror                1
            Mystery               1
			Crime                 3
			Action                1
			Thriller              1
			Romance               1
*/		

----------------------------------------------------------------------------------------------------------------------------------------------------	

--  Segment 5: Crew Analysis.

-- Q1. Identify the columns in the names table that have null values.

select column_name
from information_schema.columns
where table_name = 'names' 
and is_nullable = 'yes';

-- ANS :- height, date_of_birth, known_for_movies and name have null values.

-- Q2. Determine the top three directors in the top three genres with movies having an average rating > 8

select genre as top_genre, avg(avg_rating) as highest_rated, name as director_name
from movie 
    inner join ratings
    on movie.id = ratings.movie_id
    
    inner join genre
    on genre.movie_id = movie.id

    inner join director_mapping
    on movie.id = director_mapping.movie_id

    inner join names
    on names.id = director_mapping.name_id

where ratings.avg_rating > 8
group by genre,genre, director_name
order by highest_rated desc
limit 3;


/* ANS -- The top three directors in the top three genres with movies having an average rating > 8 are as follows:- 

		  Top_genre    highest_rated     Director_name
		  Romance           9.7          Srinivas Gundareddy
		  Drama             9.6          Balavalli Darshith Bhat
		  Action            9.5          Pradeep Kalipurayath
      
*/
      
-- Q3. Find the top two actors whose movies have a median rating >= 8.

 select avg(ratings.median_rating) as rating, names.name
 from movie
    inner join ratings
    on movie.id = ratings.movie_id

    inner join role_mapping
    on movie.id = role_mapping.movie_id

    inner join names
    on names.id = role_mapping.name_id

where ratings.median_rating >= 8 and role_mapping.category = 'actor'
group by names.name
order by rating desc, names.name
limit 2;


/* ANS -- The top two actors whose movies have a median rating >= 8 are as follows:-

			Actor             Rating
	        Aamir Qureshi      10
			Aarav Mavi         10
       
*/
       
-- Q4. Identify the top three production houses based on the number of votes received by their movies.

select movie.production_company, sum(ratings.total_votes)
from movie
    inner join ratings
    on movie.id = ratings.movie_id

group by movie.production_company
order by sum(ratings.total_votes) desc
limit 3;

/*  ANS :- The top three production houses based on the number of votes received by their movies are as follows:-

		   Production_company          sum(ratings.total_votes)
           Marvel Studios                    2656967
           Twentieth Century Fox             2411163
		   Warner Bros                       2396057
           
*/
       
-- Q5. Rank actors based on their average ratings in Indian movies released in India.

select names.name, avg(ratings.avg_rating) as rating
from movie
    inner join ratings
    on movie.id = ratings.movie_id

    inner join role_mapping
    on movie.id = role_mapping.movie_id

    inner join names
    on role_mapping.name_id = names.id

where movie.country = "India" and role_mapping.category = 'actor'
group by names.name
order by avg(ratings.avg_rating) desc;
       
-- ANS :- The actors who tops the rank on their average ratings in Indian movies released in India are 
	   --  Gopi Krishna, Shilpa Mahendar and Priyanka Augustin with equal rating of 9.7
       
-- 6. Identify the top five actresses in Hindi movies released in India based on their average ratings.

select names.name as actress_name, avg(ratings.avg_rating) as actress_rating
from movie
    inner join ratings
    on movie.id = ratings.movie_id
    
    inner join role_mapping
    on movie.id = role_mapping.movie_id

    inner join names
    on names.id = role_mapping.name_id

where movie.languages like "%Hindi%" and movie.country = 'India' and role_mapping.category = 'actress'
group by names.name
order by actress_rating desc
limit 5;       

/* ANS -- The top five actresses in Hindi movies released in India based on their average ratings are as follows:-

          Actress_name            Actress_rating
          Pranati Rai Prakash           9.4
          Leera Kaljai                  9.2
          Puneet Sikka                  8.7
          Bhairavi Athavale             8.4
          Radhika Apte                  8.4
       
*/

----------------------------------------------------------------------------------------------------------------------------------------------------
       
--  Segment 6: Broader Understanding of Data.

-- Q1. Classify thriller movies based on average ratings into different categories.

select distinct movie.title, 
case
    when avg(ratings.avg_rating) < 3 then "Low Rated"
    when avg(ratings.avg_rating) >= 3 and avg(ratings.avg_rating) < 7 then "Mid Rated"
    when avg(ratings.avg_rating) >= 7 then "High Rated"
    else ""
end as category_rating
from movie
    inner join genre
    on movie.id = genre.movie_id

    inner join ratings
    on movie.id = ratings.movie_id

where genre.genre like "%Thriller%"
group by movie.title
order by avg(ratings.avg_rating) desc;

-- Q2. analyse the genre-wise running total and moving average of the average movie duration.

select
    genre.genre as movie_genre,
    movie.duration as movie_duration,
    sum(movie.duration) over (partition by genre.genre order by movie.year) as running_total,
    avg(movie.duration) over (partition by genre.genre order by movie.year rows between unbounded preceding and current row) as moving_average
from
    movie
    inner join genre on movie.id = genre.movie_id
group by
    genre.genre, movie.duration, movie.year
order by
    genre.genre, movie.year;

-- Q3. Identify the five highest-grossing movies of each year that belong to the top three genres.

with top_three_genres as (
    select genre, count(*) as movie_count
    from genre
    group by genre
    order by movie_count desc
    limit 3
),
highest_grossing_movies as (
    select m.year, m.title, m.worlwide_gross_income, g.genre,
           row_number() over (partition by m.year, g.genre order by m.worlwide_gross_income desc) as `rank`
    from movie m
    inner join genre g on m.id = g.movie_id
    inner join top_three_genres t on g.genre = t.genre
)
select year, genre, title, worlwide_gross_income
from highest_grossing_movies
where `rank` <= 5
order by year, genre, `rank`;

-- Q4. Determine the top two production houses that have produced the highest number of hits among multilingual movies. 

with hit_movies as (
    select m.production_company, count(*) as hit_count
    from movie m
    inner join ratings r on m.id = r.movie_id
    where r.avg_rating >= 7.0
    and m.production_company is not null
    group by m.production_company
),
top_production_houses as (
    select production_company, hit_count
    from hit_movies
    order by hit_count desc
    limit 2
)
select production_company, hit_count
from top_production_houses;

/* ANS :- The top two production houses that have produced the highest number of hits among multilingual movies are as follows:-

          Production_company         hit_count
		         A24                     7
		     Warner Bros                 6

*/

-- Q5. Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

select names.name as actress_name, count(*) as movie_count, avg(ratings.avg_rating) as avg_movies_rating
from movie
    inner join ratings
    on movie.id =  ratings.movie_id

    inner join genre
    on genre.movie_id = movie.id

    inner join role_mapping
    on role_mapping.movie_id = movie.id

    inner join names
    on role_mapping.name_id = names.id

    where genre.genre like "%Drama%" and ratings.avg_rating > 8 and role_mapping.category = 'actress'

group by names.name
order by count(*) desc
limit 3;

/* ANS :-  The top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre are as follows:-
         
		   Actress_name          movie_name    avg_movies_rating
		   Amanda Lawrence            2                8.95
	       Susan Brown                2                8.95
           Parvathy Thiruvothu        2                8.2
       
*/
       
-- Q6. Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

select nm.name, count(*) as movie_count, avg(m.duration) as average_duration, sum(r.total_votes) as total_votes
from director_mapping dm
inner join names nm on dm.name_id = nm.id
inner join movie m on dm.movie_id = m.id
inner join ratings r on dm.movie_id = r.movie_id
group by dm.name_id, nm.name
order by movie_count desc
limit 9;

/* Ans:- The top nine directors based on the number of movies, including average inter-movie duration, ratings, and more are as follows:-
 
                   Name				movie_count	  average_duration    total_votes
                  A.L. Vijay			5			122.6				1754
                  Andrew Jones		    5			86.4				1989
                  Chris Stokes		    4			88					3664
                  Justin Price		    4			86.5				5343
                  Jesse V. Johnson	    4			95.75				14778
                  Steven Soderbergh	    4			100.25				171684
                  Sion Sono			    4			125.5				2972
                  Özgür Bakar			4			93.5				1092
				  Sam Liu				4			78					28557
*/

----------------------------------------------------------------------------------------------------------------------------------------------------
       
--  Segment 7: Recommendations.

--	Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.

/* ANS :- Based on the Analysis of the IMBd Movies, the recommendations for the types of content Bolly movies should focus on producing is :-

          1. The 'Triller' genre as caught the highest attention and intrest amongst the audience as the amount of 'Triller' movies watched is good,
	         so the bolly movies production houses should keep thier intrest towards producing more 'Thriller' genre movies. 
       
          2. The 'Drama' genre as gained the overall average highest imbd rating by the audience, so the bolly movies production houses 
             should focus more on producing quality content movies in the 'Drama' genre as they have being doing .
       
          3. The bolly movies prodiction houses should also focus on producing good quality movies in other genres as well for the 
             growth of the bolly movie industry.
             
*/ 

----------------------------------------------------------------------------------------------------------------------------------------------------

--- Extra Questions

-- Q1. Determine the average duration of movies released by Bolly Movies compared to the industry average.             
       
with hindi_movies_average_duration as (
    select avg(duration) as hindi_average
    from movie
    where languages like '%hindi%'
),
other_languages_average_duration as (
    select avg(duration) as other_languages_average
    from movie
    where languages not like '%hindi%'
)
select hindi_average, other_languages_average
from hindi_movies_average_duration, other_languages_average_duration;

-- ANS :- Hindi_average = 125.9795   Other_languages_average = 103.1308

--  Q2. Query to analyze the correlation between the number of votes and the average rating for movies produced in Hindi

with movie_list as (
    -- avg_rating and total_votes of bollywood movies
    select movie.id, ratings.avg_rating, ratings.total_votes
    from movie
        inner join ratings
        on movie.id = ratings.movie_id
        where movie.country like "%india%" and
            movie.languages like "%hindi%"
        group by movie.id
        order by avg_rating, total_votes   
)
-- now group movies by broader category and compare the no of votes
select sum(movie_list.total_votes) as votes ,
(case when movie_list.avg_rating between 0 and 2.5 then "low rated movie (0 - 2.5)"
      when movie_list.avg_rating between 2.5 and 5 then "average rated movie (2.5 - 5)"
      when movie_list.avg_rating between 5 and 7.5 then "hit movie (5 - 7.5)"
      else "super hit movies (7.5 - 10)" end
      ) as movie_category
    from movie_list
    group by movie_category;
    
/* ANS:- The correlation between the number of votes and the average rating for movies produced in Hindi is as follows:-
      
		      Votes           movie_category
              48611       Low Rated Movie (0 - 2.5)
              133411      Average Rated Movie (2.5 - 5)
              706798      Hit Movie (5 - 7.5)
              604431      Super Hit Movies (7.5 - 10) 
              
*/

-- Q3. Find the production house that has consistently produced movies with high ratings over the past three years.

select m.production_company
from movie m
inner join ratings r on m.id = r.movie_id
where m.date_published >= '2017-01-01' and m.date_published <= '2019-12-31'
and r.avg_rating >= 8.0
and m.production_company is not null
and r.avg_rating is not null
group by m.production_company
having count(*) = 3;

-- ANS :- the production house that has consistently produced movies with high ratings over the past three years are as follows:-
	   -- 1.Dream Warrior Pictures
       -- 2.National Theatre Live
       
-- Q4. Identify the top three directors who have successfully delivered commercially successful movies with high ratings.

with commercially_successful_movies as (
    select m.id, m.production_company, r.avg_rating, m.worlwide_gross_income
    from movie m
    inner join ratings r on m.id = r.movie_id
    where m.worlwide_gross_income is not null
    and r.avg_rating >= 8.0
    and m.production_company is not null
),
director_success_counts as (
    select dm.name_id, count(*) as success_count
    from commercially_successful_movies csm
    inner join director_mapping dm on csm.id = dm.movie_id
    group by dm.name_id
),
directors_commercial_ratings as (
    select dm.name_id, count(*) as total_movies, max(success_count) as max_success_count
    from commercially_successful_movies csm
    inner join director_mapping dm on csm.id = dm.movie_id
    inner join director_success_counts dsc on dm.name_id = dsc.name_id
    group by dm.name_id
    having count(*) >= 1
    and max(success_count) >= 1
    order by max(success_count) desc
    limit 3
)
select n.name as director_name, dcr.total_movies, dcr.max_success_count
from directors_commercial_ratings dcr
inner join names n on dcr.name_id = n.id
order by dcr.max_success_count desc;

/* ANS :- The top three directors who have successfully delivered commercially successful movies with high ratings are as follows:-
           
		   Director_name	  total_movies	  max_success_count
            Joe Russo			  2				     2
           Anthony Russo		  2				     2
           James Mangold		  2				     2

  */                
       
----------------------------------------------------------------------------------------------------------------------------------------------------
       
       







       
       


    


                      
