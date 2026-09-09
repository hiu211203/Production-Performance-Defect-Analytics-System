-- 1. Tạo Database mới
CREATE DATABASE ERP_ManufacturingDB;
GO

USE ERP_ManufacturingDB;
GO

-- 2. Tạo Bảng Raw_ERP_Data chứa chính xác 67 cột dữ liệu từ file txt
IF OBJECT_ID('dbo.Raw_ERP_Data', 'U') IS NOT NULL 
    DROP TABLE dbo.Raw_ERP_Data;
GO

CREATE TABLE dbo.Raw_ERP_Data (
    [Buyer] NVARCHAR(MAX),
    [Cust Code] NVARCHAR(MAX),
    [Cust Name] NVARCHAR(MAX),
    [Delivery Period] NVARCHAR(MAX),
    [Department Name] NVARCHAR(MAX),
    [Designer] NVARCHAR(MAX),
    [Doc Date] NVARCHAR(MAX),
    [Doc Num] NVARCHAR(MAX),
    [EMP Code] NVARCHAR(MAX),
    [Emp Name] NVARCHAR(MAX),
    [EMPCode (MEMP)] NVARCHAR(MAX),
    [End Time] NVARCHAR(MAX),
    [Fiscal Date] NVARCHAR(MAX),
    [Fiscal DateTime] NVARCHAR(MAX),
    [Form Type] NVARCHAR(MAX),
    [In Active] NVARCHAR(MAX),
    [Is Final Process] NVARCHAR(MAX),
    [Item Code] NVARCHAR(MAX),
    [Item Name] NVARCHAR(MAX),
    [Machine / Employee] NVARCHAR(MAX),
    [Machine Code] NVARCHAR(MAX),
    [Machine Code (EMP)] NVARCHAR(MAX),
    [Machine Name] NVARCHAR(MAX),
    [Machine Name (EMP)] NVARCHAR(MAX),
    [Operation Code] NVARCHAR(MAX),
    [Operation Name] NVARCHAR(MAX),
    [Rpm] NVARCHAR(MAX),
    [SAP So Num] NVARCHAR(MAX),
    [Sapgrno] NVARCHAR(MAX),
    [Shift Code] NVARCHAR(MAX),
    [Shortages] NVARCHAR(MAX),
    [SNO] NVARCHAR(MAX),
    [SO Del Date] NVARCHAR(MAX),
    [SO Delivery Date] NVARCHAR(MAX),
    [SO Docdate] NVARCHAR(MAX),
    [SO DocDate F] NVARCHAR(MAX),
    [SO Expected Delivery F] NVARCHAR(MAX),
    [SO Num] NVARCHAR(MAX),
    [So Posting Date] NVARCHAR(MAX),
    [Start Time] NVARCHAR(MAX),
    [U_GRCDate] NVARCHAR(MAX),
    [U_GRRate] NVARCHAR(MAX),
    [U_unitdeldt] NVARCHAR(MAX),
    [User Id] NVARCHAR(MAX),
    [User Id1] NVARCHAR(MAX),
    [User Name] NVARCHAR(MAX),
    [Variant Name] NVARCHAR(MAX),
    [WO Date] NVARCHAR(MAX),
    [WO Number] NVARCHAR(MAX),
    [WO Status] NVARCHAR(MAX),
    [Work Centre Code] NVARCHAR(MAX),
    [Work Centre Name] NVARCHAR(MAX),
    [Balance Qty] NVARCHAR(MAX),
    [Docnum] NVARCHAR(MAX),
    [Final Processed Qty] NVARCHAR(MAX),
    [Fiscal Year] NVARCHAR(MAX),
    [Man/Rejc] NVARCHAR(MAX),
    [Manufactured Qty] NVARCHAR(MAX),
    [Per day Machine Cost made] NVARCHAR(MAX),
    [Press Qty] NVARCHAR(MAX),
    [Processed Qty] NVARCHAR(MAX),
    [Produced Qty] NVARCHAR(MAX),
    [Rejected Qty] NVARCHAR(MAX),
    [Repeat] NVARCHAR(MAX),
    [today Manufactured qty] NVARCHAR(MAX),
    [TotalQty] NVARCHAR(MAX),
    [TotalValue] NVARCHAR(MAX),
    [WO Qty] NVARCHAR(MAX)
);
GO

--3. Import dữ liệu từ File
BULK INSERT dbo.Raw_ERP_Data
FROM 'C:\Users\hiuka\Downloads\Production Performance & Defect Analytics System\Data\PROD DATA.txt'
WITH (
    DATAFILETYPE = 'widechar',  --UTF-16 LE
    FIELDTERMINATOR = '\t', -- Dùng '\t' vì file phân tách bằng dấu Tab
    ROWTERMINATOR = '\n',   -- Ký tự xuống dòng
    FIRSTROW = 2    -- Bỏ qua dòng tiêu đề (Header)
);
GO

TRUNCATE TABLE dbo.Raw_ERP_Data; --Xóa toàn bộ dữ liệu

-- Kiểm tra xem dữ liệu đã vào đủ chưa
SELECT COUNT(*) AS TotalRows FROM dbo.Raw_ERP_Data;
SELECT TOP 100 * FROM dbo.Raw_ERP_Data;