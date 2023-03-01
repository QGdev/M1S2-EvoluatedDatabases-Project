CREATE TABLE AIRPORTS_STATS (
	icao VARCHAR(4) NOT NULL,
	date INTEGER NOT NULL
    pas_brd LONG,
    pas_crd LONG,
    st_pas LONG,
    frm_brd FLOAT,
    frm_ld_nld FLOAT,
    caf LONG,
    caf_pas LONG,
    caf_frm LONG,
	CONSTRAINT pk_stats PRIMARY KEY(icao, date),
    CONSTRAINT fk_stats_icao FOREIGN KEY(icao) REFERENCES AIRPORTS(icao) ON DELETE CASCADE,
    CONSTRAINT fk_stats_date FOREIGN KEY(date) REFERENCES DATES(id) ON DELETE CASCADE
);

CREATE TABLE AIRPORTS (
	icao VARCHAR(4) NOT NULL CHECK(REGEXP_LIKE(icao, '^[A-Z]{4}$')),
	country_id VARCHAR(3) NOT NULL,
    pas_brd LONG,
    pas_crd LONG,
    st_pas LONG,
    frm_brd FLOAT,
    frm_ld_nld FLOAT,
    caf LONG,
    caf_pas LONG,
    caf_frm LONG,
	CONSTRAINT pk_airport PRIMARY KEY(icao),
    CONSTRAINT fk_airport FOREIGN KEY(country_id) REFERENCES COUNTRIES(codeISOA3) ON DELETE CASCADE
);

CREATE TABLE COUNTRIES(
    codeISOA3 VARCHAR(3) NOT NULL CHECK(REGEXP_LIKE(codeISOA3, '^[A-Z]{3}$')),
    codeISOA2 VARCHAR(2) NOT NULL CHECK(REGEXP_LIKE(codeISOA2, '^[A-Z]{2}$')),
    region VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_country PRIMARY KEY(codeISOA3)
);
CREATE TABLE SOURCES(
    id INTEGER PRIMARY KEY NOT NULL,
    type VARCHAR(100) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    licence VARCHAR(100) NOT NULL,
    source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_source PRIMARY KEY(id),

);
CREATE TABLE DATES(
    id INTEGER NOT NULL,
    annee INTEGER NOT NULL,
    mois INTEGER,
    jour INTEGER,
    CONSTRAINT pk_date PRIMARY KEY(id)
);