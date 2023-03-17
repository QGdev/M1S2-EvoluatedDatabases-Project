------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Ensemble des pays trié par moyenne des RNB par année

SELECT p.country_name, AVG(f.gni), RANK() OVER (ORDER BY AVG(f.gni) DESC) as rank
FROM COUNTRIES p, FACTS f, AGE_GROUPS a
WHERE p.id_country = f.id_country AND f.id_age_group = a.id_age_group AND a.age_group = 'TOTAL' AND f.gni IS NOT NULL
GROUP BY(p.country_name);
