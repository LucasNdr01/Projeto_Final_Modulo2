
CREATE DATABASE IF NOT EXISTS pncp_controladoria;
USE pncp_controladoria;

CREATE TABLE dim_orgao (
    sk_orgao INT NOT NULL,
    cnpj_orgao VARCHAR(20) NOT NULL,
    nome_orgao VARCHAR(255),
    poder VARCHAR(50),
    PRIMARY KEY (sk_orgao),
    UNIQUE KEY uq_dim_orgao_cnpj (cnpj_orgao)
);

CREATE TABLE dim_fornecedor (
    sk_fornecedor INT NOT NULL,
    ni_fornecedor VARCHAR(20) NOT NULL,
    nome_fornecedor VARCHAR(255),
    tipo_pessoa VARCHAR(50),
    porte VARCHAR(100),
    PRIMARY KEY (sk_fornecedor),
    UNIQUE KEY uq_dim_fornecedor_ni (ni_fornecedor)
);

CREATE TABLE dim_modalidade (
    sk_modalidade INT NOT NULL,
    modalidade_id INT NOT NULL,
    nome_modalidade VARCHAR(100),
    PRIMARY KEY (sk_modalidade),
    UNIQUE KEY uq_dim_modalidade_id (modalidade_id)
);

CREATE TABLE dim_localidade (
    sk_localidade INT NOT NULL,
    uf_sigla VARCHAR(2) NOT NULL,
    uf_nome VARCHAR(50),
    regiao VARCHAR(50),
    PRIMARY KEY (sk_localidade),
    UNIQUE KEY uq_dim_localidade_uf (uf_sigla)
);

CREATE TABLE fato_item_contratado (
    sk_fato INT NOT NULL AUTO_INCREMENT,
    numero_controle_pncp VARCHAR(100) NOT NULL,
    numero_item INT NOT NULL,
    sk_orgao INT NOT NULL,
    sk_fornecedor INT NOT NULL,
    sk_modalidade INT NOT NULL,
    sk_localidade INT NOT NULL,
    data_publicacao DATE,
    data_homologacao DATE,
    descricao_item TEXT,
    perfil_gasto VARCHAR(50),
    quantidade DECIMAL(18,4) NOT NULL,
    valor_unitario_estimado DECIMAL(18,4),
    valor_unitario_homologado DECIMAL(18,4),
    valor_total_estimado DECIMAL(18,2),
    valor_total_homologado DECIMAL(18,2),
    comparavel TINYINT NOT NULL,
    economia_valor DECIMAL(18,2),
    dias_ciclo INT,
    PRIMARY KEY (sk_fato),
    UNIQUE KEY uq_fato_item (numero_controle_pncp, numero_item),

    CONSTRAINT chk_quantidade_positiva
        CHECK (quantidade > 0),

    CONSTRAINT chk_valores_nao_negativos CHECK (
        (valor_unitario_estimado IS NULL OR valor_unitario_estimado >= 0)
        AND (valor_unitario_homologado IS NULL OR valor_unitario_homologado >= 0)
        AND (valor_total_estimado IS NULL OR valor_total_estimado >= 0)
        AND (valor_total_homologado IS NULL OR valor_total_homologado >= 0)
    ),

    CONSTRAINT chk_comparavel
        CHECK (comparavel IN (0, 1)),

    CONSTRAINT chk_economia_comparavel
        CHECK (comparavel = 1 OR economia_valor IS NULL),

    CONSTRAINT fk_fato_orgao
        FOREIGN KEY (sk_orgao)
        REFERENCES dim_orgao (sk_orgao),

    CONSTRAINT fk_fato_fornecedor
        FOREIGN KEY (sk_fornecedor)
        REFERENCES dim_fornecedor (sk_fornecedor),

    CONSTRAINT fk_fato_modalidade
        FOREIGN KEY (sk_modalidade)
        REFERENCES dim_modalidade (sk_modalidade),

    CONSTRAINT fk_fato_localidade
        FOREIGN KEY (sk_localidade)
        REFERENCES dim_localidade (sk_localidade)
);
