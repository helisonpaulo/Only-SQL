-- Criando uma CTE para agrupar as primeiras informações e novas colunas
with data_limite as(
    SELECT
        order_id,
        STRFTIME('%Y-%m-%d', shipping_limit_date) AS data_limite
    FROM tb_order_items
),
data_entrega AS(
    SELECT
        order_id,
        STRFTIME('%Y-%m-%d', order_delivered_customer_date) AS data_entrega
    FROM tb_orders
)

SELECT
    t1.order_id,
    t1.data_limite,
    t2.data_entrega,
    CAST(JULIANDAY(t2.data_entrega) - JULIANDAY(t1.data_limite) AS INT64) AS dias_atraso
FROM data_limite AS t1
LEFT JOIN data_entrega AS t2
    ON t1.order_id = t2.order_id
WHERE data_limite < data_entrega
ORDER BY dias_atraso DESC
-- Colocado em ordem da maior quantidade de dias de atraso
