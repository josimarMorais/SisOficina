/*==============================================================================
                               DOMÍNIOS 
================================================================================*/
create domain dm_km as integer check(value >= 0);

create domain dm_quantidade as integer check(value >= 0);

create domain dm_valor as numeric(10,2) check(value >= 0);

create domain dm_codigo as integer check(value > 0);

create domain dm_ano as smallint check (value between 1900 and 2100);

create domain dm_sim_nao as char(1) check(value in('S', 'N'));

create domain dm_nome as varchar(80);

create domain dm_descricao as varchar(100) check(char_length (trim(value)) >=3);

create domain dm_email as varchar(100);

create domain dm_cpf as varchar(14);

create domain dm_placa as varchar(10);

create domain dm_telefone as varchar(20);

create domain dm_cep as varchar(10);

create domain dm_uf as char(2);

create domain dm_logradouro as varchar(60);

create domain dm_bairro as varchar(40);

create domain dm_cidade as varchar(40);

create domain dm_marca as varchar(40);

create domain dm_modelo as varchar(60);

create domain dm_texto_longo as varchar(500);

create domain dm_percentual as numeric(5,2) default 0 check(value between 0 and 100);

create domain dm_tipo_ordem as char(1) default 'N' not null check(value in('N', 'G', 'D'));





