/* WWDEInterviewQuestions
SQLQuestions

Given the following schema in Northwind ... 

For this test I've connected a local SQL Server usine Azure Data Studio to MS sample database at:
https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs
*/

-- 1.Find the order_id and date of the last discontinued item sold. 
-- (hint - discontinued flag on products table)

SELECT MAX(o1.OrderID) AS LastDisconOrderID, MAX(o1.OrderDate) AS LastDisconOrderDate
FROM Orders o1
    INNER JOIN (SELECT o.OrderID, o.OrderDate
                    FROM Orders o
                    INNER JOIN "Order Details" od ON o.OrderID = od.OrderID
                    INNER JOIN Products p ON od.ProductID = p.ProductID 
                WHERE p.Discontinued = 1
                GROUP BY o.OrderDate,
                        o.OrderID) o2 ON o2.OrderID = o1.OrderID
                                        AND o2.OrderDate = o1.OrderDate;



-- 2.Find the shipped_region where we sold (and shipped) the most items by quantity.
-- We sold and shipped the most items by quantity in orders where the ShipRegion was NULL.
-- The largest non NULL region was 'ID', which was comprised of shipping addresses in the USA.
SELECT Top 2 o.ShipRegion, SUM(od.Quantity) AS TotalQuantity
FROM Orders o
INNER JOIN "Order Details" od ON o.OrderID = od.OrderID
GROUP BY o.ShipRegion
ORDER BY TotalQuantity DESC;


-- 3.Find the average order size by a customer’s region.
-- Group and list the average order sizes as measured by Quantity and sorted descending
SELECT c.Region, AVG(od.Quantity) AS AVGQuantity
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN "Order Details" od ON o.OrderID = od.OrderID
GROUP BY c.Region
ORDER BY AVGQuantity DESC;

-- List average order sizes as measured by revenue, sorted descending by that amount
-- checking discount for NULLS
SELECT od.UnitPrice, od.Discount
FROM "Order Details" od
WHERE od.Discount IS NULL;

-- checking discount for zero values
SELECT od.UnitPrice, od.Discount
FROM "Order Details" od
WHERE od.Discount = 0;

-- Calculate a simplistic revenue amount by order for one time analysis purposes
SELECT c.Region, FORMAT(AVG(od.Quantity * (od.UnitPrice - (od.UnitPrice * Round(od.Discount, 2)))),'C') AS AVGRevenueAmt
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN "Order Details" od ON o.OrderID = od.OrderID
GROUP BY c.Region
ORDER BY AVGRevenueAmt DESC;

/* It's worth noting that, from a governance and dictionary perspective, any business logic based calculated variables should be documented and transparent,
wherever it lives on the database side or within an app environment, logic with a meaningful difference for the business should be documented in plain terms,
and referenced closely with the data domain model, such as in source control.
Depending on use cases and needs for speed, reproducibility, portability, and access control--options like stored procedures and views would be considered.*/