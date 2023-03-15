------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--  Ce fichier contient les requetes servant à la creation
--  des tables de notre projet
------------------------------------------------------

--
--  Creation de la table des faits
--
CREATE TABLE FACTS (
    id_country VARCHAR(3) NOT NULL,
    year NUMBER(4) NOT NULL CHECK (year >= 1 AND year <= 9999),
    hdi FLOAT NOT NULL CHECK (hdi >= 0 AND hdi <= 1),
    gni FLOAT NOT NULL CHECK (gni >= 0),
    co2 FLOAT NOT NULL CHECK (co2 >= 0),
    id_age_group VARCHAR(2) NOT NULL,
    population_count NUMBER NOT NULL CHECK (population_count >= 0),
    CONSTRAINT id_country_format CHECK (REGEXP_LIKE(id_country, '^[A-Z]{3}$')),
    CONSTRAINT id_age_group_format CHECK (REGEXP_LIKE(id_age_group, '^[A-Z]*$'))
);

--
--  Creation de la dimension COUNTRY
--
CREATE TABLE COUNTRY (
    id_country VARCHAR(3) NOT NULL,
    country_name VARCHAR(7),
    CONSTRAINT id_country_format CHECK (REGEXP_LIKE(id_country, '^[A-Z]{3}$')),
    CONSTRAINT country_name_format CHECK (REGEXP_LIKE(country_name, '^\D*$'))
);

--
--  Creation de la dimension AGE_GROUP
--
CREATE TABLE AGE_GROUP (
    id_age_group VARCHAR(2) NOT NULL,
    age_group VARCHAR(7),
    CONSTRAINT id_age_group_format CHECK (REGEXP_LIKE(id_age_group, '^[A-Z]*$')),
    CONSTRAINT age_group_format CHECK (REGEXP_LIKE(id_age_group, '^\d+(\s*-\s*\d+)?$'))
)