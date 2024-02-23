--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_NicholasSmith')
	 Begin 
	  Alter Database [Assignment06DB_NicholasSmith] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_NicholasSmith;
	 End
	Create Database Assignment06DB_NicholasSmith;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_NicholasSmith;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

/* 
	Need to write four separate SELECT statements to create views for each of the existing tables.

	View Names:

	[dbo].[vCategories]
	[dbo].[vProducts]
	[dbo].[vEmployees]
	[dbo].[vInventories]
	
*/

-- vCategories 

	GO
	CREATE VIEW vCategories
	WITH SCHEMABINDING
	AS
		SELECT CategoryID, CategoryName
		FROM dbo.Categories;
	GO

-- vProducts 

	GO
	CREATE VIEW vProducts
	WITH SCHEMABINDING
	AS
		SELECT ProductID, ProductName, CategoryID, UnitPrice
		FROM dbo.Products;
	GO

-- vEmployees

	GO
	CREATE VIEW vEmployees
	WITH SCHEMABINDING
	AS
		SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
		FROM dbo.Employees;
	GO

-- vInventories

	GO
	CREATE VIEW vInventories
	WITH SCHEMABINDING
	AS
		SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
		FROM dbo.Inventories;
	GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Need to DENY SELECT to tables to the public, need to GRANT SELECT to views to public.

	GO
	DENY SELECT ON Categories to Public;
	GO

	GO
	DENY SELECT ON Products to Public;
	GO

	GO
	DENY SELECT ON Employees to Public;
	GO

	GO
	DENY SELECT ON Inventories to Public;
	GO

	GO
	GRANT SELECT ON vCategories to Public;
	GO

	GO
	GRANT SELECT ON vProducts to Public;
	GO

	GO
	GRANT SELECT ON vEmployees to Public;
	GO

	GO
	GRANT SELECT ON vInventories to Public;
	GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Need to SELECT both tables to see the relationship between the two.
-- Need to create a view called vProductsbyCategories, which includes CategoryName, ProductName and UnitPrice

/*	
	Select * From Categories;
	go
	Select * From Products;
	go
*/

-- Category ID is the common column in each of the two tables Categories and Products. 

	GO
	CREATE VIEW vProductsbyCategories
	AS
		SELECT TOP 1000000 CategoryName, ProductName, UnitPrice
		FROM dbo.vCategories AS C
		JOIN dbo.vProducts AS P 
		ON C.CategoryID = P.CategoryID;
	GO

	SELECT * 
	FROM vProductsbyCategories
	ORDER BY CategoryName, ProductName;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Need to SELECT both tables to see the relationship between the two.
-- Need to create a view called vInventoriesByProductsByDates, which includes ProductName, InventoryDate and Count

/*	
	Select * From Products;
	go
	Select * From Inventories;
	go
*/

-- ProductID is the common column in each of the two tables Products and Inventories.

	GO
	CREATE VIEW vInventoriesByProductsByDates
	AS
		SELECT TOP 1000000 ProductName, InventoryDate, Count
		FROM dbo.vProducts AS P
		JOIN dbo.vInventories AS I
		ON P.ProductID = I.ProductID
	GO

	SELECT *
	FROM vInventoriesByProductsByDates
	ORDER BY ProductName, InventoryDate, Count;

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Need to SELECT both tables to see the relationship between the two.
-- Need to create a view called vInventoriesByEmployeesByDates, which includes InventoryDate and EmployeeName.

/*	
	Select * From Employees;
	go
	Select * From Inventories;
	go
*/

-- EmployeeID is the common column in each of the two tables Employees and Inventories.
-- There may be a GROUP function needed in order to return only one row per date.
-- EmployeeName will need to be concatenated.

	GO
	CREATE VIEW vInventoriesByEmployeesByDates
	AS
		SELECT TOP 1000000 InventoryDate, CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
		FROM dbo.vEmployees AS E
		JOIN dbo.vInventories AS I
		ON E.EmployeeID = I.EmployeeID
		GROUP BY InventoryDate, CONCAT (EmployeeFirstName, ' ', EmployeeLastName)
	GO

	SELECT *
	FROM vInventoriesByEmployeesByDates
	ORDER BY InventoryDate;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- List of Categories comes from Categories table, List of Products comes from Products table, and Inventory Date and Counts come from Inventories table.

/*	
	Select * From Categories;
	go
	Select * From Products;
	go
	Select * From Inventories;
	go
*/

-- CategoryID column ties the Categories and Products table, while the ProductID column ties the Products and Inventories tables.
-- Need to create a view called vInventoriesByProductsByCategories, which includes CategoryName, ProductName, InventoryDate and Count.

	GO
	CREATE VIEW vInventoriesByProductsByCategories
	AS
		SELECT TOP 1000000 CategoryName, ProductName, InventoryDate, Count
		FROM dbo.vCategories AS C
		JOIN dbo.vProducts AS P
		ON C.CategoryID = P.CategoryID
		JOIN dbo.vInventories AS I
		ON P.ProductID = I.ProductID
	GO

	SELECT *
	FROM vInventoriesByProductsByCategories
	ORDER BY CategoryName, ProductName, InventoryDate, Count;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- I think a lot of the code from question 6 can be reused in question 7.
-- Need to create a view called vInventoriesByProductsByEmployees, which includes CategoryName, ProductName, InventoryDate, Count and EmployeeName.
-- EmployeeName will need to be concatenated.
-- EmployeeID column ties the Inventories and Employees tables.

	GO
	CREATE VIEW vInventoriesByProductsByEmployees
	AS
		SELECT TOP 1000000 CategoryName, ProductName, InventoryDate, Count, CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
		FROM dbo.vCategories AS C
		JOIN dbo.vProducts AS P
		ON C.CategoryID = P.CategoryID
		JOIN dbo.vInventories AS I
		ON P.ProductID = I.ProductID
		JOIN dbo.vEmployees AS E
		ON I.EmployeeID = E.EmployeeID
	GO

	SELECT *
	FROM vInventoriesByProductsByEmployees
	ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- I think a lot of the code for question 7 can be reused for question 8. A simple WHERE clause at the end will suffice.
-- Need to create a view called vInventoriesForChaiAndChangByEmployees.

	GO
	CREATE VIEW vInventoriesForChaiAndChangByEmployees
	AS
		SELECT TOP 1000000 CategoryName, ProductName, InventoryDate, Count, CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
		FROM dbo.vCategories AS C
		JOIN dbo.vProducts AS P
		ON C.CategoryID = P.CategoryID
		JOIN dbo.vInventories AS I
		ON P.ProductID = I.ProductID
		JOIN dbo.vEmployees AS E
		ON I.EmployeeID = E.EmployeeID
	GO

	SELECT *
	FROM vInventoriesByProductsByEmployees
	WHERE ProductName IN ('Chai','Chang')
	ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;

-- Althernatively, we could potentially write a function that takes product names as parameters.

/*	
	GO
	CREATE FUNCTION dbo.fInventoriesbyProduct(@ProductName1 nvarchar(100), @ProductName2 nvarchar(100))
	RETURNS TABLE
	AS
		RETURN(
		SELECT *
		FROM vInventoriesByProductsByEmployees
		WHERE ProductName IN (@ProductName1, @ProductName2));
	GO

	SELECT * FROM dbo.fInventoriesbyProduct('Chai', 'Chang');
	GO
*/

-- This function, however, requires that the user inputs two parameters, which is not super useful. A more useful version would be a function which takes one ProductName at a time.

/*
	GO
	CREATE FUNCTION dbo.fInventoriesbyProduct(@ProductName1 nvarchar(100))
	RETURNS TABLE
	AS
		RETURN(
		SELECT *
		FROM vInventoriesByProductsByEmployees
		WHERE ProductName = @ProductName1);
	GO

	SELECT * FROM dbo.fInventoriesbyProduct('Chai');
	GO
*/

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- This will require a self join, and combining first names and last names into the same column.

-- Self Join Notes from Assignment 5:
/*	
	SELECT M.EmployeeName AS Manager, E.EmployeeName AS Employee
	FROM EmployeeCombined E
	JOIN EmployeeCombined M ON M.EmployeeID = E.ManagerID
	ORDER BY Manager, Employee;
*/

-- SELECT * FROM dbo.vEmployees;

	GO
	CREATE VIEW vEmployeesByManager
	AS
		SELECT TOP 1000000 CONCAT (M.EmployeeFirstName, ' ', M.EmployeeLastName) AS Manager, CONCAT (E.EmployeeFirstName, ' ', E.EmployeeLastName) AS Employee
		FROM dbo.vEmployees AS E
		JOIN dbo.vEmployees AS M ON M.EmployeeID = E.ManagerID
	GO

	SELECT *
	FROM vEmployeesByManager
	ORDER BY Manager, Employee


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Combining many of the queries from above to get desired results.

/*
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go
*/

-- CategoryID ties vCategories to vProducts
-- ProductID ties vProducts to vInventories
-- EmployeeID ties vInventories to vEmployees

-- Concatenation of the employee nema field will be needed as it was for question 9.

	GO
	CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
	AS
		SELECT TOP 1000000 C.CategoryID
			,CategoryName
			,P.ProductID
			,ProductName
			,UnitPrice
			,InventoryID
			,InventoryDate
			,Count
			,E.EmployeeID
			,CONCAT (E.EmployeeFirstName, ' ', E.EmployeeLastName) AS Employee
			,CONCAT (M.EmployeeFirstName, ' ', M.EmployeeLastName) AS Manager
		FROM dbo.vCategories AS C
		JOIN dbo.vProducts AS P
		ON C.CategoryID = P.CategoryID
		JOIN dbo.vInventories AS I
		ON P.ProductID = I.ProductID
		JOIN dbo.vEmployees as E
		ON E.EmployeeID = I.EmployeeID
		JOIN dbo.vEmployees AS M 
		ON M.EmployeeID = E.ManagerID
	GO

	SELECT *
	FROM vInventoriesByProductsByCategoriesByEmployees
	ORDER BY CategoryID, ProductID, InventoryID, Employee

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/