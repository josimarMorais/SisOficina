set term ^;
create or alter trigger cliente_bi for cliente
active before insert position 0
as 
 begin
    if(new.codigo is null) then 
        new.codigo = gen_id(seq_cliente, 1);
 end^
set term ;^



set term ^;
create or alter trigger veiculo_bi for veiculo
active before insert position 0
as
    begin 
        if(new.codigo is null) then
            new.codigo = gen_id(seq_veiculo, 1);
    end^
set term ;^



set term^;
create or alter trigger status_ordem_bi for status_ordem
active before insert position 0
as
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_status_ordem, 1);
    end^
set term ;^



set term ^;
create or alter trigger servico_bi for servico
active before insert position 0
as 
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_servico, 1);
    end^
set term ;^



set term ^;
create or alter trigger peca_bi for peca
active before insert position 0
as 
    begin 
        if(new.codigo is null) then
            new.codigo = gen_id(seq_peca, 1);
    end^
set term ;^



set term ^;
create or alter trigger ordem_servico_bi for ordem_servico
active before insert position 0
as
    begin
        if(new.codigo is null) then 
            new.codigo = gen_id( seq_ordem_servico, 1);
    end^
set term ;^



set term ^;
create or alter trigger item_servico_bi for item_servico
active before insert position 0
as 
    begin
        if(new.codigo is null) then
            new.codigo = gen_id(seq_item_servico, 1);
    end^
set term ;^



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



