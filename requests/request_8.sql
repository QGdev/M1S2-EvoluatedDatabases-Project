------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Le top 10 des pays les plus polluant de 2021

SELECT *
FROM (SELECT p.country_name, SUM(f.population_count * f.co2) AS emission
FROM FACTS f, COUNTRIES p, AGE_GROUPS a
WHERE f.id_country = p.id_country AND f.id_age_group = a.id_age_group AND f.year=2021 AND a.age_group='TOTAL' AND f.population_count IS NOT NULL AND f.co2 IS NOT NULL
GROUP BY p.country_name
ORDER BY emission DESC)
WHERE ROWNUM <= 10;