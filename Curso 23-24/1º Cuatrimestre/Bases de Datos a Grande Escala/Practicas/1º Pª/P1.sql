-- E1
SELECT 
    p.titulo AS "Título", 
    p.titulo_original AS "Título Original", 
    p.fecha_emision AS "Fecha de Emisión", 
    p.sinopsis AS "Sinopsis", 
    (p.ingresos - p.presupuesto) AS "Beneficios"
FROM 
    peliculas p
WHERE 
    p.idioma_original = 'it' AND
    EXTRACT(YEAR FROM p.fecha_emision) = 1960
ORDER BY 
    "Beneficios" DESC;

-- E2
SELECT 
    r.orden AS "Orden", 
    per.nombre AS "Nombre del Actor/Actriz", 
    r.personaje AS "Personaje"
FROM 
    peliculas p, 
    personas per, 
    pelicula_reparto r
WHERE 
    p.id = r.pelicula AND
    per.id = r.persona AND
    p.titulo = 'Titanic' AND
    EXTRACT(YEAR FROM p.fecha_emision) = 1997
ORDER BY 
    r.orden ASC;

-- E3
SELECT 
    pais.id AS "ID País", 
    pais.nombre AS "Nombre del País", 
    COUNT(DISTINCT p.id) AS "Número de Películas", 
    SUM(p.ingresos - p.presupuesto) AS "Beneficios Totales",
    CAST(AVG(p.popularidad) AS DECIMAL(10,2)) AS "Media de Popularidad"
FROM 
    peliculas p
JOIN 
    pelicula_pais pp ON p.id = pp.pelicula
JOIN 
    paises pais ON pais.id = pp.pais
GROUP BY 
    pais.id
ORDER BY 
    "Beneficios Totales" DESC;

-- E4
SELECT 
    dir.id AS "ID Persona", 
    dir.nombre AS "Nombre", 
    dir.num_peliculas_dirigidas AS "Películas Dirigidas",
    dir.fecha_primera_dirigida AS "Primera Dirigida",
    dir.fecha_ultima_dirigida AS "Última Dirigida",
    act.num_peliculas_actuadas AS "Películas Actuadas",
    act.fecha_primera_actuada AS "Primera Actuada",
    act.fecha_ultima_actuada AS "Última Actuada"
FROM 
    (SELECT 
         per.id, 
         per.nombre, 
         COUNT(DISTINCT p.id) AS num_peliculas_dirigidas, 
         MIN(p.fecha_emision) AS fecha_primera_dirigida, 
         MAX(p.fecha_emision) AS fecha_ultima_dirigida
     FROM 
         peliculas p
     JOIN 
         pelicula_personal pp ON p.id = pp.pelicula
     JOIN 
         personas per ON per.id = pp.persona 
     WHERE 
         pp.trabajo = 'Director'
     GROUP BY 
         per.id) dir
JOIN 
    (SELECT 
         per.id, 
         COUNT(DISTINCT p.id) AS num_peliculas_actuadas, 
         MIN(p.fecha_emision) AS fecha_primera_actuada, 
         MAX(p.fecha_emision) AS fecha_ultima_actuada
     FROM 
         peliculas p
     JOIN 
         pelicula_reparto pr ON p.id = pr.pelicula
     JOIN 
         personas per ON per.id = pr.persona
     GROUP BY 
         per.id) act ON dir.id = act.id
ORDER BY 
    (dir.num_peliculas_dirigidas * act.num_peliculas_actuadas) DESC;


-- E5
SELECT 
    g.nombre AS "Nombre del Género",
    CAST(AVG(p.popularidad) AS DECIMAL(10,2)) AS "Popularidad Media",
    SUM(p.ingresos - p.presupuesto) AS "Beneficios Totales",
    CAST(AVG(p.ingresos - p.presupuesto) AS DECIMAL(20,2)) AS "Beneficios Medios Por Película",
    (SELECT 
        p_int.titulo
     FROM 
        peliculas p_int
     JOIN 
        pelicula_genero pg_int ON p_int.id = pg_int.pelicula
     WHERE 
        pg_int.genero = g.id
     ORDER BY 
        (p_int.ingresos - p_int.presupuesto) DESC
     LIMIT 1) AS "Película con Máximos Beneficios",
    (SELECT 
        per.nombre
     FROM 
        personas per
     JOIN 
        pelicula_reparto pr ON per.id = pr.persona
     JOIN 
        peliculas p_act ON p_act.id = pr.pelicula
     JOIN 
        pelicula_genero pg_act ON p_act.id = pg_act.pelicula
     WHERE 
        pg_act.genero = g.id AND pr.orden <= 5
     ORDER BY 
        (p_act.ingresos - p_act.presupuesto) DESC
     LIMIT 1) AS "Actor/Actriz con Más Beneficios",
    (SELECT 
        per.nombre
     FROM 
        personas per
     JOIN 
        pelicula_personal pp ON per.id = pp.persona
     JOIN 
        peliculas p_dir ON p_dir.id = pp.pelicula
     JOIN 
        pelicula_genero pg_dir ON p_dir.id = pg_dir.pelicula
     WHERE 
        pg_dir.genero = g.id AND pp.trabajo = 'Director'
     ORDER BY 
        (p_dir.ingresos - p_dir.presupuesto) DESC
     LIMIT 1) AS "Director con Más Beneficios"
FROM 
    peliculas p
JOIN 
    pelicula_genero pg ON p.id = pg.pelicula
JOIN 
    generos g ON g.id = pg.genero
GROUP BY 
    g.id
ORDER BY 
    "Popularidad Media" DESC;
