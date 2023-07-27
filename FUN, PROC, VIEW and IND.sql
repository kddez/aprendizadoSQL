
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
-- Apresentação: LOTE 5 e LOTE 4 (SOMA)

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
    -- Verifico se o funcionário já está em uma jornada.
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

    -- Verifico se o caixa já está aberto.
    SELECT EXISTS (
        SELECT 1
        FROM stf_controle_caixa
        WHERE nro_int_cai = p_nro_int_cai
        AND dt_fechamento IS NULL
    ) INTO v_disponibilidade;

    IF v_disponibilidade THEN
        RAISE EXCEPTION 'O caixa já está ocupado por um funcionário.';
    END IF;

    -- Obtenho o id do funcionário através do cpf
    SELECT nro_int_fun INTO v_nro_int_fun
    FROM stf_funcionario
    WHERE cpf = p_cpf;

    IF v_nro_int_fun IS NULL THEN
        RAISE EXCEPTION 'Funcionário com CPF % não encontrado.', p_cpf;
    END IF;

    -- Insiro o registro na tabela controle caixa com a data de abertura atual
    INSERT INTO stf_controle_caixa (nro_int_cai, nro_int_fun, dt_abertura, dt_fechamento, vlr_final, vlr_inicial)
    VALUES (p_nro_int_cai, v_nro_int_fun, CURRENT_DATE, NULL, 0, 0);
END;
$$ LANGUAGE plpgsql;

-- testando função PARÂMETROS: CPF, ID CAIXA.
-- Apresentação: CAIXA 1, CPF 19404582778/ CAIXA 2, CPF 98004582778

SELECT iniciar_jornada(2, '98004582778');


-- (4) Função para encerrar uma jornada de trabalho em um caixa

CREATE OR REPLACE FUNCTION encerrar_jornada(
    p_cpf CHAR(11)
) RETURNS VOID
AS $$
DECLARE
    v_nro_int_fun INT;
BEGIN
    -- Obtenho o id do funcionário através do cpf
    SELECT nro_int_fun INTO v_nro_int_fun
    FROM stf_funcionario
    WHERE cpf = p_cpf;

    IF v_nro_int_fun IS NULL THEN
        RAISE EXCEPTION 'Funcionário com CPF % não encontrado.', p_cpf;
    END IF;

    -- Encerro o controle 
    UPDATE stf_controle_caixa
    SET dt_fechamento = CURRENT_DATE
    WHERE nro_int_fun = v_nro_int_fun
    AND dt_fechamento IS NULL;
END;
$$ LANGUAGE plpgsql;

-- testando função PARÂMETROS: CPF, ID CAIXA.
-- Apresentação: CPF 19404582778 / CPF 98004582778

SELECT encerrar_jornada('98004582778');

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
  -- Procuro o controle caixa através do cpf
  SELECT nro_int_con_cai INTO v_nro_int_con_cai
  FROM stf_controle_caixa
  WHERE nro_int_fun = (SELECT nro_int_fun FROM stf_funcionario WHERE cpf = p_cpf);
  
  -- Verifico se foi encontrado
  IF v_nro_int_con_cai IS NULL THEN
    RAISE EXCEPTION 'Controle de caixa não encontrado para o CPF fornecido.';
  END IF;
  
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
		-- ROLLBACK TESTE
	  ROLLBACK;
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
  
    -- Commit é necessário
    v_commit := true;
  
    EXCEPTION
      WHEN OTHERS THEN
        v_commit:= false;
        RAISE;
  END;
  
  IF v_commit THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
END;
$$;

-- testando procedure PARÂMETROS: CPF, ID PAGAMENTO, ID PRECO E QTD PRODUTO.
-- Apresentação: CPF 19404582778, ID PAG 1, ID PRECO 1, QTD 20.
-- Apresentação: CPF 98004582778, ID PAG 2, ID PRECO 2, QTD 30.

CALL vender_produto('19404582778', 1, 1, 20);