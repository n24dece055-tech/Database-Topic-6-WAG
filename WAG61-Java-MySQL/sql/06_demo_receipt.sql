USE wag_logistics_v61;
SET SESSION time_zone = '+00:00';
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;

SELECT Quantity AS BeforeReceipt
FROM Inventory WHERE WarehouseID='WH000001' AND ProductID='PR000005';

INSERT INTO StockMovement (MovementID, QuantityDelta, MovementType, WarehouseID, ProductID, ShipmentItemID)
VALUES ('MVDEMO', 10.00, 'Receipt', 'WH000001', 'PR000005', 'SI000006');

SELECT Quantity AS AfterReceipt
FROM Inventory WHERE WarehouseID='WH000001' AND ProductID='PR000005';

SELECT COUNT(*) AS OpenWorktopAlerts FROM OpenRestockAlert
WHERE WarehouseID='WH000001' AND ProductID='PR000005';

ROLLBACK;
