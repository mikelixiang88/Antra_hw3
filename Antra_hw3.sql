-- Question 1
SELECT DISTINCT c.City
FROM Customers c JOIN Employees e ON c.City = e.City
-- Question 2 subquery
SELECT DISTINCT c.City
FROM Customers c
WHERE c.City NOT IN (SELECT DISTINCT e.City FROM Employees e)
-- Question 2 without subquery
SELECT DISTINCT c.City
FROM Customers c LEFT JOIN Employees e ON c.City = e.City
WHERE e.City IS NULL
-- Question 3
SELECT p.ProductName, SUM(od.Quantity) AS TotalOrderQuantity
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
-- Question 4
SELECT c.City, SUM(od.Quantity) AS TotalProductsOrdered
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
-- Question 5 with union (I don't get why we need union for this, but I'll do it like this)
SELECT c.City
FROM Customers c
GROUP BY c.City
HAVING COUNT(c.CustomerID) >= 2
-- Question 5 with subquery
SELECT City
FROM (
    SELECT City, COUNT(CustomerID) AS CustomerCount
    FROM Customers
    GROUP BY City
) AS SubQuery
WHERE SubQuery.CustomerCount >= 2
-- Question 6
SELECT c.City
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
HAVING COUNT(DISTINCT od.ProductID) >= 2
-- Question 7
SELECT DISTINCT c.CustomerID, c.ContactName
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City != o.ShipCity
-- Question 8
WITH Top5Products AS (
    SELECT TOP 5 p.ProductID, p.ProductName, AVG(od.UnitPrice) AS AvgPrice, SUM(od.Quantity) AS TotalQuantity
    FROM [Order Details] od LEFT JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY p.ProductID, p.ProductName
    ORDER BY SUM(od.Quantity) DESC
),
TopCustomerCities AS (
    SELECT tp.ProductID, c.City, SUM(od.Quantity) AS QuantityOrdered
    FROM [Order Details] od
    LEFT JOIN Top5Products tp ON od.ProductID = tp.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE tp.ProductID IS NOT NULL
    GROUP BY tp.ProductID, c.City
)
SELECT tp.ProductName, tp.AvgPrice, tcc.City AS TopCustomerCity
FROM TopCustomerCities tcc
LEFT JOIN Top5Products tp ON tcc.ProductID = tp.ProductID
WHERE tcc.QuantityOrdered = (
    SELECT MAX(tcc2.QuantityOrdered)
    FROM TopCustomerCities tcc2
    WHERE tcc2.ProductID = tp.ProductID
)

-- Question 9 with subquery
SELECT DISTINCT e.City
FROM Employees e
WHERE e.City NOT IN (
    SELECT DISTINCT c.City
    FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
)
-- Question 9 without subquery
SELECT DISTINCT e.City
FROM Employees e LEFT JOIN Customers c ON e.City = c.City LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
-- Question 10
WITH EmployeeOrderCount AS (
    SELECT e.City, COUNT(o.OrderID) AS OrderCount
    FROM Orders o 
    LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
    GROUP BY e.City
),
CustomerOrderCount AS (
    SELECT c.City, SUM(od.Quantity) AS TotalQuantity
    FROM Orders o
    LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY c.City
)
SELECT TOP 1 eoc.City
FROM EmployeeOrderCount eoc
JOIN CustomerOrderCount coc ON eoc.City = coc.City
ORDER BY eoc.OrderCount DESC, coc.TotalQuantity DESC
-- Question 11 first create a common table expression with a ROW_NUMBER() window function, then use DELETE to delete rows with row_number>1