CREATE DATABASE IF NOT EXISTS wag_logistics_v61 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs;
USE wag_logistics_v61;

CREATE TABLE Warehouse (
        WarehouseID VARCHAR(15) PRIMARY KEY, WarehouseName VARCHAR(100) NOT NULL,
        Address VARCHAR(200) NOT NULL, City VARCHAR(100) NOT NULL, Country VARCHAR(100) NOT NULL,
        CapacityM3 DECIMAL(12,2) NOT NULL CHECK (CapacityM3 >= 0)
) ENGINE=InnoDB;

CREATE TABLE Product (
        ProductID VARCHAR(15) PRIMARY KEY, ProductName VARCHAR(150) NOT NULL,
        Description TEXT, Unit VARCHAR(20) NOT NULL, ProductType VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE Supplier (
        SupplierID VARCHAR(15) PRIMARY KEY, SupplierName VARCHAR(150) NOT NULL,
        ContactName VARCHAR(100), Phone VARCHAR(30), Email VARCHAR(150), Address VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE SupplierProduct (
        SupplierID VARCHAR(15) NOT NULL, ProductID VARCHAR(15) NOT NULL,
        UnitPrice DECIMAL(12,2) NOT NULL CHECK (UnitPrice >= 0), LeadTimeDays INT NOT NULL CHECK (LeadTimeDays >= 0),
        PRIMARY KEY (SupplierID, ProductID), FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
) ENGINE=InnoDB;

CREATE TABLE SupplierOrder (
        SupplierOrderID VARCHAR(15) PRIMARY KEY, SupplierID VARCHAR(15) NOT NULL, WarehouseID VARCHAR(15) NOT NULL,
        OrderDate DATE NOT NULL, ExpectedDeliveryDate DATE, Status VARCHAR(20) NOT NULL DEFAULT 'Draft',
        CHECK (Status IN ('Draft','Submitted','Cancelled')), CHECK (ExpectedDeliveryDate >= OrderDate),
        FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID), FOREIGN KEY (WarehouseID) REFERENCES Warehouse(WarehouseID)
) ENGINE=InnoDB;

CREATE TABLE SupplierOrderItem (
        SupplierOrderItemID VARCHAR(15) PRIMARY KEY, SupplierOrderID VARCHAR(15) NOT NULL, ProductID VARCHAR(15) NOT NULL,
        Quantity DECIMAL(12,2) NOT NULL CHECK (Quantity > 0), UnitPrice DECIMAL(12,2) NOT NULL CHECK (UnitPrice >= 0),
        UNIQUE (SupplierOrderID, ProductID), FOREIGN KEY (SupplierOrderID) REFERENCES SupplierOrder(SupplierOrderID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
) ENGINE=InnoDB;

CREATE TABLE Shipment (
        ShipmentID VARCHAR(15) PRIMARY KEY, SupplierOrderID VARCHAR(15) NOT NULL,
        TrackingNumber VARCHAR(50), ShipmentDate DATE, EstimatedArrival DATETIME, ActualArrival DATETIME,
        Status VARCHAR(20) NOT NULL DEFAULT 'Draft',
        CHECK (Status IN ('Draft','Dispatched','InTransit','Arrived','Cancelled')),
        CHECK (Status NOT IN ('Dispatched','InTransit','Arrived') OR ShipmentDate IS NOT NULL),
        CHECK (Status <> 'Arrived' OR ActualArrival IS NOT NULL),
        CHECK (ActualArrival IS NULL OR (Status = 'Arrived' AND DATE(ActualArrival) >= ShipmentDate)),
        FOREIGN KEY (SupplierOrderID) REFERENCES SupplierOrder(SupplierOrderID)
) ENGINE=InnoDB;

CREATE TABLE ShipmentItem (
        ShipmentItemID VARCHAR(15) PRIMARY KEY, ShipmentID VARCHAR(15) NOT NULL, SupplierOrderItemID VARCHAR(15) NOT NULL,
        Quantity DECIMAL(12,2) NOT NULL CHECK (Quantity > 0), UNIQUE (ShipmentID, SupplierOrderItemID),
        FOREIGN KEY (ShipmentID) REFERENCES Shipment(ShipmentID), FOREIGN KEY (SupplierOrderItemID) REFERENCES SupplierOrderItem(SupplierOrderItemID)
) ENGINE=InnoDB;

CREATE TABLE TrackingEvent (
        TrackingEventID VARCHAR(15) NOT NULL, ShipmentID VARCHAR(15) NOT NULL,
        EventTime DATETIME NOT NULL, Location VARCHAR(150), EventType VARCHAR(20) NOT NULL, Description TEXT,
        PRIMARY KEY (ShipmentID, TrackingEventID), FOREIGN KEY (ShipmentID) REFERENCES Shipment(ShipmentID),
        INDEX ix_tracking_time (ShipmentID, EventTime, TrackingEventID)
) ENGINE=InnoDB;

CREATE TABLE ProductComponent (
        ParentProductID VARCHAR(15) NOT NULL, ComponentProductID VARCHAR(15) NOT NULL,
        QuantityRequired DECIMAL(12,2) NOT NULL CHECK (QuantityRequired > 0),
        PRIMARY KEY (ParentProductID, ComponentProductID), CHECK (ParentProductID <> ComponentProductID),
        FOREIGN KEY (ParentProductID) REFERENCES Product(ProductID), FOREIGN KEY (ComponentProductID) REFERENCES Product(ProductID)
) ENGINE=InnoDB;

CREATE TABLE Inventory (
        WarehouseID VARCHAR(15) NOT NULL, ProductID VARCHAR(15) NOT NULL, Quantity DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (Quantity >= 0),
        ReorderLevel DECIMAL(12,2) NOT NULL CHECK (ReorderLevel >= 0), LastUpdated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (WarehouseID, ProductID), FOREIGN KEY (WarehouseID) REFERENCES Warehouse(WarehouseID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
) ENGINE=InnoDB;

CREATE TABLE StockMovement (
        MovementID VARCHAR(15) PRIMARY KEY, QuantityDelta DECIMAL(12,2) NOT NULL CHECK (QuantityDelta <> 0),
        MovementType VARCHAR(20) NOT NULL, MovementTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        WarehouseID VARCHAR(15) NOT NULL, ProductID VARCHAR(15) NOT NULL, ShipmentItemID VARCHAR(15) UNIQUE,
        CHECK (MovementType IN ('Opening','Receipt','Issue','Adjustment')),
        CHECK ((MovementType = 'Receipt') = (ShipmentItemID IS NOT NULL)),
        CHECK (MovementType NOT IN ('Opening','Receipt') OR QuantityDelta > 0),
        CHECK (MovementType <> 'Issue' OR QuantityDelta < 0),
        FOREIGN KEY (WarehouseID, ProductID) REFERENCES Inventory(WarehouseID, ProductID),
        FOREIGN KEY (ShipmentItemID) REFERENCES ShipmentItem(ShipmentItemID)
) ENGINE=InnoDB;

CREATE TABLE RestockAlert (
        WarehouseID VARCHAR(15) NOT NULL, ProductID VARCHAR(15) NOT NULL, AlertDateTime DATETIME(6) NOT NULL,
        QuantityAtAlert DECIMAL(12,2) NOT NULL, ReorderLevelAtAlert DECIMAL(12,2) NOT NULL,
        ResolvedAt DATETIME(6), Message VARCHAR(200),
        PRIMARY KEY (WarehouseID, ProductID, AlertDateTime),
        CHECK (QuantityAtAlert >= 0 AND QuantityAtAlert < ReorderLevelAtAlert),
        CHECK (ResolvedAt IS NULL OR ResolvedAt >= AlertDateTime),
        UNIQUE KEY uq_open_alert (WarehouseID, ProductID, (CASE WHEN ResolvedAt IS NULL THEN 1 ELSE NULL END)),
        FOREIGN KEY (WarehouseID, ProductID) REFERENCES Inventory(WarehouseID, ProductID)
) ENGINE=InnoDB;

CREATE VIEW OpenRestockAlert AS
SELECT a.WarehouseID, a.ProductID, a.AlertDateTime, w.WarehouseName, p.ProductName,
       i.Quantity, i.ReorderLevel, i.ReorderLevel-i.Quantity AS Shortage
FROM RestockAlert a JOIN Inventory i USING (WarehouseID, ProductID)
JOIN Warehouse w USING (WarehouseID)
JOIN Product p USING (ProductID)
WHERE a.ResolvedAt IS NULL;

CREATE VIEW AllocatedByOrderItem AS
SELECT si.SupplierOrderItemID, SUM(si.Quantity) AS Allocated
FROM ShipmentItem si JOIN Shipment s ON s.ShipmentID=si.ShipmentID
WHERE s.Status<>'Cancelled'
GROUP BY si.SupplierOrderItemID;
