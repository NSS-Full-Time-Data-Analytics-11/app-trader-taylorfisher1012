--App trader project
--Deliverables
	--a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.

	--b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority.

	--c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for the upcoming Halloween themed campaign.

	--d. Submit a report based on your findings. The report should include both of your lists of apps along with your analysis of their cost and potential profits. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report.

SELECT a.name, p.name,category,a.rating, p.rating, a.review_count AS app_review_count, p.review_count AS play_review_count ,a.content_rating, p.content_rating, p.install_count 
FROM app_store_apps AS a FULL JOIN play_store_apps AS p USING(name)
WHERE a.name IS NOT NULL AND p.name IS NOT NULL
GROUP BY a.name, p.name,category,a.rating, p.rating, a.review_count, p.review_count ,a.content_rating, p.content_rating, p.install_count 
ORDER BY a.name;

SELECT a.name, p.name,category,a.rating, p.rating, a.review_count AS app_review_count, p.review_count AS play_review_count ,a.content_rating, p.content_rating, p.install_count 
FROM app_store_apps AS a FULL JOIN play_store_apps AS p USING(name)
WHERE a.name IS NOT NULL AND p.name IS NOT NULL
GROUP BY a.name, p.name,category,a.rating, p.rating, a.review_count, p.review_count ,a.content_rating, p.content_rating, p.install_count 
ORDER BY a.name;


SELECT *
FROM app_store_apps
;

SELECT a.price, p.price, a.rating, p.rating,a.content_rating 
FROM app_store_apps AS a INNER JOIN play_store_apps AS p USING(name)
ORDER BY a.rating DESC;

SELECT a.name, ROUND(AVG((a.rating+p.rating)/2),2) AS tot_rating
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING(name)
GROUP BY a.name
ORDER BY tot_rating DESC;


--Free apps from both the play and app store that excel in all categroies of reviews and and ratings 
SELECT a.name,ROUND(AVG((a.rating + p.rating)/2),2) AS total_rating, MAX(a.price) AS price,
MAX(p.review_count) AS play_store_reviews, MAX(a.review_count) AS app_store_reviews,
p.genres,a.primary_genre, MAX(a.price) + 25000 AS price_to_buy_app
FROM app_store_apps AS a 
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE p.review_count >= 
			(SELECT AVG(review_count)
			FROM play_store_apps) 
		AND CAST(a.review_count AS int) >= 
			(SELECT AVG(review_count::numeric)
			FROM app_store_apps)
GROUP BY a.name,p.genres,a.primary_genre
ORDER BY total_rating DESC
LIMIT 10

SELECT name, ROUND((rating*24+1)/12) AS projected_life
FROM play_store_apps;

--FINAL TABLE

WITH data AS (SELECT a.name,ROUND(AVG(a.rating + p.rating)/2,2) AS total_rating,
			 		ROUND((FLOOR(AVG(a.rating + p.rating)/2/.25)*.25),2) AS rounded_total_rating,
					MAX(a.price) AS price,
			 		MAX(p.review_count) AS play_store_reviews, 
			 		MAX(a.review_count) AS app_store_reviews,
			 		p.genres,a.primary_genre,MAX(a.price) + 25000 AS price_to_buy_app,
			 		(((ROUND((FLOOR(AVG(a.rating + p.rating)/2/.25)*.25),2) *24)+12)) AS variable
			 FROM app_store_apps AS a INNER JOIN play_store_apps AS p
			 ON a.name = p.name
			 WHERE p.review_count >= (SELECT AVG(review_count)
									  FROM play_store_apps)  
			  AND CAST(a.review_count AS int) >= (SELECT AVG(review_count::numeric)
												  FROM app_store_apps)
			 GROUP BY a.name,p.genres,a.primary_genre
			 ORDER BY total_rating DESC
			 LIMIT 10)
SELECT name,total_rating,rounded_total_rating,price,play_store_reviews, app_store_reviews,
			 genres,primary_genre, price_to_buy_app,
			 ROUND(variable,2) AS longevity_in_months,
			 ROUND((variable/12),2) AS longevity_in_years,
			 ROUND(((variable+12)*5000),2)::money AS money_made_from_app,
			 ROUND(((variable+12)*1000),2)::money AS app_maintenance,
			 (ROUND(((variable+12)*5000),2)-ROUND(((variable+12)*1000),2))::money AS profit 
FROM data;








