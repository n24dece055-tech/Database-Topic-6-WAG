USE wag_logistics_v61;

WITH counts AS (
    SELECT 'Warehouse' AS TableName,COUNT(*) AS RowCount FROM Warehouse
    UNION ALL SELECT 'Product',COUNT(*) FROM Product
    UNION ALL SELECT 'Supplier',COUNT(*) FROM Supplier
    UNION ALL SELECT 'SupplierProduct',COUNT(*) FROM SupplierProduct
    UNION ALL SELECT 'SupplierOrder',COUNT(*) FROM SupplierOrder
    UNION ALL SELECT 'SupplierOrderItem',COUNT(*) FROM SupplierOrderItem
    UNION ALL SELECT 'Shipment',COUNT(*) FROM Shipment
    UNION ALL SELECT 'ShipmentItem',COUNT(*) FROM ShipmentItem
    UNION ALL SELECT 'TrackingEvent',COUNT(*) FROM TrackingEvent
    UNION ALL SELECT 'ProductComponent',COUNT(*) FROM ProductComponent
    UNION ALL SELECT 'Inventory',COUNT(*) FROM Inventory
    UNION ALL SELECT 'StockMovement',COUNT(*) FROM StockMovement
    UNION ALL SELECT 'RestockAlert',COUNT(*) FROM RestockAlert
)
SELECT TableName,RowCount FROM (
    SELECT TableName,RowCount,0 AS SortOrder FROM counts
    UNION ALL SELECT 'TOTAL',SUM(RowCount),1 FROM counts
) report ORDER BY SortOrder,TableName;

-- All violation counts should be zero.
SELECT 'Ledger balance mismatch' AS CheckName,COUNT(*) AS Violations
FROM Inventory i LEFT JOIN (
    SELECT WarehouseID,ProductID,SUM(QuantityDelta) AS LedgerQuantity
    FROM StockMovement GROUP BY WarehouseID,ProductID
) m USING (WarehouseID,ProductID)
WHERE i.Quantity<>COALESCE(m.LedgerQuantity,0) OR i.Quantity<0
UNION ALL
SELECT 'Incorrect open alert state',COUNT(*)
FROM Inventory i LEFT JOIN RestockAlert a
ON a.WarehouseID=i.WarehouseID AND a.ProductID=i.ProductID AND a.ResolvedAt IS NULL
WHERE (i.Quantity<i.ReorderLevel AND a.AlertDateTime IS NULL)
   OR (i.Quantity>=i.ReorderLevel AND a.AlertDateTime IS NOT NULL)
UNION ALL
SELECT 'Overallocated order line',COUNT(*)
FROM SupplierOrderItem oi JOIN AllocatedByOrderItem a USING (SupplierOrderItemID)
WHERE a.Allocated>oi.Quantity
UNION ALL
SELECT 'Wrong-order allocation',COUNT(*)
FROM ShipmentItem si JOIN Shipment s USING (ShipmentID)
JOIN SupplierOrderItem oi USING (SupplierOrderItemID)
WHERE s.SupplierOrderID<>oi.SupplierOrderID
UNION ALL
SELECT 'Arrival before dispatch',COUNT(*) FROM Shipment
WHERE DATE(ActualArrival)<ShipmentDate;

SELECT VERSION() AS MySQLVersion,DATABASE() AS ActiveSchema;
