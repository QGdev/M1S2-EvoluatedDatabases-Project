------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Classement des années les plus générative en co2

SELECT f.year, SUM(f.population_count*f.co2) AS emission, RANK() OVER (ORDER BY SUM(f.population_count*f.co2) DESC) AS rank
FROM FACTS f, AGE_GROUPS a
WHERE f.id_age_group = a.id_age_group AND a.age_group = 'TOTAL' AND f.population_count IS NOT NULL AND f.co2 IS NOT NULL
GROUP BY (f.year)
ORDER BY emission;