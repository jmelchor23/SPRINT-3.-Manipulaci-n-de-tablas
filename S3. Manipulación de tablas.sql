USE transactions;

# NIVEL 1 - EJERCICIO 1
/* Creación de tabla credit_card; debe ser capaz de identificar de forma única cada tarjeta y establecer una relación 
adecuada con las otras dos tablas ("transaction" y "company") e ingresar información del archivo "datos_introducir_credit".*/

CREATE TABLE IF NOT EXISTS credit_card (
		id VARCHAR(50) PRIMARY KEY,    
        iban VARCHAR(50),
        pan VARCHAR(50),
        pin INT,
        cvv INT,
        expiring_date VARCHAR(20)
        );
        
ALTER TABLE transaction
ADD CONSTRAINT fk_creditcard_transaction
FOREIGN KEY (credit_card_id)    
REFERENCES credit_card(id);				

# NIVEL 1 - EJERCICIO 2

/* El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de 
crédito con ID CcU-2938. La información que debe mostrarse para este registro es: TR323456312213576817699999 */

SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938'; 

# NIVEL 1 - EJERCICIO 3
/* En la tabla "transaction" ingresa una nueva transacción con la siguiente información:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lato	829.999
longitud	-117.999
amunt	111.11
declined	0 */

INSERT INTO company(id) VALUES ('b-9999');
INSERT INTO credit_card(id) VALUES ('CcU-9999');

INSERT INTO transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999', 'b-9999',9999, 829.999, -117.999, 111.11, 0);

# NIVEL 1 - EJERCICIO 4.
/*Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card.*/

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;
-- --------------------------------------------------------------------------------------------------------------

# NIVEL 2 - EJERCICIO 1.

-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction
WHERE id =  '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE ID = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

# NIVEL 2 - EJERCICIO 2.
/* Crear una vista llamada VistaMarketing que contenga la siguiente información: 
Nombre de la compañía. Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. 
Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra. */

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT comp.company_name AS Nombre_Compañia, 
		comp.phone AS Telefono_contacto, 
        comp.country AS Pais_de_Residencia, 
        ROUND(avg(trans.amount),2) as Media_de_compra
FROM company comp
JOIN transaction trans ON comp.id = trans.company_id
WHERE declined = 0
GROUP BY comp.id,comp.company_name, comp.phone, comp.country;

SELECT *
FROM vistamarketing                 /* He dejado el order by fuera de la vista porque, según la documentación, no se garantiza el orden de la consulta
ORDER BY Media_de_compra DESC;		al momento de llamar la vista, el resultado proviene de la ultima SELECT (la vista actúa como subquery). */
  
				

# NIVEL 2 - EJERCICIO 3.
-- Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT *
FROM vistamarketing
WHERE pais_de_Residencia = 'Germany';
-- --------------------------------------------------------------------------

# NIVEL 3 - EJERCICIO 1. 
-- PASO 1: Creación de la tabla user.
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);
-- PASO 2: Cambio de tipo de dato del campo id de la tabla user.
ALTER TABLE user
MODIFY column id INT;

-- PASO 3: Cambio de nombre de la tabla user, nuevo nombre data_user.
ALTER TABLE user
RENAME TO data_user;

-- PASO 4. Insertar el id usuario 9999 en la tabla data_user, esto para crear en el siguiente paso la relación con la tabla transaction.
INSERT INTO data_user(id) VALUES (9999);
 
-- PASO 5. Creación de la foreign key (fk_user_transaction) para relacionar los datos de la tabla transaction y la tabla user. 

ALTER TABLE transaction
ADD CONSTRAINT fk_user_transaction
FOREIGN KEY (user_id)
REFERENCES data_user(id);

-- PASO 6. Creación del campo fecha_actual en la tabla credit_card
ALTER TABLE credit_card
ADD fecha_actual DATE;

# revisar si se debe agregar la fecha actual 
	/*  UPDATE credit_card
		SET fecha_actual = sysdate()
		WHERE id IS NOT NULL;
	*/ 

-- PASO 7. Se elimina el campo website de la tabla company.
ALTER TABLE company
DROP COLUMN website;

-- PASO 8. Cambio de nombre del campo email al nombre personal_email, en la tabla data_user.
ALTER TABLE data_user
CHANGE COLUMN email personal_email VARCHAR(150);


# NIVEL 3 - EJERCICIO 2.
/* Crear una vista llamada "InformeTecnico" que contenga la siguiente información:

ID de la transacción 
Nombre del usuario/a
Apellido del usuario/a
IBAN de la tarjeta de crédito usada.  
Nombre de la compañía de la transacción realizada. 

Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar de nombre columnas según sea necesario.
Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción. */

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT 
	du.name AS Nombre_de_usuario,
    du.surname AS Apellido_del_usuario,
    comp.company_name AS Nombre_de_la_Compañía,
    cc.iban AS IBAN_de_tarjeta_de_credito_usada,
    trans.id AS ID_de_la_transaccion 
FROM transaction trans
JOIN credit_card cc ON trans.credit_card_id = cc.id
JOIN company comp ON trans.company_id = comp.id
JOIN data_user du ON trans.user_id = du.id
WHERE declined = 0;

SELECT *
FROM informetecnico
ORDER BY ID_de_la_transaccion DESC;  /* He dejado el order by fuera de la vista porque, según la documentación, no se garantiza el orden de la consulta
									al momento de llamar la vista, el resultado proviene de la ultima SELECT (la vista actúa como subquery). */
								
						