USE wag_logistics_v61;

-- Q01. Open restock alerts, most urgent first.
SELECT WarehouseName, ProductName, Quantity, ReorderLevel, Shortage
FROM OpenRestockAlert ORDER BY Shortage DESC, WarehouseID, ProductID;

-- Q02. Stock across all warehouses, including products with no inventory record.
SELECT p.ProductID,p.ProductName,COUNT(i.WarehouseID) AS WarehouseCount,
       COALESCE(SUM(i.Quantity),0) AS TotalQuantity
FROM Product p LEFT JOIN Inventory i USING (ProductID)
GROUP BY p.ProductID,p.ProductName ORDER BY p.ProductID;

-- Q03. Ordered, allocated, received and outstanding quantities for each order line.
WITH receipts AS (
    SELECT si.SupplierOrderItemID,SUM(m.QuantityDelta) AS Received
    FROM StockMovement m JOIN ShipmentItem si USING (ShipmentItemID)
    WHERE m.MovementType='Receipt' GROUP BY si.SupplierOrderItemID
)
SELECT oi.SupplierOrderID,p.ProductName,oi.Quantity AS Ordered,
       COALESCE(a.Allocated,0) AS Allocated,COALESCE(r.Received,0) AS Received,
       oi.Quantity-COALESCE(r.Received,0) AS Outstanding
FROM SupplierOrderItem oi JOIN Product p USING (ProductID)
LEFT JOIN AllocatedByOrderItem a USING (SupplierOrderItemID)
LEFT JOIN receipts r USING (SupplierOrderItemID)
ORDER BY oi.SupplierOrderID,oi.SupplierOrderItemID;

-- Q04. Latest event per shipment, including shipments without events.
WITH ranked AS (
    SELECT e.*,ROW_NUMBER() OVER (
        PARTITION BY ShipmentID ORDER BY EventTime DESC,TrackingEventID DESC
    ) AS rn FROM TrackingEvent e
)
SELECT s.ShipmentID,s.TrackingNumber,s.Status,r.EventType,r.EventTime,r.Location
FROM Shipment s LEFT JOIN ranked r ON r.ShipmentID=s.ShipmentID AND r.rn=1
ORDER BY s.ShipmentID;

-- Q05. Lowest supplier price and shortest lead time among price ties.
WITH ranked AS (
    SELECT sp.*,DENSE_RANK() OVER (
        PARTITION BY ProductID ORDER BY UnitPrice,LeadTimeDays
    ) AS quote_rank FROM SupplierProduct sp
)
SELECT p.ProductName,s.SupplierName,r.UnitPrice,r.LeadTimeDays
FROM ranked r JOIN Product p USING (ProductID) JOIN Supplier s USING (SupplierID)
WHERE r.quote_rank=1 ORDER BY p.ProductID,s.SupplierID;

-- Q06. Agreed purchasing value by supplier, for submitted orders.
SELECT s.SupplierName,COUNT(DISTINCT o.SupplierOrderID) AS OrderCount,
       ROUND(SUM(oi.Quantity*oi.UnitPrice),2) AS OrderValue
FROM SupplierOrder o JOIN Supplier s USING (SupplierID)
JOIN SupplierOrderItem oi USING (SupplierOrderID)
WHERE o.Status='Submitted' GROUP BY s.SupplierID,s.SupplierName
ORDER BY OrderValue DESC,s.SupplierID;

-- Q07. Agreed order price versus current supplier quote.
SELECT o.SupplierOrderID,p.ProductName,oi.UnitPrice AS AgreedPrice,sp.UnitPrice AS CurrentPrice
FROM SupplierOrder o JOIN SupplierOrderItem oi USING (SupplierOrderID)
JOIN Product p ON p.ProductID=oi.ProductID
JOIN SupplierProduct sp ON sp.SupplierID=o.SupplierID AND sp.ProductID=oi.ProductID
WHERE oi.UnitPrice<>sp.UnitPrice ORDER BY o.SupplierOrderID,oi.SupplierOrderItemID;

-- Q08. Late or still overdue shipments at the sample cutoff.
WITH cutoff AS (SELECT CAST('2026-11-15 00:00:00' AS DATETIME) AS ReportTime)
SELECT s.ShipmentID,s.TrackingNumber,w.WarehouseName,s.EstimatedArrival,s.ActualArrival,
       ROUND(TIMESTAMPDIFF(SECOND,s.EstimatedArrival,COALESCE(s.ActualArrival,c.ReportTime))/86400.0,2) AS DaysLate
FROM Shipment s JOIN SupplierOrder o USING (SupplierOrderID) JOIN Warehouse w USING (WarehouseID)
CROSS JOIN cutoff c
WHERE s.Status IN ('Dispatched','InTransit','Arrived')
  AND COALESCE(s.ActualArrival,c.ReportTime)>s.EstimatedArrival
ORDER BY DaysLate DESC,s.ShipmentID;

-- Q09. Leaf quantities required for 10 Packing Stations.
WITH RECURSIVE bom(ProductID, RequiredQuantity) AS (
    SELECT CAST('PR000001' AS CHAR(15)) COLLATE utf8mb4_0900_as_cs,CAST(10 AS DECIMAL(38,12))
    UNION ALL
    SELECT pc.ComponentProductID,b.RequiredQuantity*pc.QuantityRequired
    FROM bom b JOIN ProductComponent pc ON pc.ParentProductID=b.ProductID
)
SELECT p.ProductName,ROUND(SUM(b.RequiredQuantity),6) AS RequiredQuantity
FROM bom b JOIN Product p USING (ProductID)
WHERE NOT EXISTS (SELECT 1 FROM ProductComponent pc WHERE pc.ParentProductID=b.ProductID)
GROUP BY p.ProductID,p.ProductName ORDER BY p.ProductID;

-- Q10. Running inventory balance in posting order.
SELECT w.WarehouseName,p.ProductName,m.MovementID,m.MovementType,m.QuantityDelta,
       SUM(m.QuantityDelta) OVER (
           PARTITION BY m.WarehouseID,m.ProductID ORDER BY m.MovementID ROWS UNBOUNDED PRECEDING
       ) AS RunningQuantity
FROM StockMovement m JOIN Warehouse w USING (WarehouseID) JOIN Product p USING (ProductID)
ORDER BY m.WarehouseID,m.ProductID,m.MovementID;

-- Q11. Open shortages after factoring in inbound quantities awaiting receipt.
WITH inbound AS (
    SELECT o.WarehouseID,oi.ProductID,SUM(si.Quantity) AS Incoming
    FROM ShipmentItem si JOIN Shipment s USING (ShipmentID)
    JOIN SupplierOrder o ON o.SupplierOrderID=s.SupplierOrderID
    JOIN SupplierOrderItem oi ON oi.SupplierOrderItemID=si.SupplierOrderItemID
    WHERE s.Status IN ('Dispatched','InTransit','Arrived')
      AND NOT EXISTS (SELECT 1 FROM StockMovement m WHERE m.ShipmentItemID=si.ShipmentItemID)
    GROUP BY o.WarehouseID,oi.ProductID
)
SELECT a.WarehouseName,a.ProductName,a.Quantity,COALESCE(i.Incoming,0) AS Incoming,
       GREATEST(a.Shortage-COALESCE(i.Incoming,0),0) AS RemainingShortage
FROM OpenRestockAlert a LEFT JOIN inbound i USING (WarehouseID,ProductID)
ORDER BY RemainingShortage DESC,a.WarehouseID,a.ProductID;

-- Q12. Suppliers offering every low-stock product at HCMC Central.
SELECT s.SupplierID,s.SupplierName
FROM Supplier s
WHERE EXISTS (SELECT 1 FROM OpenRestockAlert a WHERE a.WarehouseID='WH000001')
  AND NOT EXISTS (
      SELECT 1 FROM OpenRestockAlert a WHERE a.WarehouseID='WH000001'
      AND NOT EXISTS (
          SELECT 1 FROM SupplierProduct sp WHERE sp.SupplierID=s.SupplierID AND sp.ProductID=a.ProductID
      )
  )
ORDER BY s.SupplierID;
