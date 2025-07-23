SELECT pg_get_viewdef('nome_da_view', true);

SELECT pg_get_viewdef('view_total_horas', true);

SELECT pg_get_viewdef('view_total_horas_mes', true);

CREATE VIEW view_total_horas AS
SELECT sum(rp.total_horas) AS total_horas_traba,
    sum(rp.total_horas_extra_dia) AS total_horas_extras,
    rp.nome_ref,
    f.nome,
    f.funcao
   FROM registro_ponto rp
     JOIN funcionario f ON rp.nome_ref = f.id
  GROUP BY rp.nome_ref, f.nome, f.funcao;
| pg_get_viewdef                                                                                                                   |
  
|
| view_total_horas_mes
|
create view view_total_horas_mes as
select
  app_data.nome,
  sum(app_data.hora_extra) as total_horas_extras_mes
from
  app_data
group by
  app_data.nome;


|
|SELECT pg_get_functiondef('update_hours'::regproc);
|
create table public.app_data (
  id bigint generated always as identity not null,
  created_at timestamp with time zone null default now(),
  nome text null,
  horario_inicio time without time zone null,
  horario_saiu time without time zone null,
  hora_total interval null,
  hora_extra interval null,
  constraint app_data_pkey primary key (id)
) TABLESPACE pg_default;

create trigger calculate_hours BEFORE INSERT
or
update on app_data for EACH row
execute FUNCTION update_hours ();


|
| update_hours()
|
CREATE OR REPLACE FUNCTION public.update_hours()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.hora_total := NEW.horario_saiu - NEW.horario_inicio;
    IF NEW.hora_total > interval '8 hours' THEN
        NEW.hora_extra := NEW.hora_total - interval '8 hours';
    ELSE
        NEW.hora_extra := interval '0';
    END IF;
    RETURN NEW;
END;
$function$
