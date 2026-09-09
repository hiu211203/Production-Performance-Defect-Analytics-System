USE ERP_ManufacturingDB;
GO

IF OBJECT_ID('dbo.Fact_Production_Clean', 'U') IS NOT NULL 
    DROP TABLE dbo.Fact_Production_Clean;
GO

SELECT 
    -- 1. Xử lý NULL cho Chuỗi Văn Bản (Text) -> Đổi NULL/Trắng thành 'N/A' hoặc 'Unknown'
    ISNULL(NULLIF(TRIM([Cust Code]), ''), 'N/A') AS CustCode,
    ISNULL(NULLIF(TRIM([Cust Name]), ''), 'Unknown Customer') AS CustName,
    ISNULL(NULLIF(TRIM([Buyer]), ''), 'N/A') AS Buyer,
    
    ISNULL(NULLIF(TRIM([WO Number]), ''), 'N/A') AS WONumber,
    ISNULL(NULLIF(TRIM([WO Status]), ''), 'Unknown') AS WOStatus,
    ISNULL(NULLIF(TRIM([Item Code]), ''), 'N/A') AS ItemCode,
    ISNULL(NULLIF(TRIM([Item Name]), ''), 'N/A') AS ItemName,
    
    ISNULL(NULLIF(TRIM([Work Centre Name]), ''), 'Unassigned') AS WorkCenterName,
    ISNULL(NULLIF(TRIM([Machine Name]), ''), 'Unassigned Machine') AS MachineName,
    ISNULL(NULLIF(TRIM([Operation Name]), ''), 'N/A') AS OperationName,
    ISNULL(NULLIF(TRIM([Emp Name]), ''), 'Unknown Operator') AS OperatorName,
    ISNULL(NULLIF(TRIM([Shift Code]), ''), 'N/A') AS ShiftCode,

    -- 2. Xử lý NULL cho Ngày Tháng (Date)
    -- Giữ NULL cho SODeliveryDate (chuẩn ERP đối với hàng tồn kho Make-To-Stock)
    TRY_CAST([SO Delivery Date] AS DATE) AS SODeliveryDate,
    
    -- SỬA LỖI 1: Nếu WODate bị NULL thì tự động lấy FiscalDate làm ngày thay thế
    COALESCE(TRY_CAST([WO Date] AS DATE), TRY_CAST([Fiscal Date] AS DATE)) AS WODate,
    
    TRY_CAST([Fiscal Date] AS DATE) AS FiscalDate,
    ISNULL(TRY_CAST([Fiscal Year] AS INT), YEAR(GETDATE())) AS FiscalYear,

    -- 3. Xử lý NULL cho Các Trường Số (Chuyển NULL/Rỗng về 0)
    ISNULL(TRY_CAST([WO Qty] AS FLOAT), 0) AS WOQty,
    ISNULL(TRY_CAST([Produced Qty] AS FLOAT), 0) AS ProducedQty,
    ISNULL(TRY_CAST([Rejected Qty] AS FLOAT), 0) AS RejectedQty,
    ISNULL(TRY_CAST([Balance Qty] AS FLOAT), 0) AS BalanceQty,
    ISNULL(TRY_CAST([Per day Machine Cost made] AS DECIMAL(18,2)), 0) AS MachineCostPerDay,

    -- 4. TỰ ĐỘNG TÍNH & BẢO VỆ PHÉP TÍNH:
    
    -- Good Qty = ProducedQty - RejectedQty
    (ISNULL(TRY_CAST([Produced Qty] AS FLOAT), 0) - ISNULL(TRY_CAST([Rejected Qty] AS FLOAT), 0)) AS GoodQty,

    -- Yield Percentage (%) -> Chống chia cho 0 hoặc NULL
    CASE 
        WHEN ISNULL(TRY_CAST([Produced Qty] AS FLOAT), 0) > 0 
        THEN ROUND(((ISNULL(TRY_CAST([Produced Qty] AS FLOAT), 0) - ISNULL(TRY_CAST([Rejected Qty] AS FLOAT), 0)) 
                   / TRY_CAST([Produced Qty] AS FLOAT)) * 100, 2)
        ELSE 0.0 
    END AS YieldPercentage,

    -- SỬA LỖI 2: Công thức MaterialLossQty (Chênh lệch giữa Kế hoạch WO và Thực tế Sản xuất)
    -- Giúp tránh bị số âm khó hiểu khi BalanceQty trong ERP chưa được ghi giảm
    (ISNULL(TRY_CAST([WO Qty] AS FLOAT), 0) - ISNULL(TRY_CAST([Produced Qty] AS FLOAT), 0)) AS MaterialLossQty,

    -- THÊM CỘT CẢNH BÁO: Đánh dấu nếu sản xuất vượt định mức kế hoạch (Over-Production)
    CASE 
        WHEN ISNULL(TRY_CAST([Produced Qty] AS FLOAT), 0) > ISNULL(TRY_CAST([WO Qty] AS FLOAT), 0) 
        THEN 'Over-Production'
        ELSE 'Normal'
    END AS ProductionStatus

INTO dbo.Fact_Production_Clean
FROM dbo.Raw_ERP_Data;
GO

-- Kiểm tra kết quả bảng sạch
SELECT TOP 200 * FROM dbo.Fact_Production_Clean;