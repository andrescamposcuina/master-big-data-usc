-- E1
-- peliculas
SELECT 
    pel.titulo AS "Titulo", 
    pel.fecha_emision AS "Fecha de Emisión",
    (rep.persona).nombre AS "Nombre del Actor/Actriz", 
    rep.personaje AS "Personaje"
FROM 
    peliculas pel, 
    UNNEST(pel.reparto) AS rep(persona, personaje)
WHERE 
    (rep.persona).nombre = 'Penélope Cruz'
ORDER BY 
    pel.fecha_emision ASC;


-- peliculasxml
SELECT
    pel.titulo AS "Titulo",
    pel.fecha_emision AS "Fecha de Emisión",
    XMLSERIALIZE(CONTENT (XPATH('/miembroreparto/text()', rep_elem.x))[1] AS TEXT) AS "Nombre del Actor/Actriz",
    XMLSERIALIZE(CONTENT (XPATH('/miembroreparto/@personaje', rep_elem.x))[1] AS TEXT) AS "Personaje"
FROM 
    peliculasxml pel, 
    UNNEST(XPATH('/reparto/miembroreparto', pel.reparto)) AS rep_elem(x)
WHERE 
    XMLSERIALIZE(CONTENT (XPATH('/miembroreparto/text()', rep_elem.x))[1] AS TEXT) = 'Penélope Cruz'
ORDER BY 
    pel.fecha_emision ASC;


-- peliculasjson
SELECT
    pel.titulo AS "Titulo",
    pel.fecha_emision AS "Fecha de Emisión",
    (rep_elemento->'persona')->>'nombre' AS "Nombre del Actor/Actriz", 
    rep_elemento->>'personaje' AS "Personaje"
FROM 
    peliculasjson pel, 
    JSONB_ARRAY_ELEMENTS(pel.reparto) WITH ORDINALITY AS reparto(rep_elemento)
WHERE 
    (rep_elemento->'persona')->>'nombre' = 'Penélope Cruz'
ORDER BY 
    pel.fecha_emision ASC;


-- E2:
-- peliculas
SELECT 
    (pers.persona).nombre AS "Nombre del Director",
    COUNT(DISTINCT peli.id) AS "Número de Películas",
    SUM(peli.ingresos - peli.presupuesto) AS "Beneficio Total"
FROM 
    peliculas peli, 
    UNNEST(peli.personal) AS pers(persona, departamento, trabajo)
WHERE 
    pers.trabajo = 'Director'
GROUP BY 
    (pers.persona).nombre
ORDER BY 
    "Beneficio Total" DESC
LIMIT 10;

-- peliculasxml
SELECT
    XMLSERIALIZE(CONTENT (XPATH('/trabajador/text()', trab.x))[1] AS TEXT) AS "Nombre del Director",
    COUNT(DISTINCT peli.id) AS "Número de Películas",
    SUM(peli.ingresos - peli.presupuesto) AS "Beneficio Total"
FROM 
    peliculasxml peli, 
    UNNEST(XPATH('/personal/trabajador', peli.personal)) AS trab(x)
WHERE
    XMLSERIALIZE(CONTENT (XPATH('/trabajador/@trabajo', trab.x))[1] AS TEXT) = 'Director'
GROUP BY 
    XMLSERIALIZE(CONTENT (XPATH('/trabajador/text()', trab.x))[1] AS TEXT)
ORDER BY 
    "Beneficio Total" DESC
LIMIT 10;


-- peliculasjson
SELECT
    (pers_elemento->'persona')->>'nombre' AS "Nombre del Director",
    COUNT(DISTINCT peli.id) AS "Número de Películas",
    SUM(peli.ingresos - peli.presupuesto) AS "Beneficio Total"
FROM 
    peliculasjson peli, 
    JSONB_ARRAY_ELEMENTS(peli.personal) WITH ORDINALITY AS personal(pers_elemento)
WHERE 
    pers_elemento->>'trabajo' = 'Director'
GROUP BY 
    (pers_elemento->'persona')->>'nombre'
ORDER BY 
    "Beneficio Total" DESC
LIMIT 10;