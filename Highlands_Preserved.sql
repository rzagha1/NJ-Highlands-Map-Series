drop table if exists municipal_preserved_land;
create table municipal_preserved_land as
SELECT * FROM(
SELECT m.mun,m.county,m.mun_code,COALESCE(q1.co,0) AS county_acres,COALESCE(q2.far,0) AS farmland_acres,
COALESCE(q3.fed,0) AS federal_acres,COALESCE(q4.mun2,0) AS municipal_acres,COALESCE(q5.np,0) AS nonprofit_acres,
COALESCE(q6.prv,0) AS private_acres, COALESCE(q7.st,0) AS state_acres,COALESCE(q8.tdr,0) as tdr_acres,
COALESCE(q9.ws,0) as wsma_acres,COALESCE(q10.hpla,0) as planning_acres,COALESCE(q11.hpra,0) as preservation_acres, m.geom 
	FROM m
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS co
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'COUNTY' group by m.mun,m.county,m.mun_code,os_class) AS q1
					ON m.mun_code= q1.mun_code 
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS far
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'FARMLAND' group by m.mun,m.county,m.mun_code,os_class) AS q2
					ON m.mun_code= q2.mun_code 
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS fed
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'FEDERAL' group by m.mun,m.county,m.mun_code,os_class) AS q3
					ON m.mun_code= q3.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS mun2
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'MUNICIPAL' group by m.mun,m.county,m.mun_code,os_class) AS q4
					ON m.mun_code= q4.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS np
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'NONPROFIT' group by m.mun,m.county,m.mun_code,os_class) AS q5
					ON m.mun_code= q5.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS prv
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'PRIVATE' group by m.mun,m.county,m.mun_code,os_class) AS q6
					ON m.mun_code= q6.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS st
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'STATE' group by m.mun,m.county,m.mun_code,os_class) AS q7
					ON m.mun_code= q7.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS tdr
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'TDR' group by m.mun,m.county,m.mun_code,os_class) AS q8
					ON m.mun_code= q8.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,pl.geom))/43560)::numeric) AS ws
			FROM m JOIN pl ON ST_INTERSECTS(m.geom,pl.geom)
				WHERE os_class = 'WSMA' group by m.mun,m.county,m.mun_code,os_class) AS q9
					ON m.mun_code= q9.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,ppa.geom))/43560)::numeric) AS hpla
			FROM m JOIN ppa ON ST_INTERSECTS(m.geom,ppa.geom)
				WHERE region = 'Highlands Planning Area' group by m.mun,m.county,m.mun_code,region) AS q10
					ON m.mun_code= q10.mun_code
	LEFT JOIN(SELECT m.mun,m.county,m.mun_code,ROUND(SUM(ST_AREA(ST_INTERSECTION(m.geom,ppa.geom))/43560)::numeric) AS hpra
			FROM m JOIN ppa ON ST_INTERSECTS(m.geom,ppa.geom)
				WHERE region = 'Highlands Preservation Area' group by m.mun,m.county,m.mun_code,region) AS q11
					ON m.mun_code= q11.mun_code
	order by county_acres,farmland_acres,federal_acres,municipal_acres,nonprofit_acres,private_acres,state_acres,tdr_acres,wsma_acres desc
	limit 88)t order by t.county,t.mun;

select * from municipal_preserved_land
			


