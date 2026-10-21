
USE sakila;


# EJERCICIO 1

SHOW INDEX FROM address;

# Consulta 1 - IN

SELECT address_id, address, postal_code
FROM address
WHERE postal_code IN ('10428', '1027', '10417');

# TIEMPO : fetched - 0,003s


#Consulta 2

SELECT address_id, address, postal_code
FROM address
WHERE postal_code NOT IN ('10428', '1027', '10417');

# TIEMPO : 0,003s


#Consulta 3

SELECT a.address_id, a.address, a.postal_code, c.city, co.country
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.postal_code IN ('10428', '1027', '10417');

# TIEMPO: 0,004s



EXPLAIN
SELECT address_id, address, postal_code
FROM address
WHERE postal_code IN ('10428', '1027', '10417');


#creo indice

CREATE INDEX idx_postal_code
ON address(postal_code);


#Chequeo q esta creado

SHOW INDEX FROM address;


# Consulta post index 1

SELECT address_id, address, postal_code
FROM address
WHERE postal_code IN ('10428', '1027', '10417');

# TIEMPO CON INDICE: 0,004s


# Consulta post index 2

SELECT address_id, address, postal_code
FROM address
WHERE postal_code NOT IN ('10428', '1027', '10417');

# TIEMPO CON INDICE: 0,005s


# Consulta post index 3

SELECT a.address_id, a.address, a.postal_code, c.city, co.country
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.postal_code IN ('10428', '1027', '10417');

# TIEMPO CON INDICE: 0,002s


# Chequear si esta utilizando el index

EXPLAIN
SELECT address_id, address, postal_code
FROM address
WHERE postal_code IN ('10428', '1027', '10417');


/*
Explicacion ejercicio 1:

antes de crear el indice, mysql puede tener que recorrer varias filas para encontrar los postal_code que buscamos.

despues de crear:

CREATE INDEX idx_postal_code
ON address(postal_code);

mysql puede usar ese indice para encontrar los datos mas rapido.

con explain podemos ver si realmente esta usando el indice mirando la columna key.

como la tabla address de sakila no es muy grande, la diferencia de tiempo puede ser bastante chica.

con not in el indice puede ayudar menos porque normalmente devuelve muchos registros.
*/



# Ejercicio 2


# VER LOS INDICES DE ACTOR

SHOW INDEX FROM actor;


# BUSCAR POR FIRST_NAME

SELECT *
FROM actor
WHERE first_name = 'PENELOPE';

# TIEMPO FIRST_NAME: 0,005s


EXPLAIN
SELECT *
FROM actor
WHERE first_name = 'PENELOPE';


# BUSCAR POR LAST_NAME

SELECT *
FROM actor
WHERE last_name = 'GUINESS';

# TIEMPO LAST_NAME: 0,004s


EXPLAIN
SELECT *
FROM actor
WHERE last_name = 'GUINESS';

/*
Explicacion ejercicio 2:

la columna last_name tiene un indice llamado:

idx_actor_last_name

en cambio first_name no tiene indice.

por eso cuando buscamos:

WHERE first_name = 'PENELOPE'

mysql puede tener que recorrer toda la tabla.

en explain puede aparecer algo como:

type = ALL
key = NULL

en cambio con:

WHERE last_name = 'GUINESS'

mysql puede usar el indice:

idx_actor_last_name

por eso la busqueda por last_name puede ser mas rapida.

igual como la tabla actor tiene pocos registros, la diferencia de tiempo puede ser muy chica.
*/




# Ejercicio 3


# BUSQUEDA CON LIKE EN FILM

SELECT film_id, title, description
FROM film
WHERE description LIKE '%drama%';

# TIEMPO LIKE: 0,006s


EXPLAIN
SELECT film_id, title, description
FROM film
WHERE description LIKE '%drama%';


# VER INDICES DE FILM_TEXT

SHOW INDEX FROM film_text;


# BUSQUEDA CON MATCH AGAINST

SELECT film_id, title, description
FROM film_text
WHERE MATCH(title, description)
AGAINST('drama');

# TIEMPO MATCH AGAINST: 0,004


EXPLAIN
SELECT film_id, title, description
FROM film_text
WHERE MATCH(title, description)
AGAINST('drama');


# Mostrar la relevancia

SELECT film_id, title, description, MATCH(title, description) AGAINST('drama') AS relevance
FROM film_text
WHERE MATCH(title, description)
AGAINST('drama');

/*
Explicacion ejercicio 3:

Like busca texto dentro de una columna, por ejemplo:

WHERE description LIKE '%drama%'

eso busca las peliculas que tengan la palabra drama en la descripcion.

al usar % antes y despues, mysql tiene que revisar bastante texto para encontrar coincidencias.

Match against funciona distinto porque usa un indice fulltext.

en film_text el fulltext esta hecho sobre title y description, por eso se usa:

MATCH(title, description)
AGAINST('drama')

y no solo match(description).

match against esta pensado para busquedas de texto y tambien puede dar un valor de relevancia.

en resumen, like busca coincidencias de texto y match against busca palabras usando fulltext.
por eso pueden devolver resultados distintos.
*/


-- =====================================================
-- Resumen
-- =====================================================

/*

Index:

sirve para acelerar busquedas en una columna.

ejemplo:

CREATE INDEX idx_postal_code
ON address(postal_code);


Explain:

sirve para ver como mysql ejecuta una consulta.

las columnas mas utiles son:

type
possible_keys
key
rows

si type = ALL significa que esta recorriendo toda la tabla.

key muestra que indice esta usando mysql.


Fulltext:

es un tipo de indice pensado para busquedas de texto.

se usa con:

MATCH(...)
AGAINST(...)


Like:

busca coincidencias dentro de un texto.

ejemplo:

WHERE description LIKE '%drama%';


Match against:

busca palabras usando un indice fulltext.

ejemplo:

WHERE MATCH(title, description)
AGAINST('drama');

*/