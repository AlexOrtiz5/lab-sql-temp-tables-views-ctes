-- Creating a Customer Summary Report
-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila 
-- database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, 
-- and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, 
-- email address, and total number of rentals (rental_count).
CREATE VIEW rental_information AS
    SELECT 
        customer.customer_id,
        CONCAT(customer.first_name, ' ', customer.last_name) AS name,
        customer.email,
        COUNT(*) AS rental_count
    FROM
        customer
            INNER JOIN
        rental ON rental.customer_id = customer.customer_id
    GROUP BY customer.customer_id;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table 
-- should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by 
-- each customer.
CREATE TEMPORARY TABLE temp_customer_payment AS
	SELECT
		rental_information.customer_id,
		SUM(payment.amount) AS total_paid
	FROM 
		rental_information
			INNER JOIN
		payment ON payment.customer_id = rental_information.customer_id
	GROUP BY rental_information.customer_id;
    
-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The 
-- CTE should include the customer's name, email address, rental count, and total amount paid.
WITH customer_report AS(
	SELECT
		rental_information.name,
		rental_information.email,
		rental_information.rental_count,
		temp_customer_payment.total_paid,
		IFNULL(temp_customer_payment.total_paid / rental_information.rental_count, 0) AS average_payment
	FROM 
		rental_information
			LEFT JOIN
		temp_customer_payment ON temp_customer_payment.customer_id = rental_information.customer_id
)

SELECT
	*
FROM
	customer_report;