------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--  This file contains the requests used to create the
--  policies for our project in PostgreSQL
--
--  The policies are used to restrict the access to the
--  data in the database for the users
--
--  This script will create 3 users (user_1, user_2,
--  user_3) and 1 role (DB_USERS) that will be used to
--  create the policies
------------------------------------------------------

--  IF DB_ROLES EXIST THEN DROP IT FOR ALL USERS
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'DB_USERS') THEN
		REVOKE DB_USERS FROM USER_1, USER_2, USER_3;
    ELSE
        RAISE NOTICE 'Role DB_USERS does not exist';
    END IF;
END $$;

--  IF USERS EXISTS THEN DROP THEM
DROP USER IF EXISTS user_1;
DROP USER IF EXISTS user_2;
DROP USER IF EXISTS user_3;

--  DROP POLICIES IF THEY EXISTS
DROP POLICY IF EXISTS users_policy ON USERS;
DROP POLICY IF EXISTS facts_policy_select ON FACTS;
DROP POLICY IF EXISTS facts_policy_insert ON FACTS;
DROP POLICY IF EXISTS facts_policy_update ON FACTS;
DROP POLICY IF EXISTS facts_policy_delete ON FACTS;

--  DROP TABLE USERS
DROP TABLE IF EXISTS USERS CASCADE;

--  DROP ALL PRIVILEGES ASSOCIATED WITH DB_USERS
REVOKE ALL PRIVILEGES ON COUNTRIES, AGE_GROUPS, FACTS FROM DB_USERS;

--  RECREATE ROLE DB_USERS
DROP ROLE IF EXISTS DB_USERS;
CREATE ROLE DB_USERS LOGIN;

--  RECREATE USERS IN POSTGRESQL
CREATE USER user_1 PASSWORD 'user_1';
CREATE USER user_2 PASSWORD 'user_2';
CREATE USER user_3 PASSWORD 'user_3';

--  RECREATE USERS TABLE NEEDED FOR POLICIES
CREATE TABLE USERS (
    user_name VARCHAR(48) NOT NULL,
    id_country VARCHAR(3) NOT NULL,
	can_select BOOLEAN NOT NULL,
	can_insert BOOLEAN NOT NULL,
	can_update BOOLEAN NOT NULL,
	can_delete BOOLEAN NOT NULL,
    CONSTRAINT pk_user PRIMARY KEY (user_name, id_country),
    CONSTRAINT fk_user FOREIGN KEY (id_country) REFERENCES COUNTRIES(id_country) ON DELETE CASCADE
);

--   RECREATE FUNCTION USED IN INSERT TRIGGER ON USERS
CREATE OR REPLACE FUNCTION check_user_exists()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_user WHERE usename = NEW.user_name) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'User must exist in order to be inserted !';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_check_user_must_exist_at_insertion
BEFORE INSERT ON USERS
FOR EACH ROW
EXECUTE FUNCTION check_user_exists();

--  RE-INSERT EACH USER IN USERS TABLE WITH CORRESPONDING PRIVILEGES ON EACH COUNTRY
INSERT INTO USERS VALUES ('user_1', 'FRA', TRUE, FALSE, FALSE, FALSE);
INSERT INTO USERS VALUES ('user_1', 'USA', TRUE, TRUE, TRUE, TRUE);
INSERT INTO USERS VALUES ('user_2', 'FRA', TRUE, TRUE, TRUE, TRUE);
INSERT INTO USERS VALUES ('user_2', 'USA', TRUE, FALSE, FALSE, FALSE);
INSERT INTO USERS VALUES ('user_3', 'BEL', TRUE, TRUE, TRUE, TRUE);
INSERT INTO USERS VALUES ('user_3', 'USA', TRUE, FALSE, FALSE, FALSE);

--  GRANT NEEDED PRIVILEGES TO DB_USERS
GRANT SELECT ON COUNTRIES, AGE_GROUPS, USERS, FACTS TO DB_USERS;
GRANT INSERT ON FACTS TO DB_USERS;
GRANT UPDATE ON FACTS TO DB_USERS;
GRANT DELETE ON FACTS TO DB_USERS;

--  GRANT DB_USERS TO USERS
GRANT DB_USERS TO USER_1;
GRANT DB_USERS TO USER_2;
GRANT DB_USERS TO USER_3;


--
--  POLICIES FOR FACTS TABLE
--

--	ENABLE POLICIES FOR FACTS TABLE
ALTER TABLE FACTS ENABLE ROW LEVEL SECURITY;

--	Each users will only be able to see data from countries which
--  they have the right to see as stipulated in USERS table
CREATE POLICY facts_policy_select
  ON FACTS
  FOR SELECT
  TO public
  USING (id_country IN (SELECT id_country FROM USERS WHERE user_name = current_user AND can_select));
  
--	Each users will only be able to insert data from countries which
--  they have the right to insert as stipulated in USERS table
CREATE POLICY facts_policy_insert
  ON FACTS
  FOR INSERT
  TO public
  WITH CHECK (id_country IN (SELECT id_country FROM USERS WHERE user_name = current_user AND can_insert));


--	Each users will only be able to update data from countries which
--  they have the right to update as stipulated in USERS table
CREATE POLICY facts_policy_update
  ON FACTS
  FOR UPDATE
  TO public
  USING (id_country IN (SELECT id_country FROM USERS WHERE user_name = current_user AND can_update));
  
--	Each users will only be able to delete data from countries which
--  they have the right to delete as stipulated in USERS table
CREATE POLICY facts_policy_delete
  ON FACTS
  FOR DELETE
  TO public
  USING (id_country IN (SELECT id_country FROM USERS WHERE user_name = current_user AND can_delete));

--
--  POLICIES FOR USERS TABLE
--

--	ENABLE POLICIES FOR USERS TABLE
ALTER TABLE USERS ENABLE ROW LEVEL SECURITY;

--  USERS will only be able to see their own data
CREATE POLICY users_policy
  ON USERS
  TO public
  USING (user_name LIKE current_user)