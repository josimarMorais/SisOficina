/*==============================================================================
                    CRIAÇÃO/ALTERAÇÃO DAS PROCEDURES
================================================================================*/

--CADASTRAR UM NOVO CLIENTE
set term ^ ;

create or alter procedure cadastrar_cliente (
    p_nome             dm_nome,
    p_cpf              dm_cpf,
    p_cep              dm_cep,
    p_logradouro       dm_logradouro,
    p_numero           varchar(7),
    p_bairro           dm_bairro,
    p_cidade           dm_cidade,
    p_uf               dm_uf,
    p_complemento      varchar(40),
    p_telefone         dm_telefone,
    p_whatsapp         dm_sim_nao,
    p_data_nascimento  date,
    p_email            dm_email
)
returns (
    cod_cliente dm_codigo
)
as
begin
    /* Valida o nome */
    if (p_nome is null or trim(p_nome) = '') then
        exception ex_cli_nome_invalido;

    /* Valida o CPF */
    if (p_cpf is null or trim(p_cpf) = '') then
        exception ex_cli_cpf_invalido;

    /* Verifica se o CPF já está cadastrado */
    if (exists(select 1 from cliente where cpf = :p_cpf)) then
        exception ex_cli_cpf_duplicado;

    /* Valida a UF */
    if (p_uf is null or char_length(trim(p_uf)) <> 2) then
        exception ex_cli_uf_invalida;

    insert into cliente (nome, cpf, cep, logradouro, numero, bairro, cidade,
        uf, complemento, telefone, whatsapp, data_nascimento, email, ativo)
    values (trim(:p_nome), trim(:p_cpf), trim(:p_cep), trim(:p_logradouro),
        trim(:p_numero), trim(:p_bairro), trim(:p_cidade), upper(trim(:p_uf)),
        trim(:p_complemento), trim(:p_telefone), :p_whatsapp, :p_data_nascimento,
        trim(:p_email), 'S')
    returning codigo
    into :cod_cliente;
end^
set term ; ^










--ALTERAR UM CADASTRO DE UM CLIENTE:
set term ^ ;
create or alter procedure alterar_cliente (
    p_codigo           dm_codigo,
    p_nome             dm_nome,
    p_cpf              dm_cpf,
    p_cep              dm_cep,
    p_logradouro       dm_logradouro,
    p_numero           varchar(7),
    p_bairro           dm_bairro,
    p_cidade           dm_cidade,
    p_uf               dm_uf,
    p_complemento      varchar(40),
    p_telefone         dm_telefone,
    p_whatsapp         dm_sim_nao,
    p_data_nascimento  date,
    p_email            dm_email
)
as
begin
    /* Verifica se o cliente existe */
    if (not exists(select 1 from cliente where codigo = :p_codigo )) then
        exception ex_cli_nao_encontrado;

    /* Valida o nome */
    if (p_nome is null or trim(p_nome) = '') then
        exception ex_cli_nome_invalido;

    /* Valida o CPF */
    if (p_cpf is null or trim(p_cpf) = '') then
        exception ex_cli_cpf_invalido;

    /* Verifica se o CPF pertence a outro cliente */
    if (exists(select 1 from cliente where cpf = :p_cpf and codigo <> :p_codigo)) then
        exception ex_cli_cpf_duplicado;

    /* Valida a UF */
    if (p_uf is null or char_length(trim(p_uf)) <> 2) then
        exception ex_cli_uf_invalida;

    update cliente
    set nome = trim(:p_nome),
        cpf = trim(:p_cpf),
        cep = trim(:p_cep),
        logradouro = trim(:p_logradouro),
        numero = trim(:p_numero),
        bairro = trim(:p_bairro),
        cidade = trim(:p_cidade),
        uf = upper(trim(:p_uf)),
        complemento = trim(:p_complemento),
        telefone = trim(:p_telefone),
        whatsapp = :p_whatsapp,
        data_nascimento = :p_data_nascimento,
        email = trim(:p_email)
    where codigo = :p_codigo;
end^
set term ; ^









--INATIVAR UM CLIENTE: 
set term ^ ;
create or alter procedure inativar_cliente (
    p_codigo dm_codigo
)
as
declare variable v_ativo dm_sim_nao;
begin
    /* Verifica se o cliente existe e carrega sua situação */
    select ativo from cliente where codigo = :p_codigo
    into :v_ativo;

    if (row_count = 0) then
        exception ex_cli_nao_encontrado;

    /* Verifica se já está inativo */
    if (v_ativo = 'N') then
        exception ex_cli_ja_inativo;

    /* Verifica se possui ordem de serviço aberta */
    if (exists( select 1 from ordem_servico os where os.cod_cliente = :p_codigo
          and os.cod_status = 1)) then
            exception ex_cli_ordem_aberta;

    update cliente set ativo = 'N' where codigo = :p_codigo;
end^
set term ; ^










--REATIVAR UM CLIENTE:
set term ^ ;
create or alter procedure reativar_cliente(
        p_codigo dm_codigo
)
 as 
 begin
    update cliente set ativo = 'S' where codigo = :p_codigo and ativo = 'N';
    
    if (row_count = 0) then
    begin
        if(exists(select 1 from cliente where codigo = :p_codigo))then
            exception ex_cli_ja_ativo;
        else
            exception exc_cliente_nao_encontrado;
    end
 end^
set term ; ^










-- ABRIR UMA NOVA ORDEM DE SERVIÇO:
set term ^ ;
create or alter procedure abrir_ordem_servico
(nCod_cliente dm_codigo, nCod_veiculo dm_codigo, nKm_entrada dm_km, sDefeito_Relatado dm_texto_longo)

returns
    (nCod_Ordem dm_codigo)
as 
    begin
        if(not exists(select 1 from cliente where codigo = :nCod_cliente)) then
            exception exc_cliente_nao_encontrado;
        
        if(not exists(select 1 from veiculo where codigo = :nCod_veiculo)) then
            exception exc_veiculo_nao_encontrado;
        
        if(not exists( select 1 from veiculo 
            where cod_cliente = :nCod_cliente and codigo = :nCod_veiculo)) then
            exception exc_veiculo_cliente;
        
        insert into ordem_servico(cod_cliente, cod_veiculo, cod_status, km_entrada, defeito_relatado)
        values(:nCod_cliente, :nCod_veiculo, 1, :nKm_entrada, :sDefeito_relatado)
        returning codigo into :nCod_ordem; 
        
    end^
set term ; ^











-- ADICIONAR UM NOVO SERVIÇO A ORDEM DE SERVIÇO:
set term ^ ; 
create or alter procedure adicionar_servico_ordem( 
    nCod_ordem dm_codigo, nCod_servico dm_codigo, nQuantidade dm_quantidade, 
    sObservacao dm_texto_longo
)returns(
nCod_item dm_codigo
) as 
        declare variable vCod_status dm_codigo; 
        declare variable vValor_servico dm_valor; 
    begin 
        if(not exists(select 1 from ordem_servico where codigo = :nCod_ordem)) then 
        exception exc_ordem_nao_encontrada;
        
        if(not exists(select 1 from servico where codigo = :nCod_servico)) then 
            exception exc_servico_nao_encontrado; 
        
        if(exists(select 1 from servico where codigo = :nCod_servico and ativo = 'N')) then 
            exception exc_servico_inativo; 
        
        select cod_status from ordem_servico where codigo = :nCod_ordem into :vCod_status; 
        
        if(vCod_status in(4, 5)) then 
            exception exc_ordem_encerrada; 
        
        select valor from servico where codigo = :nCod_servico 
            into :vValor_servico;
        
        insert into item_servico( cod_ordem_servico, cod_servico, quantidade, valor_unitario, observacao) 
            values(:nCod_ordem, :nCod_servico, :nQuantidade, :vValor_servico, :sObservacao)
            returning codigo into :nCod_item; 
    end^
set term ; ^











--ADICIONAR UMA NOVA PEÇA A ORDEM DE SERVIÇO:
set term ^ ;
create or alter procedure adicionar_peca_ordem (
    nCod_ordem dm_codigo, nCod_peca dm_codigo, nQuantidade dm_quantidade,
    nDesconto_percentual dm_percentual, sObservacao dm_texto_longo
) returns (
    nCod_item dm_codigo
)
as
    declare variable vCod_status dm_codigo;
    declare variable vValor_peca dm_valor;
    declare variable vEstoque dm_quantidade;
    declare variable vAtivo dm_sim_nao;
    declare variable vDesconto dm_percentual;
begin
    /* Valida a existência da ordem */
    if (not exists(select 1 from ordem_servico where codigo = :nCod_ordem)) then
        exception exc_ordem_nao_encontrada;

    /* Valida a existência da peça */
    if (not exists(select 1 from peca where codigo = :nCod_peca)) then
        exception exc_peca_nao_encontrada;

    /* Busca o status atual da ordem */
    select cod_status from ordem_servico where codigo = :nCod_ordem into :vCod_status;

    /* Impede alterações em ordem finalizada ou cancelada */
    if (vCod_status in (4, 5)) then
        exception exc_ordem_encerrada;

    /* Busca os dados atuais da peça */
    select valor_venda, estoque, ativo from peca where codigo = :nCod_peca
    into :vValor_peca, :vEstoque, :vAtivo;

    /* Valida se a peça está ativa */
    if (vAtivo = 'N') then
        exception exc_peca_inativa;

    /* Valida o estoque */
    if (vEstoque < nQuantidade) then
        exception exc_estoque_insuficiente;

    /* Caso o desconto não seja informado, considera zero */
    vDesconto = coalesce(nDesconto_percentual, 0);

    /* Insere a peça na ordem */
    insert into item_peca (cod_ordem_servico, cod_peca, quantidade, valor_unitario,
        desconto_percentual, observacao)
    values(:nCod_ordem, :nCod_peca, :nQuantidade, :vValor_peca, :vDesconto, :sObservacao)
    returning codigo into :nCod_item;

    /* Realiza a baixa do estoque */
    update peca set estoque = estoque - :nQuantidade where codigo = :nCod_peca;
end^
set term ; ^










--CALCULAR O VALOR TOTAL DA ORDEM DE SERVIÇO:
set term ^ ;
create or alter procedure calcular_total_ordem
(
    nCod_ordem dm_codigo
)
returns
(
    nValor_total_servicos dm_valor,
    nValor_total_pecas dm_valor,
    nValor_total_geral dm_valor,
    nQuantidade_total_pecas dm_quantidade
)
as
begin
    /* Valida se a Ordem de Serviço informada existe */
    if (not exists(select 1 from ordem_servico
        where codigo = :nCod_ordem)) then
        exception exc_ordem_nao_encontrada;


     /* Calcula o valor total dos serviços da Ordem de Serviço */
    select coalesce(
        sum(quantidade * valor_unitario),0)
    from item_servico
    where cod_ordem_servico = :nCod_ordem
    into :nValor_total_servicos;


    /* Calcula o valor total das peças, considerando o desconto individual de cada item */
    select coalesce(sum((quantidade * valor_unitario) -
    ((quantidade * valor_unitario) * desconto_percentual / 100)), 0)
    from item_peca
    where cod_ordem_servico = :nCod_ordem
    into :nValor_total_pecas;
    
    
    /* Calcula a quantidade total de peças utilizadas na Ordem de Serviço */
    select coalesce(sum(quantidade),0)
    from item_peca
    where cod_ordem_servico = :nCod_ordem
    into :nQuantidade_total_pecas;

    
    /* Calcula o valor total geral da Ordem de Serviço */
    nValor_total_geral = nValor_total_servicos + nValor_total_pecas;
end^
set term ; ^










-- ATUALIZAR O VALOR_TOTAL DA ORDEM DE SERVICO:
set term ^ ;
create or alter procedure atualizar_total_ordem
(
    nCod_ordem dm_codigo
)
returns
(
    nValor_total dm_valor
)
as
    declare variable vValor_servicos dm_valor;
    declare variable vValor_pecas dm_valor;
    declare variable vQuantidade_total_pecas dm_quantidade;
begin
    /* Valida se a Ordem de Serviço existe */
    if (not exists(
        select 1
        from ordem_servico
        where codigo = :nCod_ordem
    )) then
        exception exc_ordem_nao_encontrada;

    /* Calcula os totais atuais da Ordem de Serviço */
    execute procedure calcular_total_ordem(:nCod_ordem)
    returning_values
        :vValor_servicos,
        :vValor_pecas,
        :nValor_total,
        :vQuantidade_total_pecas;

    /* Grava o valor total calculado na Ordem de Serviço */
    update ordem_servico
    set valor_total = :nValor_total
    where codigo = :nCod_ordem;
end^
set term ; ^










-- FECHAR ORDEM DE SERVIÇO:
set term ^ ;
create or alter procedure fechar_ordem_servico
(
    nCod_ordem dm_codigo
)
returns
(
    nValor_total dm_valor
)
as
begin
    /* Valida se a Ordem de Serviço existe */
    if (not exists(
        select 1
        from ordem_servico
        where codigo = :nCod_ordem
    )) then
        exception exc_ordem_nao_encontrada;

    /* Impede o fechamento de uma ordem já finalizada ou cancelada */
    if (exists(
        select 1
        from ordem_servico
        where codigo = :nCod_ordem
          and cod_status in (4, 5)
    )) then
        exception exc_ordem_encerrada;

    /* Atualiza e retorna o valor total da Ordem de Serviço */
    execute procedure atualizar_total_ordem(:nCod_ordem)
    returning_values :nValor_total;

    /* Finaliza a Ordem de Serviço */
    update ordem_servico
    set
        cod_status = 4,
        data_fechamento = current_date
    where codigo = :nCod_ordem;
end^
set term ; ^










-- FECHAR ORDEM DE SERVIÇO:
set term ^ ;
    create or alter procedure cancelar_ordem_servico(
    nCod_ordem dm_codigo
)
as 
        declare variable vCod_peca dm_codigo;
        declare variable vQuantidade dm_quantidade;
        
    begin
        /* Valida se a Ordem de Serviço existe */
        if (not exists(select 1 from ordem_servico where codigo = :nCod_ordem)) then
            exception exc_ordem_nao_encontrada;

        /* Impede cancelar uma ordem que já está cancelada */
        if (exists(select 1 from ordem_servico where codigo = :nCod_ordem and cod_status = 5)) then
            exception exc_ordem_encerrada;

        /* Impede cancelar uma ordem já finalizada */
        if (exists(select 1 from ordem_servico where codigo = :nCod_ordem and cod_status = 4)) then
            exception exc_ordem_encerrada;
        
        for
            select cod_peca, quantidade from item_peca where cod_ordem_servico = :nCod_ordem
            into :vCod_peca, :vQuantidade
        do
         begin
            /* Devolve a quantidade da peça ao estoque */
            update peca set estoque = estoque + :vQuantidade
            where codigo = :vCod_peca;
         end
         
         
         /* Cancela a Ordem de Serviço e limpa os dados de fechamento */
        update ordem_servico
        set cod_status = 5, data_fechamento = null, valor_total = null
        where codigo = :nCod_ordem;
    
    end^
set term ; ^










-- REABRIR UMA ORDEM DE SERVIÇO (EPENAS ORDENS CANCELADAS):
set term ^ ;
create or alter procedure reabrir_ordem_servico(
    nCod_ordem dm_codigo
 )
as
        declare variable vCod_peca dm_codigo;
        declare variable vQuantidade dm_quantidade;
        declare variable vEstoque dm_quantidade;
    begin

        /* Valida se a Ordem de Serviço existe */
        if (not exists(select 1 from ordem_servico where codigo = :nCod_ordem)) then
            exception exc_ordem_nao_encontrada;


        /* Permite reabrir somente ordens canceladas */
        if (not exists(select 1 from ordem_servico where codigo = :nCod_ordem and cod_status = 5)) then
            exception exc_ordem_nao_cancelada;

            
        /* Percorre todas as peças da Ordem de Serviço */
    for
        select ip.cod_peca, ip.quantidade, p.estoque
        from item_peca ip
        inner join peca p
        on p.codigo = ip.cod_peca
        where ip.cod_ordem_servico = :nCod_ordem
        into :vCod_peca, :vQuantidade, :vEstoque
    do
     begin
        /* Valida se existe estoque suficiente para reabrir a ordem */
        if (vEstoque < vQuantidade) then
            exception exc_estoque_insuficiente;
     end
     
     
     /* Percorre novamente as peças para realizar a baixa do estoque */
    for
        select cod_peca, quantidade
        from item_peca
        where cod_ordem_servico = :nCod_ordem
        into :vCod_peca, :vQuantidade
    do
     begin
        /* Baixa novamente as peças utilizadas na ordem */
        update peca
        set estoque = estoque - :vQuantidade
        where codigo = :vCod_peca;
     end
     
     
     /* Reabre a Ordem de Serviço */
    update ordem_servico
    set cod_status = 1, data_fechamento = null, valor_total = null 
    where codigo = :nCod_ordem;
     
    end^
set term ; ^










-- REFAZER UMA ORDEM DE SERVIÇO COMO GARANTIA:
set term ^ ;
create or alter procedure refazer_ordem_garantia
(
    nCod_ordem_original dm_codigo,
    nKm_entrada dm_km
)
returns
(
    nCod_nova_ordem dm_codigo
)
as
    declare variable vCod_cliente dm_codigo;
    declare variable vCod_veiculo dm_codigo;
    declare variable vCod_peca dm_codigo;
    declare variable vDefeito dm_texto_longo;
    declare variable vQuantidade dm_quantidade;
    declare variable vEstoque dm_quantidade;
begin
    
    /* Valida se a ordem original existe */
    if (not exists(select 1 from ordem_servico where codigo = :nCod_ordem_original)) then
        exception exc_ordem_nao_encontrada;
        
    /* Permite refazer somente ordens finalizadas */
    if (not exists(select 1 from ordem_servico 
    where codigo = :nCod_ordem_original and cod_status = 4)) then
        exception exc_ordem_nao_finalizada;
        
    /* Busca o cliente e o veículo da ordem original */
    select cod_cliente, cod_veiculo, defeito_relatado from ordem_servico 
    where codigo = :nCod_ordem_original
    into :vCod_cliente, :vCod_veiculo, :vDefeito;
    
    /* Cria uma nova Ordem de Serviço baseada na ordem original */
    insert into ordem_servico( cod_cliente, cod_veiculo, cod_status, km_entrada,
    defeito_relatado, observacao, tipo_ordem, cod_ordem_origem)
    values(:vCod_cliente, :vCod_veiculo,1,:nKm_entrada, :vDefeito, 
    'Ordem refeita a partir da OS ' || :nCod_ordem_original, 'G', :nCod_ordem_original)
    returning codigo 
    into :nCod_nova_ordem;
    
    /* Copia os serviços da ordem original para a nova ordem */
    insert into item_servico(cod_ordem_servico, cod_servico, quantidade,
    valor_unitario, data_execucao, observacao) 
    select :nCod_nova_ordem, cod_servico, quantidade, 0,null, observacao
    from item_servico 
    where cod_ordem_servico = :nCod_ordem_original;
    
    /* Valida se existe estoque suficiente para todas as peças da ordem original */
    for
        select ip.cod_peca, ip.quantidade, p.estoque
        from item_peca ip inner join peca p
        on p.codigo = ip.cod_peca
        where ip.cod_ordem_servico = :nCod_ordem_original
        into :vCod_peca, :vQuantidade, :vEstoque
    do
     begin
        if (vEstoque < vQuantidade) then
            exception exc_estoque_insuficiente;
     end
    
    /* Copia as peças da ordem original para a nova ordem */
    insert into item_peca(cod_ordem_servico, cod_peca, quantidade, valor_unitario,
    desconto_percentual, observacao)
    select :nCod_nova_ordem, cod_peca, quantidade, 0,
    0, observacao
    from item_peca
    where cod_ordem_servico = :nCod_ordem_original;
    
    /* Percorre as peças da ordem original para realizar a baixa no estoque */
    for
        select cod_peca, quantidade 
        from item_peca
        where cod_ordem_servico = :nCod_ordem_original
        into :vCod_peca, :vQuantidade
    do
     begin
        /* Baixa novamente as peças utilizadas na nova ordem */
        update peca
        set estoque = estoque - :vQuantidade
        where codigo = :vCod_peca;
     end
end^
set term ; ^










-- DUPLICAR UMA ORDEM DE SERVIÇO:
set term ^ ;
create or alter procedure duplicar_ordem_servico
(
    nCod_ordem_original dm_codigo,
    nKm_entrada dm_km
)
returns
(
    nCod_nova_ordem dm_codigo
)
as
    declare variable vCod_cliente dm_codigo;
    declare variable vCod_veiculo dm_codigo;
    declare variable vCod_peca dm_codigo;
    declare variable vDefeito dm_texto_longo;
    declare variable vQuantidade dm_quantidade;
    declare variable vEstoque dm_quantidade;
begin
    
    /* Valida se a ordem original existe */
    if (not exists(select 1 from ordem_servico where codigo = :nCod_ordem_original)) then
        exception exc_ordem_nao_encontrada;
        
    /* Permite duplicar somente ordens finalizadas */
    if (not exists(select 1 from ordem_servico 
    where codigo = :nCod_ordem_original and cod_status = 4)) then
        exception exc_ordem_nao_finalizada;
        
    /* Busca o cliente e o veículo da ordem original */
    select cod_cliente, cod_veiculo, defeito_relatado from ordem_servico 
    where codigo = :nCod_ordem_original
    into :vCod_cliente, :vCod_veiculo, :vDefeito;
    
    /* Cria uma nova Ordem de Serviço baseada na ordem original */
    insert into ordem_servico( cod_cliente, cod_veiculo, cod_status, km_entrada,
    defeito_relatado, observacao, tipo_ordem, cod_ordem_origem)
    values(:vCod_cliente, :vCod_veiculo,1,:nKm_entrada, :vDefeito, 
    'Ordem duplicada a partir da OS ' || :nCod_ordem_original, 'D', :nCod_ordem_original)
    returning codigo 
    into :nCod_nova_ordem;
    
    /* Copia os serviços da ordem original para a nova ordem */
    insert into item_servico(cod_ordem_servico, cod_servico, quantidade,
    valor_unitario, data_execucao, observacao) 
    select :nCod_nova_ordem, iserv.cod_servico, iserv.quantidade, s.valor, null, iserv.observacao
    from item_servico iserv
    inner join servico s 
    on s.codigo = iserv.cod_servico 
    where iserv.cod_ordem_servico = :nCod_ordem_original;
    
    /* Valida se existe estoque suficiente para todas as peças da ordem original */
    for
        select ip.cod_peca, ip.quantidade, p.estoque
        from item_peca ip inner join peca p
        on p.codigo = ip.cod_peca
        where ip.cod_ordem_servico = :nCod_ordem_original
        into :vCod_peca, :vQuantidade, :vEstoque
    do
     begin
        if (vEstoque < vQuantidade) then
            exception exc_estoque_insuficiente;
     end
    
    /* Copia as peças da ordem original para a nova ordem */
    insert into item_peca(cod_ordem_servico, cod_peca, quantidade, valor_unitario,
    desconto_percentual, observacao)
    select :nCod_nova_ordem, ip.cod_peca, ip.quantidade, p.valor_venda, 0, ip.observacao
    from item_peca ip
    inner join peca p
    on p.codigo = ip.cod_peca
    where ip.cod_ordem_servico = :nCod_ordem_original;
    
    /* Percorre as peças da ordem original para realizar a baixa no estoque */
    for
        select cod_peca, quantidade 
        from item_peca
        where cod_ordem_servico = :nCod_ordem_original
        into :vCod_peca, :vQuantidade
    do
     begin
        /* Baixa novamente as peças utilizadas na nova ordem */
        update peca
        set estoque = estoque - :vQuantidade
        where codigo = :vCod_peca;
     end
end^
set term ; ^










-- CADASTRAR UM NOVO VEÍCULO:
set term ^ ;
create or alter procedure cadastrar_veiculo(
    p_cod_cliente    dm_codigo,
    p_placa          dm_placa,
    p_marca          dm_marca,
    p_modelo         dm_modelo,
    p_ano_fabricacao dm_ano,
    p_cor            varchar(30)
)
as
begin

    -- Verifica se o cliente existe
    if (not exists(select 1 from cliente where codigo = :p_cod_cliente)) then
        exception exc_cliente_nao_encontrado;

    -- Verifica se o cliente está ativo
    if (exists(select 1 from cliente where codigo = :p_cod_cliente and ativo = 'N')) then
        exception ex_vei_cliente_inativo;

    -- Verifica se a placa é nula
    if (p_placa is null) then
        exception ex_vei_placa_invalida;

    -- Verifica se a placa está vazia
    if (trim(p_placa) = '') then
        exception ex_vei_placa_invalida;

    -- Verifica o tamanho da placa
    if (char_length(trim(p_placa)) <> 7) then
        exception ex_vei_placa_invalida;

    -- Posições 1, 2 e 3 devem ser letras
    if (position(substring(upper(p_placa) from 1 for 1) in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0) then
        exception ex_vei_placa_invalida;

    if (position(substring(upper(p_placa) from 2 for 1) in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0) then
        exception ex_vei_placa_invalida;

    if (position(substring(upper(p_placa) from 3 for 1) in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0) then
        exception ex_vei_placa_invalida;

    -- Posição 4 deve ser número
    if (position(substring(p_placa from 4 for 1) in '0123456789') = 0) then
        exception ex_vei_placa_invalida;

    -- Posição 5 pode ser letra ou número
    if (position(substring(upper(p_placa) from 5 for 1) in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') = 0) then
        exception ex_vei_placa_invalida;

    -- Posições 6 e 7 devem ser números
    if (position(substring(p_placa from 6 for 1) in '0123456789') = 0) then
        exception ex_vei_placa_invalida;

    if (position(substring(p_placa from 7 for 1) in '0123456789') = 0) then
        exception ex_vei_placa_invalida;

    -- Verifica se a placa já existe
    if (exists(select 1 from veiculo where placa = upper(trim(:p_placa)))) then
        exception ex_vei_placa_duplicada;
        
    -- Verifica se a marca é nula
    if (p_marca is null) then
        exception ex_vei_marca_invalida;

    -- Verifica se a marca está vazia
    if (trim(p_marca) = '') then
        exception ex_vei_marca_invalida;
        
    --Verifica se o modelo é nulo
    if (p_modelo is null) then 
        exception ex_vei_modelo_invalido;
    
    --Verifica se o modelo está vazio
    if (trim(p_modelo) =  '') then
        exception ex_vei_modelo_invalido;
    
    -- Verifica se o ano de fabricação é nulo
    if (p_ano_fabricacao is null) then
        exception ex_vei_ano_invalido;
    
    -- Verifica se a cor é nula
    if (p_cor is null) then
        exception ex_vei_cor_invalida;

    -- Verifica se a cor está vazia
    if (trim(p_cor) = '') then
        exception ex_vei_cor_invalida;
    
    
    
    
end^
set term ; ^












