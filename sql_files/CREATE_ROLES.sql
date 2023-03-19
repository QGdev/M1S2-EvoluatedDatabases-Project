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
DROP TABLE USER;
CREATE TABLE USER (
    user_name VARCHAR(48) NOT NULL,
    id_country VARCHAR(3) NOT NULL,
    CONSTRAINT pk_user PRIMARY KEY (user_name),
    CONSTRAINT fk_user FOREIGN KEY (id_country) REFERENCES COUNTRIES(id_country) ON DELETE CASCADE
);

INSERT INTO USER VALUES ('', 'FRA');
INSERT INTO USER VALUES ('', 'BEL');

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
        FROM USER
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
    return_val := 'id_country = SYS_CONTEXT("user_ctx","id_country")';
    RETURN return_val;
END auth_country;
/

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'admi', -- NOM DU COMPTE
        object_name => 'country',
        policy_name => 'country_policy',
        function_schema => 'admi', -- NOM DU COMPTE
        policy_function => 'auth_country',
        statement_types => 'select, insert, update, delete'
    );
END;
/
