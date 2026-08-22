/*==============================================================================
                    INSERÇÃO DOS CLIENTES
================================================================================*/
insert into cliente
(nome, cpf, cep, logradouro, numero, bairro, cidade, uf, complemento, telefone, whatsapp, data_nascimento, email, ativo)
values
('João da Silva', '12345678901', '74000000', 'Rua das Flores', '100', 'Centro', 'Goiânia', 'GO', 'Casa', '62999999999',
 'S', '1990-05-15', 'joao@email.com', 'S');
 
insert into cliente
(nome, cpf, cep, logradouro, numero, bairro, cidade, uf, complemento, telefone, whatsapp, data_nascimento, email, ativo)
values
('Maria Oliveira', '98765432100', '74800000', 'Avenida Central', '250', 'Setor Oeste', 'Goiânia', 'GO',
 'Apto 12', '62988887777', 'S', '1985-11-20', 'maria@email.com', 'S');


insert into cliente
(nome, cpf, cep, logradouro, numero, bairro, cidade, uf, complemento, telefone, whatsapp, data_nascimento, email, ativo)
values
('Carlos Souza', '45678912300', '74900000', 'Rua das Palmeiras', '45', 'Jardim América', 'Goiânia', 'GO',
 'Casa 2', '62977776666', 'N', '1978-03-10', 'carlos@email.com', 'N');
 
 
 /*==============================================================================
                    INSERÇÃO DOS VEÍCULOS
================================================================================*/
insert into veiculo
(cod_cliente, placa, marca, modelo, ano_fabricacao, cor, ativo)
select codigo,'ABC1D23','Volkswagen','Gol',2015,'Prata','S'
from cliente where cpf = '12345678901';


insert into veiculo
(cod_cliente, placa, marca, modelo, ano_fabricacao, cor, ativo)
select codigo,'DEF4G56','Chevrolet','Onix',2020,'Branco','S'
from cliente where cpf = '98765432100';

select codigo, nome, ativo
from cliente
order by codigo;