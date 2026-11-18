package wag.api;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Map;
import java.util.StringJoiner;

public final class WagApi {
    private static final Map<String, String> REPORTS = Map.of(
        "/api/warehouses", """
            SELECT JSON_OBJECT('warehouseId', WarehouseID, 'name', WarehouseName, 'city', City)
            FROM Warehouse ORDER BY WarehouseID
            """,
        "/api/inventory", """
            SELECT JSON_OBJECT('warehouse', w.WarehouseName, 'product', p.ProductName,
                   'quantity', i.Quantity, 'reorderLevel', i.ReorderLevel)
            FROM Inventory i JOIN Warehouse w USING (WarehouseID) JOIN Product p USING (ProductID)
            ORDER BY i.WarehouseID, i.ProductID
            """,
        "/api/alerts", """
            SELECT JSON_OBJECT('warehouse', WarehouseName, 'product', ProductName,
                   'quantity', Quantity, 'reorderLevel', ReorderLevel, 'shortage', Shortage)
            FROM OpenRestockAlert ORDER BY Shortage DESC, WarehouseID, ProductID
            """,
        "/api/receipts", """
            SELECT JSON_OBJECT('movementId', MovementID, 'shipmentItemId', ShipmentItemID,
                   'warehouseId', WarehouseID, 'productId', ProductID, 'quantity', QuantityDelta)
            FROM StockMovement WHERE MovementType='Receipt' ORDER BY MovementTime DESC, MovementID DESC
            """,
        "/api/pending-receipts", """
            SELECT JSON_OBJECT('shipmentItemId', si.ShipmentItemID, 'trackingNumber', s.TrackingNumber,
                   'warehouse', w.WarehouseName, 'product', p.ProductName, 'quantity', si.Quantity)
            FROM ShipmentItem si JOIN Shipment s USING (ShipmentID)
            JOIN SupplierOrder o ON o.SupplierOrderID=s.SupplierOrderID
            JOIN SupplierOrderItem oi ON oi.SupplierOrderItemID=si.SupplierOrderItemID
            JOIN Warehouse w ON w.WarehouseID=o.WarehouseID
            JOIN Product p ON p.ProductID=oi.ProductID
            WHERE s.Status='Arrived'
              AND NOT EXISTS (SELECT 1 FROM StockMovement m WHERE m.ShipmentItemID=si.ShipmentItemID)
            ORDER BY si.ShipmentItemID
            """
    );

    private final String databaseUrl;
    private final String user;
    private final String password;

    private WagApi(String databaseUrl, String user, String password) {
        this.databaseUrl = databaseUrl;
        this.user = user;
        this.password = password;
    }

    public static void main(String[] args) throws IOException {
        var env = System.getenv();
        String user = env.get("WAG_DB_USER");
        String password = env.get("WAG_DB_PASSWORD");
        if (user == null || user.isBlank() || password == null) {
            System.err.println("Set WAG_DB_USER and WAG_DB_PASSWORD in Eclipse Run Configurations > Environment.");
            return;
        }
        String url = env.getOrDefault("WAG_DB_URL",
            "jdbc:mysql://127.0.0.1:3306/wag_logistics_v61?connectTimeout=5000&socketTimeout=10000");
        int port = Integer.parseInt(env.getOrDefault("WAG_API_PORT", "8080"));
        var api = new WagApi(url, user, password);
        var server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);
        server.createContext("/", api::handle);
        server.start();
        System.out.println("Open http://127.0.0.1:" + server.getAddress().getPort() + "/");
    }

    private Connection connect() throws SQLException {
        return DriverManager.getConnection(databaseUrl, user, password);
    }

    private void handle(HttpExchange exchange) throws IOException {
        try (exchange) {
            String path = exchange.getRequestURI().getPath();
            String method = exchange.getRequestMethod();
            if (path.equals("/api/receipts") && method.equals("POST")) {
                receive(exchange);
                return;
            }
            String report = REPORTS.get(path);
            boolean health = path.equals("/api/health");
            boolean page = path.equals("/");
            if (report == null && !health && !page) {
                error(exchange, 404, "not_found");
            } else if (!method.equals("GET")) {
                exchange.getResponseHeaders().set("Allow", path.equals("/api/receipts") ? "GET, POST" : "GET");
                error(exchange, 405, "method_not_allowed");
            } else if (page) {
                try (var resource = WagApi.class.getResourceAsStream("index.html")) {
                    if (resource == null) {
                        error(exchange, 500, "missing_index_html");
                    } else {
                        send(exchange, 200, "text/html", new String(resource.readAllBytes(), StandardCharsets.UTF_8));
                    }
                }
            } else {
                query(exchange, health, report);
            }
        }
    }

    private void query(HttpExchange exchange, boolean health, String report) throws IOException {
        String sql = health ? """
            SELECT JSON_OBJECT('status','ok','schema',DATABASE(),
                   'warehouses',(SELECT COUNT(*) FROM Warehouse),
                   'inventoryRows',(SELECT COUNT(*) FROM Inventory))
            """ : report;
        String response;
        try (var db = connect(); var statement = db.prepareStatement(sql);
             var rows = statement.executeQuery()) {
            if (health) {
                rows.next();
                response = rows.getString(1);
            } else {
                var data = new StringJoiner(",", "[", "]");
                while (rows.next()) {
                    data.add(rows.getString(1));
                }
                response = "{\"status\":\"success\",\"data\":" + data + "}";
            }
        } catch (SQLException failure) {
            log(failure);
            error(exchange, 503, "database_error");
            return;
        }
        send(exchange, 200, "application/json", response);
    }

    private record ReceiptInput(String movementId, String shipmentItemId) {}

    // MySQL's JSON functions parse the small request without an extra Java dependency.
    private static ReceiptInput parseReceipt(Connection db, String json) throws SQLException {
        try (var statement = db.prepareStatement("""
            WITH input AS (SELECT CAST(? AS JSON) AS payload)
            SELECT JSON_UNQUOTE(JSON_EXTRACT(payload,'$.movementId')),
                   JSON_UNQUOTE(JSON_EXTRACT(payload,'$.shipmentItemId'))
            FROM input
            WHERE JSON_TYPE(payload)='OBJECT' AND JSON_LENGTH(payload)=2
              AND JSON_TYPE(JSON_EXTRACT(payload,'$.movementId'))='STRING'
              AND JSON_TYPE(JSON_EXTRACT(payload,'$.shipmentItemId'))='STRING'
            """)) {
            statement.setString(1, json);
            try (var row = statement.executeQuery()) {
                if (row.next()) {
                    String movement = row.getString(1);
                    String item = row.getString(2);
                    if (movement.matches("[A-Za-z0-9_-]{1,15}") && item.matches("[A-Za-z0-9_-]{1,15}")) {
                        return new ReceiptInput(movement, item);
                    }
                }
                return null;
            }
        }
    }

    private void receive(HttpExchange exchange) throws IOException {
        String type = exchange.getRequestHeaders().getFirst("Content-Type");
        if (type == null || !type.split(";", 2)[0].strip().equalsIgnoreCase("application/json")) {
            error(exchange, 415, "expected_application_json");
            return;
        }
        byte[] bytes = exchange.getRequestBody().readNBytes(4097);
        if (bytes.length > 4096) {
            error(exchange, 413, "request_too_large");
            return;
        }
        ReceiptInput input;
        try (var db = connect()) {
            input = parseReceipt(db, new String(bytes, StandardCharsets.UTF_8));
            if (input == null) {
                error(exchange, 400, "expected_movementId_and_shipmentItemId");
                return;
            }
            db.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
            try (var timezone = db.createStatement()) {
                timezone.execute("SET SESSION time_zone = '+00:00'");
            }
            db.setAutoCommit(false);
            try {
                if (!insertReceipt(db, input)) {
                    db.rollback();
                    error(exchange, 404, "shipment_item_not_found");
                    return;
                }
                db.commit();
            } catch (SQLException failure) {
                try {
                    db.rollback();
                } catch (SQLException rollbackFailure) {
                    failure.addSuppressed(rollbackFailure);
                }
                throw failure;
            }
        } catch (SQLException failure) {
            switch (failure.getErrorCode()) {
                case 3140, 3141 -> error(exchange, 400, "invalid_json");
                case 1062 -> error(exchange, 409, "receipt_or_movement_id_already_exists");
                case 1644 -> error(exchange, 409, "shipment_not_arrived_or_inventory_record_missing");
                default -> {
                    log(failure);
                    error(exchange, 503, "database_error");
                }
            }
            return;
        }
        send(exchange, 201, "application/json",
                "{\"status\":\"success\",\"movementId\":\"" + input.movementId() + "\"}");
    }

    private static boolean insertReceipt(Connection db, ReceiptInput input) throws SQLException {
        String warehouse;
        String product;
        java.math.BigDecimal quantity;
        try (var find = db.prepareStatement("""
            SELECT o.WarehouseID, oi.ProductID, si.Quantity
            FROM ShipmentItem si JOIN Shipment s USING (ShipmentID)
            JOIN SupplierOrder o ON o.SupplierOrderID=s.SupplierOrderID
            JOIN SupplierOrderItem oi ON oi.SupplierOrderItemID=si.SupplierOrderItemID
            WHERE si.ShipmentItemID=?
            """)) {
            find.setString(1, input.shipmentItemId());
            try (var row = find.executeQuery()) {
                if (!row.next()) {
                    return false;
                }
                warehouse = row.getString(1);
                product = row.getString(2);
                quantity = row.getBigDecimal(3);
            }
        }
        try (var insert = db.prepareStatement("""
            INSERT INTO StockMovement
                (MovementID, QuantityDelta, MovementType, WarehouseID, ProductID, ShipmentItemID)
            VALUES (?, ?, 'Receipt', ?, ?, ?)
            """)) {
            insert.setString(1, input.movementId());
            insert.setBigDecimal(2, quantity);
            insert.setString(3, warehouse);
            insert.setString(4, product);
            insert.setString(5, input.shipmentItemId());
            insert.executeUpdate();
        }
        return true;
    }

    private static void log(SQLException failure) {
        System.err.printf("MySQL error %d (SQLState %s): %s%n",
            failure.getErrorCode(), failure.getSQLState(), failure.getMessage());
    }

    private static void error(HttpExchange exchange, int code, String message) throws IOException {
        send(exchange, code, "application/json", "{\"error\":\"" + message + "\"}");
    }

    private static void send(HttpExchange exchange, int code, String type, String text)
            throws IOException {
        byte[] data = text.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", type + "; charset=utf-8");
        exchange.getResponseHeaders().set("Cache-Control", "no-store");
        exchange.sendResponseHeaders(code, data.length);
        exchange.getResponseBody().write(data);
    }
}
