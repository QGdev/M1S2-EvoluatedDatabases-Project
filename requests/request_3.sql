------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--L’IDH moyen par pays par année

SELECT p.country_name, f.year, AVG(hdi)
FROM COUNTRIES p, FACTS f WHERE p.id_country = f.id_country AND f.hdi IS NOT NULL
GROUP BY CUBE(p.country_name,f.year);

SELECT p.country_name, f.year, AVG(hdi)
FROM COUNTRIES p, FACTS f
WHERE p.id_country = f.id_country AND f.hdi IS NOT NULL
GROUP BY GROUPING SETS((p.country_name),(p.country_name, f.year))
ORDER BY p.country_name, f.year;