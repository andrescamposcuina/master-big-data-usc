-- EJERCICIOS A ENTREGAR:

-- Ejercicio E1:

select pel.titulo, 
 pel.titulo_original, 
 pel.fecha_emision, 
 pel.sinopsis, 
 (pel.ingresos- pel.presupuesto) as beneficios
from peliculas as pel
where pel.idioma_original = 'it'
 and extract(year from pel.fecha_emision) = '1960'
order by (pel.ingresos- pel.presupuesto) desc

-- Ejercicio E2:

select pr.orden, per.nombre, pr.personaje
from peliculas as pel, personas as per, pelicula_reparto as pr
where pel.id = pr.pelicula
 and per.id = pr.persona
 and pel.titulo = 'Titanic'
 and extract(year from pel.fecha_emision) = '1997'
order by pr.orden asc

-- Ejercicio E3:

select pai.id, 
 pai.nombre, 
 count(distinct pel.id) as peliculas, 
 sum(pel.ingresos - pel.presupuesto) as beneficios,
 cast(avg(pel.popularidad) as decimal(4,2)) as media_popularidad
from peliculas as pel, paises as pai, pelicula_pais as pp 
where pel.id = pp.pelicula
 and pai.id = pp.pais
group by pai.id
order by beneficios desc

-- Ejercicio E4:

select dirigidas.id, 
 dirigidas.nombre, 
 dirigidas.peliculas_dirigidas,
 dirigidas.primera_dirigida,
 dirigidas.ultima_dirigida,
 actuadas.peliculas_actuadas,
 actuadas.primera_actuada,
 actuadas.ultima_actuada
from 
   (select per.id as id, 
	 per.nombre as nombre, 
	 count(distinct pel.id) as peliculas_dirigidas, 
	 min(pel.fecha_emision) as primera_dirigida, 
	 max(pel.fecha_emision) as ultima_dirigida
	from peliculas as pel, personas as per, pelicula_personal as pp
	where pel.id = pp.pelicula 
	 and per.id = pp.persona 
	 and pp.trabajo = 'Director'
	group by per.id) as dirigidas,
   (select per.id as id,
	per.nombre as nombre, 
	count(distinct pel.id) as peliculas_actuadas, 
	min(pel.fecha_emision) as primera_actuada, 
	max(pel.fecha_emision) as ultima_actuada
	from peliculas as pel, personas as per, pelicula_reparto as pr
	where pel.id = pr.pelicula 
	 and per.id = pr.persona
	group by per.id) as actuadas
where dirigidas.id = actuadas.id
order by (peliculas_dirigidas * peliculas_actuadas) desc

-- Ejercicio E5:

select
 gen_outer.nombre as genero_nombre,
 cast(avg(pel_outer.popularidad) as decimal(4,2)) as popularidad_media,
 sum(pel_outer.ingresos - pel_outer.presupuesto) as beneficios_totales,
 cast(avg(pel_outer.ingresos - pel_outer.presupuesto) as decimal(20,2)) as beneficios_medios,
 (select 
   pel.titulo
  from 
   peliculas as pel, 
   generos as gen, 
   pelicula_genero as pg 
  where 
   pel.id = pg.pelicula
   and gen.id = pg.genero
   and gen.id = gen_outer.id
   and (gen.id, (pel.ingresos - pel.presupuesto)) in (select 
 													   gen.id,
													   max(pel.ingresos - pel.presupuesto)
													  from 
													   peliculas as pel, 
													   generos as gen, 
													   pelicula_genero as pg 
													  where 
													   pel.id = pg.pelicula
													   and gen.id = pg.genero
													  group by gen.id)) as pelicula_max_beneficios,
 (select actor_nombre
  from
   (select 
     per.nombre as actor_nombre,
     sum(pel.ingresos - pel.presupuesto) as beneficios
    from 
     peliculas as pel, 
     generos as gen,
     personas as per,
     pelicula_genero as pg,
     pelicula_reparto as pr 
    where 
     pel.id = pg.pelicula
     and gen.id = pg.genero 
     and pel.id = pr.pelicula
     and per.id = pr.persona
     and pr.orden < 6
     and gen.id = gen_outer.id
    group by gen.id, per.id) as actor_beneficios_aux
  order by beneficios desc
  limit 1) as actor_beneficios,
   (select director_nombre
  from
   (select 
     per.nombre as director_nombre,
     sum(pel.ingresos - pel.presupuesto) as beneficios
    from 
     peliculas as pel, 
     generos as gen,
     personas as per,
     pelicula_genero as pg,
     pelicula_personal as pp
    where 
     pel.id = pg.pelicula
     and gen.id = pg.genero 
     and pel.id = pp.pelicula
     and per.id = pp.persona
     and pp.trabajo = 'Director'
     and gen.id = gen_outer.id
    group by gen.id, per.id) as director_beneficios_aux
  order by beneficios desc
  limit 1) as director_beneficios
from 
 peliculas as pel_outer, 
 generos as gen_outer, 
 pelicula_genero as pg_outer 
where 
 pel_outer.id = pg_outer.pelicula
 and gen_outer.id = pg_outer.genero
group by gen_outer.id
order by popularidad_media desc


													



