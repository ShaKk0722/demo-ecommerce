CREATE OR REPLACE FUNCTION get_avg_order_by_month()
RETURNS TABLE(order_month TEXT, avg_order_value NUMERIC)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        TO_CHAR(os.modified_date, 'YYYY-MM') AS order_month,
        ROUND(AVG(sub.order_total), 2) AS avg_order_value
    FROM (
        SELECT
            o.order_id,
            SUM(h.quantity * h.unitprice) AS order_total
        FROM orders o
        JOIN order_status os ON o.order_id = os.order_id
        JOIN has h ON o.order_id = h.order_id
        WHERE 
            os.orderstatus IN ('Shipped', 'Completed')
            AND EXTRACT(YEAR FROM os.modified_date) = EXTRACT(YEAR FROM CURRENT_DATE)
        GROUP BY o.order_id
    ) sub
    JOIN order_status os ON sub.order_id = os.order_id
    GROUP BY order_month
    ORDER BY order_month;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_avg_order_by_month();


-- Order information
SELECT
    o.order_id,
    os.orderstatus,
    os.modified_date,
    o.order_address,
    SUM(h.quantity * h.unitprice) AS order_total
FROM orders o
JOIN order_status os ON o.order_id = os.order_id
JOIN has h ON o.order_id = h.order_id
GROUP BY o.order_id, os.orderstatus, os.modified_date, o.order_address
ORDER BY os.modified_date DESC;