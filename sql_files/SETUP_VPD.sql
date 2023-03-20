------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--  Ce fichier contient les créations des rôles associés à la base de donnée,
--  ainsi que les règles de la VPD.
------------------------------------------------------

--  Création de la table des users
DROP TABLE USERS;
CREATE TABLE USERS (
    user_name VARCHAR(48) NOT NULL,
    id_country VARCHAR(3) NOT NULL,
    CONSTRAINT pk_user PRIMARY KEY (user_name),
    CONSTRAINT fk_user FOREIGN KEY (id_country) REFERENCES COUNTRIES(id_country) ON DELETE CASCADE
);

GRANT SELECT ON COUNTRIES TO admi22;
GRANT SELECT ON COUNTRIES TO admi28;
GRANT SELECT ON COUNTRIES TO admi32;

GRANT SELECT ON AGE_GROUPS TO admi22;
GRANT SELECT ON AGE_GROUPS TO admi28;
GRANT SELECT ON AGE_GROUPS TO admi32;

GRANT SELECT, INSERT, DELETE ON admi18.FACTS TO admi22;
GRANT SELECT, INSERT, DELETE ON admi18.FACTS TO admi28;
GRANT SELECT, INSERT, DELETE ON admi18.FACTS TO admi32;

GRANT SELECT ON USERS TO admi22;
GRANT SELECT ON USERS TO admi28;
GRANT SELECT ON USERS TO admi32;

INSERT INTO USERS VALUES ('ADMI22', 'BEL');
INSERT INTO USERS VALUES ('ADMI28', 'FRA');
INSERT INTO USERS VALUES ('ADMI32', 'FRA');

--  Création du contexte et du package
CREATE OR REPLACE CONTEXT user_ctx USING set_user_ctx_pkg;
CREATE OR REPLACE PACKAGE set_user_ctx_pkg IS
    PROCEDURE set_country;
END;
/

CREATE OR REPLACE PACKAGE BODY set_user_ctx_pkg IS
    PROCEDURE set_country
    IS
        id_ctx VARCHAR(3);
        name_ctx VARCHAR(48);
    BEGIN
        name_ctx:=SYS_CONTEXT('USERENV', 'SESSION_USER');
        DBMS_SESSION.SET_CONTEXT('user_ctx','user_name',name_ctx);

        SELECT id_country INTO id_ctx
        FROM admi18.USERS
        WHERE user_name = UPPER(name_ctx);
        DBMS_SESSION.SET_CONTEXT('user_ctx','id_country',id_ctx);
    END set_country;
END set_user_ctx_pkg;
/

--  Fonction qui assure qu'un utilisateur reçoit les valeurs de requête le concernant
--  (ex: l'utilisateur "France" ne reçoit que les données pour la France)
CREATE OR REPLACE FUNCTION auth_country(
    schema_var IN VARCHAR2,
    table_var IN VARCHAR2
)
RETURN VARCHAR
IS
    return_val VARCHAR(400);
BEGIN
    return_val := 'id_country IN (SELECT id_country INTO id_ctx FROM admi18.USERS WHERE user_name = UPPER(name_ctx);)';
    RETURN return_val;
END auth_country;
/


GRANT EXECUTE ON set_user_ctx_pkg TO admi22;
GRANT EXECUTE ON set_user_ctx_pkg TO admi28;
GRANT EXECUTE ON set_user_ctx_pkg TO admi32;

GRANT EXECUTE ON auth_country TO admi22;
GRANT EXECUTE ON auth_country TO admi28;
GRANT EXECUTE ON auth_country TO admi32;


EXECUTE DBMS_RLS.DROP_POLICY('admi18', 'FACTS', 'country_policy'); 

BEGIN  
    DBMS_RLS.ADD_POLICY (
        object_schema => 'admi18', -- NOM DU COMPTE
        object_name => 'FACTS',
        policy_name => 'country_policy',
        function_schema => 'admi18', -- NOM DU COMPTE
        policy_function => 'auth_country',
        statement_types => 'select, insert, update, delete',
        sec_relevant_cols => 'id_country');
END;
/