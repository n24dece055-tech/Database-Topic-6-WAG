# WAG 6.1 Java API và MySQL

Project dùng thiết kế trong **WAG-6-1.docx**. Thư mục **sql** chứa script MySQL, **src/wag/api/WagApi.java** là API Java, và **src/wag/api/index.html** là trang demo. Tệp Connector/J nằm sẵn trong **lib**. Project dùng **JDK 17 trở lên** và chạy được từ Eclipse.

## 1. Nạp MySQL trong Workbench

Mở kết nối **WAG MySQL**. Nếu schema `wag_logistics_v61` chưa có bảng, mở từng tệp từ thư mục **sql** bằng **Ctrl+Shift+O**, rồi bấm tia sét **Execute All or Selection** khi không chọn riêng một đoạn.

| Tệp | Mục đích |
|---|---|
| `01_schema_mysql.sql` | Tạo schema, 13 bảng và 2 view. |
| `02_rules_mysql.sql` | Tạo trigger và thủ tục. Chạy cả tệp. |
| `03_seed_mysql.sql` | Nạp dữ liệu demo. Các dòng liền nhau cùng bảng và cùng danh sách cột được gộp vào một lệnh INSERT nhiều VALUES. |
| `04_queries_mysql.sql` | 12 câu truy vấn báo cáo. |
| `05_verify_mysql.sql` | Kiểm tra tổng 1.500 dòng và các ràng buộc. |
| `06_demo_receipt.sql` | Demo nhận Worktop trong giao dịch rồi hoàn tác. Đây là bước tùy chọn. |

Nếu **đã có bảng**, chạy **05** trước. Nếu tổng bằng **1.500** thì dùng dữ liệu hiện tại. Nếu tổng bằng **0**, chạy **03** sau khi xác nhận **02** đã tạo các trigger. Kiểm tra **Action Output** đến dòng **COMMIT**. Nếu có lỗi giữa chừng, chạy `ROLLBACK;` trong cùng kết nối. Nếu tổng khác 0 vì schema đã có một phần dữ liệu, kiểm tra các dòng đã nạp trước khi chạy lại 03 để tránh trùng khóa. Các script tạo bảng giữ lại schema đang có, nên 01–02 dành cho lần cài đặt mới. Chạy lại 05 sau khi nạp, rồi kiểm tra bảng Inventory có **126** dòng.

## 2. Import project vào Eclipse

1. Giải nén toàn bộ ZIP. Trong Eclipse chọn **File → Import… → General → Existing Projects into Workspace → Next**.
2. Chọn **Select root directory** rồi trỏ tới thư mục **WAG61-Java-MySQL** có file `.project`. Chọn project tìm được và bấm **Finish**.
3. Mở **src → wag.api → WagApi.java**. Project đã khai báo JAR trong thư mục **lib**. Nếu Eclipse báo thiếu JavaSE-17, chọn một JDK đã cài từ 17 trở lên trong **Properties → Java Build Path → Libraries → JRE System Library**.
4. Nếu API cũ còn chạy, bấm nút đỏ **Terminate** trong Console trước khi chạy project mới cùng cổng 8080.

## 3. Điền kết nối và chạy

1. Vào **Run → Run Configurations…**, nhấp đúp **Java Application**. Ở tab **Main**, chọn project **WAG61-Java-MySQL** và main class **wag.api.WagApi**.
2. Vào **Environment → Add…** để thêm `WAG_DB_USER` với tên tài khoản MySQL và `WAG_DB_PASSWORD` với mật khẩu tương ứng. `WAG MySQL` là tên kết nối hiển thị trong Workbench.
3. Nếu MySQL chạy cổng khác 3306, thêm `WAG_DB_URL` với giá trị dạng `jdbc:mysql://127.0.0.1:3306/wag_logistics_v61` và sửa cổng. Nếu muốn đổi cổng web, thêm `WAG_API_PORT`.
4. Bấm **Apply → Run**. Mở **http://127.0.0.1:8080/api/health** để kiểm tra schema và số dòng tồn. Sau đó mở **http://127.0.0.1:8080/**.

## 4. Demo Phase 4

| API | Dùng để |
|---|---|
| GET /api/health | Xác nhận schema và số dòng kho, tồn kho. |
| GET /api/warehouses | Xem danh sách kho. |
| GET /api/inventory | Xem tồn kho theo kho và sản phẩm. |
| GET /api/alerts | Xem cảnh báo đang mở. |
| GET /api/pending-receipts | Xem các dòng giao đã tới nhưng chưa nhận vào kho. |
| GET /api/receipts | Xem lịch sử nhận hàng. |
| POST /api/receipts | Ghi nhận đủ một dòng hàng đã đến. |

Trên bộ dữ liệu mẫu, mở **Tồn kho** và tìm **Worktop tại HCMC Central**. Tồn ban đầu là **5**, ngưỡng là **10**. Trong form **Nhận hàng**, chọn **SI000006 / WAG-005 / Worktop / 10** rồi bấm **Xác nhận nhận đủ**. Trang gửi JSON tương đương:

```json
{"movementId":"MVPHASE4","shipmentItemId":"SI000006"}
```

Kết quả thành công là **HTTP 201**. Bấm **Tồn kho** để thấy Worktop tăng lên **15**, rồi bấm **Cảnh báo** để thấy cảnh báo Worktop đã đóng. API lấy kho đích, sản phẩm và lượng thực nhận từ dữ liệu của dòng chuyến. Trigger MySQL cập nhật tồn và cảnh báo trong cùng giao dịch. Gửi lại dòng đó qua một công cụ thử HTTP sẽ trả **409** và không tăng tồn lần nữa.

POST lưu giao dịch thật trong schema demo. Sau khi nhận, dòng đó biến mất khỏi danh sách chờ. Nút **Xem JSON** cho thấy yêu cầu đã trả dữ liệu gì. Bản demo chạy trên máy cá nhân, gồm các chức năng tra cứu và nhận hàng nói trên.
