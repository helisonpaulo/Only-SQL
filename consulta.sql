-- 1ª CTE: data limite que o pedido deve ser entregue
-- 2ª CTE: data em que foi entregue os pedidos
with data_limite as(
    SELECT
        order_id,
        STRFTIME('%Y-%m-%d', shipping_limit_date) AS data_limite
    FROM tb_order_items
),
data_entrega AS(
    SELECT
        order_id,
        STRFTIME('%Y-%m-%d', order_delivered_customer_date) AS data_entrega,
        STRFTIME('%Y-%m', order_delivered_customer_date) AS mes_entrega -- Mês para a partição
    FROM tb_orders
)

SELECT
    t1.order_id,
    t1.data_limite,
    t2.data_entrega,
    CAST(JULIANDAY(t2.data_entrega) - JULIANDAY(t1.data_limite) AS INT64) AS dias_atraso,
    -- Classificando os pedidos por atraso (do maior para o menor) DENTRO DE CADA MÊS
    RANK() OVER (PARTITION BY t2.mes_entrega ORDER BY CAST(JULIANDAY(t2.data_entrega) - JULIANDAY(t1.data_limite) AS INT64) DESC) AS rank_atraso_mensal
FROM data_limite AS t1
LEFT JOIN data_entrega AS t2
    ON t1.order_id = t2.order_id
WHERE data_limite < data_entrega
ORDER BY mes_entrega DESC; -- Ordenado pelo mês mais recente