USE wag_logistics_v61;

SET SESSION time_zone = '+00:00';
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
INSERT INTO Warehouse (WarehouseID, WarehouseName, Address, City, Country, CapacityM3) VALUES
    ('WH000001', 'HCMC Central', '12 Warehouse Road', 'Ho Chi Minh City', 'Vietnam', 1200.00),
    ('WH000002', 'Da Nang Hub', '8 Port Road', 'Da Nang', 'Vietnam', 650.00),
    ('WH000003', 'Hanoi North', '20 Logistics Road', 'Hanoi', 'Vietnam', 850.00);
INSERT INTO Product (ProductID, ProductName, Description, Unit, ProductType) VALUES
    ('PR000001', 'Packing Station', NULL, 'set', 'Finished'),
    ('PR000002', 'Frame Assembly', NULL, 'set', 'Component'),
    ('PR000003', 'Steel Tube', NULL, 'piece', 'Raw'),
    ('PR000004', 'Bolt', NULL, 'piece', 'Raw'),
    ('PR000005', 'Worktop', NULL, 'piece', 'Component'),
    ('PR000006', 'Label Roll', NULL, 'roll', 'Raw');
INSERT INTO Supplier (SupplierID, SupplierName, ContactName, Phone, Email, Address) VALUES
    ('SU000001', 'Mekong Metals', NULL, NULL, NULL, NULL),
    ('SU000002', 'Central Hardware', NULL, NULL, NULL, NULL),
    ('SU000003', 'North Packaging', NULL, NULL, NULL, NULL);
INSERT INTO SupplierProduct (SupplierID, ProductID, UnitPrice, LeadTimeDays) VALUES
    ('SU000001', 'PR000003', 125.00, 5),
    ('SU000001', 'PR000004', 0.45, 4),
    ('SU000002', 'PR000003', 130.00, 2),
    ('SU000002', 'PR000004', 0.50, 2),
    ('SU000002', 'PR000005', 300.00, 8),
    ('SU000003', 'PR000006', 25.00, 3);
INSERT INTO ProductComponent (ParentProductID, ComponentProductID, QuantityRequired) VALUES
    ('PR000001', 'PR000002', 1.00),
    ('PR000001', 'PR000005', 1.00),
    ('PR000001', 'PR000004', 4.00),
    ('PR000002', 'PR000003', 3.00),
    ('PR000002', 'PR000004', 8.00);
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000001', 'PR000003', 30.00),
    ('WH000001', 'PR000004', 50.00),
    ('WH000001', 'PR000005', 10.00),
    ('WH000002', 'PR000003', 10.00),
    ('WH000002', 'PR000004', 15.00),
    ('WH000003', 'PR000006', 5.00);
INSERT INTO StockMovement (MovementID, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000001', 'Opening', 20.00, 'WH000001', 'PR000003'),
    ('MV000002', 'Opening', 60.00, 'WH000001', 'PR000004'),
    ('MV000003', 'Opening', 5.00, 'WH000001', 'PR000005'),
    ('MV000004', 'Opening', 12.00, 'WH000002', 'PR000003'),
    ('MV000005', 'Opening', 20.00, 'WH000002', 'PR000004'),
    ('MV000006', 'Opening', 5.00, 'WH000003', 'PR000006');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate) VALUES
    ('PO000001', 'SU000001', 'WH000001', '2026-10-20', '2026-10-27'),
    ('PO000002', 'SU000002', 'WH000002', '2026-10-25', '2026-11-01'),
    ('PO000003', 'SU000003', 'WH000003', '2026-11-10', '2026-11-14'),
    ('PO000004', 'SU000002', 'WH000001', '2026-11-10', '2026-11-15');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000001', 'PO000001', 'PR000003', 60.00, 120.00),
    ('OI000002', 'PO000001', 'PR000004', 40.00, 0.40),
    ('OI000003', 'PO000002', 'PR000004', 10.00, 0.50),
    ('OI000004', 'PO000003', 'PR000006', 10.00, 25.00),
    ('OI000005', 'PO000004', 'PR000005', 10.00, 300.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID IN ('PO000001', 'PO000002', 'PO000004');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000001', 'PO000001', 'WAG-001', '2026-10-25 10:00:00'),
    ('SH000002', 'PO000001', 'WAG-002', '2026-10-27 12:00:00'),
    ('SH000003', 'PO000002', 'WAG-003', '2026-11-01 10:00:00'),
    ('SH000004', 'PO000001', 'WAG-004', '2026-10-27 10:00:00'),
    ('SH000005', 'PO000004', 'WAG-005', '2026-11-14 11:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000001', 'SH000001', 'OI000001', 25.00),
    ('SI000002', 'SH000001', 'OI000002', 40.00),
    ('SI000003', 'SH000002', 'OI000001', 25.00),
    ('SI000004', 'SH000003', 'OI000003', 10.00),
    ('SI000005', 'SH000004', 'OI000001', 10.00),
    ('SI000006', 'SH000005', 'OI000005', 10.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000004';
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-24' WHERE ShipmentID IN ('SH000001', 'SH000002');
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-30' WHERE ShipmentID='SH000003';
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-11-12' WHERE ShipmentID='SH000005';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-26 09:00:00' WHERE ShipmentID='SH000001';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-11-01 09:00:00' WHERE ShipmentID='SH000003';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-11-14 11:30:00' WHERE ShipmentID='SH000005';
INSERT INTO TrackingEvent (ShipmentID, EventTime, Location, EventType, Description, TrackingEventID) VALUES
    ('SH000001', '2026-10-24 08:00:00', 'Mekong', 'PickedUp', NULL, 'EV000001'),
    ('SH000001', '2026-10-26 09:00:00', 'HCMC', 'Arrived', NULL, 'EV000002'),
    ('SH000002', '2026-10-24 12:00:00', 'Mekong', 'PickedUp', NULL, 'EV000001'),
    ('SH000002', '2026-10-25 15:00:00', 'Regional Hub', 'LocationUpdated', NULL, 'EV000002'),
    ('SH000003', '2026-11-01 09:00:00', 'Da Nang', 'Arrived', NULL, 'EV000001'),
    ('SH000005', '2026-11-14 11:30:00', 'HCMC', 'Arrived', NULL, 'EV000001');
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000007', 'SI000001', 'Receipt', 25.00, 'WH000001', 'PR000003'),
    ('MV000008', 'SI000002', 'Receipt', 40.00, 'WH000001', 'PR000004'),
    ('MV000009', 'SI000004', 'Receipt', 10.00, 'WH000002', 'PR000004');
INSERT INTO StockMovement (MovementID, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000010', 'Issue', -60.00, 'WH000001', 'PR000004');
INSERT INTO Warehouse (WarehouseID, WarehouseName, Address, City, Country, CapacityM3) VALUES
    ('WH000004', 'Binh Duong Distribution Center', '14 Logistics Park', 'Binh Duong', 'Vietnam', 2198.00),
    ('WH000005', 'Dong Nai Distribution Center', '15 Logistics Park', 'Dong Nai', 'Vietnam', 879.00),
    ('WH000006', 'Hai Phong Distribution Center', '16 Logistics Park', 'Hai Phong', 'Vietnam', 4011.00),
    ('WH000007', 'Can Tho Distribution Center', '17 Logistics Park', 'Can Tho', 'Vietnam', 1755.00),
    ('WH000008', 'Bac Ninh Distribution Center', '18 Logistics Park', 'Bac Ninh', 'Vietnam', 1174.00);
INSERT INTO Product (ProductID, ProductName, Description, Unit, ProductType) VALUES
    ('PR000007', 'Euro Pallet', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000008', 'Stackable Tote', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000009', 'Pallet Collar', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000010', 'Stretch Film', 'Warehouse packaging and handling supply', 'roll', 'Component'),
    ('PR000011', 'Kraft Tape', 'Warehouse packaging and handling supply', 'roll', 'Component'),
    ('PR000012', 'Carton S', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000013', 'Carton M', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000014', 'Carton L', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000015', 'Corrugated Divider', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000016', 'Barcode Label', 'Warehouse packaging and handling supply', 'roll', 'Component'),
    ('PR000017', 'Thermal Ribbon', 'Warehouse packaging and handling supply', 'roll', 'Component'),
    ('PR000018', 'Tamper Seal', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000019', 'Corner Protector', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000020', 'PET Strap', 'Warehouse packaging and handling supply', 'roll', 'Component'),
    ('PR000021', 'Strap Buckle', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000022', 'Bubble Wrap', 'Warehouse packaging and handling supply', 'roll', 'Component'),
    ('PR000023', 'Foam Sheet', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000024', 'Insulated Liner', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000025', 'Cold Pack', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000026', 'Humidity Indicator', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000027', 'Desiccant Pack', 'Warehouse packaging and handling supply', 'piece', 'Component'),
    ('PR000028', 'Export Pallet Kit', 'Warehouse packaging and handling supply', 'set', 'Finished'),
    ('PR000029', 'Cold-chain Parcel Kit', 'Warehouse packaging and handling supply', 'set', 'Finished'),
    ('PR000030', 'Fragile Packing Kit', 'Warehouse packaging and handling supply', 'set', 'Finished');
INSERT INTO Supplier (SupplierID, SupplierName, ContactName, Phone, Email, Address) VALUES
    ('SU000004', 'Delta Pallet Works', 'Sales Desk', NULL, 'orders4@example.test', 'Vietnam'),
    ('SU000005', 'Red River Packaging', 'Sales Desk', NULL, 'orders5@example.test', 'Vietnam'),
    ('SU000006', 'Lotus Labels', 'Sales Desk', NULL, 'orders6@example.test', 'Vietnam'),
    ('SU000007', 'Coastal Cold Chain', 'Sales Desk', NULL, 'orders7@example.test', 'Vietnam'),
    ('SU000008', 'Southern Cartons', 'Sales Desk', NULL, 'orders8@example.test', 'Vietnam'),
    ('SU000009', 'Green Wrap Supply', 'Sales Desk', NULL, 'orders9@example.test', 'Vietnam'),
    ('SU000010', 'Mekong Industrial Supply', 'Sales Desk', NULL, 'orders10@example.test', 'Vietnam'),
    ('SU000011', 'Northern Handling', 'Sales Desk', NULL, 'orders11@example.test', 'Vietnam'),
    ('SU000012', 'East Port Materials', 'Sales Desk', NULL, 'orders12@example.test', 'Vietnam');
INSERT INTO SupplierProduct (SupplierID, ProductID, UnitPrice, LeadTimeDays) VALUES
    ('SU000004', 'PR000019', 399.75, 1),
    ('SU000004', 'PR000020', 255.50, 6),
    ('SU000004', 'PR000021', 395.50, 1),
    ('SU000004', 'PR000022', 92.25, 1),
    ('SU000004', 'PR000023', 346.50, 7),
    ('SU000004', 'PR000024', 140.75, 4),
    ('SU000004', 'PR000025', 140.25, 7),
    ('SU000004', 'PR000026', 192.25, 5),
    ('SU000005', 'PR000022', 259.25, 5),
    ('SU000005', 'PR000023', 300.50, 8),
    ('SU000005', 'PR000024', 22.75, 4),
    ('SU000005', 'PR000025', 308.75, 7),
    ('SU000005', 'PR000026', 200.75, 7),
    ('SU000005', 'PR000027', 225.75, 6),
    ('SU000005', 'PR000028', 320.00, 1),
    ('SU000005', 'PR000029', 141.75, 3),
    ('SU000006', 'PR000007', 13.75, 6),
    ('SU000006', 'PR000008', 155.25, 2),
    ('SU000006', 'PR000025', 280.75, 2),
    ('SU000006', 'PR000026', 372.00, 1),
    ('SU000006', 'PR000027', 403.75, 2),
    ('SU000006', 'PR000028', 242.00, 6),
    ('SU000006', 'PR000029', 184.00, 5),
    ('SU000006', 'PR000030', 252.00, 4),
    ('SU000007', 'PR000007', 336.00, 4),
    ('SU000007', 'PR000008', 256.75, 8),
    ('SU000007', 'PR000009', 310.50, 5),
    ('SU000007', 'PR000010', 89.50, 2),
    ('SU000007', 'PR000011', 351.75, 2),
    ('SU000007', 'PR000028', 263.25, 3),
    ('SU000007', 'PR000029', 323.50, 8),
    ('SU000007', 'PR000030', 180.50, 7),
    ('SU000008', 'PR000007', 428.00, 1),
    ('SU000008', 'PR000008', 186.75, 5),
    ('SU000008', 'PR000009', 309.50, 6),
    ('SU000008', 'PR000010', 343.00, 8),
    ('SU000008', 'PR000011', 310.25, 5),
    ('SU000008', 'PR000012', 117.75, 5),
    ('SU000008', 'PR000013', 73.00, 4),
    ('SU000008', 'PR000014', 366.50, 7),
    ('SU000009', 'PR000010', 24.75, 6),
    ('SU000009', 'PR000011', 285.50, 3),
    ('SU000009', 'PR000012', 301.50, 8),
    ('SU000009', 'PR000013', 304.00, 5),
    ('SU000009', 'PR000014', 385.25, 5),
    ('SU000009', 'PR000015', 339.00, 7),
    ('SU000009', 'PR000016', 139.50, 6),
    ('SU000009', 'PR000017', 137.75, 5),
    ('SU000010', 'PR000013', 387.00, 5),
    ('SU000010', 'PR000014', 52.50, 5),
    ('SU000010', 'PR000015', 168.50, 4),
    ('SU000010', 'PR000016', 134.75, 2),
    ('SU000010', 'PR000017', 199.00, 1),
    ('SU000010', 'PR000018', 222.75, 2),
    ('SU000010', 'PR000019', 180.75, 1),
    ('SU000010', 'PR000020', 324.00, 6),
    ('SU000011', 'PR000016', 332.25, 3),
    ('SU000011', 'PR000017', 87.00, 8),
    ('SU000011', 'PR000018', 120.25, 8),
    ('SU000011', 'PR000019', 282.25, 4),
    ('SU000011', 'PR000020', 354.50, 8),
    ('SU000011', 'PR000021', 277.75, 3),
    ('SU000011', 'PR000022', 5.75, 3),
    ('SU000011', 'PR000023', 364.75, 5),
    ('SU000012', 'PR000019', 122.75, 5),
    ('SU000012', 'PR000020', 289.75, 1),
    ('SU000012', 'PR000021', 77.25, 4),
    ('SU000012', 'PR000022', 393.00, 2),
    ('SU000012', 'PR000023', 345.25, 5),
    ('SU000012', 'PR000024', 355.75, 8),
    ('SU000012', 'PR000025', 214.25, 5),
    ('SU000012', 'PR000026', 13.25, 4);
INSERT INTO ProductComponent (ParentProductID, ComponentProductID, QuantityRequired) VALUES
    ('PR000028', 'PR000007', 1.00),
    ('PR000028', 'PR000009', 2.00),
    ('PR000028', 'PR000020', 1.00),
    ('PR000028', 'PR000021', 4.00),
    ('PR000029', 'PR000014', 1.00),
    ('PR000029', 'PR000024', 1.00),
    ('PR000029', 'PR000025', 2.00),
    ('PR000029', 'PR000026', 1.00),
    ('PR000029', 'PR000027', 1.00),
    ('PR000030', 'PR000013', 1.00),
    ('PR000030', 'PR000015', 3.00),
    ('PR000030', 'PR000019', 4.00),
    ('PR000030', 'PR000022', 1.00),
    ('PR000030', 'PR000011', 1.00);
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000007', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000011', '2026-08-01 08:00:00', 'Opening', 118.00, 'WH000004', 'PR000007');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000008', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000012', '2026-08-01 08:00:00', 'Opening', 69.00, 'WH000004', 'PR000008'),
    ('MV000013', '2026-08-12 10:00:00', 'Issue', -27.00, 'WH000004', 'PR000008');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000009', 40.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000014', '2026-08-01 08:00:00', 'Opening', 134.00, 'WH000004', 'PR000009');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000010', 37.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000015', '2026-08-01 08:00:00', 'Opening', 103.00, 'WH000004', 'PR000010');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000011', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000016', '2026-08-01 08:00:00', 'Opening', 108.00, 'WH000004', 'PR000011');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000012', 19.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000017', '2026-08-01 08:00:00', 'Opening', 73.00, 'WH000004', 'PR000012'),
    ('MV000018', '2026-08-12 10:00:00', 'Issue', -15.00, 'WH000004', 'PR000012');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000013', 34.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000019', '2026-08-01 08:00:00', 'Opening', 121.00, 'WH000004', 'PR000013');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000014', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000020', '2026-08-01 08:00:00', 'Opening', 116.00, 'WH000004', 'PR000014');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000015', 26.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000021', '2026-08-01 08:00:00', 'Opening', 98.00, 'WH000004', 'PR000015');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000016', 14.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000022', '2026-08-01 08:00:00', 'Opening', 77.00, 'WH000004', 'PR000016'),
    ('MV000023', '2026-08-12 10:00:00', 'Issue', -19.00, 'WH000004', 'PR000016');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000017', 28.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000024', '2026-08-01 08:00:00', 'Opening', 148.00, 'WH000004', 'PR000017');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000018', 32.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000025', '2026-08-01 08:00:00', 'Opening', 95.00, 'WH000004', 'PR000018');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000019', 19.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000026', '2026-08-01 08:00:00', 'Opening', 56.00, 'WH000004', 'PR000019');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000020', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000027', '2026-08-01 08:00:00', 'Opening', 113.00, 'WH000004', 'PR000020'),
    ('MV000028', '2026-08-12 10:00:00', 'Issue', -15.00, 'WH000004', 'PR000020');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000021', 17.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000029', '2026-08-01 08:00:00', 'Opening', 29.00, 'WH000004', 'PR000021');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000022', 21.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000030', '2026-08-01 08:00:00', 'Opening', 101.00, 'WH000004', 'PR000022');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000023', 11.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000031', '2026-08-01 08:00:00', 'Opening', 38.00, 'WH000004', 'PR000023');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000024', 13.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000032', '2026-08-01 08:00:00', 'Opening', 79.00, 'WH000004', 'PR000024'),
    ('MV000033', '2026-08-12 10:00:00', 'Issue', -26.00, 'WH000004', 'PR000024');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000025', 12.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000034', '2026-08-01 08:00:00', 'Opening', 41.00, 'WH000004', 'PR000025');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000026', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000035', '2026-08-01 08:00:00', 'Opening', 146.00, 'WH000004', 'PR000026');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000027', 21.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000036', '2026-08-01 08:00:00', 'Opening', 133.00, 'WH000004', 'PR000027');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000028', 34.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000037', '2026-08-01 08:00:00', 'Opening', 149.00, 'WH000004', 'PR000028'),
    ('MV000038', '2026-08-12 10:00:00', 'Issue', -22.00, 'WH000004', 'PR000028');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000029', 33.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000039', '2026-08-01 08:00:00', 'Opening', 126.00, 'WH000004', 'PR000029');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000004', 'PR000030', 30.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000040', '2026-08-01 08:00:00', 'Opening', 64.00, 'WH000004', 'PR000030');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000007', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000041', '2026-08-01 08:00:00', 'Opening', 150.00, 'WH000005', 'PR000007'),
    ('MV000042', '2026-08-12 10:00:00', 'Issue', -7.00, 'WH000005', 'PR000007');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000008', 39.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000043', '2026-08-01 08:00:00', 'Opening', 28.00, 'WH000005', 'PR000008');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000009', 22.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000044', '2026-08-01 08:00:00', 'Opening', 81.00, 'WH000005', 'PR000009');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000010', 26.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000045', '2026-08-01 08:00:00', 'Opening', 98.00, 'WH000005', 'PR000010');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000011', 36.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000046', '2026-08-01 08:00:00', 'Opening', 94.00, 'WH000005', 'PR000011'),
    ('MV000047', '2026-08-12 10:00:00', 'Issue', -14.00, 'WH000005', 'PR000011');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000012', 31.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000048', '2026-08-01 08:00:00', 'Opening', 71.00, 'WH000005', 'PR000012');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000013', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000049', '2026-08-01 08:00:00', 'Opening', 51.00, 'WH000005', 'PR000013');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000014', 8.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000050', '2026-08-01 08:00:00', 'Opening', 145.00, 'WH000005', 'PR000014');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000015', 27.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000051', '2026-08-01 08:00:00', 'Opening', 47.00, 'WH000005', 'PR000015'),
    ('MV000052', '2026-08-12 10:00:00', 'Issue', -8.00, 'WH000005', 'PR000015');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000016', 26.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000053', '2026-08-01 08:00:00', 'Opening', 69.00, 'WH000005', 'PR000016');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000017', 20.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000054', '2026-08-01 08:00:00', 'Opening', 54.00, 'WH000005', 'PR000017');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000018', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000055', '2026-08-01 08:00:00', 'Opening', 65.00, 'WH000005', 'PR000018');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000019', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000056', '2026-08-01 08:00:00', 'Opening', 75.00, 'WH000005', 'PR000019'),
    ('MV000057', '2026-08-12 10:00:00', 'Issue', -23.00, 'WH000005', 'PR000019');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000020', 18.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000058', '2026-08-01 08:00:00', 'Opening', 124.00, 'WH000005', 'PR000020');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000021', 37.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000059', '2026-08-01 08:00:00', 'Opening', 30.00, 'WH000005', 'PR000021');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000022', 18.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000060', '2026-08-01 08:00:00', 'Opening', 24.00, 'WH000005', 'PR000022');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000023', 38.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000061', '2026-08-01 08:00:00', 'Opening', 115.00, 'WH000005', 'PR000023'),
    ('MV000062', '2026-08-12 10:00:00', 'Issue', -22.00, 'WH000005', 'PR000023');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000024', 25.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000063', '2026-08-01 08:00:00', 'Opening', 27.00, 'WH000005', 'PR000024');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000025', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000064', '2026-08-01 08:00:00', 'Opening', 74.00, 'WH000005', 'PR000025');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000026', 36.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000065', '2026-08-01 08:00:00', 'Opening', 117.00, 'WH000005', 'PR000026');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000027', 27.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000066', '2026-08-01 08:00:00', 'Opening', 125.00, 'WH000005', 'PR000027'),
    ('MV000067', '2026-08-12 10:00:00', 'Issue', -10.00, 'WH000005', 'PR000027');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000028', 40.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000068', '2026-08-01 08:00:00', 'Opening', 98.00, 'WH000005', 'PR000028');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000029', 40.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000069', '2026-08-01 08:00:00', 'Opening', 125.00, 'WH000005', 'PR000029');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000005', 'PR000030', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000070', '2026-08-01 08:00:00', 'Opening', 98.00, 'WH000005', 'PR000030');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000007', 33.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000071', '2026-08-01 08:00:00', 'Opening', 66.00, 'WH000006', 'PR000007');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000008', 18.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000072', '2026-08-01 08:00:00', 'Opening', 102.00, 'WH000006', 'PR000008');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000009', 14.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000073', '2026-08-01 08:00:00', 'Opening', 144.00, 'WH000006', 'PR000009');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000010', 20.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000074', '2026-08-01 08:00:00', 'Opening', 131.00, 'WH000006', 'PR000010'),
    ('MV000075', '2026-08-12 10:00:00', 'Issue', -13.00, 'WH000006', 'PR000010');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000011', 33.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000076', '2026-08-01 08:00:00', 'Opening', 105.00, 'WH000006', 'PR000011');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000012', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000077', '2026-08-01 08:00:00', 'Opening', 81.00, 'WH000006', 'PR000012');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000013', 29.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000078', '2026-08-01 08:00:00', 'Opening', 75.00, 'WH000006', 'PR000013');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000014', 8.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000079', '2026-08-01 08:00:00', 'Opening', 41.00, 'WH000006', 'PR000014'),
    ('MV000080', '2026-08-12 10:00:00', 'Issue', -28.00, 'WH000006', 'PR000014');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000015', 13.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000081', '2026-08-01 08:00:00', 'Opening', 54.00, 'WH000006', 'PR000015');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000016', 8.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000082', '2026-08-01 08:00:00', 'Opening', 69.00, 'WH000006', 'PR000016');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000017', 30.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000083', '2026-08-01 08:00:00', 'Opening', 106.00, 'WH000006', 'PR000017');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000018', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000084', '2026-08-01 08:00:00', 'Opening', 120.00, 'WH000006', 'PR000018'),
    ('MV000085', '2026-08-12 10:00:00', 'Issue', -12.00, 'WH000006', 'PR000018');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000019', 17.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000086', '2026-08-01 08:00:00', 'Opening', 48.00, 'WH000006', 'PR000019');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000020', 26.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000087', '2026-08-01 08:00:00', 'Opening', 82.00, 'WH000006', 'PR000020');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000021', 19.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000088', '2026-08-01 08:00:00', 'Opening', 98.00, 'WH000006', 'PR000021');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000022', 21.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000089', '2026-08-01 08:00:00', 'Opening', 36.00, 'WH000006', 'PR000022'),
    ('MV000090', '2026-08-12 10:00:00', 'Issue', -17.00, 'WH000006', 'PR000022');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000023', 30.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000091', '2026-08-01 08:00:00', 'Opening', 16.00, 'WH000006', 'PR000023');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000024', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000092', '2026-08-01 08:00:00', 'Opening', 88.00, 'WH000006', 'PR000024');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000025', 17.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000093', '2026-08-01 08:00:00', 'Opening', 64.00, 'WH000006', 'PR000025');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000026', 21.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000094', '2026-08-01 08:00:00', 'Opening', 53.00, 'WH000006', 'PR000026'),
    ('MV000095', '2026-08-12 10:00:00', 'Issue', -18.00, 'WH000006', 'PR000026');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000027', 24.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000096', '2026-08-01 08:00:00', 'Opening', 62.00, 'WH000006', 'PR000027');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000028', 35.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000097', '2026-08-01 08:00:00', 'Opening', 71.00, 'WH000006', 'PR000028');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000029', 16.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000098', '2026-08-01 08:00:00', 'Opening', 116.00, 'WH000006', 'PR000029');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000006', 'PR000030', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000099', '2026-08-01 08:00:00', 'Opening', 126.00, 'WH000006', 'PR000030'),
    ('MV000100', '2026-08-12 10:00:00', 'Issue', -30.00, 'WH000006', 'PR000030');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000007', 31.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000101', '2026-08-01 08:00:00', 'Opening', 22.00, 'WH000007', 'PR000007');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000008', 10.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000102', '2026-08-01 08:00:00', 'Opening', 112.00, 'WH000007', 'PR000008');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000009', 22.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000103', '2026-08-01 08:00:00', 'Opening', 138.00, 'WH000007', 'PR000009'),
    ('MV000104', '2026-08-12 10:00:00', 'Issue', -16.00, 'WH000007', 'PR000009');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000010', 33.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000105', '2026-08-01 08:00:00', 'Opening', 143.00, 'WH000007', 'PR000010');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000011', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000106', '2026-08-01 08:00:00', 'Opening', 89.00, 'WH000007', 'PR000011');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000012', 31.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000107', '2026-08-01 08:00:00', 'Opening', 47.00, 'WH000007', 'PR000012');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000013', 40.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000108', '2026-08-01 08:00:00', 'Opening', 148.00, 'WH000007', 'PR000013'),
    ('MV000109', '2026-08-12 10:00:00', 'Issue', -25.00, 'WH000007', 'PR000013');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000014', 15.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000110', '2026-08-01 08:00:00', 'Opening', 36.00, 'WH000007', 'PR000014');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000015', 15.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000111', '2026-08-01 08:00:00', 'Opening', 52.00, 'WH000007', 'PR000015');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000016', 29.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000112', '2026-08-01 08:00:00', 'Opening', 139.00, 'WH000007', 'PR000016');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000017', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000113', '2026-08-01 08:00:00', 'Opening', 31.00, 'WH000007', 'PR000017'),
    ('MV000114', '2026-08-12 10:00:00', 'Issue', -21.00, 'WH000007', 'PR000017');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000018', 35.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000115', '2026-08-01 08:00:00', 'Opening', 92.00, 'WH000007', 'PR000018');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000019', 30.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000116', '2026-08-01 08:00:00', 'Opening', 128.00, 'WH000007', 'PR000019');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000020', 25.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000117', '2026-08-01 08:00:00', 'Opening', 105.00, 'WH000007', 'PR000020');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000021', 26.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000118', '2026-08-01 08:00:00', 'Opening', 60.00, 'WH000007', 'PR000021'),
    ('MV000119', '2026-08-12 10:00:00', 'Issue', -14.00, 'WH000007', 'PR000021');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000022', 28.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000120', '2026-08-01 08:00:00', 'Opening', 104.00, 'WH000007', 'PR000022');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000023', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000121', '2026-08-01 08:00:00', 'Opening', 100.00, 'WH000007', 'PR000023');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000024', 25.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000122', '2026-08-01 08:00:00', 'Opening', 54.00, 'WH000007', 'PR000024');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000025', 40.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000123', '2026-08-01 08:00:00', 'Opening', 51.00, 'WH000007', 'PR000025'),
    ('MV000124', '2026-08-12 10:00:00', 'Issue', -9.00, 'WH000007', 'PR000025');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000026', 24.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000125', '2026-08-01 08:00:00', 'Opening', 20.00, 'WH000007', 'PR000026');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000027', 35.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000126', '2026-08-01 08:00:00', 'Opening', 53.00, 'WH000007', 'PR000027');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000028', 36.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000127', '2026-08-01 08:00:00', 'Opening', 64.00, 'WH000007', 'PR000028');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000029', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000128', '2026-08-01 08:00:00', 'Opening', 132.00, 'WH000007', 'PR000029'),
    ('MV000129', '2026-08-12 10:00:00', 'Issue', -28.00, 'WH000007', 'PR000029');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000007', 'PR000030', 12.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000130', '2026-08-01 08:00:00', 'Opening', 136.00, 'WH000007', 'PR000030');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000007', 14.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000131', '2026-08-01 08:00:00', 'Opening', 54.00, 'WH000008', 'PR000007');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000008', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000132', '2026-08-01 08:00:00', 'Opening', 67.00, 'WH000008', 'PR000008'),
    ('MV000133', '2026-08-12 10:00:00', 'Issue', -29.00, 'WH000008', 'PR000008');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000009', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000134', '2026-08-01 08:00:00', 'Opening', 38.00, 'WH000008', 'PR000009');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000010', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000135', '2026-08-01 08:00:00', 'Opening', 147.00, 'WH000008', 'PR000010');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000011', 28.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000136', '2026-08-01 08:00:00', 'Opening', 111.00, 'WH000008', 'PR000011');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000012', 26.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000137', '2026-08-01 08:00:00', 'Opening', 122.00, 'WH000008', 'PR000012'),
    ('MV000138', '2026-08-12 10:00:00', 'Issue', -15.00, 'WH000008', 'PR000012');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000013', 38.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000139', '2026-08-01 08:00:00', 'Opening', 95.00, 'WH000008', 'PR000013');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000014', 40.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000140', '2026-08-01 08:00:00', 'Opening', 58.00, 'WH000008', 'PR000014');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000015', 37.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000141', '2026-08-01 08:00:00', 'Opening', 142.00, 'WH000008', 'PR000015');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000016', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000142', '2026-08-01 08:00:00', 'Opening', 145.00, 'WH000008', 'PR000016'),
    ('MV000143', '2026-08-12 10:00:00', 'Issue', -29.00, 'WH000008', 'PR000016');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000017', 8.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000144', '2026-08-01 08:00:00', 'Opening', 65.00, 'WH000008', 'PR000017');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000018', 16.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000145', '2026-08-01 08:00:00', 'Opening', 25.00, 'WH000008', 'PR000018');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000019', 35.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000146', '2026-08-01 08:00:00', 'Opening', 69.00, 'WH000008', 'PR000019');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000020', 10.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000147', '2026-08-01 08:00:00', 'Opening', 65.00, 'WH000008', 'PR000020'),
    ('MV000148', '2026-08-12 10:00:00', 'Issue', -14.00, 'WH000008', 'PR000020');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000021', 9.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000149', '2026-08-01 08:00:00', 'Opening', 142.00, 'WH000008', 'PR000021');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000022', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000150', '2026-08-01 08:00:00', 'Opening', 133.00, 'WH000008', 'PR000022');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000023', 38.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000151', '2026-08-01 08:00:00', 'Opening', 88.00, 'WH000008', 'PR000023');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000024', 24.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000152', '2026-08-01 08:00:00', 'Opening', 25.00, 'WH000008', 'PR000024'),
    ('MV000153', '2026-08-12 10:00:00', 'Issue', -24.00, 'WH000008', 'PR000024');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000025', 20.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000154', '2026-08-01 08:00:00', 'Opening', 47.00, 'WH000008', 'PR000025');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000026', 39.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000155', '2026-08-01 08:00:00', 'Opening', 144.00, 'WH000008', 'PR000026');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000027', 22.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000156', '2026-08-01 08:00:00', 'Opening', 61.00, 'WH000008', 'PR000027');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000028', 0.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000157', '2026-08-01 08:00:00', 'Opening', 64.00, 'WH000008', 'PR000028'),
    ('MV000158', '2026-08-12 10:00:00', 'Issue', -13.00, 'WH000008', 'PR000028');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000029', 18.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000159', '2026-08-01 08:00:00', 'Opening', 18.00, 'WH000008', 'PR000029');
INSERT INTO Inventory (WarehouseID, ProductID, ReorderLevel) VALUES
    ('WH000008', 'PR000030', 14.00);
INSERT INTO StockMovement (MovementID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000160', '2026-08-01 08:00:00', 'Opening', 19.00, 'WH000008', 'PR000030');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000005', 'SU000004', 'WH000004', '2026-08-17', '2026-08-23', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000006', 'PO000005', 'PR000022', 29.00, 92.00),
    ('OI000007', 'PO000005', 'PR000025', 33.00, 140.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000006', 'SU000005', 'WH000005', '2026-08-18', '2026-08-23', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000008', 'PO000006', 'PR000027', 38.00, 225.75),
    ('OI000009', 'PO000006', 'PR000022', 26.00, 259.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000006';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000006', 'PO000006', 'VN-00006', '2026-08-23 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000007', 'SH000006', 'OI000008', 38.00),
    ('SI000008', 'SH000006', 'OI000009', 26.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-19' WHERE ShipmentID='SH000006';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-23 15:00:00' WHERE ShipmentID='SH000006';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000161', 'SI000007', '2026-08-23 16:00:00', 'Receipt', 38.00, 'WH000005', 'PR000027'),
    ('MV000162', 'SI000008', '2026-08-23 16:00:00', 'Receipt', 26.00, 'WH000005', 'PR000022');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000007', 'SU000006', 'WH000006', '2026-08-19', '2026-08-26', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000010', 'PO000007', 'PR000030', 39.00, 252.00),
    ('OI000011', 'PO000007', 'PR000007', 67.00, 13.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000007';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000007', 'PO000007', 'VN-00007', '2026-08-26 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000009', 'SH000007', 'OI000010', 39.00),
    ('SI000010', 'SH000007', 'OI000011', 67.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-20' WHERE ShipmentID='SH000007';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-27 15:00:00' WHERE ShipmentID='SH000007';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000163', 'SI000009', '2026-08-27 16:00:00', 'Receipt', 39.00, 'WH000006', 'PR000030'),
    ('MV000164', 'SI000010', '2026-08-27 16:00:00', 'Receipt', 67.00, 'WH000006', 'PR000007');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000008', 'SU000007', 'WH000007', '2026-08-20', '2026-08-25', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000012', 'PO000008', 'PR000030', 28.00, 180.50),
    ('OI000013', 'PO000008', 'PR000011', 49.00, 351.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000008';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000008', 'PO000008', 'VN-00008', '2026-08-25 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000011', 'SH000008', 'OI000012', 28.00),
    ('SI000012', 'SH000008', 'OI000013', 49.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-21' WHERE ShipmentID='SH000008';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-27 15:00:00' WHERE ShipmentID='SH000008';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000165', 'SI000011', '2026-08-27 16:00:00', 'Receipt', 28.00, 'WH000007', 'PR000030'),
    ('MV000166', 'SI000012', '2026-08-27 16:00:00', 'Receipt', 49.00, 'WH000007', 'PR000011');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000009', 'SU000008', 'WH000008', '2026-08-21', '2026-08-29', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000014', 'PO000009', 'PR000012', 31.00, 117.75),
    ('OI000015', 'PO000009', 'PR000010', 30.00, 343.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000009';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000009', 'PO000009', 'VN-00009', '2026-08-29 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000013', 'SH000009', 'OI000014', 15.00),
    ('SI000014', 'SH000009', 'OI000015', 15.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-22' WHERE ShipmentID='SH000009';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-28 15:00:00' WHERE ShipmentID='SH000009';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000167', 'SI000013', '2026-08-28 16:00:00', 'Receipt', 15.00, 'WH000008', 'PR000012'),
    ('MV000168', 'SI000014', '2026-08-28 16:00:00', 'Receipt', 15.00, 'WH000008', 'PR000010');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000010', 'PO000009', 'VN-00010', '2026-08-31 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000015', 'SH000010', 'OI000014', 16.00),
    ('SI000016', 'SH000010', 'OI000015', 15.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-24' WHERE ShipmentID='SH000010';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-30 15:00:00' WHERE ShipmentID='SH000010';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000169', 'SI000015', '2026-08-30 16:00:00', 'Receipt', 16.00, 'WH000008', 'PR000012'),
    ('MV000170', 'SI000016', '2026-08-30 16:00:00', 'Receipt', 15.00, 'WH000008', 'PR000010');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000010', 'SU000009', 'WH000004', '2026-08-22', '2026-08-28', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000016', 'PO000010', 'PR000014', 62.00, 385.00),
    ('OI000017', 'PO000010', 'PR000015', 67.00, 338.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000010';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000011', 'PO000010', 'VN-00011', '2026-08-28 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000017', 'SH000011', 'OI000016', 62.00),
    ('SI000018', 'SH000011', 'OI000017', 67.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-23' WHERE ShipmentID='SH000011';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-28 15:00:00' WHERE ShipmentID='SH000011';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000171', 'SI000017', '2026-08-28 16:00:00', 'Receipt', 62.00, 'WH000004', 'PR000014'),
    ('MV000172', 'SI000018', '2026-08-28 16:00:00', 'Receipt', 67.00, 'WH000004', 'PR000015');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000011', 'SU000010', 'WH000005', '2026-08-23', '2026-08-28', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000018', 'PO000011', 'PR000019', 31.00, 180.75),
    ('OI000019', 'PO000011', 'PR000016', 21.00, 134.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000011';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000012', 'PO000011', 'VN-00012', '2026-08-28 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000019', 'SH000012', 'OI000018', 31.00),
    ('SI000020', 'SH000012', 'OI000019', 21.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-24' WHERE ShipmentID='SH000012';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-08-29 15:00:00' WHERE ShipmentID='SH000012';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000012', 'SU000011', 'WH000006', '2026-08-24', '2026-08-28', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000020', 'PO000012', 'PR000016', 51.00, 332.25),
    ('OI000021', 'PO000012', 'PR000023', 19.00, 364.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000012';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000013', 'PO000012', 'VN-00013', '2026-08-28 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000021', 'SH000013', 'OI000020', 51.00),
    ('SI000022', 'SH000013', 'OI000021', 19.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-25' WHERE ShipmentID='SH000013';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000013', 'SU000012', 'WH000007', '2026-08-25', '2026-09-02', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000022', 'PO000013', 'PR000022', 32.00, 393.00),
    ('OI000023', 'PO000013', 'PR000025', 39.00, 214.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000013';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000014', 'PO000013', 'VN-00014', '2026-09-02 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000023', 'SH000014', 'OI000022', 16.00),
    ('SI000024', 'SH000014', 'OI000023', 19.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-26' WHERE ShipmentID='SH000014';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-01 15:00:00' WHERE ShipmentID='SH000014';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000173', 'SI000023', '2026-09-01 16:00:00', 'Receipt', 16.00, 'WH000007', 'PR000022'),
    ('MV000174', 'SI000024', '2026-09-01 16:00:00', 'Receipt', 19.00, 'WH000007', 'PR000025');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000015', 'PO000013', 'VN-00015', '2026-09-04 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000025', 'SH000015', 'OI000022', 16.00),
    ('SI000026', 'SH000015', 'OI000023', 20.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-28' WHERE ShipmentID='SH000015';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-03 15:00:00' WHERE ShipmentID='SH000015';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000175', 'SI000025', '2026-09-03 16:00:00', 'Receipt', 16.00, 'WH000007', 'PR000022'),
    ('MV000176', 'SI000026', '2026-09-03 16:00:00', 'Receipt', 20.00, 'WH000007', 'PR000025');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000014', 'SU000004', 'WH000008', '2026-08-26', '2026-09-02', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000024', 'PO000014', 'PR000020', 12.00, 255.50),
    ('OI000025', 'PO000014', 'PR000026', 68.00, 192.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000014';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000016', 'PO000014', 'VN-00016', '2026-09-02 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000027', 'SH000016', 'OI000024', 12.00),
    ('SI000028', 'SH000016', 'OI000025', 68.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000016';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000015', 'SU000005', 'WH000004', '2026-08-27', '2026-09-04', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000026', 'PO000015', 'PR000024', 51.00, 22.50),
    ('OI000027', 'PO000015', 'PR000022', 53.00, 259.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000015';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000017', 'PO000015', 'VN-00017', '2026-09-04 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000029', 'SH000017', 'OI000026', 51.00),
    ('SI000030', 'SH000017', 'OI000027', 53.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000016', 'SU000006', 'WH000005', '2026-08-28', '2026-09-02', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000028', 'PO000016', 'PR000007', 69.00, 13.75),
    ('OI000029', 'PO000016', 'PR000026', 35.00, 372.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000017', 'SU000007', 'WH000006', '2026-08-29', '2026-09-04', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000030', 'PO000017', 'PR000008', 62.00, 256.75),
    ('OI000031', 'PO000017', 'PR000009', 45.00, 310.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000017';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000018', 'PO000017', 'VN-00018', '2026-09-04 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000031', 'SH000018', 'OI000030', 31.00),
    ('SI000032', 'SH000018', 'OI000031', 22.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-08-30' WHERE ShipmentID='SH000018';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-03 15:00:00' WHERE ShipmentID='SH000018';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000019', 'PO000017', 'VN-00019', '2026-09-06 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000033', 'SH000019', 'OI000030', 31.00),
    ('SI000034', 'SH000019', 'OI000031', 23.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-01' WHERE ShipmentID='SH000019';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-05 15:00:00' WHERE ShipmentID='SH000019';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000018', 'SU000008', 'WH000007', '2026-08-30', '2026-09-06', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000032', 'PO000018', 'PR000009', 22.00, 309.50),
    ('OI000033', 'PO000018', 'PR000007', 58.00, 428.00);
UPDATE SupplierOrder SET Status='Cancelled' WHERE SupplierOrderID='PO000018';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000019', 'SU000009', 'WH000008', '2026-08-31', '2026-09-07', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000034', 'PO000019', 'PR000011', 34.00, 285.50),
    ('OI000035', 'PO000019', 'PR000016', 11.00, 139.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000019';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000020', 'PO000019', 'VN-00020', '2026-09-07 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000035', 'SH000020', 'OI000034', 34.00),
    ('SI000036', 'SH000020', 'OI000035', 11.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-01' WHERE ShipmentID='SH000020';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000020', 'SU000010', 'WH000004', '2026-09-01', '2026-09-08', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000036', 'PO000020', 'PR000015', 53.00, 168.25),
    ('OI000037', 'PO000020', 'PR000014', 12.00, 52.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000020';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000021', 'PO000020', 'VN-00021', '2026-09-08 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000037', 'SH000021', 'OI000036', 53.00),
    ('SI000038', 'SH000021', 'OI000037', 12.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-02' WHERE ShipmentID='SH000021';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-10 15:00:00' WHERE ShipmentID='SH000021';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000177', 'SI000037', '2026-09-10 16:00:00', 'Receipt', 53.00, 'WH000004', 'PR000015'),
    ('MV000178', 'SI000038', '2026-09-10 16:00:00', 'Receipt', 12.00, 'WH000004', 'PR000014');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000021', 'SU000011', 'WH000005', '2026-09-02', '2026-09-08', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000038', 'PO000021', 'PR000018', 59.00, 120.25),
    ('OI000039', 'PO000021', 'PR000020', 36.00, 354.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000021';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000022', 'PO000021', 'VN-00022', '2026-09-08 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000039', 'SH000022', 'OI000038', 29.00),
    ('SI000040', 'SH000022', 'OI000039', 18.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-03' WHERE ShipmentID='SH000022';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-07 15:00:00' WHERE ShipmentID='SH000022';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000179', 'SI000039', '2026-09-07 16:00:00', 'Receipt', 29.00, 'WH000005', 'PR000018'),
    ('MV000180', 'SI000040', '2026-09-07 16:00:00', 'Receipt', 18.00, 'WH000005', 'PR000020');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000023', 'PO000021', 'VN-00023', '2026-09-10 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000041', 'SH000023', 'OI000038', 30.00),
    ('SI000042', 'SH000023', 'OI000039', 18.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-05' WHERE ShipmentID='SH000023';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-09 15:00:00' WHERE ShipmentID='SH000023';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000181', 'SI000041', '2026-09-09 16:00:00', 'Receipt', 30.00, 'WH000005', 'PR000018'),
    ('MV000182', 'SI000042', '2026-09-09 16:00:00', 'Receipt', 18.00, 'WH000005', 'PR000020');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000022', 'SU000012', 'WH000006', '2026-09-03', '2026-09-08', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000040', 'PO000022', 'PR000024', 56.00, 355.75),
    ('OI000041', 'PO000022', 'PR000022', 52.00, 393.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000022';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000024', 'PO000022', 'VN-00024', '2026-09-08 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000043', 'SH000024', 'OI000040', 56.00),
    ('SI000044', 'SH000024', 'OI000041', 52.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-04' WHERE ShipmentID='SH000024';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-08 15:00:00' WHERE ShipmentID='SH000024';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000183', 'SI000043', '2026-09-08 16:00:00', 'Receipt', 56.00, 'WH000006', 'PR000024'),
    ('MV000184', 'SI000044', '2026-09-08 16:00:00', 'Receipt', 52.00, 'WH000006', 'PR000022');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000023', 'SU000004', 'WH000007', '2026-09-04', '2026-09-10', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000042', 'PO000023', 'PR000021', 38.00, 395.50),
    ('OI000043', 'PO000023', 'PR000024', 34.00, 140.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000023';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000025', 'PO000023', 'VN-00025', '2026-09-10 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000045', 'SH000025', 'OI000042', 38.00),
    ('SI000046', 'SH000025', 'OI000043', 34.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000025';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000024', 'SU000005', 'WH000008', '2026-09-05', '2026-09-13', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000044', 'PO000024', 'PR000025', 11.00, 308.75),
    ('OI000045', 'PO000024', 'PR000022', 30.00, 259.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000024';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000026', 'PO000024', 'VN-00026', '2026-09-13 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000047', 'SH000026', 'OI000044', 11.00),
    ('SI000048', 'SH000026', 'OI000045', 30.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-06' WHERE ShipmentID='SH000026';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-15 15:00:00' WHERE ShipmentID='SH000026';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000185', 'SI000047', '2026-09-15 16:00:00', 'Receipt', 11.00, 'WH000008', 'PR000025'),
    ('MV000186', 'SI000048', '2026-09-15 16:00:00', 'Receipt', 30.00, 'WH000008', 'PR000022');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000025', 'SU000006', 'WH000004', '2026-09-06', '2026-09-10', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000046', 'PO000025', 'PR000028', 65.00, 241.75),
    ('OI000047', 'PO000025', 'PR000008', 58.00, 155.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000025';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000027', 'PO000025', 'VN-00027', '2026-09-10 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000049', 'SH000027', 'OI000046', 32.00),
    ('SI000050', 'SH000027', 'OI000047', 29.00);
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000028', 'PO000025', 'VN-00028', '2026-09-12 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000051', 'SH000028', 'OI000046', 33.00),
    ('SI000052', 'SH000028', 'OI000047', 29.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000026', 'SU000007', 'WH000005', '2026-09-07', '2026-09-14', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000048', 'PO000026', 'PR000029', 63.00, 323.50),
    ('OI000049', 'PO000026', 'PR000010', 26.00, 89.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000026';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000029', 'PO000026', 'VN-00029', '2026-09-14 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000053', 'SH000029', 'OI000048', 63.00),
    ('SI000054', 'SH000029', 'OI000049', 26.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-08' WHERE ShipmentID='SH000029';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000027', 'SU000008', 'WH000006', '2026-09-08', '2026-09-14', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000050', 'PO000027', 'PR000007', 26.00, 428.00),
    ('OI000051', 'PO000027', 'PR000008', 13.00, 186.75);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000028', 'SU000009', 'WH000007', '2026-09-09', '2026-09-13', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000052', 'PO000028', 'PR000016', 19.00, 139.50),
    ('OI000053', 'PO000028', 'PR000014', 56.00, 385.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000028';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000030', 'PO000028', 'VN-00030', '2026-09-13 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000055', 'SH000030', 'OI000052', 19.00),
    ('SI000056', 'SH000030', 'OI000053', 56.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-10' WHERE ShipmentID='SH000030';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-15 15:00:00' WHERE ShipmentID='SH000030';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000187', 'SI000055', '2026-09-15 16:00:00', 'Receipt', 19.00, 'WH000007', 'PR000016'),
    ('MV000188', 'SI000056', '2026-09-15 16:00:00', 'Receipt', 56.00, 'WH000007', 'PR000014');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000029', 'SU000010', 'WH000008', '2026-09-10', '2026-09-16', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000054', 'PO000029', 'PR000014', 10.00, 52.50),
    ('OI000055', 'PO000029', 'PR000018', 61.00, 222.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000029';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000031', 'PO000029', 'VN-00031', '2026-09-16 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000057', 'SH000031', 'OI000054', 5.00),
    ('SI000058', 'SH000031', 'OI000055', 30.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-11' WHERE ShipmentID='SH000031';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-15 15:00:00' WHERE ShipmentID='SH000031';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000032', 'PO000029', 'VN-00032', '2026-09-18 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000059', 'SH000032', 'OI000054', 5.00),
    ('SI000060', 'SH000032', 'OI000055', 31.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-13' WHERE ShipmentID='SH000032';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-17 15:00:00' WHERE ShipmentID='SH000032';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000030', 'SU000011', 'WH000004', '2026-09-11', '2026-09-15', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000056', 'PO000030', 'PR000019', 27.00, 282.00),
    ('OI000057', 'PO000030', 'PR000021', 43.00, 277.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000030';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000033', 'PO000030', 'VN-00033', '2026-09-15 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000061', 'SH000033', 'OI000056', 27.00),
    ('SI000062', 'SH000033', 'OI000057', 43.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-12' WHERE ShipmentID='SH000033';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-15 15:00:00' WHERE ShipmentID='SH000033';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000189', 'SI000061', '2026-09-15 16:00:00', 'Receipt', 27.00, 'WH000004', 'PR000019'),
    ('MV000190', 'SI000062', '2026-09-15 16:00:00', 'Receipt', 43.00, 'WH000004', 'PR000021');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000031', 'SU000012', 'WH000005', '2026-09-12', '2026-09-19', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000058', 'PO000031', 'PR000021', 69.00, 77.25),
    ('OI000059', 'PO000031', 'PR000022', 59.00, 393.00);
UPDATE SupplierOrder SET Status='Cancelled' WHERE SupplierOrderID='PO000031';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000032', 'SU000004', 'WH000006', '2026-09-13', '2026-09-18', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000060', 'PO000032', 'PR000025', 23.00, 140.25),
    ('OI000061', 'PO000032', 'PR000026', 64.00, 192.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000032';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000034', 'PO000032', 'VN-00034', '2026-09-18 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000063', 'SH000034', 'OI000060', 23.00),
    ('SI000064', 'SH000034', 'OI000061', 64.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000034';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000033', 'SU000005', 'WH000007', '2026-09-14', '2026-09-21', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000062', 'PO000033', 'PR000022', 69.00, 259.25),
    ('OI000063', 'PO000033', 'PR000027', 22.00, 225.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000033';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000035', 'PO000033', 'VN-00035', '2026-09-21 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000065', 'SH000035', 'OI000062', 34.00),
    ('SI000066', 'SH000035', 'OI000063', 11.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-15' WHERE ShipmentID='SH000035';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000036', 'PO000033', 'VN-00036', '2026-09-23 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000067', 'SH000036', 'OI000062', 35.00),
    ('SI000068', 'SH000036', 'OI000063', 11.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-17' WHERE ShipmentID='SH000036';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000034', 'SU000006', 'WH000008', '2026-09-15', '2026-09-22', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000064', 'PO000034', 'PR000025', 70.00, 280.75),
    ('OI000065', 'PO000034', 'PR000029', 70.00, 184.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000034';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000037', 'PO000034', 'VN-00037', '2026-09-22 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000069', 'SH000037', 'OI000064', 70.00),
    ('SI000070', 'SH000037', 'OI000065', 70.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-16' WHERE ShipmentID='SH000037';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-22 15:00:00' WHERE ShipmentID='SH000037';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000191', 'SI000069', '2026-09-22 16:00:00', 'Receipt', 70.00, 'WH000008', 'PR000025'),
    ('MV000192', 'SI000070', '2026-09-22 16:00:00', 'Receipt', 70.00, 'WH000008', 'PR000029');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000035', 'SU000007', 'WH000004', '2026-09-16', '2026-09-22', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000066', 'PO000035', 'PR000008', 39.00, 256.50),
    ('OI000067', 'PO000035', 'PR000007', 27.00, 335.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000035';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000038', 'PO000035', 'VN-00038', '2026-09-22 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000071', 'SH000038', 'OI000066', 39.00),
    ('SI000072', 'SH000038', 'OI000067', 27.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000036', 'SU000008', 'WH000005', '2026-09-17', '2026-09-24', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000068', 'PO000036', 'PR000011', 21.00, 310.25),
    ('OI000069', 'PO000036', 'PR000008', 40.00, 186.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000036';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000039', 'PO000036', 'VN-00039', '2026-09-24 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000073', 'SH000039', 'OI000068', 21.00),
    ('SI000074', 'SH000039', 'OI000069', 40.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-18' WHERE ShipmentID='SH000039';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-26 15:00:00' WHERE ShipmentID='SH000039';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000193', 'SI000073', '2026-09-26 16:00:00', 'Receipt', 21.00, 'WH000005', 'PR000011'),
    ('MV000194', 'SI000074', '2026-09-26 16:00:00', 'Receipt', 40.00, 'WH000005', 'PR000008');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000037', 'SU000009', 'WH000006', '2026-09-18', '2026-09-25', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000070', 'PO000037', 'PR000014', 47.00, 385.25),
    ('OI000071', 'PO000037', 'PR000016', 10.00, 139.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000037';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000040', 'PO000037', 'VN-00040', '2026-09-25 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000075', 'SH000040', 'OI000070', 23.00),
    ('SI000076', 'SH000040', 'OI000071', 5.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-19' WHERE ShipmentID='SH000040';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-24 15:00:00' WHERE ShipmentID='SH000040';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000195', 'SI000075', '2026-09-24 16:00:00', 'Receipt', 23.00, 'WH000006', 'PR000014'),
    ('MV000196', 'SI000076', '2026-09-24 16:00:00', 'Receipt', 5.00, 'WH000006', 'PR000016');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000041', 'PO000037', 'VN-00041', '2026-09-27 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000077', 'SH000041', 'OI000070', 24.00),
    ('SI000078', 'SH000041', 'OI000071', 5.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-21' WHERE ShipmentID='SH000041';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-26 15:00:00' WHERE ShipmentID='SH000041';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000197', 'SI000077', '2026-09-26 16:00:00', 'Receipt', 24.00, 'WH000006', 'PR000014'),
    ('MV000198', 'SI000078', '2026-09-26 16:00:00', 'Receipt', 5.00, 'WH000006', 'PR000016');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000038', 'SU000010', 'WH000007', '2026-09-19', '2026-09-24', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000072', 'PO000038', 'PR000013', 15.00, 387.00),
    ('OI000073', 'PO000038', 'PR000018', 42.00, 222.75);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000039', 'SU000011', 'WH000008', '2026-09-20', '2026-09-26', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000074', 'PO000039', 'PR000017', 28.00, 87.00),
    ('OI000075', 'PO000039', 'PR000018', 19.00, 120.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000039';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000042', 'PO000039', 'VN-00042', '2026-09-26 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000079', 'SH000042', 'OI000074', 28.00),
    ('SI000080', 'SH000042', 'OI000075', 19.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-21' WHERE ShipmentID='SH000042';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-27 15:00:00' WHERE ShipmentID='SH000042';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000199', 'SI000079', '2026-09-27 16:00:00', 'Receipt', 28.00, 'WH000008', 'PR000017'),
    ('MV000200', 'SI000080', '2026-09-27 16:00:00', 'Receipt', 19.00, 'WH000008', 'PR000018');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000040', 'SU000012', 'WH000004', '2026-09-21', '2026-09-27', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000076', 'PO000040', 'PR000020', 55.00, 289.50),
    ('OI000077', 'PO000040', 'PR000026', 69.00, 13.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000040';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000043', 'PO000040', 'VN-00043', '2026-09-27 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000081', 'SH000043', 'OI000076', 55.00),
    ('SI000082', 'SH000043', 'OI000077', 69.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-22' WHERE ShipmentID='SH000043';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000041', 'SU000004', 'WH000005', '2026-09-22', '2026-09-27', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000078', 'PO000041', 'PR000020', 54.00, 255.50),
    ('OI000079', 'PO000041', 'PR000022', 34.00, 92.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000041';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000044', 'PO000041', 'VN-00044', '2026-09-27 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000083', 'SH000044', 'OI000078', 27.00),
    ('SI000084', 'SH000044', 'OI000079', 17.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000044';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000045', 'PO000041', 'VN-00045', '2026-09-29 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000085', 'SH000045', 'OI000078', 27.00),
    ('SI000086', 'SH000045', 'OI000079', 17.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-25' WHERE ShipmentID='SH000045';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-28 15:00:00' WHERE ShipmentID='SH000045';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000042', 'SU000005', 'WH000006', '2026-09-23', '2026-09-28', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000080', 'PO000042', 'PR000027', 27.00, 225.75),
    ('OI000081', 'PO000042', 'PR000026', 46.00, 200.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000042';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000046', 'PO000042', 'VN-00046', '2026-09-28 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000087', 'SH000046', 'OI000080', 27.00),
    ('SI000088', 'SH000046', 'OI000081', 46.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-24' WHERE ShipmentID='SH000046';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-09-28 15:00:00' WHERE ShipmentID='SH000046';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000201', 'SI000087', '2026-09-28 16:00:00', 'Receipt', 27.00, 'WH000006', 'PR000027'),
    ('MV000202', 'SI000088', '2026-09-28 16:00:00', 'Receipt', 46.00, 'WH000006', 'PR000026');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000043', 'SU000006', 'WH000007', '2026-09-24', '2026-10-01', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000082', 'PO000043', 'PR000027', 42.00, 403.75),
    ('OI000083', 'PO000043', 'PR000028', 48.00, 242.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000043';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000047', 'PO000043', 'VN-00047', '2026-10-01 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000089', 'SH000047', 'OI000082', 42.00),
    ('SI000090', 'SH000047', 'OI000083', 48.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-25' WHERE ShipmentID='SH000047';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-02 15:00:00' WHERE ShipmentID='SH000047';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000203', 'SI000089', '2026-10-02 16:00:00', 'Receipt', 42.00, 'WH000007', 'PR000027'),
    ('MV000204', 'SI000090', '2026-10-02 16:00:00', 'Receipt', 48.00, 'WH000007', 'PR000028');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000044', 'SU000007', 'WH000008', '2026-09-25', '2026-09-29', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000084', 'PO000044', 'PR000010', 52.00, 89.50),
    ('OI000085', 'PO000044', 'PR000007', 50.00, 336.00);
UPDATE SupplierOrder SET Status='Cancelled' WHERE SupplierOrderID='PO000044';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000045', 'SU000008', 'WH000004', '2026-09-26', '2026-10-01', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000086', 'PO000045', 'PR000009', 25.00, 309.25),
    ('OI000087', 'PO000045', 'PR000013', 31.00, 72.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000045';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000048', 'PO000045', 'VN-00048', '2026-10-01 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000091', 'SH000048', 'OI000086', 12.00),
    ('SI000092', 'SH000048', 'OI000087', 15.00);
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000049', 'PO000045', 'VN-00049', '2026-10-03 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000093', 'SH000049', 'OI000086', 13.00),
    ('SI000094', 'SH000049', 'OI000087', 16.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000046', 'SU000009', 'WH000005', '2026-09-27', '2026-10-03', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000088', 'PO000046', 'PR000017', 64.00, 137.75),
    ('OI000089', 'PO000046', 'PR000011', 64.00, 285.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000046';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000050', 'PO000046', 'VN-00050', '2026-10-03 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000095', 'SH000050', 'OI000088', 64.00),
    ('SI000096', 'SH000050', 'OI000089', 64.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-28' WHERE ShipmentID='SH000050';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-03 15:00:00' WHERE ShipmentID='SH000050';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000205', 'SI000095', '2026-10-03 16:00:00', 'Receipt', 64.00, 'WH000005', 'PR000017'),
    ('MV000206', 'SI000096', '2026-10-03 16:00:00', 'Receipt', 64.00, 'WH000005', 'PR000011');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000047', 'SU000010', 'WH000006', '2026-09-28', '2026-10-02', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000090', 'PO000047', 'PR000018', 11.00, 222.75),
    ('OI000091', 'PO000047', 'PR000015', 22.00, 168.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000047';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000051', 'PO000047', 'VN-00051', '2026-10-02 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000097', 'SH000051', 'OI000090', 11.00),
    ('SI000098', 'SH000051', 'OI000091', 22.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-29' WHERE ShipmentID='SH000051';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000048', 'SU000011', 'WH000007', '2026-09-29', '2026-10-03', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000092', 'PO000048', 'PR000019', 27.00, 282.25),
    ('OI000093', 'PO000048', 'PR000023', 21.00, 364.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000048';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000052', 'PO000048', 'VN-00052', '2026-10-03 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000099', 'SH000052', 'OI000092', 27.00),
    ('SI000100', 'SH000052', 'OI000093', 21.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-09-30' WHERE ShipmentID='SH000052';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-05 15:00:00' WHERE ShipmentID='SH000052';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000207', 'SI000099', '2026-10-05 16:00:00', 'Receipt', 27.00, 'WH000007', 'PR000019'),
    ('MV000208', 'SI000100', '2026-10-05 16:00:00', 'Receipt', 21.00, 'WH000007', 'PR000023');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000049', 'SU000012', 'WH000008', '2026-09-30', '2026-10-06', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000094', 'PO000049', 'PR000020', 16.00, 289.75),
    ('OI000095', 'PO000049', 'PR000023', 35.00, 345.25);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000050', 'SU000004', 'WH000004', '2026-10-01', '2026-10-09', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000096', 'PO000050', 'PR000025', 31.00, 140.00),
    ('OI000097', 'PO000050', 'PR000021', 66.00, 395.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000050';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000053', 'PO000050', 'VN-00053', '2026-10-09 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000101', 'SH000053', 'OI000096', 31.00),
    ('SI000102', 'SH000053', 'OI000097', 66.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000053';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000051', 'SU000005', 'WH000005', '2026-10-02', '2026-10-10', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000098', 'PO000051', 'PR000025', 62.00, 308.75),
    ('OI000099', 'PO000051', 'PR000023', 61.00, 300.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000051';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000054', 'PO000051', 'VN-00054', '2026-10-10 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000103', 'SH000054', 'OI000098', 62.00),
    ('SI000104', 'SH000054', 'OI000099', 61.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-03' WHERE ShipmentID='SH000054';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-11 15:00:00' WHERE ShipmentID='SH000054';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000209', 'SI000103', '2026-10-11 16:00:00', 'Receipt', 62.00, 'WH000005', 'PR000025'),
    ('MV000210', 'SI000104', '2026-10-11 16:00:00', 'Receipt', 61.00, 'WH000005', 'PR000023');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000052', 'SU000006', 'WH000006', '2026-10-03', '2026-10-10', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000100', 'PO000052', 'PR000029', 64.00, 184.00),
    ('OI000101', 'PO000052', 'PR000030', 53.00, 252.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000052';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000055', 'PO000052', 'VN-00055', '2026-10-10 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000105', 'SH000055', 'OI000100', 64.00),
    ('SI000106', 'SH000055', 'OI000101', 53.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-04' WHERE ShipmentID='SH000055';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-12 15:00:00' WHERE ShipmentID='SH000055';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000211', 'SI000105', '2026-10-12 16:00:00', 'Receipt', 64.00, 'WH000006', 'PR000029'),
    ('MV000212', 'SI000106', '2026-10-12 16:00:00', 'Receipt', 53.00, 'WH000006', 'PR000030');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000053', 'SU000007', 'WH000007', '2026-10-04', '2026-10-09', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000102', 'PO000053', 'PR000008', 45.00, 256.75),
    ('OI000103', 'PO000053', 'PR000009', 37.00, 310.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000053';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000056', 'PO000053', 'VN-00056', '2026-10-09 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000107', 'SH000056', 'OI000102', 22.00),
    ('SI000108', 'SH000056', 'OI000103', 18.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-05' WHERE ShipmentID='SH000056';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-08 15:00:00' WHERE ShipmentID='SH000056';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000057', 'PO000053', 'VN-00057', '2026-10-11 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000109', 'SH000057', 'OI000102', 23.00),
    ('SI000110', 'SH000057', 'OI000103', 19.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-07' WHERE ShipmentID='SH000057';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-10 15:00:00' WHERE ShipmentID='SH000057';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000054', 'SU000008', 'WH000008', '2026-10-05', '2026-10-13', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000104', 'PO000054', 'PR000007', 51.00, 428.00),
    ('OI000105', 'PO000054', 'PR000010', 60.00, 343.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000054';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000058', 'PO000054', 'VN-00058', '2026-10-13 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000111', 'SH000058', 'OI000104', 51.00),
    ('SI000112', 'SH000058', 'OI000105', 60.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-06' WHERE ShipmentID='SH000058';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000055', 'SU000009', 'WH000004', '2026-10-06', '2026-10-14', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000106', 'PO000055', 'PR000015', 32.00, 338.75),
    ('OI000107', 'PO000055', 'PR000013', 30.00, 303.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000055';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000059', 'PO000055', 'VN-00059', '2026-10-14 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000113', 'SH000059', 'OI000106', 32.00),
    ('SI000114', 'SH000059', 'OI000107', 30.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000056', 'SU000010', 'WH000005', '2026-10-07', '2026-10-12', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000108', 'PO000056', 'PR000019', 47.00, 180.75),
    ('OI000109', 'PO000056', 'PR000015', 40.00, 168.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000056';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000060', 'PO000056', 'VN-00060', '2026-10-12 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000115', 'SH000060', 'OI000108', 47.00),
    ('SI000116', 'SH000060', 'OI000109', 40.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-08' WHERE ShipmentID='SH000060';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-14 15:00:00' WHERE ShipmentID='SH000060';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000213', 'SI000115', '2026-10-14 16:00:00', 'Receipt', 47.00, 'WH000005', 'PR000019'),
    ('MV000214', 'SI000116', '2026-10-14 16:00:00', 'Receipt', 40.00, 'WH000005', 'PR000015');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000057', 'SU000011', 'WH000006', '2026-10-08', '2026-10-15', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000110', 'PO000057', 'PR000023', 52.00, 364.75),
    ('OI000111', 'PO000057', 'PR000018', 50.00, 120.25);
UPDATE SupplierOrder SET Status='Cancelled' WHERE SupplierOrderID='PO000057';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000058', 'SU000012', 'WH000007', '2026-10-09', '2026-10-14', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000112', 'PO000058', 'PR000019', 42.00, 122.75),
    ('OI000113', 'PO000058', 'PR000025', 63.00, 214.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000058';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000061', 'PO000058', 'VN-00061', '2026-10-14 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000117', 'SH000061', 'OI000112', 42.00),
    ('SI000118', 'SH000061', 'OI000113', 63.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-10' WHERE ShipmentID='SH000061';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-14 15:00:00' WHERE ShipmentID='SH000061';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000215', 'SI000117', '2026-10-14 16:00:00', 'Receipt', 42.00, 'WH000007', 'PR000019'),
    ('MV000216', 'SI000118', '2026-10-14 16:00:00', 'Receipt', 63.00, 'WH000007', 'PR000025');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000059', 'SU000004', 'WH000008', '2026-10-10', '2026-10-18', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000114', 'PO000059', 'PR000025', 51.00, 140.25),
    ('OI000115', 'PO000059', 'PR000023', 60.00, 346.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000059';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000062', 'PO000059', 'VN-00062', '2026-10-18 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000119', 'SH000062', 'OI000114', 51.00),
    ('SI000120', 'SH000062', 'OI000115', 60.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000062';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000060', 'SU000005', 'WH000004', '2026-10-11', '2026-10-19', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000116', 'PO000060', 'PR000026', 14.00, 200.50),
    ('OI000117', 'PO000060', 'PR000027', 63.00, 225.50);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000061', 'SU000006', 'WH000005', '2026-10-12', '2026-10-20', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000118', 'PO000061', 'PR000028', 58.00, 242.00),
    ('OI000119', 'PO000061', 'PR000030', 18.00, 252.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000061';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000063', 'PO000061', 'VN-00063', '2026-10-20 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000121', 'SH000063', 'OI000118', 29.00),
    ('SI000122', 'SH000063', 'OI000119', 9.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-13' WHERE ShipmentID='SH000063';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000064', 'PO000061', 'VN-00064', '2026-10-22 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000123', 'SH000064', 'OI000118', 29.00),
    ('SI000124', 'SH000064', 'OI000119', 9.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-15' WHERE ShipmentID='SH000064';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000062', 'SU000007', 'WH000006', '2026-10-13', '2026-10-17', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000120', 'PO000062', 'PR000029', 37.00, 323.50),
    ('OI000121', 'PO000062', 'PR000008', 22.00, 256.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000062';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000065', 'PO000062', 'VN-00065', '2026-10-17 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000125', 'SH000065', 'OI000120', 37.00),
    ('SI000126', 'SH000065', 'OI000121', 22.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-14' WHERE ShipmentID='SH000065';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-17 15:00:00' WHERE ShipmentID='SH000065';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000217', 'SI000125', '2026-10-17 16:00:00', 'Receipt', 37.00, 'WH000006', 'PR000029'),
    ('MV000218', 'SI000126', '2026-10-17 16:00:00', 'Receipt', 22.00, 'WH000006', 'PR000008');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000063', 'SU000008', 'WH000007', '2026-10-14', '2026-10-20', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000122', 'PO000063', 'PR000011', 38.00, 310.25),
    ('OI000123', 'PO000063', 'PR000010', 43.00, 343.00);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000063';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000066', 'PO000063', 'VN-00066', '2026-10-20 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000127', 'SH000066', 'OI000122', 38.00),
    ('SI000128', 'SH000066', 'OI000123', 43.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-15' WHERE ShipmentID='SH000066';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-21 15:00:00' WHERE ShipmentID='SH000066';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000219', 'SI000127', '2026-10-21 16:00:00', 'Receipt', 38.00, 'WH000007', 'PR000011'),
    ('MV000220', 'SI000128', '2026-10-21 16:00:00', 'Receipt', 43.00, 'WH000007', 'PR000010');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000064', 'SU000009', 'WH000008', '2026-10-15', '2026-10-23', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000124', 'PO000064', 'PR000015', 37.00, 339.00),
    ('OI000125', 'PO000064', 'PR000016', 49.00, 139.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000064';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000067', 'PO000064', 'VN-00067', '2026-10-23 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000129', 'SH000067', 'OI000124', 37.00),
    ('SI000130', 'SH000067', 'OI000125', 49.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-16' WHERE ShipmentID='SH000067';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-25 15:00:00' WHERE ShipmentID='SH000067';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000221', 'SI000129', '2026-10-25 16:00:00', 'Receipt', 37.00, 'WH000008', 'PR000015'),
    ('MV000222', 'SI000130', '2026-10-25 16:00:00', 'Receipt', 49.00, 'WH000008', 'PR000016');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000065', 'SU000010', 'WH000004', '2026-10-16', '2026-10-20', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000126', 'PO000065', 'PR000017', 47.00, 198.75),
    ('OI000127', 'PO000065', 'PR000016', 53.00, 134.50);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000065';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000068', 'PO000065', 'VN-00068', '2026-10-20 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000131', 'SH000068', 'OI000126', 23.00),
    ('SI000132', 'SH000068', 'OI000127', 26.00);
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000069', 'PO000065', 'VN-00069', '2026-10-22 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000133', 'SH000069', 'OI000126', 24.00),
    ('SI000134', 'SH000069', 'OI000127', 27.00);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000066', 'SU000011', 'WH000005', '2026-10-17', '2026-10-23', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000128', 'PO000066', 'PR000022', 63.00, 5.75),
    ('OI000129', 'PO000066', 'PR000023', 53.00, 364.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000066';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000070', 'PO000066', 'VN-00070', '2026-10-23 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000135', 'SH000070', 'OI000128', 63.00),
    ('SI000136', 'SH000070', 'OI000129', 53.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-18' WHERE ShipmentID='SH000070';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-23 15:00:00' WHERE ShipmentID='SH000070';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000223', 'SI000135', '2026-10-23 16:00:00', 'Receipt', 63.00, 'WH000005', 'PR000022'),
    ('MV000224', 'SI000136', '2026-10-23 16:00:00', 'Receipt', 53.00, 'WH000005', 'PR000023');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000067', 'SU000012', 'WH000006', '2026-10-18', '2026-10-25', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000130', 'PO000067', 'PR000023', 39.00, 345.25),
    ('OI000131', 'PO000067', 'PR000019', 52.00, 122.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000067';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000071', 'PO000067', 'VN-00071', '2026-10-25 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000137', 'SH000071', 'OI000130', 39.00),
    ('SI000138', 'SH000071', 'OI000131', 52.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-19' WHERE ShipmentID='SH000071';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-26 15:00:00' WHERE ShipmentID='SH000071';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000225', 'SI000137', '2026-10-26 16:00:00', 'Receipt', 39.00, 'WH000006', 'PR000023'),
    ('MV000226', 'SI000138', '2026-10-26 16:00:00', 'Receipt', 52.00, 'WH000006', 'PR000019');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000068', 'SU000004', 'WH000007', '2026-10-19', '2026-10-26', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000132', 'PO000068', 'PR000026', 68.00, 192.25),
    ('OI000133', 'PO000068', 'PR000024', 60.00, 140.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000068';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000072', 'PO000068', 'VN-00072', '2026-10-26 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000139', 'SH000072', 'OI000132', 68.00),
    ('SI000140', 'SH000072', 'OI000133', 60.00);
UPDATE Shipment SET Status='Cancelled' WHERE ShipmentID='SH000072';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000069', 'SU000005', 'WH000008', '2026-10-20', '2026-10-27', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000134', 'PO000069', 'PR000027', 12.00, 225.75),
    ('OI000135', 'PO000069', 'PR000022', 43.00, 259.25);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000069';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000073', 'PO000069', 'VN-00073', '2026-10-27 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000141', 'SH000073', 'OI000134', 6.00),
    ('SI000142', 'SH000073', 'OI000135', 21.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-21' WHERE ShipmentID='SH000073';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-26 15:00:00' WHERE ShipmentID='SH000073';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000227', 'SI000141', '2026-10-26 16:00:00', 'Receipt', 6.00, 'WH000008', 'PR000027'),
    ('MV000228', 'SI000142', '2026-10-26 16:00:00', 'Receipt', 21.00, 'WH000008', 'PR000022');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000074', 'PO000069', 'VN-00074', '2026-10-29 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000143', 'SH000074', 'OI000134', 6.00),
    ('SI000144', 'SH000074', 'OI000135', 22.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-23' WHERE ShipmentID='SH000074';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-28 15:00:00' WHERE ShipmentID='SH000074';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000229', 'SI000143', '2026-10-28 16:00:00', 'Receipt', 6.00, 'WH000008', 'PR000027'),
    ('MV000230', 'SI000144', '2026-10-28 16:00:00', 'Receipt', 22.00, 'WH000008', 'PR000022');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000070', 'SU000006', 'WH000004', '2026-10-21', '2026-10-25', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000136', 'PO000070', 'PR000025', 29.00, 280.50),
    ('OI000137', 'PO000070', 'PR000028', 18.00, 241.75);
UPDATE SupplierOrder SET Status='Cancelled' WHERE SupplierOrderID='PO000070';
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000071', 'SU000007', 'WH000005', '2026-10-22', '2026-10-27', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000138', 'PO000071', 'PR000011', 70.00, 351.75),
    ('OI000139', 'PO000071', 'PR000009', 16.00, 310.50);
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000072', 'SU000008', 'WH000006', '2026-10-23', '2026-10-31', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000140', 'PO000072', 'PR000013', 29.00, 73.00),
    ('OI000141', 'PO000072', 'PR000012', 64.00, 117.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000072';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000075', 'PO000072', 'VN-00075', '2026-10-31 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000145', 'SH000075', 'OI000140', 29.00),
    ('SI000146', 'SH000075', 'OI000141', 64.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-24' WHERE ShipmentID='SH000075';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-11-02 15:00:00' WHERE ShipmentID='SH000075';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000231', 'SI000145', '2026-11-02 16:00:00', 'Receipt', 29.00, 'WH000006', 'PR000013'),
    ('MV000232', 'SI000146', '2026-11-02 16:00:00', 'Receipt', 64.00, 'WH000006', 'PR000012');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000073', 'SU000009', 'WH000007', '2026-10-24', '2026-10-28', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000142', 'PO000073', 'PR000016', 27.00, 139.50),
    ('OI000143', 'PO000073', 'PR000010', 13.00, 24.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000073';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000076', 'PO000073', 'VN-00076', '2026-10-28 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000147', 'SH000076', 'OI000142', 13.00),
    ('SI000148', 'SH000076', 'OI000143', 6.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-25' WHERE ShipmentID='SH000076';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-27 15:00:00' WHERE ShipmentID='SH000076';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000233', 'SI000147', '2026-10-27 16:00:00', 'Receipt', 13.00, 'WH000007', 'PR000016'),
    ('MV000234', 'SI000148', '2026-10-27 16:00:00', 'Receipt', 6.00, 'WH000007', 'PR000010');
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000077', 'PO000073', 'VN-00077', '2026-10-30 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000149', 'SH000077', 'OI000142', 14.00),
    ('SI000150', 'SH000077', 'OI000143', 7.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-27' WHERE ShipmentID='SH000077';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-10-29 15:00:00' WHERE ShipmentID='SH000077';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000235', 'SI000149', '2026-10-29 16:00:00', 'Receipt', 14.00, 'WH000007', 'PR000016'),
    ('MV000236', 'SI000150', '2026-10-29 16:00:00', 'Receipt', 7.00, 'WH000007', 'PR000010');
INSERT INTO SupplierOrder (SupplierOrderID, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, Status) VALUES
    ('PO000074', 'SU000010', 'WH000008', '2026-10-25', '2026-11-02', 'Draft');
INSERT INTO SupplierOrderItem (SupplierOrderItemID, SupplierOrderID, ProductID, Quantity, UnitPrice) VALUES
    ('OI000144', 'PO000074', 'PR000014', 50.00, 52.50),
    ('OI000145', 'PO000074', 'PR000016', 29.00, 134.75);
UPDATE SupplierOrder SET Status='Submitted' WHERE SupplierOrderID='PO000074';
INSERT INTO Shipment (ShipmentID, SupplierOrderID, TrackingNumber, EstimatedArrival) VALUES
    ('SH000078', 'PO000074', 'VN-00078', '2026-11-02 14:00:00');
INSERT INTO ShipmentItem (ShipmentItemID, ShipmentID, SupplierOrderItemID, Quantity) VALUES
    ('SI000151', 'SH000078', 'OI000144', 50.00),
    ('SI000152', 'SH000078', 'OI000145', 29.00);
UPDATE Shipment SET Status='Dispatched',ShipmentDate='2026-10-26' WHERE ShipmentID='SH000078';
UPDATE Shipment SET Status='Arrived',ActualArrival='2026-11-02 15:00:00' WHERE ShipmentID='SH000078';
INSERT INTO StockMovement (MovementID, ShipmentItemID, MovementTime, MovementType, QuantityDelta, WarehouseID, ProductID) VALUES
    ('MV000237', 'SI000151', '2026-11-02 16:00:00', 'Receipt', 50.00, 'WH000008', 'PR000014'),
    ('MV000238', 'SI000152', '2026-11-02 16:00:00', 'Receipt', 29.00, 'WH000008', 'PR000016');
INSERT INTO TrackingEvent (ShipmentID, EventTime, Location, EventType, Description, TrackingEventID) VALUES
    ('SH000006', '2026-08-18 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000006', '2026-08-19 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000006', '2026-08-19 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000006', '2026-08-19 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000006', '2026-08-19 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000006', '2026-08-19 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000006', '2026-08-19 14:00:00', 'Dong Nai route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000006', '2026-08-23 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000007', '2026-08-19 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000007', '2026-08-20 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000007', '2026-08-20 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000007', '2026-08-20 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000007', '2026-08-20 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000007', '2026-08-20 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000007', '2026-08-20 14:00:00', 'Hai Phong route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000007', '2026-08-27 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000008', '2026-08-20 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000008', '2026-08-21 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000008', '2026-08-21 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000008', '2026-08-21 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000008', '2026-08-21 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000008', '2026-08-21 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000008', '2026-08-21 14:00:00', 'Can Tho route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000008', '2026-08-27 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000009', '2026-08-21 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000009', '2026-08-22 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000009', '2026-08-22 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000009', '2026-08-22 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000009', '2026-08-22 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000009', '2026-08-22 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000009', '2026-08-22 14:00:00', 'Bac Ninh route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000009', '2026-08-28 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000010', '2026-08-21 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000010', '2026-08-24 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000010', '2026-08-24 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000010', '2026-08-24 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000010', '2026-08-24 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000010', '2026-08-24 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000010', '2026-08-24 14:00:00', 'Bac Ninh route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000010', '2026-08-30 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000011', '2026-08-22 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000011', '2026-08-23 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000011', '2026-08-23 09:00:00', 'Binh Duong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000011', '2026-08-23 10:30:00', 'Binh Duong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000011', '2026-08-23 12:00:00', 'Binh Duong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000011', '2026-08-23 13:15:00', 'Binh Duong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000011', '2026-08-23 14:00:00', 'Binh Duong route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000011', '2026-08-28 15:00:00', 'Binh Duong', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000012', '2026-08-23 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000012', '2026-08-24 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000012', '2026-08-24 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000012', '2026-08-24 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000012', '2026-08-24 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000012', '2026-08-24 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000012', '2026-08-24 14:00:00', 'Dong Nai route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000012', '2026-08-29 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000013', '2026-08-24 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000013', '2026-08-25 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000013', '2026-08-25 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000013', '2026-08-25 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000013', '2026-08-25 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000013', '2026-08-25 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000013', '2026-08-25 14:00:00', 'Hai Phong route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000014', '2026-08-25 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000014', '2026-08-26 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000014', '2026-08-26 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000014', '2026-08-26 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000014', '2026-08-26 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000014', '2026-08-26 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000014', '2026-08-26 14:00:00', 'Can Tho route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000014', '2026-09-01 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000015', '2026-08-25 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000015', '2026-08-28 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000015', '2026-08-28 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000015', '2026-08-28 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000015', '2026-08-28 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000015', '2026-08-28 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000015', '2026-08-28 14:00:00', 'Can Tho route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000015', '2026-09-03 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000016', '2026-08-26 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000016', '2026-08-27 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000017', '2026-08-27 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000018', '2026-08-29 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000018', '2026-08-30 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000018', '2026-08-30 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000018', '2026-08-30 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000018', '2026-08-30 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000018', '2026-08-30 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000018', '2026-08-30 14:00:00', 'Hai Phong route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000018', '2026-09-03 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000019', '2026-08-29 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000019', '2026-09-01 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000019', '2026-09-01 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000019', '2026-09-01 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000019', '2026-09-01 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000019', '2026-09-01 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000019', '2026-09-01 14:00:00', 'Hai Phong route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000019', '2026-09-05 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000008'),
    ('SH000020', '2026-08-31 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000020', '2026-09-01 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002');
INSERT INTO TrackingEvent (ShipmentID, EventTime, Location, EventType, Description, TrackingEventID) VALUES
    ('SH000020', '2026-09-01 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000020', '2026-09-01 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000020', '2026-09-01 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000020', '2026-09-01 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000020', '2026-09-01 14:00:00', 'Bac Ninh route', 'LocationUpdated', 'Destination transfer', 'EV000007'),
    ('SH000021', '2026-09-01 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000021', '2026-09-02 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000021', '2026-09-02 09:00:00', 'Binh Duong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000021', '2026-09-02 10:30:00', 'Binh Duong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000021', '2026-09-02 12:00:00', 'Binh Duong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000021', '2026-09-02 13:15:00', 'Binh Duong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000021', '2026-09-10 15:00:00', 'Binh Duong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000022', '2026-09-02 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000022', '2026-09-03 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000022', '2026-09-03 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000022', '2026-09-03 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000022', '2026-09-03 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000022', '2026-09-03 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000022', '2026-09-07 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000023', '2026-09-02 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000023', '2026-09-05 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000023', '2026-09-05 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000023', '2026-09-05 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000023', '2026-09-05 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000023', '2026-09-05 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000023', '2026-09-09 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000024', '2026-09-03 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000024', '2026-09-04 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000024', '2026-09-04 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000024', '2026-09-04 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000024', '2026-09-04 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000024', '2026-09-04 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000024', '2026-09-08 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000025', '2026-09-04 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000025', '2026-09-05 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000026', '2026-09-05 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000026', '2026-09-06 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000026', '2026-09-06 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000026', '2026-09-06 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000026', '2026-09-06 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000026', '2026-09-06 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000026', '2026-09-15 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000027', '2026-09-06 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000028', '2026-09-06 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000029', '2026-09-07 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000029', '2026-09-08 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000029', '2026-09-08 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000029', '2026-09-08 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000029', '2026-09-08 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000029', '2026-09-08 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000030', '2026-09-09 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000030', '2026-09-10 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000030', '2026-09-10 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000030', '2026-09-10 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000030', '2026-09-10 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000030', '2026-09-10 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000030', '2026-09-15 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000031', '2026-09-10 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000031', '2026-09-11 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000031', '2026-09-11 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000031', '2026-09-11 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000031', '2026-09-11 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000031', '2026-09-11 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000031', '2026-09-15 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000032', '2026-09-10 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000032', '2026-09-13 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000032', '2026-09-13 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000032', '2026-09-13 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000032', '2026-09-13 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000032', '2026-09-13 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000032', '2026-09-17 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000033', '2026-09-11 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000033', '2026-09-12 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000033', '2026-09-12 09:00:00', 'Binh Duong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000033', '2026-09-12 10:30:00', 'Binh Duong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000033', '2026-09-12 12:00:00', 'Binh Duong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000033', '2026-09-12 13:15:00', 'Binh Duong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000033', '2026-09-15 15:00:00', 'Binh Duong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000034', '2026-09-13 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000034', '2026-09-14 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000035', '2026-09-14 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000035', '2026-09-15 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000035', '2026-09-15 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000035', '2026-09-15 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000035', '2026-09-15 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000035', '2026-09-15 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000036', '2026-09-14 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000036', '2026-09-17 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000036', '2026-09-17 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000036', '2026-09-17 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000036', '2026-09-17 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000036', '2026-09-17 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000037', '2026-09-15 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000037', '2026-09-16 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000037', '2026-09-16 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000037', '2026-09-16 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000037', '2026-09-16 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000037', '2026-09-16 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000037', '2026-09-22 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000038', '2026-09-16 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001');
INSERT INTO TrackingEvent (ShipmentID, EventTime, Location, EventType, Description, TrackingEventID) VALUES
    ('SH000039', '2026-09-17 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000039', '2026-09-18 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000039', '2026-09-18 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000039', '2026-09-18 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000039', '2026-09-18 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000039', '2026-09-18 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000039', '2026-09-26 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000040', '2026-09-18 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000040', '2026-09-19 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000040', '2026-09-19 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000040', '2026-09-19 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000040', '2026-09-19 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000040', '2026-09-19 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000040', '2026-09-24 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000041', '2026-09-18 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000041', '2026-09-21 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000041', '2026-09-21 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000041', '2026-09-21 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000041', '2026-09-21 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000041', '2026-09-21 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000041', '2026-09-26 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000042', '2026-09-20 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000042', '2026-09-21 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000042', '2026-09-21 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000042', '2026-09-21 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000042', '2026-09-21 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000042', '2026-09-21 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000042', '2026-09-27 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000043', '2026-09-21 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000043', '2026-09-22 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000043', '2026-09-22 09:00:00', 'Binh Duong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000043', '2026-09-22 10:30:00', 'Binh Duong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000043', '2026-09-22 12:00:00', 'Binh Duong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000043', '2026-09-22 13:15:00', 'Binh Duong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000044', '2026-09-22 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000044', '2026-09-23 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000045', '2026-09-22 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000045', '2026-09-25 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000045', '2026-09-25 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000045', '2026-09-25 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000045', '2026-09-25 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000045', '2026-09-25 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000045', '2026-09-28 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000046', '2026-09-23 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000046', '2026-09-24 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000046', '2026-09-24 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000046', '2026-09-24 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000046', '2026-09-24 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000046', '2026-09-24 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000046', '2026-09-28 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000047', '2026-09-24 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000047', '2026-09-25 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000047', '2026-09-25 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000047', '2026-09-25 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000047', '2026-09-25 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000047', '2026-09-25 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000047', '2026-10-02 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000048', '2026-09-26 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000049', '2026-09-26 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000050', '2026-09-27 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000050', '2026-09-28 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000050', '2026-09-28 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000050', '2026-09-28 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000050', '2026-09-28 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000050', '2026-09-28 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000050', '2026-10-03 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000051', '2026-09-28 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000051', '2026-09-29 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000051', '2026-09-29 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000051', '2026-09-29 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000051', '2026-09-29 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000051', '2026-09-29 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000052', '2026-09-29 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000052', '2026-09-30 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000052', '2026-09-30 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000052', '2026-09-30 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000052', '2026-09-30 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000052', '2026-09-30 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000052', '2026-10-05 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000053', '2026-10-01 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000053', '2026-10-02 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000054', '2026-10-02 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000054', '2026-10-03 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000054', '2026-10-03 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000054', '2026-10-03 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000054', '2026-10-03 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000054', '2026-10-03 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000054', '2026-10-11 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000055', '2026-10-03 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000055', '2026-10-04 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000055', '2026-10-04 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000055', '2026-10-04 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000055', '2026-10-04 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000055', '2026-10-04 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000055', '2026-10-12 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000056', '2026-10-04 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000056', '2026-10-05 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000056', '2026-10-05 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000056', '2026-10-05 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000056', '2026-10-05 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005');
INSERT INTO TrackingEvent (ShipmentID, EventTime, Location, EventType, Description, TrackingEventID) VALUES
    ('SH000056', '2026-10-05 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000056', '2026-10-08 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000057', '2026-10-04 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000057', '2026-10-07 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000057', '2026-10-07 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000057', '2026-10-07 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000057', '2026-10-07 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000057', '2026-10-07 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000057', '2026-10-10 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000058', '2026-10-05 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000058', '2026-10-06 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000058', '2026-10-06 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000058', '2026-10-06 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000058', '2026-10-06 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000058', '2026-10-06 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000059', '2026-10-06 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000060', '2026-10-07 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000060', '2026-10-08 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000060', '2026-10-08 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000060', '2026-10-08 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000060', '2026-10-08 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000060', '2026-10-08 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000060', '2026-10-14 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000061', '2026-10-09 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000061', '2026-10-10 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000061', '2026-10-10 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000061', '2026-10-10 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000061', '2026-10-10 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000061', '2026-10-10 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000061', '2026-10-14 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000062', '2026-10-10 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000062', '2026-10-11 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000063', '2026-10-12 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000063', '2026-10-13 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000063', '2026-10-13 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000063', '2026-10-13 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000063', '2026-10-13 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000063', '2026-10-13 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000064', '2026-10-12 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000064', '2026-10-15 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000064', '2026-10-15 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000064', '2026-10-15 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000064', '2026-10-15 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000064', '2026-10-15 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000065', '2026-10-13 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000065', '2026-10-14 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000065', '2026-10-14 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000065', '2026-10-14 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000065', '2026-10-14 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000065', '2026-10-14 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000065', '2026-10-17 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000066', '2026-10-14 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000066', '2026-10-15 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000066', '2026-10-15 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000066', '2026-10-15 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000066', '2026-10-15 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000066', '2026-10-15 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000066', '2026-10-21 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000067', '2026-10-15 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000067', '2026-10-16 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000067', '2026-10-16 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000067', '2026-10-16 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000067', '2026-10-16 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000067', '2026-10-16 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000067', '2026-10-25 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000068', '2026-10-16 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000069', '2026-10-16 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000070', '2026-10-17 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000070', '2026-10-18 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000070', '2026-10-18 09:00:00', 'Dong Nai route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000070', '2026-10-18 10:30:00', 'Dong Nai route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000070', '2026-10-18 12:00:00', 'Dong Nai route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000070', '2026-10-18 13:15:00', 'Dong Nai route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000070', '2026-10-23 15:00:00', 'Dong Nai', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000071', '2026-10-18 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000071', '2026-10-19 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000071', '2026-10-19 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000071', '2026-10-19 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000071', '2026-10-19 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000071', '2026-10-19 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000071', '2026-10-26 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000072', '2026-10-19 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000072', '2026-10-20 09:00:00', 'Supplier depot', 'Cancelled', 'Booking cancelled before pickup', 'EV000002'),
    ('SH000073', '2026-10-20 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000073', '2026-10-21 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000073', '2026-10-21 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000073', '2026-10-21 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000073', '2026-10-21 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000073', '2026-10-21 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000073', '2026-10-26 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000074', '2026-10-20 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000074', '2026-10-23 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000074', '2026-10-23 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000074', '2026-10-23 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000074', '2026-10-23 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000074', '2026-10-23 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000074', '2026-10-28 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000075', '2026-10-23 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000075', '2026-10-24 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000075', '2026-10-24 09:00:00', 'Hai Phong route', 'LocationUpdated', 'Origin sorting', 'EV000003');
INSERT INTO TrackingEvent (ShipmentID, EventTime, Location, EventType, Description, TrackingEventID) VALUES
    ('SH000075', '2026-10-24 10:30:00', 'Hai Phong route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000075', '2026-10-24 12:00:00', 'Hai Phong route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000075', '2026-10-24 13:15:00', 'Hai Phong route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000075', '2026-11-02 15:00:00', 'Hai Phong', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000076', '2026-10-24 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000076', '2026-10-25 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000076', '2026-10-25 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000076', '2026-10-25 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000076', '2026-10-25 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000076', '2026-10-25 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000076', '2026-10-27 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000077', '2026-10-24 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000077', '2026-10-27 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000077', '2026-10-27 09:00:00', 'Can Tho route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000077', '2026-10-27 10:30:00', 'Can Tho route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000077', '2026-10-27 12:00:00', 'Can Tho route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000077', '2026-10-27 13:15:00', 'Can Tho route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000077', '2026-10-29 15:00:00', 'Can Tho', 'Arrived', 'Warehouse gate check-in', 'EV000007'),
    ('SH000078', '2026-10-25 10:00:00', 'Supplier depot', 'Booked', 'Carrier booking created', 'EV000001'),
    ('SH000078', '2026-10-26 08:00:00', 'Supplier depot', 'PickedUp', 'Carrier collected freight', 'EV000002'),
    ('SH000078', '2026-10-26 09:00:00', 'Bac Ninh route', 'LocationUpdated', 'Origin sorting', 'EV000003'),
    ('SH000078', '2026-10-26 10:30:00', 'Bac Ninh route', 'LocationUpdated', 'Loaded onto linehaul', 'EV000004'),
    ('SH000078', '2026-10-26 12:00:00', 'Bac Ninh route', 'LocationUpdated', 'Regional checkpoint', 'EV000005'),
    ('SH000078', '2026-10-26 13:15:00', 'Bac Ninh route', 'LocationUpdated', 'Route scan', 'EV000006'),
    ('SH000078', '2026-11-02 15:00:00', 'Bac Ninh', 'Arrived', 'Warehouse gate check-in', 'EV000007');
COMMIT;
