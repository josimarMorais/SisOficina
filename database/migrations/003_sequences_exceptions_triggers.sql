/*==============================================================================
                    CRIAÇÃO DAS SEQUENCES E TRIGGERS
================================================================================*/
create sequence seq_cliente;

set term ^;
create or alter trigger cliente_bi for cliente
active before insert position 0
as 
 begin
    if(new.codigo is null) then 
        new.codigo = gen_id(seq_cliente, 1);
 end^
set term ;^




 
create sequence seq_veiculo;

set term ^;
create or alter trigger veiculo_bi for veiculo
active before insert position 0
as
    begin 
        if(new.codigo is null) then
            new.codigo = gen_id(seq_veiculo, 1);
    end^
set term ;^





create sequence seq_status_ordem;

set term^;
create or alter trigger status_ordem_bi for status_ordem
active before insert position 0
as
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_status_ordem, 1);
    end^
set term ;^





create sequence seq_servico;

set term ^;
create or alter trigger servico_bi for servico
active before insert position 0
as 
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_servico, 1);
    end^
set term ;^





create sequence seq_peca;

set term ^;
create or alter trigger peca_bi for peca
active before insert position 0
as 
    begin 
        if(new.codigo is null) then
            new.codigo = gen_id(seq_peca, 1);
    end^
set term ;^





create sequence seq_ordem_servico;

set term ^;
create or alter trigger ordem_servico_bi for ordem_servico
active before insert position 0
as
    begin
        if(new.codigo is null) then 
            new.codigo = gen_id( seq_ordem_servico, 1);
    end^
set term ;^





create sequence seq_item_servico;

set term ^;
create or alter trigger item_servico_bi for item_servico
active before insert position 0
as 
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_item_servico, 1);
    end^
set term ;^





create sequence seq_item_peca;

set term ^;
create or alter trigger item_peca_bi for item_peca
active before insert position 0
as 
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_item_peca, 1);
    end^
set term ;^






set term ^;
create or alter trigger ordem_servico_biu_validar for ordem_servico
active before insert or update position 1
as
    begin
        if(new.tipo_ordem = 'N') then
            if(new.cod_ordem_origem is not null) then 
                exception exc_ordem_normal;
         
        if ((new.tipo_ordem = 'G') or (new.tipo_ordem = 'D')) then 
            if(new.cod_ordem_origem is null) then 
                exception exc_ordem_origem_obrigatoria;
        
        if(new.cod_ordem_origem = new.codigo) then
            exception exc_ordem_auto_referencia;
        
        if (updating) then
         begin
            if (
                old.tipo_ordem <> new.tipo_ordem
                or (old.cod_ordem_origem is null and new.cod_ordem_origem is not null)
                or (old.cod_ordem_origem is not null and new.cod_ordem_origem is null)
                or (old.cod_ordem_origem <> new.cod_ordem_origem)
                ) then
                    exception exc_ordem_imutavel;
         end
    end^
set term ;^














/*==============================================================================
                    CRIAÇÃO DAS EXPECTION COM AS TRIGGERS
================================================================================*/
create exception exc_veiculo_cliente 'O veículo informado não pertence ao cliente. ';

set term ^;
create or alter trigger ordem_servico_biu for ordem_servico
active before insert or update position 0
as
        declare variable v_cod_cliente dm_codigo;
    begin
        select cod_cliente
        from veiculo
        where codigo = new.cod_veiculo
        into :v_cod_cliente;
        
        if(v_cod_cliente <> new.cod_cliente) then
            exception exc_veiculo_cliente;
        
    end^
set term ;^


create exception exc_estoque_insuficiente 'Estoque insuficiente para a peça informada. ';

set term ^;
create or alter trigger item_peca_biu for item_peca
active before insert or update position 0
as
        declare variable v_estoque dm_quantidade;
    begin
        select estoque
        from peca
        where codigo = new.cod_peca
        into :v_estoque;
        
        if(v_estoque < new.quantidade) then
            exception exc_estoque_insuficiente;
    end^
set term ;^

create exception exc_cliente_nao_encontrado 'Cliente não encontrado.';

create exception exc_veiculo_nao_encontrado 'Veículo não encontrado.';

create exception exc_ordem_nao_encontrada 'Ordem de serviço não encontrada.';

create exception exc_servico_nao_encontrado 'Serviço não encontrado.';

create exception exc_servico_inativo 'O serviço informado está inativo.';

create exception exc_ordem_encerrada 'Não é permitido alterar uma ordem finalizada ou cancelada.';

create exception exc_peca_nao_encontrada 'Peça não encontrada.';

create exception exc_peca_inativa 'A peça informada está inativa.';

create exception exc_ordem_nao_cancelada 'Apenas ordens canceladas podem ser reabertas.';

create exception exc_ordem_nao_finalizada 'Apenas ordens finalizadas podem ser refeitas.';

create exception exc_ordem_normal 'Tipo de ordem de serviço Normal não pode ter origem informada. ';

create exception exc_ordem_origem_obrigatoria 'Tipo de ordem de serviço Garantia ou Duplicidade exige origem informada. ';

create exception exc_ordem_auto_referencia 'Ordem de serviço não pode apontar para si mesma. ';

create exception exc_ordem_imutavel 'O tipo da ordem e sua ordem de origem não podem ser alterados após a criação. ';

create exception ex_cli_nome_invalido 'Informe o nome do cliente';

create exception ex_cli_cpf_invalido 'Informe o CPF do cliente';

create exception ex_cli_cpf_duplicado 'CPF já cadastrado';

create exception ex_cli_uf_invalida 'A UF deve possuir exatamente 2 caracteres';

create exception ex_cli_nao_encontrado 'Cliente não encontrado';

create exception ex_cli_ja_inativo 'Cliente já está inativo';

create exception ex_cli_ordem_aberta 'Cliente possui ordem de serviço aberta';








