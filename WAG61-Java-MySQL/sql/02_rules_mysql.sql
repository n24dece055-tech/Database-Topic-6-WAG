USE wag_logistics_v61;
DELIMITER $$

CREATE TRIGGER order_create BEFORE INSERT ON SupplierOrder FOR EACH ROW
BEGIN
    IF NEW.Status <> 'Draft' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New orders must start in Draft';
    END IF;
END$$

CREATE TRIGGER order_change BEFORE UPDATE ON SupplierOrder FOR EACH ROW
BEGIN
    IF NEW.SupplierOrderID <> OLD.SupplierOrderID OR NEW.SupplierID <> OLD.SupplierID
       OR NEW.WarehouseID <> OLD.WarehouseID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Order identity, supplier and destination are fixed';
    END IF;
    IF NEW.Status <> OLD.Status AND NOT (
        (OLD.Status='Draft' AND NEW.Status IN ('Submitted','Cancelled'))
        OR (OLD.Status='Submitted' AND NEW.Status='Cancelled')
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid order status transition';
    END IF;
    IF NEW.Status='Submitted' AND NOT EXISTS (
        SELECT 1 FROM SupplierOrderItem WHERE SupplierOrderID=OLD.SupplierOrderID
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Submitted orders need at least one line';
    END IF;
    IF NEW.Status='Cancelled' AND EXISTS (
        SELECT 1 FROM Shipment WHERE SupplierOrderID=OLD.SupplierOrderID AND Status<>'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cancel active shipments before cancelling the order';
    END IF;
END$$

CREATE PROCEDURE require_draft_order(IN p_order VARCHAR(15))
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT Status INTO v_status FROM SupplierOrder WHERE SupplierOrderID=p_order FOR UPDATE;
    IF v_status IS NULL OR v_status<>'Draft' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Only draft order lines may be edited';
    END IF;
END$$

CREATE TRIGGER order_line_create BEFORE INSERT ON SupplierOrderItem FOR EACH ROW
BEGIN
    DECLARE v_offer VARCHAR(15);
    CALL require_draft_order(NEW.SupplierOrderID);
    SELECT sp.ProductID INTO v_offer
    FROM SupplierProduct sp JOIN SupplierOrder o ON o.SupplierID=sp.SupplierID
    WHERE o.SupplierOrderID=NEW.SupplierOrderID AND sp.ProductID=NEW.ProductID FOR SHARE;
    IF v_offer IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Supplier does not offer the ordered product';
    END IF;
END$$

CREATE TRIGGER order_line_change BEFORE UPDATE ON SupplierOrderItem FOR EACH ROW
BEGIN
    CALL require_draft_order(OLD.SupplierOrderID);
    IF NEW.SupplierOrderItemID<>OLD.SupplierOrderItemID OR NEW.SupplierOrderID<>OLD.SupplierOrderID
       OR NEW.ProductID<>OLD.ProductID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Order line keys are fixed';
    END IF;
END$$

CREATE TRIGGER order_line_remove BEFORE DELETE ON SupplierOrderItem FOR EACH ROW
BEGIN
    CALL require_draft_order(OLD.SupplierOrderID);
END$$

CREATE TRIGGER offer_keys_fixed BEFORE UPDATE ON SupplierProduct FOR EACH ROW
BEGIN
    IF NEW.SupplierID<>OLD.SupplierID OR NEW.ProductID<>OLD.ProductID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Supplier offering keys are fixed';
    END IF;
END$$

CREATE TRIGGER offer_remove BEFORE DELETE ON SupplierProduct FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM SupplierOrder o JOIN SupplierOrderItem oi USING (SupplierOrderID)
        WHERE o.SupplierID=OLD.SupplierID AND oi.ProductID=OLD.ProductID
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Offering is referenced by an order line';
    END IF;
END$$

CREATE TRIGGER shipment_create BEFORE INSERT ON Shipment FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT Status INTO v_status FROM SupplierOrder WHERE SupplierOrderID=NEW.SupplierOrderID FOR UPDATE;
    IF v_status IS NULL OR v_status<>'Submitted' OR NEW.Status<>'Draft' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Shipments start in Draft for a submitted order';
    END IF;
END$$

CREATE TRIGGER shipment_change BEFORE UPDATE ON Shipment FOR EACH ROW
BEGIN
    IF NEW.ShipmentID<>OLD.ShipmentID OR NEW.SupplierOrderID<>OLD.SupplierOrderID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Shipment identity and order are fixed';
    END IF;
    IF NEW.Status<>OLD.Status AND NOT (
        (OLD.Status='Draft' AND NEW.Status IN ('Dispatched','Cancelled'))
        OR (OLD.Status='Dispatched' AND NEW.Status IN ('InTransit','Arrived','Cancelled'))
        OR (OLD.Status='InTransit' AND NEW.Status IN ('Arrived','Cancelled'))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid shipment status transition';
    END IF;
    IF NEW.Status IN ('Dispatched','InTransit','Arrived') AND NOT EXISTS (
        SELECT 1 FROM ShipmentItem WHERE ShipmentID=OLD.ShipmentID
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='A dispatched shipment needs at least one line';
    END IF;
END$$

CREATE PROCEDURE validate_allocation(
    IN p_shipment VARCHAR(15), IN p_item VARCHAR(15), IN p_quantity DECIMAL(12,2), IN p_ignore VARCHAR(15)
)
BEGIN
    DECLARE v_shipment_order VARCHAR(15);
    DECLARE v_item_order VARCHAR(15);
    DECLARE v_status VARCHAR(20);
    DECLARE v_ordered DECIMAL(12,2);
    DECLARE v_allocated DECIMAL(30,2);
    SELECT SupplierOrderID, Status INTO v_shipment_order, v_status
    FROM Shipment WHERE ShipmentID=p_shipment FOR UPDATE;
    IF v_status IS NULL OR v_status<>'Draft' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Allocations can only be edited for a draft shipment';
    END IF;
    SELECT SupplierOrderID, Quantity INTO v_item_order, v_ordered
    FROM SupplierOrderItem WHERE SupplierOrderItemID=p_item FOR UPDATE;
    IF v_item_order IS NULL OR v_shipment_order<>v_item_order THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Shipment and order line must belong to the same order';
    END IF;
    SELECT COALESCE(SUM(si.Quantity),0) INTO v_allocated
    FROM ShipmentItem si JOIN Shipment s USING (ShipmentID)
    WHERE si.SupplierOrderItemID=p_item AND s.Status<>'Cancelled'
      AND (p_ignore IS NULL OR si.ShipmentItemID<>p_ignore);
    IF v_allocated+p_quantity>v_ordered THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Allocation exceeds ordered quantity';
    END IF;
END$$

CREATE TRIGGER allocation_create BEFORE INSERT ON ShipmentItem FOR EACH ROW
BEGIN
    CALL validate_allocation(NEW.ShipmentID, NEW.SupplierOrderItemID, NEW.Quantity, NULL);
END$$

CREATE TRIGGER allocation_change BEFORE UPDATE ON ShipmentItem FOR EACH ROW
BEGIN
    IF NEW.ShipmentItemID<>OLD.ShipmentItemID OR NEW.ShipmentID<>OLD.ShipmentID OR NEW.SupplierOrderItemID<>OLD.SupplierOrderItemID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Allocation keys are fixed';
    END IF;
    CALL validate_allocation(NEW.ShipmentID, NEW.SupplierOrderItemID, NEW.Quantity, OLD.ShipmentItemID);
END$$

CREATE TRIGGER allocation_remove BEFORE DELETE ON ShipmentItem FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT Status INTO v_status FROM Shipment WHERE ShipmentID=OLD.ShipmentID FOR UPDATE;
    IF v_status<>'Draft' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Allocations can only be removed from a draft shipment';
    END IF;
END$$

CREATE TRIGGER bom_no_cycle BEFORE INSERT ON ProductComponent FOR EACH ROW
BEGIN
    DECLARE v_lock VARCHAR(15);
    DECLARE v_cycle INT;
    -- Serialize edge additions by locking the first row in the product catalog.
    SELECT ProductID INTO v_lock FROM Product ORDER BY ProductID LIMIT 1 FOR UPDATE;
    WITH RECURSIVE descendants(ProductID) AS (
        SELECT CAST(NEW.ComponentProductID AS CHAR(15)) COLLATE utf8mb4_0900_as_cs
        UNION DISTINCT
        SELECT pc.ComponentProductID FROM ProductComponent pc
        JOIN descendants d ON d.ProductID=pc.ParentProductID
    )
    SELECT COUNT(*) INTO v_cycle FROM descendants WHERE ProductID=NEW.ParentProductID;
    IF v_cycle>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='BOM cycle detected';
    END IF;
END$$

CREATE TRIGGER bom_keys_fixed BEFORE UPDATE ON ProductComponent FOR EACH ROW
BEGIN
    IF NEW.ParentProductID<>OLD.ParentProductID OR NEW.ComponentProductID<>OLD.ComponentProductID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Replace BOM edges using a delete and an insert';
    END IF;
END$$

CREATE PROCEDURE sync_alert(IN p_warehouse VARCHAR(15), IN p_product VARCHAR(15),
                            IN p_quantity DECIMAL(12,2), IN p_threshold DECIMAL(12,2))
BEGIN
    DECLARE v_now DATETIME(6);
    SET v_now=UTC_TIMESTAMP(6);
    IF p_quantity>=p_threshold THEN
        UPDATE RestockAlert SET ResolvedAt=GREATEST(v_now,AlertDateTime)
        WHERE WarehouseID=p_warehouse AND ProductID=p_product AND ResolvedAt IS NULL;
    ELSEIF NOT EXISTS (
        SELECT 1 FROM RestockAlert
        WHERE WarehouseID=p_warehouse AND ProductID=p_product AND ResolvedAt IS NULL
    ) THEN
        SELECT GREATEST(v_now, COALESCE(TIMESTAMPADD(MICROSECOND,1,MAX(AlertDateTime)),v_now))
        INTO v_now FROM RestockAlert WHERE WarehouseID=p_warehouse AND ProductID=p_product;
        INSERT INTO RestockAlert (WarehouseID, ProductID, AlertDateTime, QuantityAtAlert, ReorderLevelAtAlert, Message)
        VALUES (p_warehouse,p_product,v_now,p_quantity,p_threshold,'Below reorder level');
    END IF;
END$$

CREATE TRIGGER inventory_create BEFORE INSERT ON Inventory FOR EACH ROW
BEGIN
    IF NEW.Quantity<>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Create inventory at zero and record an Opening movement';
    END IF;
END$$

CREATE TRIGGER inventory_change BEFORE UPDATE ON Inventory FOR EACH ROW
BEGIN
    DECLARE v_ledger DECIMAL(30,2);
    IF NEW.WarehouseID<>OLD.WarehouseID OR NEW.ProductID<>OLD.ProductID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Inventory keys are fixed';
    END IF;
    IF NEW.Quantity<>OLD.Quantity THEN
        SELECT COALESCE(SUM(QuantityDelta),0) INTO v_ledger FROM StockMovement
        WHERE WarehouseID=OLD.WarehouseID AND ProductID=OLD.ProductID;
        IF NEW.Quantity<>v_ledger THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Change quantity through StockMovement';
        END IF;
    END IF;
END$$

CREATE TRIGGER alerts_after_inventory_insert AFTER INSERT ON Inventory FOR EACH ROW
BEGIN
    CALL sync_alert(NEW.WarehouseID,NEW.ProductID,NEW.Quantity,NEW.ReorderLevel);
END$$

CREATE TRIGGER alerts_after_inventory_update AFTER UPDATE ON Inventory FOR EACH ROW
BEGIN
    IF NEW.Quantity<>OLD.Quantity OR NEW.ReorderLevel<>OLD.ReorderLevel THEN
        CALL sync_alert(NEW.WarehouseID,NEW.ProductID,NEW.Quantity,NEW.ReorderLevel);
    END IF;
END$$

CREATE TRIGGER movement_guard BEFORE INSERT ON StockMovement FOR EACH ROW
BEGIN
    DECLARE v_stock DECIMAL(12,2);
    SELECT Quantity INTO v_stock FROM Inventory
    WHERE WarehouseID=NEW.WarehouseID AND ProductID=NEW.ProductID FOR UPDATE;
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Create the inventory record before recording movements';
    END IF;
    IF v_stock+NEW.QuantityDelta<0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Insufficient stock';
    END IF;
    IF NEW.MovementType='Opening' AND EXISTS (
        SELECT 1 FROM StockMovement WHERE WarehouseID=NEW.WarehouseID AND ProductID=NEW.ProductID
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Opening must be the first movement';
    END IF;
    IF NEW.MovementType='Receipt' AND NOT EXISTS (
        SELECT 1 FROM ShipmentItem si JOIN Shipment s USING (ShipmentID)
        JOIN SupplierOrder o ON o.SupplierOrderID=s.SupplierOrderID
        JOIN SupplierOrderItem oi USING (SupplierOrderItemID)
        WHERE si.ShipmentItemID=NEW.ShipmentItemID AND s.Status='Arrived'
          AND si.Quantity=NEW.QuantityDelta AND o.WarehouseID=NEW.WarehouseID AND oi.ProductID=NEW.ProductID
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Receipt requires an arrived shipment and the full quantity at the correct warehouse and product';
    END IF;
END$$

CREATE TRIGGER movement_apply AFTER INSERT ON StockMovement FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET Quantity=Quantity+NEW.QuantityDelta, LastUpdated=GREATEST(LastUpdated,NEW.MovementTime)
    WHERE WarehouseID=NEW.WarehouseID AND ProductID=NEW.ProductID;
END$$

CREATE TRIGGER movement_no_update BEFORE UPDATE ON StockMovement FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Stock movements are append-only';
END$$

CREATE TRIGGER movement_no_delete BEFORE DELETE ON StockMovement FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Stock movements are append-only';
END$$

DELIMITER ;
