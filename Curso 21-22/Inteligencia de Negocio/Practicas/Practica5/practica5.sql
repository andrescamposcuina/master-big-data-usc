-- ROLAP:

-- Ejercicio 1:

select 
 p.nombre as productora, 
 t.ano as ano, 
 t.mes as mes, 
 sum(ingresos-coste) as beneficio
from 
 public.finanzas as f, 
 public.productora as p, 
 public.tiempo as t 
where 
 f.productora = p.id
 and f.tiempo = t.id 
 and p.nombre in ('Paramount Pictures', 'New Line Cinema')
 and t.ano between 2014 and 2016
group by p.id, t.ano, t.mes
order by productora, ano, mes

-- Ejercicio 2:

select 
 p.nombre as productora, 
 t.ano as ano, 
 t.mes as mes, 
 sum(ingresos-coste) as beneficio
from 
 public.finanzas f, 
 public.productora p, 
 public.tiempo t 
where 
 f.productora = p.id
 and f.tiempo = t.id 
 and p.nombre in ('Paramount Pictures', 'New Line Cinema')
 and t.ano between 2014 and 2016
group by rollup (p.nombre, t.ano, t.mes)
order by productora, ano, mes

-- Ejercicio 3:

select 
 p.nombre as productora, 
 t.ano as ano, 
 t.mes as mes, 
 sum(ingresos-coste) as beneficio
from 
 public.finanzas f, 
 public.productora p, 
 public.tiempo t 
where 
 f.productora = p.id
 and f.tiempo = t.id 
 and p.nombre in ('Paramount Pictures', 'New Line Cinema')
 and t.ano between 2014 and 2016
group by cube (p.nombre, t.ano, t.mes)
order by productora, ano, mes

-- Ejercicio 4:

select 
 *, 
 sum(beneficio) 
  over (partition by productora, ano) as beneficio_anual,
 (beneficio / sum(beneficio) 
  over (partition by productora, ano))*100 as porcentaje_beneficio_anual,
 (beneficio / sum(beneficio) 
  over (partition by productora))*100 as porcentaje_beneficio_productora
from beneficio_mensual1

-- Ejercicio 5:

select 
 *, 
 avg(beneficio) 
  over (partition by productora order by ano, mes rows between 1 preceding and 1 following) as beneficio_suavizado
from beneficio_mensual1 

-- Ejercicio 6:

select 
 *, 
 rank() over (order by beneficio desc) as ranking_total,
 rank() over (partition by productora order by beneficio desc) as ranking_productora,
 cume_dist() over (partition by productora order by ano, mes) as percentil,
 beneficio / lag (beneficio, 1, null) over (partition by productora order by ano, mes) as ratio_incremento_beneficio
from beneficio_mensual1 
order by productora, ano, mes

-- Consulta 1:

select 
 d.nombre as director, 
 t.ano as ano, 
 sum(ingresos-coste) as beneficios
from 
 public.finanzas f, 
 public.director d,
 public.tiempo t 
where 
 f.director = d.id
 and f.tiempo = t.id 
group by rollup (d.nombre, t.ano)
order by director, ano

-- Consulta 2:

select 
 p.nombre as productora,
 t.ano as año,
 t.mes as mes,
 avg(su.satisfaccion) as satisfaccion
from 
 public.satisfaccion_usuarios su, 
 public.productora p, 
 public.tiempo t 
where 
 su.productora = p.id
 and su.tiempo_emision = t.id 
 and p.nombre = 'Walt Disney Pictures'
group by cube (p.nombre, t.ano, t.mes)
order by productora, ano, mes

-- Consulta 3:

create view beneficio_director1 as
select
 p.nombre as productora,
 d.nombre as director,
 sum(f.ingresos - f.coste) as beneficios
from 
 director as d,
 productora as p,
 finanzas as f
where
 d.id = f.director
 and p.id = f.productora
 and p.nombre in ('Walt Disney Pictures', 'New Line Cinema')
group by d.nombre, p.nombre 

select 
 *, 
 (beneficios / sum(beneficios) 
  over (partition by productora))*100 as porcentaje_beneficio_director
from beneficio_director1

-- Consulta 4:

create view satisfaccion_mensual1 as
select
 p.nombre as productora,
 t.ano as ano,
 t.mes as mes,
 avg(su.satisfaccion) as satisfaccion
from 
 productora as p,
 tiempo as t,
 satisfaccion_usuarios as su
where
 p.id = su.productora 
 and t.id = su.tiempo_votacion
 and p.nombre in ('Walt Disney Pictures', 'New Line Cinema')
group by p.nombre, t.ano, t.mes

select 
 *, 
 avg(satisfaccion) 
  over (partition by productora order by ano, mes rows between 1 preceding and 1 following) as satisfaccion_suavizada
from satisfaccion_mensual1 

-- Consulta 5:

select 
 *,
 satisfaccion / lag (satisfaccion, 1, null) over (partition by productora order by ano, mes) as ratio_incremento_satisfaccion,
 first_value(satisfaccion) over (partition by productora, ano order by satisfaccion desc) as mejor_valoracion_por_ano,
 first_value(satisfaccion) over (partition by productora, ano order by satisfaccion asc) as peor_valoracion_por_ano,
 rank() over (order by satisfaccion desc) as ranking_total,
 rank() over (partition by productora order by satisfaccion desc) as ranking_productora
from satisfaccion_mensual1 
order by productora, ano, mes 

