create exception exc_veiculo_cliente 'O veículo informado não pertence ao cliente. ';

create exception exc_estoque_insuficiente 'Estoque insuficiente para a peça informada. ';

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

create exception ex_cli_ja_ativo 'Cliente já está ativo';