SET NOCOUNT ON;

IF DB_ID(N'FBR_SaaS_testing') IS NULL
BEGIN
  CREATE DATABASE FBR_SaaS_testing;
  PRINT 'Database FBR_SaaS_testing created successfully.';
END
ELSE
BEGIN
  PRINT 'Database FBR_SaaS_testing already exists.';
END
GO

USE FBR_SaaS_testing;
GO

IF OBJECT_ID(N'dbo.Companies', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Companies (
    CompanyID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Companies PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    NTNNumber NVARCHAR(20) NOT NULL,
    CNIC NVARCHAR(20) NULL,
    Address NVARCHAR(255) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Province NVARCHAR(50) NOT NULL,
    ContactPerson NVARCHAR(100) NOT NULL,
    ContactEmail NVARCHAR(100) NOT NULL,
    ContactPhone NVARCHAR(20) NOT NULL,
    BusinessNameForSalesInvoice NVARCHAR(255) NULL,
    BusinessActivity NVARCHAR(MAX) NULL,
    Sector NVARCHAR(MAX) NULL,
    FBRToken NVARCHAR(500) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Companies_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Companies_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Companies_UpdatedAt DEFAULT GETDATE()
  );
  PRINT 'Table Companies created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Companies already exists.';
END
GO

IF COL_LENGTH('dbo.Companies', 'CNIC') IS NULL
BEGIN
  ALTER TABLE dbo.Companies ADD CNIC NVARCHAR(20) NULL;
  PRINT 'Companies.CNIC added.';
END
GO

IF COL_LENGTH('dbo.Companies', 'BusinessNameForSalesInvoice') IS NULL
BEGIN
  ALTER TABLE dbo.Companies ADD BusinessNameForSalesInvoice NVARCHAR(255) NULL;
  PRINT 'Companies.BusinessNameForSalesInvoice added.';
END
GO

IF COL_LENGTH('dbo.Companies', 'BusinessActivity') IS NULL
BEGIN
  ALTER TABLE dbo.Companies ADD BusinessActivity NVARCHAR(MAX) NULL;
  PRINT 'Companies.BusinessActivity added.';
END
GO

IF COL_LENGTH('dbo.Companies', 'Sector') IS NULL
BEGIN
  ALTER TABLE dbo.Companies ADD Sector NVARCHAR(MAX) NULL;
  PRINT 'Companies.Sector added.';
END
GO

IF COL_LENGTH('dbo.Companies', 'FBRToken') IS NULL
BEGIN
  ALTER TABLE dbo.Companies ADD FBRToken NVARCHAR(500) NULL;
  PRINT 'Companies.FBRToken added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Companies_CNIC' AND object_id = OBJECT_ID(N'dbo.Companies'))
BEGIN
  CREATE INDEX IX_Companies_CNIC ON dbo.Companies(CNIC);
  PRINT 'Index IX_Companies_CNIC created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Companies_BusinessActivity_JSON' AND parent_object_id = OBJECT_ID(N'dbo.Companies'))
BEGIN
  ALTER TABLE dbo.Companies ADD CONSTRAINT CK_Companies_BusinessActivity_JSON
    CHECK (BusinessActivity IS NULL OR ISJSON(BusinessActivity) = 1);
  PRINT 'Constraint CK_Companies_BusinessActivity_JSON created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Companies_Sector_JSON' AND parent_object_id = OBJECT_ID(N'dbo.Companies'))
BEGIN
  ALTER TABLE dbo.Companies ADD CONSTRAINT CK_Companies_Sector_JSON
    CHECK (Sector IS NULL OR ISJSON(Sector) = 1);
  PRINT 'Constraint CK_Companies_Sector_JSON created.';
END
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Users (
    UserID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Users PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NULL,
    Username NVARCHAR(50) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Role NVARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT GETDATE(),
    CONSTRAINT UQ_Users_Username UNIQUE (Username)
  );
  PRINT 'Table Users created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Users already exists.';
END
GO

IF COL_LENGTH('dbo.Users', 'CompanyID') IS NULL
BEGIN
  ALTER TABLE dbo.Users ADD CompanyID UNIQUEIDENTIFIER NULL;
  PRINT 'Users.CompanyID added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Users_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Users'))
BEGIN
  IF COL_LENGTH('dbo.Users', 'CompanyID') IS NOT NULL
  BEGIN
    ALTER TABLE dbo.Users WITH NOCHECK
      ADD CONSTRAINT FK_Users_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
    PRINT 'FK_Users_Companies created.';
  END
END
GO

IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Customers (
    CustomerID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Customers PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    Buyer_NTNCNIC NVARCHAR(20) NOT NULL,
    Buyer_Business_Name NVARCHAR(100) NOT NULL,
    Buyer_Province NVARCHAR(50) NOT NULL,
    Buyer_Address NVARCHAR(255) NOT NULL,
    Buyer_RegistrationType NVARCHAR(20) NOT NULL,
    Buyer_RegistrationNo NVARCHAR(50) NULL,
    Buyer_Email NVARCHAR(100) NULL,
    Buyer_Cellphone NVARCHAR(20) NULL,
    ContactPersonName NVARCHAR(100) NULL,
    BusinessActivity NVARCHAR(MAX) NULL,
    Sector NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Customers_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Customers_UpdatedAt DEFAULT GETDATE()
  );
  PRINT 'Table Customers created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Customers already exists.';
END
GO

IF COL_LENGTH('dbo.Customers', 'Buyer_RegistrationNo') IS NULL
BEGIN
  ALTER TABLE dbo.Customers ADD Buyer_RegistrationNo NVARCHAR(50) NULL;
  PRINT 'Customers.Buyer_RegistrationNo added.';
END
GO

IF COL_LENGTH('dbo.Customers', 'Buyer_Email') IS NULL
BEGIN
  ALTER TABLE dbo.Customers ADD Buyer_Email NVARCHAR(100) NULL;
  PRINT 'Customers.Buyer_Email added.';
END
GO

IF COL_LENGTH('dbo.Customers', 'Buyer_Cellphone') IS NULL
BEGIN
  ALTER TABLE dbo.Customers ADD Buyer_Cellphone NVARCHAR(20) NULL;
  PRINT 'Customers.Buyer_Cellphone added.';
END
GO

IF COL_LENGTH('dbo.Customers', 'ContactPersonName') IS NULL
BEGIN
  ALTER TABLE dbo.Customers ADD ContactPersonName NVARCHAR(100) NULL;
  PRINT 'Customers.ContactPersonName added.';
END
GO

IF COL_LENGTH('dbo.Customers', 'BusinessActivity') IS NULL
BEGIN
  ALTER TABLE dbo.Customers ADD BusinessActivity NVARCHAR(MAX) NULL;
  PRINT 'Customers.BusinessActivity added.';
END
GO

IF COL_LENGTH('dbo.Customers', 'Sector') IS NULL
BEGIN
  ALTER TABLE dbo.Customers ADD Sector NVARCHAR(MAX) NULL;
  PRINT 'Customers.Sector added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Customers_BusinessActivity_JSON' AND parent_object_id = OBJECT_ID(N'dbo.Customers'))
BEGIN
  ALTER TABLE dbo.Customers ADD CONSTRAINT CK_Customers_BusinessActivity_JSON
    CHECK (BusinessActivity IS NULL OR ISJSON(BusinessActivity) = 1);
  PRINT 'Constraint CK_Customers_BusinessActivity_JSON created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Customers_Sector_JSON' AND parent_object_id = OBJECT_ID(N'dbo.Customers'))
BEGIN
  ALTER TABLE dbo.Customers ADD CONSTRAINT CK_Customers_Sector_JSON
    CHECK (Sector IS NULL OR ISJSON(Sector) = 1);
  PRINT 'Constraint CK_Customers_Sector_JSON created.';
END
GO

IF COL_LENGTH('dbo.Customers', 'BuyerBusinessName') IS NULL AND COL_LENGTH('dbo.Customers', 'Buyer_Business_Name') IS NOT NULL
BEGIN
  ALTER TABLE dbo.Customers ADD BuyerBusinessName AS (Buyer_Business_Name) PERSISTED;
  PRINT 'Customers.BuyerBusinessName computed column added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Customers_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Customers'))
BEGIN
  ALTER TABLE dbo.Customers WITH NOCHECK
    ADD CONSTRAINT FK_Customers_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_Customers_Companies created.';
END
GO

IF OBJECT_ID(N'dbo.Vendors', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Vendors (
    VendorID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Vendors PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    VendorName NVARCHAR(255) NOT NULL,
    VendorNTN NVARCHAR(50) NULL,
    ContactPersonName NVARCHAR(255) NULL,
    VendorCNIC NVARCHAR(15) NULL,
    Address NVARCHAR(500) NULL,
    Phone NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    VendorAddress NVARCHAR(500) NULL,
    VendorPhone NVARCHAR(20) NULL,
    VendorEmail NVARCHAR(255) NULL,
    BusinessActivity NVARCHAR(MAX) NULL,
    Sector NVARCHAR(MAX) NULL,
    CreatedBy UNIQUEIDENTIFIER NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Vendors_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Vendors_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Vendors_UpdatedAt DEFAULT GETDATE()
  );
  PRINT 'Table Vendors created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Vendors already exists.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'VendorNTN') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD VendorNTN NVARCHAR(50) NULL;
  PRINT 'Vendors.VendorNTN added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'ContactPersonName') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD ContactPersonName NVARCHAR(255) NULL;
  PRINT 'Vendors.ContactPersonName added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'VendorCNIC') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD VendorCNIC NVARCHAR(15) NULL;
  PRINT 'Vendors.VendorCNIC added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'VendorAddress') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD VendorAddress NVARCHAR(500) NULL;
  PRINT 'Vendors.VendorAddress added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'VendorPhone') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD VendorPhone NVARCHAR(20) NULL;
  PRINT 'Vendors.VendorPhone added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'VendorEmail') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD VendorEmail NVARCHAR(255) NULL;
  PRINT 'Vendors.VendorEmail added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'CreatedBy') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD CreatedBy UNIQUEIDENTIFIER NULL;
  PRINT 'Vendors.CreatedBy added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'Address') IS NOT NULL AND COL_LENGTH('dbo.Vendors', 'VendorAddress') IS NOT NULL
BEGIN
  UPDATE dbo.Vendors
  SET VendorAddress = COALESCE(VendorAddress, Address)
  WHERE VendorAddress IS NULL AND Address IS NOT NULL;
END
GO

IF COL_LENGTH('dbo.Vendors', 'Phone') IS NOT NULL AND COL_LENGTH('dbo.Vendors', 'VendorPhone') IS NOT NULL
BEGIN
  UPDATE dbo.Vendors
  SET VendorPhone = COALESCE(VendorPhone, Phone)
  WHERE VendorPhone IS NULL AND Phone IS NOT NULL;
END
GO

IF COL_LENGTH('dbo.Vendors', 'Email') IS NOT NULL AND COL_LENGTH('dbo.Vendors', 'VendorEmail') IS NOT NULL
BEGIN
  UPDATE dbo.Vendors
  SET VendorEmail = COALESCE(VendorEmail, Email)
  WHERE VendorEmail IS NULL AND Email IS NOT NULL;
END
GO

IF COL_LENGTH('dbo.Vendors', 'BusinessActivity') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD BusinessActivity NVARCHAR(MAX) NULL;
  PRINT 'Vendors.BusinessActivity added.';
END
GO

IF COL_LENGTH('dbo.Vendors', 'Sector') IS NULL
BEGIN
  ALTER TABLE dbo.Vendors ADD Sector NVARCHAR(MAX) NULL;
  PRINT 'Vendors.Sector added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Vendors_BusinessActivity_JSON' AND parent_object_id = OBJECT_ID(N'dbo.Vendors'))
BEGIN
  ALTER TABLE dbo.Vendors ADD CONSTRAINT CK_Vendors_BusinessActivity_JSON
    CHECK (BusinessActivity IS NULL OR ISJSON(BusinessActivity) = 1);
  PRINT 'Constraint CK_Vendors_BusinessActivity_JSON created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Vendors_Sector_JSON' AND parent_object_id = OBJECT_ID(N'dbo.Vendors'))
BEGIN
  ALTER TABLE dbo.Vendors ADD CONSTRAINT CK_Vendors_Sector_JSON
    CHECK (Sector IS NULL OR ISJSON(Sector) = 1);
  PRINT 'Constraint CK_Vendors_Sector_JSON created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Vendors_ContactPersonName' AND object_id = OBJECT_ID(N'dbo.Vendors'))
BEGIN
  CREATE INDEX IX_Vendors_ContactPersonName ON dbo.Vendors(ContactPersonName);
  PRINT 'Index IX_Vendors_ContactPersonName created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Vendors_VendorCNIC' AND object_id = OBJECT_ID(N'dbo.Vendors'))
BEGIN
  CREATE INDEX IX_Vendors_VendorCNIC ON dbo.Vendors(VendorCNIC);
  PRINT 'Index IX_Vendors_VendorCNIC created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Vendors_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Vendors'))
BEGIN
  ALTER TABLE dbo.Vendors WITH NOCHECK
    ADD CONSTRAINT FK_Vendors_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_Vendors_Companies created.';
END
GO

IF OBJECT_ID(N'dbo.Items', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Items (
    ItemID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Items PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    HSCode NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    PurchaseTaxValue DECIMAL(5, 2) NOT NULL CONSTRAINT DF_Items_PurchaseTaxValue DEFAULT 0,
    SalesTaxValue DECIMAL(5, 2) NOT NULL CONSTRAINT DF_Items_SalesTaxValue DEFAULT 0,
    UoM NVARCHAR(50) NOT NULL CONSTRAINT DF_Items_UoM DEFAULT N'PCS',
    InitialStock DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Items_InitialStock DEFAULT 0,
    IsActive BIT NOT NULL CONSTRAINT DF_Items_IsActive DEFAULT 1,
    CreatedBy UNIQUEIDENTIFIER NULL,
    ItemCreateDate DATETIME NOT NULL CONSTRAINT DF_Items_ItemCreateDate DEFAULT GETDATE(),
    CreatedAt DATETIME NULL,
    UpdatedAt DATETIME NULL
  );
  PRINT 'Table Items created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Items already exists.';
END
GO

IF COL_LENGTH('dbo.Items', 'InitialStock') IS NULL
BEGIN
  ALTER TABLE dbo.Items ADD InitialStock DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Items_InitialStock_Alt DEFAULT 0;
  PRINT 'Items.InitialStock added.';
END
GO

IF EXISTS (
  SELECT 1
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'Items'
    AND COLUMN_NAME = 'UoM'
    AND CHARACTER_MAXIMUM_LENGTH IS NOT NULL
    AND CHARACTER_MAXIMUM_LENGTH < 50
)
BEGIN
  ALTER TABLE dbo.Items ALTER COLUMN UoM NVARCHAR(50) NOT NULL;
  PRINT 'Items.UoM altered to NVARCHAR(50).';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Items_CompanyID' AND object_id = OBJECT_ID(N'dbo.Items'))
BEGIN
  CREATE INDEX IX_Items_CompanyID ON dbo.Items(CompanyID);
  PRINT 'Index IX_Items_CompanyID created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Items_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Items'))
BEGIN
  ALTER TABLE dbo.Items WITH NOCHECK
    ADD CONSTRAINT FK_Items_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_Items_Companies created.';
END
GO

IF OBJECT_ID(N'dbo.Invoices', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Invoices (
    InvoiceID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Invoices PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    CustomerID UNIQUEIDENTIFIER NULL,
    InvoiceNumber NVARCHAR(50) NOT NULL,
    InvoiceType NVARCHAR(50) NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    SellerNTNCNIC NVARCHAR(20) NOT NULL,
    SellerBusinessName NVARCHAR(255) NOT NULL,
    SellerProvince NVARCHAR(50) NOT NULL,
    SellerAddress NVARCHAR(255) NOT NULL,
    BuyerNTNCNIC NVARCHAR(20) NOT NULL,
    BuyerBusinessName NVARCHAR(255) NOT NULL,
    BuyerProvince NVARCHAR(50) NOT NULL,
    BuyerAddress NVARCHAR(255) NOT NULL,
    BuyerRegistrationType NVARCHAR(50) NOT NULL,
    InvoiceRefNo NVARCHAR(50) NOT NULL CONSTRAINT DF_Invoices_InvoiceRefNo DEFAULT N'',
    PONumber NVARCHAR(50) NULL,
    DeliveryChallanNo NVARCHAR(50) NULL,
    DeliveryChallanDate DATETIME NULL,
    ScenarioID NVARCHAR(20) NOT NULL,
    TotalAmount DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Invoices_TotalAmount DEFAULT 0,
    TotalSalesTax DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Invoices_TotalSalesTax DEFAULT 0,
    TotalFurtherTax DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Invoices_TotalFurtherTax DEFAULT 0,
    TotalDiscount DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Invoices_TotalDiscount DEFAULT 0,
    FBRInvoiceNumber NVARCHAR(50) NULL,
    FBRResponseStatus NVARCHAR(10) NULL,
    FBRResponseMessage NVARCHAR(255) NULL,
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Invoices_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Invoices_UpdatedAt DEFAULT GETDATE()
  );
  PRINT 'Table Invoices created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Invoices already exists.';
END
GO

IF COL_LENGTH('dbo.Invoices', 'PONumber') IS NULL
BEGIN
  ALTER TABLE dbo.Invoices ADD PONumber NVARCHAR(50) NULL;
  PRINT 'Invoices.PONumber added.';
END
GO

IF COL_LENGTH('dbo.Invoices', 'DeliveryChallanNo') IS NULL
BEGIN
  ALTER TABLE dbo.Invoices ADD DeliveryChallanNo NVARCHAR(50) NULL;
  PRINT 'Invoices.DeliveryChallanNo added.';
END
GO

IF COL_LENGTH('dbo.Invoices', 'DeliveryChallanDate') IS NULL
BEGIN
  ALTER TABLE dbo.Invoices ADD DeliveryChallanDate DATETIME NULL;
  PRINT 'Invoices.DeliveryChallanDate added.';
END
GO

IF COL_LENGTH('dbo.Invoices', 'CustomerID') IS NULL
BEGIN
  ALTER TABLE dbo.Invoices ADD CustomerID UNIQUEIDENTIFIER NULL;
  PRINT 'Invoices.CustomerID added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Invoices_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Invoices'))
BEGIN
  ALTER TABLE dbo.Invoices WITH NOCHECK
    ADD CONSTRAINT FK_Invoices_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_Invoices_Companies created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Invoices_Customers' AND parent_object_id = OBJECT_ID(N'dbo.Invoices'))
BEGIN
  IF COL_LENGTH('dbo.Invoices', 'CustomerID') IS NOT NULL AND OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL
  BEGIN
    ALTER TABLE dbo.Invoices WITH NOCHECK
      ADD CONSTRAINT FK_Invoices_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID);
    PRINT 'FK_Invoices_Customers created.';
  END
END
GO

IF OBJECT_ID(N'dbo.InvoiceItems', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.InvoiceItems (
    ItemID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_InvoiceItems PRIMARY KEY DEFAULT NEWID(),
    InvoiceID UNIQUEIDENTIFIER NOT NULL,
    MasterItemID UNIQUEIDENTIFIER NULL,
    HSCode NVARCHAR(50) NOT NULL,
    ProductDescription NVARCHAR(255) NOT NULL,
    Rate NVARCHAR(20) NOT NULL,
    UoM NVARCHAR(50) NOT NULL,
    Quantity DECIMAL(18, 4) NOT NULL,
    TotalValues DECIMAL(18, 2) NOT NULL,
    ValueSalesExcludingST DECIMAL(18, 2) NOT NULL,
    FixedNotifiedValueOrRetailPrice DECIMAL(18, 2) NOT NULL,
    SalesTaxApplicable DECIMAL(18, 2) NOT NULL,
    SalesTaxWithheldAtSource DECIMAL(18, 2) NOT NULL,
    ExtraTax DECIMAL(18, 2) NOT NULL,
    FurtherTax DECIMAL(18, 2) NOT NULL,
    SROScheduleNo NVARCHAR(50) NULL,
    FEDPayable DECIMAL(18, 2) NOT NULL,
    Discount DECIMAL(18, 2) NOT NULL,
    SaleType NVARCHAR(100) NOT NULL,
    SROItemSerialNo NVARCHAR(50) NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_InvoiceItems_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_InvoiceItems_UpdatedAt DEFAULT GETDATE()
  );
  PRINT 'Table InvoiceItems created successfully.';
END
ELSE
BEGIN
  PRINT 'Table InvoiceItems already exists.';
END
GO

IF COL_LENGTH('dbo.InvoiceItems', 'MasterItemID') IS NULL
BEGIN
  ALTER TABLE dbo.InvoiceItems ADD MasterItemID UNIQUEIDENTIFIER NULL;
  PRINT 'InvoiceItems.MasterItemID added.';
END
GO

IF EXISTS (
  SELECT 1
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvoiceItems'
    AND COLUMN_NAME = 'UoM'
    AND CHARACTER_MAXIMUM_LENGTH IS NOT NULL
    AND CHARACTER_MAXIMUM_LENGTH < 50
)
BEGIN
  DECLARE @InvoiceItemsUomIsNullable NVARCHAR(3);
  SELECT @InvoiceItemsUomIsNullable = IS_NULLABLE
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvoiceItems'
    AND COLUMN_NAME = 'UoM';

  IF (@InvoiceItemsUomIsNullable = 'YES')
    EXEC('ALTER TABLE dbo.InvoiceItems ALTER COLUMN UoM NVARCHAR(50) NULL;');
  ELSE
    EXEC('ALTER TABLE dbo.InvoiceItems ALTER COLUMN UoM NVARCHAR(50) NOT NULL;');

  PRINT 'InvoiceItems.UoM altered to NVARCHAR(50).';
END
GO

IF COL_LENGTH('dbo.InvoiceItems', 'ProductName') IS NULL AND COL_LENGTH('dbo.InvoiceItems', 'ProductDescription') IS NOT NULL
BEGIN
  ALTER TABLE dbo.InvoiceItems ADD ProductName AS (ProductDescription) PERSISTED;
  PRINT 'InvoiceItems.ProductName computed column added.';
END
GO

IF COL_LENGTH('dbo.InvoiceItems', 'TotalAmount') IS NULL AND COL_LENGTH('dbo.InvoiceItems', 'TotalValues') IS NOT NULL
BEGIN
  ALTER TABLE dbo.InvoiceItems ADD TotalAmount AS (TotalValues) PERSISTED;
  PRINT 'InvoiceItems.TotalAmount computed column added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_InvoiceItems_Invoices' AND parent_object_id = OBJECT_ID(N'dbo.InvoiceItems'))
BEGIN
  ALTER TABLE dbo.InvoiceItems WITH NOCHECK
    ADD CONSTRAINT FK_InvoiceItems_Invoices FOREIGN KEY (InvoiceID) REFERENCES dbo.Invoices(InvoiceID);
  PRINT 'FK_InvoiceItems_Invoices created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_InvoiceItems_MasterItem' AND parent_object_id = OBJECT_ID(N'dbo.InvoiceItems'))
BEGIN
  IF COL_LENGTH('dbo.InvoiceItems', 'MasterItemID') IS NOT NULL AND OBJECT_ID(N'dbo.Items', N'U') IS NOT NULL
  BEGIN
    ALTER TABLE dbo.InvoiceItems WITH NOCHECK
      ADD CONSTRAINT FK_InvoiceItems_MasterItem FOREIGN KEY (MasterItemID) REFERENCES dbo.Items(ItemID);
    PRINT 'FK_InvoiceItems_MasterItem created.';
  END
END
GO

IF OBJECT_ID(N'dbo.Inventory', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Inventory (
    InventoryID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Inventory PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    ProductCode NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    CurrentStock INT NOT NULL CONSTRAINT DF_Inventory_CurrentStock DEFAULT 0,
    MinStock INT NOT NULL CONSTRAINT DF_Inventory_MinStock DEFAULT 0,
    UnitPrice DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Inventory_UnitPrice DEFAULT 0,
    TotalValue AS (CurrentStock * UnitPrice) PERSISTED,
    IsActive BIT NOT NULL CONSTRAINT DF_Inventory_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Inventory_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Inventory_UpdatedAt DEFAULT GETDATE(),
    CONSTRAINT UQ_Inventory_Company_ProductCode UNIQUE (CompanyID, ProductCode)
  );
  PRINT 'Table Inventory created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Inventory already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Inventory_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Inventory'))
BEGIN
  ALTER TABLE dbo.Inventory WITH NOCHECK
    ADD CONSTRAINT FK_Inventory_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_Inventory_Companies created.';
END
GO

IF OBJECT_ID(N'dbo.Purchases', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Purchases (
    PurchaseID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Purchases PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    PONumber NVARCHAR(50) NULL,
    PODate DATE NULL,
    CRNumber NVARCHAR(50) NULL,
    Date DATE NULL,
    VendorID UNIQUEIDENTIFIER NOT NULL,
    VendorName NVARCHAR(255) NOT NULL,
    TotalAmount DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Purchases_TotalAmount DEFAULT 0,
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Purchases_Status DEFAULT N'pending',
    StockApplied BIT NOT NULL CONSTRAINT DF_Purchases_StockApplied DEFAULT 0,
    IsActive BIT NOT NULL CONSTRAINT DF_Purchases_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Purchases_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_Purchases_UpdatedAt DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NULL
  );
  PRINT 'Table Purchases created successfully.';
END
ELSE
BEGIN
  PRINT 'Table Purchases already exists.';
END
GO

IF COL_LENGTH('dbo.Purchases', 'CRNumber') IS NULL
BEGIN
  ALTER TABLE dbo.Purchases ADD CRNumber NVARCHAR(50) NULL;
  PRINT 'Purchases.CRNumber added.';
END
GO

IF COL_LENGTH('dbo.Purchases', 'Date') IS NULL
BEGIN
  ALTER TABLE dbo.Purchases ADD Date DATE NULL;
  PRINT 'Purchases.Date added.';
END
GO

IF COL_LENGTH('dbo.Purchases', 'StockApplied') IS NULL
BEGIN
  ALTER TABLE dbo.Purchases ADD StockApplied BIT NOT NULL CONSTRAINT DF_Purchases_StockApplied_Alt DEFAULT 0;
  PRINT 'Purchases.StockApplied added.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Purchases_CompanyID' AND object_id = OBJECT_ID(N'dbo.Purchases'))
BEGIN
  CREATE INDEX IX_Purchases_CompanyID ON dbo.Purchases(CompanyID);
  PRINT 'Index IX_Purchases_CompanyID created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Purchases_VendorID' AND object_id = OBJECT_ID(N'dbo.Purchases'))
BEGIN
  CREATE INDEX IX_Purchases_VendorID ON dbo.Purchases(VendorID);
  PRINT 'Index IX_Purchases_VendorID created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Purchases_CRNumber' AND object_id = OBJECT_ID(N'dbo.Purchases'))
BEGIN
  CREATE INDEX IX_Purchases_CRNumber ON dbo.Purchases(CRNumber);
  PRINT 'Index IX_Purchases_CRNumber created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Purchases_Date' AND object_id = OBJECT_ID(N'dbo.Purchases'))
BEGIN
  CREATE INDEX IX_Purchases_Date ON dbo.Purchases(Date);
  PRINT 'Index IX_Purchases_Date created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Purchases_Companies' AND parent_object_id = OBJECT_ID(N'dbo.Purchases'))
BEGIN
  ALTER TABLE dbo.Purchases WITH NOCHECK
    ADD CONSTRAINT FK_Purchases_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_Purchases_Companies created.';
END
GO

IF OBJECT_ID(N'dbo.PurchaseItems', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.PurchaseItems (
    PurchaseItemID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_PurchaseItems PRIMARY KEY DEFAULT NEWID(),
    PurchaseID UNIQUEIDENTIFIER NOT NULL,
    ItemID NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(255) NOT NULL,
    PurchasePrice DECIMAL(18, 2) NOT NULL,
    PurchaseQty DECIMAL(18, 2) NOT NULL,
    TotalAmount DECIMAL(18, 2) NOT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_PurchaseItems_CreatedAt DEFAULT GETDATE()
  );
  PRINT 'Table PurchaseItems created successfully.';
END
ELSE
BEGIN
  PRINT 'Table PurchaseItems already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PurchaseItems_PurchaseID' AND object_id = OBJECT_ID(N'dbo.PurchaseItems'))
BEGIN
  CREATE INDEX IX_PurchaseItems_PurchaseID ON dbo.PurchaseItems(PurchaseID);
  PRINT 'Index IX_PurchaseItems_PurchaseID created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PurchaseItems_Purchases' AND parent_object_id = OBJECT_ID(N'dbo.PurchaseItems'))
BEGIN
  ALTER TABLE dbo.PurchaseItems WITH NOCHECK
    ADD CONSTRAINT FK_PurchaseItems_Purchases FOREIGN KEY (PurchaseID) REFERENCES dbo.Purchases(PurchaseID);
  PRINT 'FK_PurchaseItems_Purchases created.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.ScenarioMapping (
    id INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_ScenarioMapping PRIMARY KEY,
    business_activity NVARCHAR(100) NOT NULL,
    sector NVARCHAR(100) NOT NULL,
    applicable_scenarios NVARCHAR(MAX) NOT NULL,
    is_active BIT NOT NULL CONSTRAINT DF_ScenarioMapping_is_active DEFAULT 1,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_ScenarioMapping_created_at DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL CONSTRAINT DF_ScenarioMapping_updated_at DEFAULT GETDATE(),
    BusinessActivity NVARCHAR(100) NULL,
    ApplicableScenarios NVARCHAR(MAX) NULL,
    IsActive BIT NULL,
    CreatedAt DATETIME2 NULL,
    UpdatedAt DATETIME2 NULL
  );
  PRINT 'Table ScenarioMapping created successfully.';
END
ELSE
BEGIN
  PRINT 'Table ScenarioMapping already exists.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'business_activity') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD business_activity NVARCHAR(100) NULL;
  PRINT 'ScenarioMapping.business_activity added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'sector') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD sector NVARCHAR(100) NULL;
  PRINT 'ScenarioMapping.sector added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'applicable_scenarios') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD applicable_scenarios NVARCHAR(MAX) NULL;
  PRINT 'ScenarioMapping.applicable_scenarios added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'is_active') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD is_active BIT NULL;
  PRINT 'ScenarioMapping.is_active added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'created_at') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD created_at DATETIME2 NULL;
  PRINT 'ScenarioMapping.created_at added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'updated_at') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD updated_at DATETIME2 NULL;
  PRINT 'ScenarioMapping.updated_at added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'BusinessActivity') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD BusinessActivity NVARCHAR(100) NULL;
  PRINT 'ScenarioMapping.BusinessActivity added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'ApplicableScenarios') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD ApplicableScenarios NVARCHAR(MAX) NULL;
  PRINT 'ScenarioMapping.ApplicableScenarios added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'IsActive') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD IsActive BIT NULL;
  PRINT 'ScenarioMapping.IsActive added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'CreatedAt') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD CreatedAt DATETIME2 NULL;
  PRINT 'ScenarioMapping.CreatedAt added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL AND COL_LENGTH('dbo.ScenarioMapping', 'UpdatedAt') IS NULL
BEGIN
  ALTER TABLE dbo.ScenarioMapping ADD UpdatedAt DATETIME2 NULL;
  PRINT 'ScenarioMapping.UpdatedAt added.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ScenarioMapping_BusinessActivity_Sector' AND object_id = OBJECT_ID(N'dbo.ScenarioMapping'))
BEGIN
  CREATE INDEX IX_ScenarioMapping_BusinessActivity_Sector ON dbo.ScenarioMapping (business_activity, sector);
  PRINT 'Index IX_ScenarioMapping_BusinessActivity_Sector created.';
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL
BEGIN
  UPDATE sm
  SET
    BusinessActivity = COALESCE(sm.BusinessActivity, sm.business_activity),
    ApplicableScenarios = COALESCE(
      sm.ApplicableScenarios,
      CASE
        WHEN sm.applicable_scenarios IS NULL THEN NULL
        WHEN ISJSON(sm.applicable_scenarios) = 1 THEN
          STUFF((
            SELECT N',' + j.[value]
            FROM OPENJSON(sm.applicable_scenarios) j
            FOR XML PATH(''), TYPE
          ).value('.', 'NVARCHAR(MAX)'), 1, 1, N'')
        ELSE sm.applicable_scenarios
      END
    ),
    IsActive = COALESCE(sm.IsActive, sm.is_active),
    CreatedAt = COALESCE(sm.CreatedAt, sm.created_at),
    UpdatedAt = COALESCE(sm.UpdatedAt, sm.updated_at)
  FROM dbo.ScenarioMapping sm;
END
GO

IF OBJECT_ID(N'dbo.ScenarioMapping', N'U') IS NOT NULL
BEGIN
  IF OBJECT_ID(N'dbo.TR_ScenarioMapping_Sync', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_ScenarioMapping_Sync;

  DECLARE @CreateScenarioMappingTrigger NVARCHAR(MAX) = N'
    CREATE TRIGGER dbo.TR_ScenarioMapping_Sync
    ON dbo.ScenarioMapping
    AFTER INSERT, UPDATE
    AS
    BEGIN
      SET NOCOUNT ON;

      UPDATE sm
      SET
        BusinessActivity = sm.business_activity,
        ApplicableScenarios =
          CASE
            WHEN sm.applicable_scenarios IS NULL THEN NULL
            WHEN ISJSON(sm.applicable_scenarios) = 1 THEN
              STUFF((
                SELECT N'','' + j.[value]
                FROM OPENJSON(sm.applicable_scenarios) j
                FOR XML PATH(''''), TYPE
              ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, N'''')
            ELSE sm.applicable_scenarios
          END,
        IsActive = sm.is_active,
        CreatedAt = sm.created_at,
        UpdatedAt = sm.updated_at
      FROM dbo.ScenarioMapping sm
      INNER JOIN inserted i ON sm.id = i.id;
    END';

  EXEC sp_executesql @CreateScenarioMappingTrigger;
END
GO

IF OBJECT_ID(N'dbo.FBRApiTokens', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.FBRApiTokens (
    TokenID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_FBRApiTokens PRIMARY KEY DEFAULT NEWID(),
    CompanyID UNIQUEIDENTIFIER NOT NULL,
    TokenValue NVARCHAR(255) NOT NULL,
    Environment NVARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_FBRApiTokens_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_FBRApiTokens_CreatedAt DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL CONSTRAINT DF_FBRApiTokens_UpdatedAt DEFAULT GETDATE()
  );
  PRINT 'Table FBRApiTokens created successfully.';
END
ELSE
BEGIN
  PRINT 'Table FBRApiTokens already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_FBRApiTokens_Companies' AND parent_object_id = OBJECT_ID(N'dbo.FBRApiTokens'))
BEGIN
  ALTER TABLE dbo.FBRApiTokens WITH NOCHECK
    ADD CONSTRAINT FK_FBRApiTokens_Companies FOREIGN KEY (CompanyID) REFERENCES dbo.Companies(CompanyID);
  PRINT 'FK_FBRApiTokens_Companies created.';
END
GO

PRINT 'Database update completed successfully.';
GO
