-- Customer (before 6-12 months)
SELECT o.customerNo, os.orderstatus, os.modified_date
FROM orders o
JOIN order_status os ON o.order_id = os.order_id
WHERE os.orderstatus = 'Completed'
  AND os.modified_date >= current_date - INTERVAL '12 months'
  AND os.modified_date < current_date - INTERVAL '6 months';

  -- Customer (nearly 6 months)
SELECT o.customerNo, os.orderstatus, os.modified_date
FROM orders o
JOIN order_status os ON o.order_id = os.order_id
WHERE os.modified_date >= current_date - INTERVAL '6 months'
  AND os.orderstatus IN ('Shipped', 'Completed', 'Processing');

  -- 
  CREATE OR REPLACE FUNCTION get_churn_rate()
RETURNS numeric AS $$
DECLARE
    churned_count INT;
    active_count INT;
    churn_rate NUMERIC(5, 2);
BEGIN

    SELECT COUNT(DISTINCT o1.customerNo)
    INTO churned_count
    FROM orders o1
    WHERE EXISTS (
        SELECT 1 FROM order_status os1
        WHERE os1.order_id = o1.order_id
          AND os1.orderstatus = 'Completed'
          AND os1.modified_date >= current_date - INTERVAL '12 months'
          AND os1.modified_date < current_date - INTERVAL '6 months'
    )
    AND NOT EXISTS (
        SELECT 1 FROM orders o2
        JOIN order_status os2 ON o2.order_id = os2.order_id
        WHERE o2.customerNo = o1.customerNo
          AND os2.modified_date >= current_date - INTERVAL '6 months'
          AND os2.orderstatus IN ('Shipped', 'Completed')
    );


    SELECT COUNT(DISTINCT o.customerNo)
    INTO active_count
    FROM orders o
    JOIN order_status os ON o.order_id = os.order_id
    WHERE os.modified_date >= current_date - INTERVAL '12 months';

    IF active_count = 0 THEN
        RETURN 0;
    END IF;

    churn_rate := (churned_count::NUMERIC / active_count) * 100;

    RETURN ROUND(churn_rate, 2);
END;
$$ LANGUAGE plpgsql;