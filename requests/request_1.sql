------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Les émissions de co2 par pays et par année

SELECT p.country_name, f.year, SUM(f.co2)
FROM COUNTRIES p, FACTS f, AGE_GROUPS a
WHERE p.id_country = f.id_country AND f.id_age_group = a.id_age_group AND a.age_group = 'TOTAL' AND f.co2 IS NOT NULL
GROUP BY CUBE(p.country_name,f.year);
