USE pncp_controladoria;

-- PERGUNTA 1: Economia global do Poder Público
-- Qual é o percentual e o valor financeiro nominal economizado pelo governo 
-- (diferença entre valor estimado e valor homologado)?

SELECT
    COUNT(*) AS total_itens,
    SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END) AS estimado_comparavel,
    SUM(CASE WHEN comparavel = 1 THEN valor_total_homologado ELSE 0 END) AS homologado_comparavel,
    SUM(CASE WHEN comparavel = 1 THEN economia_valor ELSE 0 END) AS economia_nominal,
    100.0 * SUM(CASE WHEN comparavel = 1 THEN economia_valor ELSE 0 END) /
        NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0) AS economia_percentual
FROM fato_item_contratado;

-- PERGUNTA 2: Concentracao e risco de fornecedores
-- Quem são os maiores fornecedores em volume financeiro e qual percentual do orçamento público está concentrado neles?

SELECT
    f.sk_fornecedor,
    d.nome_fornecedor,
    d.ni_fornecedor,
    SUM(f.valor_total_homologado) AS volume_homologado,
    100.0 * SUM(f.valor_total_homologado) /
        NULLIF((SELECT SUM(valor_total_homologado)
                FROM fato_item_contratado), 0) AS percentual_do_total
FROM fato_item_contratado f
JOIN dim_fornecedor d ON f.sk_fornecedor = d.sk_fornecedor
GROUP BY f.sk_fornecedor, d.nome_fornecedor, d.ni_fornecedor
ORDER BY SUM(f.valor_total_homologado) DESC
LIMIT 10;

-- PERGUNTA 3: Eficácia por modalidade
-- Quais modalidades licitatórias trazem maior deságio/economia e quais concentram o maior volume de recursos?

SELECT
    m.nome_modalidade,
    100.0 * SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0) AS economia_percentual,
    SUM(f.valor_total_homologado) AS volume_homologado
FROM fato_item_contratado f
JOIN dim_modalidade m ON f.sk_modalidade = m.sk_modalidade
GROUP BY m.modalidade_id, m.nome_modalidade
ORDER BY SUM(f.valor_total_homologado) DESC;


-- PERGUNTA 4: Tempo do ciclo de compras
-- Qual a duração média (em dias) entre o lançamento do edital e a sua homologação final, segmentada por órgão?

SELECT
    d.nome_orgao,
    COUNT(f.dias_ciclo) AS itens_com_ciclo,
    ROUND(AVG(f.dias_ciclo), 1) AS media_dias_ciclo,
    MAX(f.dias_ciclo) AS maior_ciclo_dias,
    COUNT(DISTINCT d.cnpj_orgao) AS unidades_cnpj
FROM fato_item_contratado f
JOIN dim_orgao d ON f.sk_orgao = d.sk_orgao
GROUP BY d.nome_orgao
HAVING COUNT(f.dias_ciclo) >= 5
ORDER BY AVG(f.dias_ciclo) DESC;

-- PERGUNTA 5: Quais estados e regiões concentram as maiores despesas e quais apresentam os melhores indicadores de desconto?

-- Distribuição por estado
SELECT
    l.uf_sigla,
    l.uf_nome,
    l.regiao,
    SUM(f.valor_total_homologado) AS volume_homologado,
    SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) AS economia_nominal,
    100.0 * SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0) AS economia_percentual
FROM fato_item_contratado f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
GROUP BY l.uf_sigla, l.uf_nome, l.regiao
ORDER BY SUM(f.valor_total_homologado) DESC;

-- Distribuição por região
SELECT
    l.regiao,
    SUM(f.valor_total_homologado) AS volume_homologado,
    SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) AS economia_nominal,
    100.0 * SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0) AS economia_percentual
FROM fato_item_contratado f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
GROUP BY l.regiao
ORDER BY SUM(f.valor_total_homologado) DESC;

-- PERGUNTA 6: Perfil de gastos por categoria
-- Como os recursos se distribuem entre bens, serviços e obras e engenharia?
SELECT
    f.perfil_gasto,
    COUNT(*) AS total_itens,
    SUM(f.valor_total_homologado) AS volume_homologado,
    100.0 * SUM(f.valor_total_homologado) /
        NULLIF(SUM(SUM(f.valor_total_homologado)) OVER (), 0) AS percentual_do_total
FROM fato_item_contratado f
GROUP BY f.perfil_gasto
ORDER BY SUM(f.valor_total_homologado) DESC;