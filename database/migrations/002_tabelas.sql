/*==============================================================================
                    CRIAÇÃO DAS TABELAS
================================================================================*/
create table Cliente (
    codigo dm_codigo not null,
    nome dm_nome not null,
    cpf dm_cpf not null,
    cep dm_cep not null,
    logradouro dm_logradouro not null,
    numero varchar(7) not null,
    bairro dm_bairro not null,
    cidade dm_cidade not null,
    uf dm_uf not null,
    complemento varchar(40),
    telefone dm_telefone not null,
    whatsapp dm_sim_nao not null,
    data_nascimento date,
    email dm_email,
    
    constraint pk_cliente primary key(codigo),
    constraint uk_cliente_cpf unique(cpf)
);


create table Veiculo(
    codigo dm_codigo not null,
    cod_cliente dm_codigo not null,
    placa dm_placa not null,
    marca dm_marca not null, 
    modelo dm_modelo not null,
    ano_fabricacao dm_ano not null,
    cor varchar(30) not null,
    
    constraint pk_veiculo primary key(codigo),
    constraint uk_veiculo_placa unique(placa)
);


create table ordem_servico(
    codigo dm_codigo not null,
    cod_veiculo dm_codigo not null,
    cod_cliente dm_codigo not null,
    cod_status dm_codigo not null,
    data_abertura date default current_date not null,
    data_fechamento date,
    km_entrada dm_km not null,
    defeito_relatado dm_texto_longo,
    observacao dm_texto_longo,
    
    constraint pk_ordem_servico primary key(codigo)
);


create table status_ordem(
    codigo dm_codigo not null,
    descricao dm_descricao not null,
    
    constraint pk_status_ordem primary key(codigo),
    constraint uk_status_ordem unique(descricao) 
);


create table servico(
    codigo dm_codigo not null,
    descricao dm_descricao not null,
    valor dm_valor not null,
    tempo_medio_minutos integer not null,
    ativo dm_sim_nao not null,
    
    constraint pk_servico primary key(codigo),
    constraint uk_servico_descricao unique(descricao),
    constraint ck_servico_tempo_medio_minutos check( tempo_medio_minutos > 0)
);


create table item_servico(
    codigo dm_codigo not null,
    cod_ordem_servico dm_codigo not null,
    cod_servico dm_codigo not null,
    quantidade dm_quantidade default 1 not null,
    valor_unitario dm_valor not null,
    data_execucao date,
    observacao dm_texto_longo,
    
    constraint pk_item_servico primary key(codigo),
    constraint uk_item_servico unique(cod_ordem_servico, cod_servico),
    constraint ck_item_servico_quantidade check( quantidade > 0)
);


create table peca(
    codigo dm_codigo not null,
    descricao dm_descricao not null,
    marca dm_marca not null,
    valor_compra dm_valor not null,
    valor_venda dm_valor not null,
    estoque dm_quantidade default 0 not null,
    estoque_minimo dm_quantidade default 0 not null,
    ativo dm_sim_nao default 'S' not null,
    
    constraint pk_peca primary key(codigo),
    constraint uk_peca_descricao unique(descricao)
);


create table item_peca(
    codigo dm_codigo not null,
    cod_ordem_servico dm_codigo not null,
    cod_peca dm_codigo not null,
    quantidade dm_quantidade default 1 not null,
    valor_unitario dm_valor not null,
    desconto_percentual dm_percentual not null,
    observacao dm_texto_longo,
    
    constraint pk_item_peca primary key(codigo),
    constraint uk_item_peca_ordem_servico_peca unique(cod_ordem_servico, cod_peca),
    constraint ck_item_peca_quantidade check(quantidade > 0)
);




/*==============================================================================
                    ALTERAÇÕES NOS ATRIBUTOS DURANTE O DESENVOLVIMENTO
================================================================================*/
--Altera a tabela para que não precise sempre ficar calculando o valor total:
alter table ordem_servico
add valor_total dm_valor;

alter table ordem_servico
add tipo_ordem dm_tipo_ordem, add cod_ordem_origem dm_codigo;

alter table cliente
add ativo dm_sim_nao default 'S' not null;

alter table veiculo
add ativo dm_sim_nao default 'S' not null;



/*==============================================================================
                    CRIAÇÃO DOS RELACIONAMENTOS
================================================================================*/
alter table veiculo
add constraint fk_veiculo_cliente
foreign key (cod_cliente)
references cliente (codigo);


alter table ordem_servico
add constraint fk_ordem_servico_cliente
foreign key (cod_cliente)
references cliente (codigo);


alter table ordem_servico
add constraint fk_ordem_servico_veiculo
foreign key (cod_veiculo)
references veiculo (codigo);


alter table ordem_servico
add constraint fk_ordem_servico_status
foreign key (cod_status)
references status_ordem (codigo);


alter table item_servico
add constraint fk_item_servico_ordem_servico
foreign key (cod_ordem_servico)
references ordem_servico (codigo);


alter table item_servico
add constraint fk_item_servico_servico
foreign key (cod_servico)
references servico (codigo);


alter table item_peca
add constraint fk_item_peca_ordem_servico
foreign key (cod_ordem_servico)
references ordem_servico(codigo);


alter table item_peca 
add constraint fk_item_peca_peca
foreign key (cod_peca)
references peca (codigo);


alter table ordem_servico
add constraint fk_cod_ordem_origem
foreign key(cod_ordem_origem)
references ordem_servico(codigo);







