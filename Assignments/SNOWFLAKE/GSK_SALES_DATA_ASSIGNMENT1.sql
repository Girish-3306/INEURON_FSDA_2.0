USE DATABASE DEMO_DATABASE;

DELETE FROM GSK_SALESDATA;
-----------------------------------------------------------------------------------------------------------
--1. Load the given dataset into snowflake with a primary key to Order Date column.
CREATE OR REPLACE TABLE GSK_SALESDATA
(
  order_id VARCHAR(30),
  order_date STRING PRIMARY KEY,
  ship_date STRING,
  ship_mode VARCHAR(25),
  customer_name VARCHAR(50),
  segment VARCHAR(20),
  state VARCHAR(50),
  country VARCHAR(50),
  market VARCHAR(15),
  region VARCHAR(20),
  product_id VARCHAR(50),
  category VARCHAR(25),
  sub_category VARCHAR(25),
  product_name STRING,
  sales DECIMAL(10, 2),
  quantity INT,
  discount DECIMAL(5, 2),
  profit DECIMAL(10, 2),
  shipping_cost DECIMAL(10, 2),
  order_priority VARCHAR(20),
  year INT
);

DESCRIBE TABLE GSK_SALESDATA;

SELECT * FROM GSK_SALESDATA;

--------------------------------------------------------------------------------------------------------------
-- 2. Change the Primary key to Order Id Column

ALTER TABLE GSK_SALESDATA
DROP PRIMARY KEY;

DESCRIBE TABLE GSK_SALESDATA;

ALTER TABLE GSK_SALESDATA
ADD PRIMARY KEY(order_id);

-----------------------------------------------------------------------------------------------------------------
--3. Check the data type for Order date and Ship date and mention in what data type it should be?
ALTER TABLE GSK_SALESDATA DROP COLUMN NEW_ORDER_DATE;
ALTER TABLE GSK_SALESDATA DROP COLUMN  ORDER_DATE;

----------------------------------------ORDER_DATE------------------------------------------------------
ALTER TABLE GSK_SALESDATA DROP COLUMN  NEW_ORDER_DATE;
-- DATA TYPE OF ORDER_DATE IS VARCHAR AND IT SHOULD BE IN DATE DATATYPE
-- DATA TYPE OF SHIP_DATE IS ALSO VARCHAR AND IT SHOULD BE IN DATE DATATYPE

ALTER TABLE GSK_SALESDATA ADD NEW_ORDER_DATE DATE;

UPDATE GSK_SALESDATA SET NEW_ORDER_DATE = CAST(ORDER_DATE AS DATE);

ALTER TABLE GSK_SALESDATA RENAME COLUMN NEW_ORDER_DATE TO ORDER_DATE;


SELECT NEW_ORDER_DATE FROM GSK_SALESDATA;
SELECT ORDER_DATE FROM GSK_SALESDATA;

-------------------------------------------SHIP_DATE----------------------------------------------------------
ALTER TABLE GSK_SALESDATA DROP COLUMN NEW_SHIP_DATE; -- To drop NEW_SHIP_DATE

ALTER TABLE GSK_SALESDATA ADD NEW_SHIP_DATE DATE; -- To Create new column NEW_SHIP_DATE with datatype as DATE

UPDATE GSK_SALESDATA SET NEW_SHIP_DATE = CAST(SHIP_DATE AS DATE);

ALTER TABLE GSK_SALESDATA DROP COLUMN SHIP_DATE;

ALTER TABLE GSK_SALESDATA RENAME COLUMN NEW_SHIP_DATE TO SHIP_DATE;

------------------------------------------------------------------------------------------------------------
--4. Create a new column called order_extract and extract the number after the last ‘–‘from Order ID column.

ALTER TABLE GSK_SALESDATA
ADD COLUMN ORDER_EXTRACT VARCHAR;

UPDATE GSK_SALESDATA
SET ORDER_EXTRACT = SPLIT_PART(ORDER_ID,'-',-1);

SELECT ORDER_ID, ORDER_EXTRACT FROM GSK_SALESDATA;

-------------------------------------------------METHOD - 2--------------------------------------------
-- Using Regex functions

ALTER TABLE GSK_SALESDATA
ADD COLUMN ORDER_EXTRACT VARCHAR;

UPDATE GSK_SALESDATA
SET ORDER_EXTRACT = REGEXP_SUBSTR(ORDER_ID, '[^-]+$');

--------------------------------------------------------------------------------------------------------------
--5. Create a new column called Discount Flag and categorize it based on discount. 
--    Use ‘Yes’ if the discount is greater than zero else ‘No’.
SELECT * FROM GSK_SALESDATA;

-- Add a new column called Discount_Flag
ALTER TABLE GSK_SALESDATA
ADD COLUMN DISCOUNT_FLAG VARCHAR(15);

-- Update the Discount_Flag column based on the discount value
UPDATE GSK_SALESDATA
SET DISCOUNT_FLAG = CASE
    WHEN DISCOUNT > 0 THEN 'Yes'
    ELSE 'No'
    END;
    
SELECT DISCOUNT, DISCOUNT_FLAG FROM GSK_SALESDATA;

------------------------------------METHOD - 2----------------------------------------------
-- Add a new computed column called Discount_Flag
ALTER TABLE GSK_SALESDATA ADD COLUMN Discount_Flag VARCHAR(3)
AS (CASE WHEN DISCOUNT > 0 THEN 'Yes' ELSE 'No' END) VIRTUAL;

----------------------------------------------------------------------------------------------------------------
--6. Create a new column called process days and calculate how many days it takes 
--for each order id to process from the order to its shipment.

ALTER TABLE GSK_SALESDATA
ADD COLUMN PROCESS_DAYS INT;

UPDATE GSK_SALESDATA
SET PROCESS_DAYS = DATEDIFF(DAY,ORDER_DATE,SHIP_DATE);

SELECT ORDER_ID,ORDER_DATE, PROCESS_DAYS, SHIP_DATE FROM GSK_SALESDATA;

------------------------------------------METHOD-2-------------------------------------------
ALTER TABLE GSK_SALESDATA
ADD COLUMN process_days AS DATEDIFF(DAY, order_date, ship_date) VIRTUAL;

---------------------------------------------------------------------------------------------------
/*7. Create a new column called Rating and then based on the Process days give rating like given below.
    a. If process days less than or equal to 3days then rating should be 5
    b. If process days are greater than 3 and less than or equal to 6 then rating should be 4
    c. If process days are greater than 6 and less than or equal to 10 then rating should be 3
    d. If process days are greater than 10 then the rating should be 2
*/

ALTER TABLE GSK_SALESDATA
ADD COLUMN RATING INT;

UPDATE GSK_SALESDATA
SET RATING = CASE
    WHEN PROCESS_DAYS <= 3 THEN 5
    WHEN PROCESS_DAYS > 3 AND PROCESS_DAYS <= 6 THEN 4
    WHEN PROCESS_DAYS > 6 AND PROCESS_DAYS <= 10 THEN 3
    ELSE 2
END;

SELECT PROCESS_DAYS, RATING FROM GSK_SALESDATA;

--------------------------------------------------METHOD - 2 ------------------------------------------------
ALTER TABLE GSK_SALESDATA
ADD COLUMN RATING INT AS (
  CASE
    WHEN PROCESS_DAYS <= 3 THEN 5
    WHEN PROCESS_DAYS > 3 AND PROCESS_DAYS <= 6 THEN 4
    WHEN PROCESS_DAYS > 6 AND PROCESS_DAYS <= 10 THEN 3
    ELSE 2
  END
) VIRTUAL;

-------------------------------------------------------------------------------------------------------------------

