-- DDL (Data Definition Language)

--CREATE TABLE SUPERMERCADO
CREATE TABLE IF NOT EXISTS STF_FILIAL_SUPERMERCADO (
	NRO_INT_FIL_SUP SERIAL PRIMARY KEY,
	CNPJ CHAR(14) NOT NULL UNIQUE,
	NOME VARCHAR(100) NOT NULL,
	UF CHAR(2) NOT NULL,
	LOGRADOURO VARCHAR(45) NOT NULL,
	CIDADE VARCHAR(45) NOT NULL,
	NUMERO INT NOT NULL,
	CEP CHAR(9) NOT NULL
);

--CREATE TABLE FUNCIONARIO
CREATE TABLE IF NOT EXISTS STF_FUNCIONARIO (
	NRO_INT_FUN SERIAL PRIMARY KEY,
	NRO_INT_FIL_SUP INT NOT NULL,
	NOME VARCHAR(100) NOT NULL,
	CPF CHAR(11) NOT NULL UNIQUE,
	CONSTRAINT FK_FUNCIONARIO_SUPERMERCADO
	FOREIGN KEY (NRO_INT_FIL_SUP)
	REFERENCES STF_FILIAL_SUPERMERCADO (NRO_INT_FIL_SUP)
	
);

--CREATE TABLE CAIXA
CREATE TABLE IF NOT EXISTS STF_CAIXA (
	NRO_INT_CAI SERIAL PRIMARY KEY,
	NRO_INT_FIL_SUP INT NOT NULL,
	TIPO_ATENDIMENTO VARCHAR(45) NOT NULL,
	CONSTRAINT FK_CAIXA_SUPERMERCADO
	FOREIGN KEY (NRO_INT_FIL_SUP) REFERENCES STF_FILIAL_SUPERMERCADO (NRO_INT_FIL_SUP)
);

--CREATE TABLE CONTROLE CAIXA
CREATE TABLE IF NOT EXISTS STF_CONTROLE_CAIXA (
	NRO_INT_CON_CAI SERIAL PRIMARY KEY,
	NRO_INT_FUN INT NOT NULL,
	NRO_INT_CAI INT NOT NULL,
	DT_ABERTURA DATE NOT NULL,
	DT_FECHAMENTO DATE NULL,
	VLR_INICIAL DECIMAL(11,2) NOT NULL,
	VLR_FINAL DECIMAL(11,2) NULL,
	CONSTRAINT FK_CONTROLE_FUNCIONARIO
	FOREIGN KEY (NRO_INT_FUN) REFERENCES STF_FUNCIONARIO (NRO_INT_FUN),
	CONSTRAINT FK_CONTROLE_CAIXA
	FOREIGN KEY (NRO_INT_CAI) REFERENCES STF_CAIXA (NRO_INT_CAI)
);

--CREATE TABLE PAGAMENTO
CREATE TABLE IF NOT EXISTS STF_PAGAMENTO(
	NRO_INT_PAG SERIAL PRIMARY KEY,
	FORMA_PAGAMENTO VARCHAR(45) NOT NULL,
	INSTITUICAO_FINANCEIRA VARCHAR(45) NOT NULL,
	BANDEIRA VARCHAR(45) NULL
);

--CREATE TABLE VENDA
CREATE TABLE IF NOT EXISTS STF_VENDA(
	NRO_INT_VEN SERIAL PRIMARY KEY,
	NRO_INT_CON_CAI INT NOT NULL,
	NRO_INT_PAG INT NOT NULL,
	DT_VENDA DATE NOT NULL,
	VLR_VENDA DECIMAL(11,2) NOT NULL,
	CONSTRAINT FK_CONTROLE_VENDA
	FOREIGN KEY (NRO_INT_CON_CAI) REFERENCES STF_CONTROLE_CAIXA (NRO_INT_CON_CAI),
	CONSTRAINT FK_PAGAMENTO_VENDA
	FOREIGN KEY (NRO_INT_PAG) REFERENCES STF_PAGAMENTO (NRO_INT_PAG)
);

--CREATE TABLE CATEGORIA PRODUTO
CREATE TABLE IF NOT EXISTS STF_CATEGORIA_PRODUTO(
	NRO_INT_CAT_PRO SERIAL PRIMARY KEY,
	CATEGORIA VARCHAR(45) NOT NULL
);

--CREATE TABLE CATALOGO
CREATE TABLE IF NOT EXISTS STF_CATALOGO(
	NRO_INT_CAT SERIAL PRIMARY KEY,
	NRO_INT_CAT_PRO INT NOT NULL,
	NOME_PRODUTO VARCHAR(100) NOT NULL,
	CODIGO_DE_BARRAS CHAR(13) NOT NULL UNIQUE,
	QTD_CONTIDA INT NOT NULL,
	IND_ISCAIXA CHAR(1) NOT NULL,
	CONSTRAINT FK_CATEGORIA_CATALOGO
	FOREIGN KEY (NRO_INT_CAT_PRO) REFERENCES STF_CATEGORIA_PRODUTO (NRO_INT_CAT_PRO)
);

--CREATE TABLE LOTE
CREATE TABLE IF NOT EXISTS STF_LOTE(
	NRO_INT_LOT SERIAL PRIMARY KEY,
	NRO_INT_CAT INT NOT NULL,
	DT_RECEBIMENTO DATE NOT NULL,
	VLR_PAGO DECIMAL(11,2) NOT NULL,
	QTD_RECEBIDA INT NOT NULL,
	NRO_LOTE CHAR(6) NOT NULL UNIQUE,
	IND_ISALOCADO CHAR(6) NOT NULL,
	DT_VALIDADE DATE NOT NULL,
	CONSTRAINT FK_PRODUTO_LOTE
	FOREIGN KEY (NRO_INT_CAT) REFERENCES STF_CATALOGO (NRO_INT_CAT)
);

--CREATE TABLE ESTOQUE
CREATE TABLE IF NOT EXISTS STF_ESTOQUE(
	NRO_INT_EST SERIAL PRIMARY KEY,
	NRO_INT_LOT INT NOT NULL,
	NRO_INT_FIL_SUP INT NOT NULL,
	NRO_INT_CAT INT NOT NULL,
	QTD_DISPONIVEL INT NOT NULL,
	CONSTRAINT FK_LOTE_ESTOQUE
	FOREIGN KEY (NRO_INT_LOT) REFERENCES STF_LOTE (NRO_INT_LOT),
	CONSTRAINT FK_SUPERMERCADO_ESTOQUE
	FOREIGN KEY (NRO_INT_FIL_SUP) REFERENCES STF_FILIAL_SUPERMERCADO (NRO_INT_FIL_SUP),
	CONSTRAINT FK_CATALOGO_ESTOQUE
	FOREIGN KEY (NRO_INT_CAT) REFERENCES STF_CATALOGO (NRO_INT_CAT)
);

--CREATE TABLE HISTORICO PRECO
CREATE TABLE IF NOT EXISTS STF_HISTORICO_PRECO(
	NRO_INT_HIS_PRE SERIAL PRIMARY KEY,
	NRO_INT_EST INT NOT NULL,
	VLR_VENDA DECIMAL(11,2) NOT NULL,
	DT_ALTERACAO DATE NOT NULL,
	HHMMSS_ALTERACAO TIME NOT NULL,
	CONSTRAINT FK_ESTOQUE_PRECO
	FOREIGN KEY (NRO_INT_EST) REFERENCES STF_ESTOQUE (NRO_INT_EST)
);

--CREATE TABLE PRODUTO VENDA
CREATE TABLE IF NOT EXISTS STF_PRODUTO_VENDA(
	NRO_INT_PRO_VEN SERIAL PRIMARY KEY,
	NRO_INT_VEN INT NOT NULL,
	NRO_INT_HIS_PRE INT NOT NULL,
	QTD_PRODUTO INT NOT NULL,
	VLR_SOMA_PRODUTO DECIMAL(11,2) NOT NULL,
	CONSTRAINT FK_VENDA_PRODUTO_VENDA
	FOREIGN KEY (NRO_INT_VEN) REFERENCES STF_VENDA (NRO_INT_VEN),
	CONSTRAINT FK_VENDA_HISTORICO
	FOREIGN KEY (NRO_INT_HIS_PRE) REFERENCES STF_HISTORICO_PRECO (NRO_INT_HIS_PRE)
);


--CREATE TABLE NOTA FISCAL
CREATE TABLE IF NOT EXISTS STF_NOTA_FISCAL(
	NRO_INT_NOT_FIS SERIAL PRIMARY KEY,
	NRO_INT_FIL_SUP INT NOT NULL,
	NRO_INT_VEN INT NOT NULL,
	DT_EMISSAO DATE NOT NULL,
	CPF_CLIENTE CHAR(11) NULL,
	CODIGO_DE_BARRAS CHAR(13) NOT NULL,
	VLR_TOTAL_COM_TRIBUTOS DECIMAL(11,2) NOT NULL,
	VLR_ICMS DECIMAL(11,2) NOT NULL,
	CONSTRAINT FK_SUPERMERCADO_NOTA_FISCAL
	FOREIGN KEY (NRO_INT_FIL_SUP) REFERENCES STF_FILIAL_SUPERMERCADO (NRO_INT_FIL_SUP),
	CONSTRAINT FK_VENDA_NOTA_FISCAL
	FOREIGN KEY (NRO_INT_VEN) REFERENCES STF_VENDA (NRO_INT_VEN)
);


------------------------------------------------------------ INDEXES -------------------------------------------------------------------


-- (1) índice no atributo código de barras, na tabela catálogo;
CREATE INDEX idx_codigo_de_barras ON STF_CATALOGO (codigo_de_barras);

SELECT * FROM stf_catalogo WHERE codigo_de_barras = '7532210560391';

-- (2) índice no atributo nome, na tabela funcionário;
CREATE INDEX idx_nome_funcionario ON STF_FUNCIONARIO (nome);

SELECT * FROM stf_funcionario WHERE nome = 'Marcos Vinicius da Silva Lopes';


---------------------------------------------------------- FUNCTIONS -------------------------------------------------------------------

-- (1) Função para alocar lote em um estoque, após ser adquirido pelo supermercado.

CREATE OR REPLACE FUNCTION atualizar_estoque(
    p_nro_int_lot INTEGER,
    p_nro_int_fil_sup INTEGER
)
RETURNS VOID AS
$$
DECLARE
    v_qtd_recebida INTEGER;
    v_ind_isalocado CHAR(1);
    v_nro_int_cat INTEGER;
BEGIN
    -- Obtenho a quantidade recebida do lote e o número de categoria
    SELECT qtd_recebida, ind_isalocado, nro_int_cat
    INTO v_qtd_recebida, v_ind_isalocado, v_nro_int_cat
    FROM stf_lote
    WHERE nro_int_lot = p_nro_int_lot;

    -- Verifico se o lote está atualizado
    IF v_ind_isalocado = 'N' THEN
        -- Verifico se o produto consta no estoque
        IF EXISTS (
            SELECT 1
            FROM stf_estoque
            WHERE nro_int_cat = v_nro_int_cat
        ) THEN
            -- Atualizo o estoque
            UPDATE stf_estoque
            SET qtd_disponivel = qtd_disponivel + v_qtd_recebida
            WHERE nro_int_cat = v_nro_int_cat;
        ELSE
            -- Caso não exista o produto no estoque, eu crio um novo registro
            INSERT INTO stf_estoque (nro_int_lot, nro_int_cat, nro_int_fil_sup, qtd_disponivel)
            VALUES (p_nro_int_lot, v_nro_int_cat, p_nro_int_fil_sup,  v_qtd_recebida);
        END IF;

        -- Marco o lote como atualizado
        UPDATE stf_lote
        SET ind_isalocado = 'S'
        WHERE nro_int_lot = p_nro_int_lot;
    END IF;
END;
$$
LANGUAGE plpgsql;

-- testando a função PARÂMETROS: LOTE, SUPERMERCADO

SELECT atualizar_estoque(3, 1);

-- (2) Função para calcular o total de vendas por período em determinado caixa

CREATE OR REPLACE FUNCTION calcular_valor_total_vendas_por_periodo(
  p_nro_int_cai INT,
  p_data_inicio DATE,
  p_data_fim DATE
)
RETURNS DECIMAL(10,2)
AS $$
DECLARE
  v_valor_total DECIMAL(10,2);
BEGIN
  SELECT SUM(vlr_final - vlr_inicial)
  INTO v_valor_total
  FROM stf_controle_caixa
  WHERE nro_int_cai = p_nro_int_cai
  AND dt_abertura >= p_data_inicio
  AND dt_fechamento <= p_data_fim;

  RETURN v_valor_total;
END;
$$ LANGUAGE plpgsql;

-- testando função PARÂMETROS: ID CAIXA, DATA INICIO E DATA FIM.

SELECT calcular_valor_total_vendas_por_periodo(2, '2023-03-01', '2023-03-01');

-- (3) Função para iniciar uma jornada de trabalho em um caixa

CREATE OR REPLACE FUNCTION iniciar_jornada(
    p_nro_int_cai INT,
    p_cpf CHAR(11)
) 
RETURNS VOID 
AS $$
DECLARE
    v_nro_int_fun INT;
    v_disponibilidade BOOLEAN;
BEGIN
    -- Verificar se o funcionário já está em um controle_caixa
    SELECT EXISTS (
        SELECT 1
        FROM stf_controle_caixa
        WHERE nro_int_fun = (
            SELECT nro_int_fun
            FROM stf_funcionario
            WHERE cpf = p_cpf
        )
        AND dt_fechamento IS NULL
    ) INTO v_disponibilidade;

    IF v_disponibilidade THEN
        RAISE EXCEPTION 'O funcionário já está em um controle caixa aberto.';
    END IF;

    -- Verificar se o caixa está aberto através do atributo dt_fechamento
    SELECT EXISTS (
        SELECT 1
        FROM stf_controle_caixa
        WHERE nro_int_cai = p_nro_int_cai
        AND dt_fechamento IS NULL
    ) INTO v_disponibilidade;

    IF v_disponibilidade THEN
        RAISE EXCEPTION 'O caixa já está ocupado por um funcionário.';
    END IF;

    -- Obter o ID do funcionário com base no CPF
    SELECT nro_int_fun INTO v_nro_int_fun
    FROM stf_funcionario
    WHERE cpf = p_cpf;

    IF v_nro_int_fun IS NULL THEN
        RAISE EXCEPTION 'Funcionário com CPF % não encontrado.', p_cpf;
    END IF;

    -- Inserir o registro na tabela controle caixa com a data de abertura atual
    INSERT INTO stf_controle_caixa (nro_int_cai, nro_int_fun, dt_abertura, dt_fechamento, vlr_final, vlr_inicial)
    VALUES (p_nro_int_cai, v_nro_int_fun, CURRENT_DATE, NULL, 0, 0);
END;
$$ LANGUAGE plpgsql;

-- testando função PARÂMETROS: CPF, ID CAIXA.

SELECT iniciar_jornada(1, '19404582778');


-- (4) Função para encerrar uma jornada de trabalho em um caixa

CREATE OR REPLACE FUNCTION encerrar_jornada(
    p_cpf CHAR(11)
) RETURNS VOID
AS $$
DECLARE
    v_nro_int_fun INT;
BEGIN
    -- Obter o ID do funcionário com base no CPF
    SELECT nro_int_fun INTO v_nro_int_fun
    FROM stf_funcionario
    WHERE cpf = p_cpf;

    IF v_nro_int_fun IS NULL THEN
        RAISE EXCEPTION 'Funcionário com CPF % não encontrado.', p_cpf;
    END IF;

    -- Encerrar o controle de caixa aberto para o funcionário
    UPDATE stf_controle_caixa
    SET dt_fechamento = CURRENT_DATE
    WHERE nro_int_fun = v_nro_int_fun
    AND dt_fechamento IS NULL;
END;
$$ LANGUAGE plpgsql;

-- testando função PARÂMETROS: CPF, ID CAIXA.

SELECT encerrar_jornada('19404582778');

select * from stf_controle_caixa;
--------------------------------------------------------------- VIEW -------------------------------------------------------------------


-- View para ver os produtos mais adquiridos pelo supermercado e a quantidade disponível em estoque

CREATE OR REPLACE VIEW vw_produtos_mais_adquiridos AS
SELECT
    c.nro_int_cat,
    c.nome_produto AS NOME_PRODUTO,
    cat.categoria,
    c.codigo_de_barras,
    c.qtd_contida,
    SUM(l.vlr_pago) AS TOTAL_PAGO,
    SUM(l.qtd_recebida) AS TOTAL_QUANTIDADE_RECEBIDA,
    e.qtd_disponivel
FROM
    stf_catalogo c
    INNER JOIN stf_categoria_produto cat ON c.nro_int_cat_pro = cat.nro_int_cat_pro
    LEFT JOIN stf_lote l ON c.nro_int_cat = l.nro_int_cat
    LEFT JOIN stf_estoque e ON c.nro_int_cat = e.nro_int_cat
GROUP BY
    c.nro_int_cat,
    c.nome_produto,
    cat.categoria,
    c.codigo_de_barras,
    c.qtd_contida,
    e.qtd_disponivel
ORDER BY
	TOTAL_QUANTIDADE_RECEBIDA DESC;
	
-- testando view

SELECT * FROM vw_produtos_mais_adquiridos;

---------------------------------------------------------- PROCEDURE -------------------------------------------------------------------

-- Procedure para vender produto 

CREATE OR REPLACE PROCEDURE vender_produto(
  IN p_cpf char(11),
  IN p_nro_int_pag INT,
  IN p_nro_int_his_pre INT,
  IN p_qtd_produto INT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_nro_int_con_cai INT;
  v_nro_int_ven INT;
  v_qtd_disponivel INT;
  v_vlr_venda decimal(10,2);
  v_vlr_soma_produto decimal(10,2);
  v_nro_int_pro_ven INT;
  v_commit BOOLEAN := false;
BEGIN
  -- Encontro o controle caixa com o cpf passado no parâmetro
  SELECT nro_int_con_cai INTO v_nro_int_con_cai
  FROM stf_controle_caixa
  WHERE nro_int_fun = (SELECT nro_int_fun FROM stf_funcionario WHERE cpf = p_cpf);
  
  -- Verifico se foi encontrado
  IF v_nro_int_con_cai IS NULL THEN
    RAISE EXCEPTION 'Controle de caixa não encontrado para o CPF fornecido.';
  END IF;
  
  -- Inicio a transação
  BEGIN
    -- Crio uma nova venda
    INSERT INTO stf_venda (nro_int_con_cai, nro_int_pag, dt_venda, vlr_venda)
    VALUES (v_nro_int_con_cai, p_nro_int_pag, CURRENT_DATE, 0)
    RETURNING nro_int_ven INTO v_nro_int_ven;
   
    -- Verifico a quantidade disponível no estoque
    SELECT qtd_disponivel INTO v_qtd_disponivel
    FROM stf_estoque
    WHERE nro_int_est = (SELECT nro_int_est FROM stf_historico_preco WHERE nro_int_his_pre = p_nro_int_his_pre);
    
    -- Verifico se possuo em estoque a quantidade de produtos a ser vendida.
    IF p_qtd_produto > v_qtd_disponivel THEN
      RAISE EXCEPTION 'Quantidade de produtos indisponível no estoque.';
    END IF;
    
    -- Crio um produto_venda para a venda criada
    INSERT INTO stf_produto_venda (nro_int_ven, nro_int_his_pre, vlr_soma_produto, qtd_produto)
    VALUES (v_nro_int_ven, p_nro_int_his_pre, 0, p_qtd_produto)
    RETURNING nro_int_pro_ven INTO v_nro_int_pro_ven;
    
    -- Atualizo a quantidade disponível no estoque
    UPDATE stf_estoque
    SET qtd_disponivel = qtd_disponivel - p_qtd_produto
    WHERE nro_int_est = (SELECT nro_int_est FROM stf_historico_preco WHERE nro_int_his_pre = p_nro_int_his_pre);
    
    -- Atualizo o valor do produto no produto_venda
    SELECT vlr_venda INTO v_vlr_venda
    FROM stf_historico_preco
    WHERE nro_int_his_pre = p_nro_int_his_pre;
    v_vlr_soma_produto := v_vlr_venda * p_qtd_produto;
    UPDATE stf_produto_venda
    SET vlr_soma_produto = v_vlr_soma_produto
    WHERE nro_int_pro_ven = v_nro_int_pro_ven;
  
    -- Atualizo o valor total da venda
    UPDATE stf_venda
    SET vlr_venda = (
      SELECT COALESCE(SUM(vlr_soma_produto), 0)
      FROM stf_produto_venda 
      WHERE nro_int_ven = v_nro_int_ven
    )
    WHERE nro_int_ven = v_nro_int_ven;
	
	 -- Atualizo o valor adquirido por vendas na tabela controle caixa
    UPDATE stf_controle_caixa
    SET vlr_final = vlr_final + v_vlr_soma_produto
    WHERE nro_int_con_cai = v_nro_int_con_cai;
  
    -- Marco que o commit é necessário
    v_commit := true;
  
    -- Faço rollback caso dê algum erro
    EXCEPTION
      WHEN OTHERS THEN
        v_commit:= false;
        RAISE;
  END;
  
  -- Realizo o commit
  IF v_commit THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
END;
$$;

-- testando procedure PARÂMETROS: CPF, ID PAGAMENTO, ID PRECO E QTD PRODUTO.
CALL vender_produto('19404582778', 1, 10, 20);


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
(1, 4, '2023-07-07', '13:00:00'),
(3, 40, '2023-07-07', '14:00:00'),
(2, 25, '2023-07-07', '12:00:00');

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



