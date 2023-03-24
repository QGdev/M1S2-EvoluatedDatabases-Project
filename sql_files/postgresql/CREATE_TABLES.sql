------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--  This file contains the queries used to create
--  the tables of our project in PostgreSQL
------------------------------------------------------

--
--  Creation of the dimension COUNTRIES
--
CREATE TABLE COUNTRIES (
    id_country VARCHAR(3) NOT NULL,
    country_name VARCHAR(48),
    CONSTRAINT pk_country PRIMARY KEY (id_country),
    CONSTRAINT id_country_format CHECK(id_country ~ '[A-Z]{3}')
);

--
--  Creation of the dimension AGE_GROUPS
--
CREATE TABLE AGE_GROUPS (
    id_age_group INTEGER NOT NULL,
    age_group VARCHAR(7),
    CONSTRAINT pk_age_group PRIMARY KEY (id_age_group),
    CONSTRAINT id_age_group_format CHECK(id_age_group >= 0),
    CONSTRAINT age_group_format CHECK(age_group ~ '^(([0-9]{1,2} - [0-9]{1,2})|(LESS_[0-9]{1,2})|([0-9]{1,2}_OVER)|TOTAL)$')
);

--
--  Creation of the dimension FACTS
--
CREATE TABLE FACTS (
    id_country VARCHAR(3) NOT NULL CHECK(id_country ~ '^[A-Z]{3}$'),
    year INTEGER NOT NULL CHECK (year >= 1 AND year <= 9999),
    hdi FLOAT CHECK (hdi >= 0 AND hdi <= 1),
    gni FLOAT CHECK (gni >= 0),
    co2 FLOAT CHECK (co2 >= 0),
    id_age_group INTEGER NOT NULL CHECK(id_age_group >= 0),
    population_count INTEGER CHECK(population_count >= 0),
    CONSTRAINT pk_facts PRIMARY KEY (id_country, id_age_group, year),
    CONSTRAINT fk_facts_country FOREIGN KEY (id_country) REFERENCES COUNTRIES(id_country) ON DELETE CASCADE,
    CONSTRAINT fk_facts_age_group FOREIGN KEY (id_age_group) REFERENCES AGE_GROUPS(id_age_group) ON DELETE CASCADE
);
