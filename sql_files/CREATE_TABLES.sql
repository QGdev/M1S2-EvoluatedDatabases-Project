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
--  Creation de la dimension COUNTRY
--
CREATE TABLE COUNTRIES (
    id_country VARCHAR(3) NOT NULL,
    country_name VARCHAR(7),
    CONSTRAINT pk_country PRIMARY KEY (id_country),
    CONSTRAINT id_country_format CHECK (REGEXP_LIKE(id_country, '^[A-Z]{3}$'))
);

--
--  Creation de la dimension AGE_GROUP
--
CREATE TABLE AGE_GROUPS (
    id_age_group VARCHAR(2) NOT NULL,
    age_group VARCHAR(7),
    CONSTRAINT pk_age_group PRIMARY KEY (id_age_group),
    CONSTRAINT id_age_group_format CHECK (REGEXP_LIKE(id_age_group, '^[A-Z]*$')),
    CONSTRAINT age_group_format CHECK (REGEXP_LIKE(id_age_group, '^[0-9A-Z_ -]*$'))
);

--
--  Creation de la table des faits
--
CREATE TABLE FACTS (
    id_country VARCHAR(3) NOT NULL CHECK (REGEXP_LIKE(id_country, '^[A-Z]{3}$')),
    year NUMBER(4) NOT NULL CHECK (year >= 1 AND year <= 9999),
    hdi FLOAT CHECK (hdi >= 0 AND hdi <= 1),
    gni FLOAT CHECK (gni >= 0),
    co2 FLOAT CHECK (co2 >= 0),
    id_age_group VARCHAR(2) NOT NULL CHECK (REGEXP_LIKE(id_age_group, '^[A-Z]*$')),
    population_count NUMBER CHECK (population_count >= 0),
    CONSTRAINT pk_facts PRIMARY KEY (id_country, id_age_group, year),
    CONSTRAINT fk_facts_country FOREIGN KEY (id_country) REFERENCES COUNTRIES(id_country) ON DELETE CASCADE,
    CONSTRAINT fk_facts_age_group FOREIGN KEY (id_age_group) REFERENCES AGE_GROUPS(id_age_group) ON DELETE CASCADE
);