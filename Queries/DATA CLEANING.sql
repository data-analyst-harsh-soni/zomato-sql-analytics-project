SELECT * FROM customers;
SELECT COUNT(*) FROM customers
where 
      customer_id IS NULL
	  OR
	  customer_name IS NULL
	  OR
	  reg_date IS NULL;


SELECT * FROM delivery;
SELECT COUNT(*) FROM delivery
WHERE
      delivery_id IS NULL
	  OR 
	  order_id IS NULL
	  OR
	  delivery_status IS NULL
	  OR
	  delivery_time IS NULL
	  OR
	  rider_id IS NULL;

UPDATE delivery
SET delivery_time = '00:00:00'
WHERE delivery_time IS NULL;


SELECT * FROM orders;
SELECT COUNT (*) FROM orders
where 
      order_id IS NULL
	  OR
	  customer_id IS NULL
	  OR
	  restaurant_id IS NULL
	  OR 
	  order_item IS NULL
	  OR
	  order_date IS NULL
	  OR
	  order_time IS NULL
	  OR 
	  order_status IS NULL
	  OR
	  total_amount IS NULL;

SELECT * FROM restaurants;
SELECT COUNT(*) FROM restaurants
WHERE
      restaurant_id IS NULL
	  OR
	  restaurant_name IS NULL
	  OR
	  city IS NULL
	  OR
	  opening_hours IS NULL;

SELECT * FROM rider;
SELECT COUNT(*) FROM rider
WHERE 
      rider_id IS NULL
	  OR
	  rider_name IS NULL
	  OR
	  sign_up_date IS NULL

