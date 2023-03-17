Les émissions de co2 par pays et par année

SELECT p.country_name, f.year, SUM(f.co2) FROM COUNTRIES p, FACTS f WHERE p.id_country = f.id_country GROUP BY CUBE(p.country_name,f.year);

gni par pays par année

SELECT p.country_name, f.year, sum(gni) from COUNTRIES p, FACTS f WHERE p.id_country = f.id_country GROUP BY ROLLUP(p.country_name,f.year)

hdi par pays par année

SELECT p.country_name, f.year, sum(hdi) from COUNTRIES p, FACTS f WHERE p.id_country = f.id_country GROUP BY CUBE(p.country_name,f.year)


SELECT p.country_name, f.year, SUM(f.co2), SUM(SUM(f.co2)), OVER (order by f.year ROWS UNBOUNDED PRECEDING) FROM COUNTRIES p, FACTS f WHERE f.id_country = p.id_country GROUP BY f.id_country, f.year;

pays trié par moyenne des RNB par pays par annee

SELECT p.country_name AVG(GNI),RANK() OVER (ORDER BY AVG(GNI) desc) as rank FROM COUNTRIES p, FACTS f where p.id_country = g.id_country group by(f.id_country, f.year);

pays trié par leur hdi moyen par année
SELECT p.country_name AVG(hdi),NTILE(4) OVER (ORDER BY AVG(hdi) desc) rank FROM COUNTRIES p, FACTS f where p.id_country = g.id_country group by(f.id_country, f.year);

Partition des pays ou l'on affiche la moyenne de population en fonction de la tranche d'AGE_GROUPS et du pays

SELECT p.country_name, a.age_group, AVG(f.nbpersonne) as age, DENSE_RANK() OVER (PARTITION BY a.age_group ORDER BY(f.age_group)) FROM FACTS f, COUNTRIES p, age a WHERE p.id_country=f.id_country AND f.id_age_group = a.id_age_group GROUP BY(p.country_name, a.age_group);

top 10 des plus gros pollueur de 2021
SELECT * FROM (SELECT p.country_name, SUM(f.population_count*f.co2) AS emission FROM FACTS f, COUNTRIES p WHERE f.id_country = p.id_country AND f.year="2021"GROUP BY p.country_name,f.age_group ORDER BY emission )WHERE ROWNUM <= 10;

top 10 des plus gros gni par habitant
SELECT * FROM (SELECT p.country_name, SUM(f.population_count*f.gni) AS gni FROM FACTS f, COUNTRIES p WHERE f.id_country = p.id_country AND f.year="2021"GROUP BY p.country_name,f.age_group ORDER BY gni )WHERE ROWNUM <= 10;

les années les plus polluantes
SELECT f.year, sum(f.population_count*f.co2) as emission,RANK() OVER (ORDER BY sum(f.population_count*f.co2) desc) as rank FROM FACTS f WHERE GROUP BY (f.id_country,f.year,f.population_count) ORDER BY emission
