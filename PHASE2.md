# Phase 2 — Logical Design and Normalization

**INT1313 · Topic 6 · Supply Chain and Warehouse Logistics Network**

**Nhóm WAG** — Dương Gia Bảo, Mạc Thanh Toàn, Nguyễn Thanh Tú

## 1. Ánh xạ từ EER sang mô hình quan hệ

Ba thực thể độc lập Warehouse, Product và Supplier trở thành ba quan hệ có khóa chính riêng. Với quan hệ 1:N, đặt khóa ngoại ở phía N. Với quan hệ M:N, tạo quan hệ liên kết chứa khóa của hai phía và các thuộc tính mô tả chính quan hệ đó. Trong BOM, hai khóa ngoại cùng tham chiếu Product và phân biệt vai trò cha và thành phần. Với quan hệ tùy chọn 0..1 ở cả hai phía giữa ShipmentItem và StockMovement, đặt FK ở StockMovement và áp dụng UNIQUE trên các giá trị khác NULL.

| Quan hệ SQL | PK | Khóa ứng viên khác | FK và quan hệ EER |
| --- | --- | --- | --- |
| warehouse | id | — | — |
| product | id | — | — |
| supplier | id | — | — |
| inventory_policy | id | (warehouse_id, product_id) | warehouse_id → warehouse, product_id → product (R01–R02) |
| supplier_product | (supplier_id, product_id) | — | supplier_id → supplier, product_id → product (R03–R04) |
| supplier_order | id | — | supplier_id → supplier, warehouse_id → warehouse (R05–R06) |
| order_item | id | (order_id, product_id) | order_id → supplier_order, product_id → product (R07–R08) |
| shipment | id | — | order_id → supplier_order (R09) |
| shipment_item | id | (shipment_id, order_item_id) | shipment_id → shipment, order_item_id → order_item (R10–R11) |
| tracking_event | id | — | shipment_id → shipment (R12) |
| product_component | (parent_id, component_id) | — | parent_id → product, component_id → product (R13–R14) |
| stock_movement | id | shipment_item_id chỉ trong tập Receipt | inventory_id → inventory_policy, shipment_item_id → shipment_item, cho phép NULL (R15, R17) |
| restock_alert | id | inventory_id chỉ trong tập cảnh báo đang mở | inventory_id → inventory_policy (R16) |

Mọi FK trỏ tới cột `id` của bảng đích. FK bắt buộc có NOT NULL hoặc thuộc PK của bảng STRICT. UNIQUE bổ sung tại ShipmentItem biểu diễn một lần phân bổ cho mỗi cặp chuyến và dòng đơn. Muốn chia giao một dòng đơn, tạo nhiều chuyến. Kho đích của chuyến được lấy qua SupplierOrder. OrderItem lấy nhà cung cấp qua SupplierOrder để kiểm tra danh mục và tránh sao chép SupplierID vào dòng đơn.

**Điều chỉnh mô hình vật lý.** Inventory gốc được biểu diễn bởi bảng `inventory_policy` lưu định danh kho–sản phẩm và ngưỡng, cùng view `inventory` tái tạo số tồn từ tổng `stock_movement.delta`. Một kho chưa có biến động có tồn bằng 0. `last_updated` lấy thời điểm biến động mới nhất, mặc định là lúc tạo bản ghi kho–sản phẩm. Các báo cáo đọc trực tiếp view. Quy tắc BR13 được dùng để chốt tính bắt buộc của ShipmentItemID với Receipt, phù hợp với FR08. Giá và số lượng lưu bằng số nguyên theo đơn vị ×100 để phép cộng, so sánh và kiểm tra tồn chính xác đến 0,01.

## 2. Chứng minh 1NF, 2NF, 3NF và BCNF

Xét các phụ thuộc hàm phi tầm thường do quy tắc nghiệp vụ quy định, không suy ra thêm phụ thuộc từ sự trùng hợp trong dữ liệu mẫu. Bảng bên dưới liệt kê một cơ sở của các phụ thuộc này theo từng quan hệ. Ký hiệu “mọi cột còn lại” là toàn bộ cột ngoài vế trái trong đúng bảng đang xét.

| Quan hệ | Phụ thuộc hàm từ nghiệp vụ | Vì sao đạt BCNF |
| --- | --- | --- |
| warehouse | id → name, address, city, country, capacity | id là PK. Tên thành phố được hiểu trong phạm vi địa lý và không mặc định xác định duy nhất một nước. |
| product | id → name, description, unit, type | id là PK. Type không quy định một đơn vị đo duy nhất. |
| supplier | id → name, contact, phone, email, address | id là PK. Các trường liên hệ không được giả định duy nhất. |
| inventory_policy | id → mọi cột còn lại, (warehouse_id, product_id) → id, reorder_level, created_at | Cả hai vế trái là khóa ứng viên. Mỗi ngưỡng thuộc một cặp kho–sản phẩm. |
| supplier_product | (supplier_id, product_id) → price, lead_days | Cả cặp là PK. Giá và lead time phụ thuộc vào nhà cung cấp cụ thể cho sản phẩm cụ thể. |
| supplier_order | id → supplier_id, warehouse_id, ordered_on, expected_on, status | id là PK. Một nhà cung cấp có thể giao nhiều kho và nhiều ngày khác nhau. |
| order_item | id → mọi cột còn lại, (order_id, product_id) → id, quantity, agreed_price | Cả hai vế trái là khóa ứng viên. Giá chốt có thể thay đổi giữa hai đơn của cùng một sản phẩm. |
| shipment | id → order_id, tracking_no, dispatched_on, eta, arrived_at, status | id là PK. Một order_id có thể đi qua nhiều chuyến. |
| shipment_item | id → mọi cột còn lại, (shipment_id, order_item_id) → id, quantity | Cả hai vế trái là khóa ứng viên. Một trong hai cột riêng lẻ chưa xác định lượng phân bổ. |
| tracking_event | id → shipment_id, event_at, location, status, description | id là PK. Một chuyến có thể có hai sự kiện cùng thời điểm. |
| product_component | (parent_id, component_id) → quantity | Cả cặp là PK. Lượng thành phần phụ thuộc vào cả sản phẩm cha lẫn thành phần. |
| stock_movement | id → inventory_id, shipment_item_id, recorded_at, kind, delta | id là PK. Khi xét tập Receipt, shipment_item_id khác NULL và duy nhất, nên cũng là khóa của tập con này. |
| restock_alert | id → inventory_id, opened_at, quantity_at_alert, reorder_at_alert, resolved_at, message | id là PK. inventory_id là khóa của tập cảnh báo đang mở, một kho–sản phẩm có nhiều cảnh báo lịch sử. Các giá trị lúc mở là ảnh chụp lịch sử. |

- **1NF.** Mỗi cột chứa một giá trị theo miền kiểu dữ liệu. Dòng đơn, dòng chuyến, thành phần BOM và sự kiện được lưu mỗi mục một hàng, nên không có nhóm lặp trong một ô.
- **2NF.** Các bảng có khóa ghép trực tiếp (`supplier_product`, `product_component`) cần toàn bộ khóa để xác định giá, thời gian giao hoặc lượng thành phần. Các khóa ghép thay thế của `inventory_policy`, `order_item`, `shipment_item` cũng xác định dữ liệu ở cấp cặp. Mỗi phần khóa có thể xuất hiện trong nhiều cặp với giá trị khác nhau.
- **3NF và BCNF.** Với cơ sở phụ thuộc hàm trên, mọi vế trái đều là siêu khóa trong quan hệ được xét. Suy ra các bảng đạt BCNF và do đó đạt 3NF. Các quy tắc chỉ đúng trên tập con có điều kiện (Receipt, cảnh báo đang mở) được thi hành riêng bằng UNIQUE hoặc chỉ mục có điều kiện.
- **Phép nối bảo toàn dữ liệu.** Ví dụ, tách thông tin đặt hàng thành `supplier_order` và `order_item` theo `order_id`. Thuộc tính giao là khóa của bảng đầu đơn, nên mỗi dòng đơn nối về đúng một đầu đơn qua FK. LEFT JOIN giữ được các đầu đơn nháp chưa có dòng khi hiển thị danh sách đầu đơn. Với BOM, mỗi cạnh nối được về đúng một Product ở từng vai trò qua hai FK. Số tồn được tính theo biến động nối với đúng bản ghi kho–sản phẩm, không nhân bản vì từng biến động thuộc đúng một bản ghi tồn.

## 3. Quy tắc nào được cơ sở dữ liệu kiểm tra?

| Quy tắc | Cơ chế |
| --- | --- |
| BR01–BR03 | FK, PK ghép và UNIQUE theo bảng ánh xạ |
| BR04 | UNIQUE trên cặp đơn–sản phẩm, đơn mới ở Draft, trigger kiểm tra có dòng khi nộp. Chỉnh dòng khi đơn còn Draft. |
| BR05 | Trigger kiểm tra nhà cung cấp có bán sản phẩm và chặn xóa báo giá đang được tham chiếu. Giá chốt được lưu riêng và cố định khi nộp. |
| BR06–BR07 | FK đơn, trigger chặn dòng thuộc đơn khác và chặn dispatch nếu chuyến rỗng. Chỉnh phân bổ khi chuyến còn Draft. |
| BR08 | Trigger cộng phân bổ hiện có, bỏ qua chuyến Cancelled và so với lượng đặt. Chuyến đã hủy là trạng thái kết thúc. |
| BR09 | FK và PK của tracking event. Chỉ mục theo chuyến, thời điểm và ID hỗ trợ truy vấn sự kiện mới nhất. |
| BR10–BR11 | FK theo hai vai trò, CHECK lượng dương, CTE đệ quy kiểm tra đường dẫn từ component về parent trước khi thêm cạnh. |
| BR12 | CHECK ngưỡng không âm, trigger so tồn hiện tại với biến động mới, và nhật ký append-only. Giao dịch lỗi được hủy trước khi ghi thay đổi. |
| BR13 | UNIQUE trên shipment_item_id, CHECK loại biến động, trigger kiểm tra chuyến đã đến, đúng kho, đúng sản phẩm và đúng lượng của dòng. |
| BR14–BR15 | Trigger sau tạo tồn, sau đổi ngưỡng và sau biến động đều chạy kiểm tra cảnh báo. Chỉ mục UNIQUE có điều kiện giới hạn một cảnh báo mở mỗi cặp. |

Chỉ mục trên StockMovement.inventory_id hỗ trợ tính tồn theo bản ghi và đọc lịch sử. Chỉ mục trên ShipmentItem.order_item_id hỗ trợ kiểm tra phân bổ khi thêm hoặc sửa dòng. Tính tồn từ nhật ký ưu tiên tính nhất quán cho bộ dữ liệu của bài. Nếu sau này nhật ký lớn, có thể đo truy vấn và cân nhắc bảng số dư cập nhật trong cùng giao dịch.
