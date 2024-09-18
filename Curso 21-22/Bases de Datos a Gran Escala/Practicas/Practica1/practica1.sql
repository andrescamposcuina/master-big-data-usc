-- Ejercicio 1:

select *
from peliculas as pel
where pel.idioma_original = 'es'
 and pel.ingresos  > 15000000

-- Ejercicio 2:

select titulo, sinopsis, lema 
from peliculas
where titulo like '%Pirate%'
order by presupuesto desc

-- Ejercicio 3:

select titulo
from peliculas
where duracion < 60
order by presupuesto desc 
limit 10

-- Ejercicio 4:

select pel.titulo_original, pr.personaje 
from peliculas pel, pelicula_reparto pr , personas per
where pel.id = pr.pelicula 
  and pr.persona = per.id 
  and per.nombre = 'Penélope Cruz'
order by pel.popularidad  desc

-- Ejercicio 5:

select pel.titulo_original, pel.presupuesto, pel.ingresos 
from peliculas as pel, personas as per, pelicula_personal as pp 
where pel.id = pp.pelicula 
  and per.id = pp.persona 
  and per.nombre = 'Steven Spielberg'
  and pp.trabajo = 'Director'
order by pel.popularidad  desc 

-- Ejercicio 6:

select max(presupuesto) as maximo_presupuesto, 
       min(presupuesto) as minimo_presupuesto,
       cast(avg(presupuesto) as integer) as media_presupuesto,
       max(ingresos) as maximo_ingresos, 
       min(ingresos) as minimo_ingresos,
       cast(avg(ingresos) as integer) as media_ingresos
from peliculas pel, pelicula_pais pp
where pel.id =pp.pelicula 
  and pp.pais ='ES'

-- Ejercicio 7:

select max(pel.ingresos - pel.presupuesto) as maximo_Beneficio, 
       min(pel.ingresos - pel.presupuesto) as minimo_Beneficio,
       avg(pel.ingresos - pel.presupuesto) as media_Beneficio
from peliculas as pel, colecciones as col
where pel.coleccion = col.id
  and col.nombre = 'Star Wars Collection'

-- Ejercicio 8:

select p.titulo, pp.departamento, count(distinct pp.persona) as personas
 from peliculas p, colecciones c, pelicula_personal pp 
where p.coleccion = c.id 
 and p.id =pp.pelicula 
 and c.nombre = 'Star Wars Collection'
group by p.titulo, pp.departamento
order by p.titulo, pp.departamento 

-- Ejercicio 9:

select prod.nombre, 
 count(*) as peliculas, 
 count(distinct pel.idioma_original) as idiomas,
 sum(pel.presupuesto) as presupuesto,
 sum(pel.ingresos) as ingresos,
 sum(pel.ingresos - pel.presupuesto) as beneficios,
 min(pel.fecha_emision) as primeraFecha,
 max(pel.fecha_emision) as ultimaFecha
from peliculas as pel, productoras as prod, pelicula_productora as pp
where pel.id = pp.pelicula 
 and prod.id = pp.productora
group by prod.id
order by count(*) desc
limit 10

-- Ejercicio 10:

select per.nombre, 
 count(pel.id) as peliculas,
 sum(pel.ingresos) as ingresos,
 sum(pel.presupuesto) as presupuesto,
 sum(pel.ingresos - pel.presupuesto) as beneficio,
 count(distinct pel.idioma_original) as num_idiomas,
 string_agg(distinct idioma_original, ',') as idiomas
from peliculas pel, pelicula_personal pp, personas per
where pel.id  = pp.pelicula 
 and per.id  = pp.persona
 and pp.trabajo like 'Director'
group by per.id
having sum(pel.ingresos) > 1500000000
order by beneficio desc

-- Ejercicio 11:

select per.nombre , 
 count(distinct pel.id) as peliculas,
 cast(avg(pel.popularidad) as numeric(4, 2)) as media_popularidad
from peliculas pel, 
 paises as pa, 
 personas as per, 
 pelicula_pais as pp, 
 pelicula_reparto as pr 
where pel.id  = pp.pelicula 
 and pel.id = pr.pelicula
 and pa.id = pp.pais 
 and per.id = pr.persona
 and pa.id = 'ES'
group by per.id
having count(pel.id) > 15
order by media_popularidad desc

-- Ejercicio 12:

select reparto.titulo, reparto.num_reparto, reparto.reparto,
       personal.num_personal, personal.departamentos, personal.trabajos, personal.directores
from
	(select pel.id as id, pel.titulo as titulo, pel.ingresos as ingresos,
	       count(distinct pr.persona) as num_reparto,
	       string_agg(per.nombre,' ,' order by pr.orden) as reparto
	from peliculas pel, pelicula_reparto pr, personas per
	where pel.id =pr.pelicula and pr.persona = per.id 
	group by pel.id, pel.titulo) as reparto,
	(select pel.id as id,
	       count(distinct pp.persona) as num_personal,
	       count(distinct pp.departamento) as departamentos,
	       count(distinct pp.trabajo) as trabajos,
	       string_agg(per.nombre, ' ,' order by per.nombre) filter (where pp.trabajo = 'Director') as directores
	from peliculas pel, pelicula_personal pp, personas per
	where pel.id=pp.pelicula  and pp.persona = per.id 
	group by pel.id) as personal
where reparto.id = personal.id
order by reparto.ingresos desc 
limit 10

-- Ejercicio 13:

select titulo, fecha_emision, sinopsis 
from peliculas pel
where (ingresos - presupuesto) > 1000000000
  and fecha_emision = (select max(fecha_emision) 
                       from peliculas pel1 
                       where (ingresos - presupuesto) > 1000000000

-- Ejercicio 14:

select reparto.titulo, reparto.presupuesto, reparto.ingresos, reparto.reparto, directores.directores
from
	(select pel.id as id,
	  pel.titulo_original as titulo, 
	  pel.presupuesto as presupuesto, 
	  pel.ingresos as ingresos, 
	  string_agg(per.nombre,' ,') as reparto
	 from peliculas as pel, personas as per, pelicula_reparto as pr
	 where pel.id = pr.pelicula 
	  and per.id = pr.persona
	  and pel.id = pr.pelicula 
	  and per.id = pr.persona  
	 group by pel.id ) as reparto,
	(select pel.id as id, 
	  string_agg(per.nombre,' ,') as directores
     from peliculas as pel, personas as per, pelicula_personal as pp2
	 where pel.id = pp2.pelicula 
      and per.id = pp2.persona
      and pp2.trabajo = 'Director'
	 group by pel.id ) as directores
where reparto.id = directores.id
 and reparto.id in (select pel.id
					from peliculas as pel, pelicula_pais as pp
					where pel.id = pp.pelicula
					 and pp.pais = 'ES'
					 and pel.id in (select pel.id
									from peliculas as pel, pelicula_pais as pp 
									where pel.id = pp.pelicula 
									group by pel.id
									having count(*) = 1)
					order by pel.ingresos desc
					limit 10)
order by reparto.ingresos desc

-- Ejercicio 15:

select pel.titulo, pel.fecha_emision, 'Actor: ' || pr.personaje as trabajo
from peliculas as pel, pelicula_reparto as pr , personas as per 
where pel.id = pr.pelicula
 and pr.persona = per.id 
 and per.nombre = 'Quentin Tarantino'
union all
select pel.titulo, pel.fecha_emision, pp.trabajo as trabajo
from peliculas as pel, pelicula_personal as pp , personas as per
where pel.id = pp.pelicula 
 and pp.persona = per.id 
 and per.nombre = 'Quentin Tarantino'
order by fecha_emision, titulo

-- Ejercicio 16:

select titulo, 
 fecha_emision, 
 popularidad, nombre as coleccion
from peliculas natural left outer join colecciones as c(coleccion, nombre)
where extract('year' from fecha_emision) = 2017
order by popularidad desc
limit 20

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

-- tmp ->

select *
from 
   (select tabla3.id_genero, max(tabla3.beneficios)
	from
	   (select per.id as id_actor, 
		 per.nombre as nombre_actor,
		 gen.id as id_genero,
		 gen.nombre as nombre_genero,
		 sum(pel.ingresos - pel.presupuesto) as beneficios
		from peliculas as pel, 
		 generos as gen,
		 personas as per,
		 pelicula_genero as pg,
		 pelicula_reparto as pr 
		where pel.id = pg.pelicula
		 and gen.id = pg.genero 
		 and pel.id = pr.pelicula
		 and per.id = pr.persona
		 and pr.orden < 6
		group by gen.id, per.id) as tabla3
	group by tabla3.id_genero) as tabla4,
   (select per.id as id_actor, 
	 per.nombre as nombre_actor,
	 gen.id as id_genero,
	 gen.nombre as nombre_genero,
	 sum(pel.ingresos - pel.presupuesto) as beneficios
	from peliculas as pel, 
	 generos as gen,
	 personas as per,
	 pelicula_genero as pg,
	 pelicula_reparto as pr 
	where pel.id = pg.pelicula
	 and gen.id = pg.genero 
	 and pel.id = pr.pelicula
	 and per.id = pr.persona
	 and pr.orden < 6
	group by gen.id, per.id) as tabla5
where tabla5.id_genero = tabla4.

-- VERSIÓN FINAL:

-- Para cada género, muestra la popularidad media de sus películas, la suma de beneficios, el beneficio por película medio:

select 
 gen.id as genero_id,
 gen.nombre as genero_nombre,
 cast(avg(pel.popularidad) as decimal(4,2)) as popularidad_media,
 sum(pel.ingresos - pel.presupuesto) as beneficios_totales,
 cast(avg(pel.ingresos - pel.presupuesto) as decimal(20,2)) as beneficios_medios
from 
 peliculas as pel, 
 generos as gen, 
 pelicula_genero as pg 
where 
 pel.id = pg.pelicula
 and gen.id = pg.genero
group by gen.id

-- Para cada género, muestra el título de la película que generó más beneficios:

select 
 gen.id as genero_id,
 gen.nombre as genero_nombre,
 pel.id as id_pelicula,
 pel.titulo as titulo_pelicula
from 
 peliculas as pel, 
 generos as gen, 
 pelicula_genero as pg 
where 
 pel.id = pg.pelicula
 and gen.id = pg.genero
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
													group by gen.id)

-- Unimos los dos resultados anteriores mediante una subconsulta en la clausula SELECT:
-- Para cada género, muestra la popularidad media de sus películas, la suma de beneficios, el beneficio por película medio, el título de la películaque generó más beneficios:

select 
 gen_outer .id as genero_id,
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
													  group by gen.id)) as pelicula_max_beneficios
from 
 peliculas as pel_outer, 
 generos as gen_outer, 
 pelicula_genero as pg_outer 
where 
 pel_outer.id = pg_outer.pelicula
 and gen_outer.id = pg_outer.genero
group by gen_outer.id
order by popularidad_media desc

-- Para cada género, muestra el actor/actriz principal (entre los 5 primeros en orden) que ha generado más beneficios:

select 
 gen_outer.id as genero_id,
 gen_outer.nombre as genero_nombre,
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
  limit 1) as actor_beneficios
from 
 peliculas as pel, 
 generos as gen_outer, 
 pelicula_genero as pg 
where 
 pel.id = pg.pelicula
 and gen_outer.id = pg.genero
group by gen_outer.id

-- Para cada género, muestra el director que ha generado más beneficios:

select 
 gen_outer.id as genero_id,
 gen_outer.nombre as genero_nombre,
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
 peliculas as pel, 
 generos as gen_outer, 
 pelicula_genero as pg 
where 
 pel.id = pg.pelicula
 and gen_outer.id = pg.genero
group by gen_outer.id

-- Consulta final:

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
