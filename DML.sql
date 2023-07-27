-- DML (Data Manipulation Language)

----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- INSERTS -----------------------------------------------
----------------------------------------------------------------------------------------------------------------

--------- SUPERMERCADO
INSERT INTO STF_FILIAL_SUPERMERCADO (CNPJ, NOME, UF, LOGRADOURO, CIDADE, NUMERO, CEP) VALUES 
('1234567890123', 'Supermercado Guanabara', 'RJ', 'Rua Leopoldo Bulhões','Rio de Janeiro', 700, '20911300');

--------- FUNCIONARIO
INSERT INTO STF_FUNCIONARIO (NRO_INT_FIL_SUP, NOME, CPF) VALUES
(1, 'Yuri Moura', '98004582778'),
(1, 'Marcos Vinicius da Silva Lopes', '19404582778'),
(1, 'Renan Gonzaga', '33404582666');

--------- CAIXA
INSERT INTO STF_CAIXA (NRO_INT_FIL_SUP, TIPO_ATENDIMENTO) VALUES
(1, 'Prioritário'),
(1, 'Convencional'),
(1, 'Convencional');

--------- CATEGORIA
INSERT INTO STF_CATEGORIA_PRODUTO (CATEGORIA) VALUES 
('Limpeza'),
('Bebidas'),
('Mercearia');

--------- CATALOGO
INSERT INTO STF_CATALOGO (NRO_INT_CAT_PRO, NOME_PRODUTO, CODIGO_DE_BARRAS, QTD_CONTIDA, IND_ISCAIXA) VALUES 
(1, 'PACOTE 10 UNIDADES ARROZ TIO JOÃO TIPO 1 100% GRÃOS NOBRES 1KG', '7532210560391', 10, 'S'),
(2, 'CERVEJA PILSEN LATA 350ML 1 UNIDADE SKOL', '7532210560381', 1, 'N'),
(2, 'FARDO CERVEJA PILSEN LATA 350ML 12 UNIDADE SKOL', '7532210560371', 12, 'S'),
(3, 'PACOTE ARROZ TIO JOÃO TIPO 1 100% GRÃOS NOBRES 1KG', '7532210560361', 1, 'N');

--------- LOTE
INSERT INTO STF_LOTE (NRO_INT_CAT, DT_RECEBIMENTO, VLR_PAGO, DT_VALIDADE, QTD_RECEBIDA, NRO_LOTE, IND_ISALOCADO) VALUES 
(4, '2023-03-01', 350.00, '2024-01-01', 65, '000006', 'N'),
(2, '2023-03-01', 450.00, '2024-01-01', 400, '000002', 'N'),
(3, '2023-03-01', 550.00, '2024-01-01', 50, '000003', 'N'),
(4, '2023-03-01', 650.00, '2024-01-01', 120, '000004', 'N'),
(1, '2023-03-01', 350.00, '2024-01-01', 35, '000005', 'N');

--------- HISTORICO PRECO
INSERT INTO STF_HISTORICO_PRECO (NRO_INT_EST, VLR_VENDA, DT_ALTERACAO, HHMMSS_ALTERACAO) VALUES 
-- Apresentação: Inserir este preço após a function "Atualizar_estoque"
(2, 15, '2023-07-07', '14:00:00');

--------- PAGAMENTO
INSERT INTO STF_PAGAMENTO (FORMA_PAGAMENTO, BANDEIRA, INSTITUICAO_FINANCEIRA) VALUES 
('CARTÃO DE CRÉDITO', 'VISA', 'ITAÚ'),
('CARTÃO DE DÉBITO', 'VISA', 'ITAÚ'),
('PIX', null, 'ITAÚ'),
('TICKET ALIMENTAÇÃO', 'MASTERCAD', 'SODEXO');


----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- SELECTS -----------------------------------------------
----------------------------------------------------------------------------------------------------------------


----------------- CATALOGO, ESTOQUE E HISTORICO_PRECO 

SELECT c.nome_produto, c.qtd_contida, e.qtd_disponivel, h.vlr_venda, h.dt_alteracao
FROM stf_catalogo AS c
INNER JOIN stf_estoque AS e ON c.nro_int_cat = e.nro_int_cat
INNER JOIN stf_historico_preco AS h ON e.nro_int_est = h.nro_int_est
WHERE h.dt_alteracao <= CURRENT_DATE
ORDER BY h.dt_alteracao DESC;


----------------- SUPERMERCADO
SELECT * FROM stf_filial_supermercado;

----------------- FUNCIONARIO
SELECT * FROM stf_funcionario;

----------------- CAIXA
SELECT * FROM stf_caixa;

----------------- CATEGORIA
SELECT * FROM stf_categoria_produto;

----------------- CONTROLE CAIXA
SELECT * FROM stf_controle_caixa;

----------------- CATALOGO
SELECT * FROM stf_catalogo;

----------------- ESTOQUE
SELECT * FROM stf_estoque;

----------------- LOTE
SELECT * FROM stf_lote;

----------------- HISTORICO PRECO
select * from stf_historico_preco;

----------------- CONTROLE CAIXA
select * from stf_controle_caixa;

----------------- PAGAMENTO
select * from stf_pagamento;

----------------- PRODUTO VENDA
select * from stf_produto_venda;

----------------- VENDA
select * from stf_venda;