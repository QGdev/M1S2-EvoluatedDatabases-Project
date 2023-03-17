--Les émissions de co2 par pays et par année

SELECT p.country_name, f.year, SUM(f.co2) FROM COUNTRIES p, FACTS f WHERE p.id_country = f.id_country GROUP BY CUBE(p.country_name,f.year);

--Le RNB par pays par année

SELECT p.country_name, f.year, sum(gni) from COUNTRIES p, FACTS f WHERE p.id_country = f.id_country GROUP BY ROLLUP(p.country_name,f.year);

--L’IDH par pays par année

SELECT p.country_name, f.year, sum(hdi) from COUNTRIES p, FACTS f WHERE p.id_country = f.id_country GROUP BY CUBE(p.country_name,f.year);

--Cumul du co2 produit par pays et par année

SELECT p.country_name, f.year, f.co2 *f.population_count AS CO2, SUM(f.co2 * f.population_count) OVER (order by f.year ROWS UNBOUNDED PRECEDING) AS CUMUL_CO2 FROM COUNTRIES p, FACTS f, AGE_GROUPS a WHERE f.id_country = p.id_country AND f.id_age_group = a.id_age_group AND a.age_group = 'TOTAL' AND f.population_count IS NOT NULL AND f.co2 IS NOT NULL ORDER BY p.country_name, f.year;

--Ensemble des pays trié par moyenne des RNB par année

SELECT p.country_name AVG(GNI),RANK() OVER (ORDER BY AVG(GNI) desc) as rank FROM COUNTRIES p, FACTS f where p.id_country = g.id_country group by(f.id_country, f.year);

--Ensemble des pays trié par leur idh moyen par année

SELECT p.country_name AVG(hdi),NTILE(4) OVER (ORDER BY AVG(hdi) desc) rank FROM COUNTRIES p, FACTS f where p.id_country = g.id_country group by(f.id_country, f.year);

--Population moyenne par tranche d’âge par pays 

SELECT p.country_name, a.age_group, AVG(f.nbpersonne) as age, DENSE_RANK() OVER (PARTITION BY a.age_group ORDER BY(f.age_group)) FROM FACTS f, COUNTRIES p, age a WHERE p.id_country=f.id_country AND f.id_age_group = a.id_age_group GROUP BY(p.country_name, a.age_group);

--Le top 10 des pays les plus polluant de 2021

SELECT * FROM (SELECT p.country_name, SUM(f.population_count*f.co2) AS emission FROM FACTS f, COUNTRIES p WHERE f.id_country = p.id_country AND f.year="2021"GROUP BY p.country_name,f.age_group ORDER BY emission )WHERE ROWNUM <= 10;

--Le top 10 des pays avec le plus gros pib en 2021

SELECT * FROM (SELECT p.country_name, SUM(f.population_count*f.gni) AS gni FROM FACTS f, COUNTRIES p WHERE f.id_country = p.id_country AND f.year="2021"GROUP BY p.country_name,f.age_group ORDER BY gni )WHERE ROWNUM <= 10;

--Classement des années les plus générative en co2

SELECT f.year, sum(f.population_count*f.co2) as emission,RANK() OVER (ORDER BY sum(f.population_count*f.co2) desc) as rank FROM FACTS f WHERE GROUP BY (f.id_country,f.year,f.population_count) ORDER BY emission;
