-- TABLA PELICULAS:

-- Ejercicio E1:

select 
 titulo, 
 fecha_emision,
 (reparto.persona).nombre as actriz, 
 reparto.personaje as personaje
from 
 peliculas as p, 
 unnest(reparto) as reparto(persona, personaje)
where (reparto.persona).nombre = 'Penélope Cruz'
order by p.fecha_emision asc

-- Ejercicio E2:

select 
 (personal.persona).nombre as nombre_director,
 count(distinct pel.id) as n_peliculas,
 sum(pel.ingresos - pel.presupuesto) as beneficio_total
from 
 peliculas as pel, 
 unnest(personal) as personal(persona, departamento, trabajo)
where personal.trabajo = 'Director'
group by (personal.persona).nombre
order by beneficio_total desc
limit 10

-- TABLA PELICULASXML:

-- Ejercicio E1:

select
 titulo,
 fecha_emision,
 xmlserialize(content (xpath('/miembroreparto/text()', x))[1] as text) as nombre,
 xmlserialize(content (xpath('/miembroreparto/@personaje', x))[1] as text) as personaje
from 
 peliculasxml as pel, 
 unnest(xpath('/reparto/miembroreparto', reparto)) as miembro_reparto(x)
where 
 xmlserialize(content (xpath('/miembroreparto/text()', x))[1] as text) = 'Penélope Cruz'
order by fecha_emision asc

-- Ejercicio E2:

select
 xmlserialize(content (xpath('/trabajador/text()', x))[1] as text) as nombre,
 count(distinct id) as peliculas,
 sum(ingresos - presupuesto) as beneficios
from 
 peliculasxml as pel, 
 unnest(xpath('/personal/trabajador', personal)) as trabajador(x)
where
 xmlserialize(content (xpath('/trabajador/@trabajo', x))[1] as text) = 'Director'
group by nombre
order by beneficios desc
limit 10

-- TABLA PELICULASJSON:

-- Ejercicio E1:

select
 titulo,
 fecha_emision,
 (elemento->'persona')->>'nombre' as nombre, 
 elemento->>'personaje' as personaje
from 
 peliculasjson as pel, 
 jsonb_array_elements(reparto) with ordinality as reparto(elemento)
where 
 (elemento->'persona')->>'nombre' = 'Penélope Cruz'
order by fecha_emision asc

-- Ejercicio E2:

select
 (elemento->'persona')->>'nombre' as nombre,
 count(distinct id) as peliculas,
 sum(ingresos-presupuesto) as beneficios
from 
 peliculasjson as pel, 
 jsonb_array_elements(personal) with ordinality as personal(elemento)
where 
 elemento->>'trabajo' = 'Director'
group by (elemento->'persona')->>'nombre'
order by beneficios desc
limit 10
