--App Trader
--Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store.   

--App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchases. The apps' developers retain all money from users purchasing the app from the relevant app store, and they retain half of the money made from in-app purchases. App Trader will be solely responsible for marketing any apps they purchase the rights to.

--Unfortunately, the data for Apple App Store apps and the data for Android Play Store apps are located in separate tables with no referential integrity.
--Deliverables
	--a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.
	--b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority.
	--c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for the upcoming Halloween themed campaign.
	--d. Submit a report based on your findings. The report should include both of your lists of apps along with your analysis of their cost and potential profits. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report.
--Top ten apps 
WITH app_stats AS (SELECT name, 
					p.rating, 
					s.rating, 
					ROUND(ROUND(((p.rating + s.rating)/2)*4)/4,2) AS avg_rating,
					(p.review_count + s.review_count::INT)/2 AS avg_review_count,
					MAX(p.price) AS app_store_price, 
					MAX(s.price),
					p.genres,
					s.primary_genre AS game_genre,
					(s.price+25000)::money AS app_sale_cost
					FROM play_store_apps AS p INNER JOIN app_store_apps AS s USING(name)
					WHERE s.price = 0 
					GROUP BY name, 
					p.rating,
					s.rating, 
					s.price,
					p.genres,
					s.primary_genre,
					p.review_count,
					s.review_count
					ORDER BY avg_rating DESC)
SELECT  name, 
		game_genre,
		app_store_price,
		avg_rating,
		avg_review_count,
		app_sale_cost, 
		(avg_rating * 2)+1 AS longevity_in_yrs,
		((avg_rating * 2 + 1) *12 *1000)::money AS maintenance_cost, 
		((avg_rating * 2 + 1) *12 *5000)::money AS app_revenue,
		((avg_rating * 2 + 1) *12 *5000)::money - (((avg_rating * 2 + 1) *12 *1000)+2500)::money AS profit
FROM app_stats
WHERE avg_review_Count >= (SELECT AVG(avg_review_count)
									FROM app_stats)
ORDER BY avg_rating DESC;

--Halloween Themed apps 
WITH Halloween_apps AS (SELECT DISTINCT name, 
ROUND((p.rating+ s.rating)/2,1) AS avg_rating,
s.price AS price,
(s.price+25000)::money AS cost_to_buy_app
FROM play_store_apps AS p INNER JOIN app_store_apps AS s USING(name)
WHERE name ILIKE '%zombie%'
ORDER BY avg_rating DESC)


SELECT name,
avg_rating,
price,
(avg_rating * 2)+1 AS longevity_in_yrs,
((avg_rating * 2 + 1) *12 *1000)::money AS maintenance_cost, 
((avg_rating * 2 + 1) *12 *5000)::money AS app_revenue,
((avg_rating * 2 + 1) *12 *5000)::money - (((avg_rating * 2 + 1) *12 *1000)+25000)::money AS profit
FROM Halloween_apps;



