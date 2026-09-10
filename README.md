# Database-Topic-6-WAG

## 👥 Thành viên nhóm

| STT | Họ và tên | Email |
|-----|-----------|-------|
| 1 | **Dương Gia Bảo** | n24dece055@student.ptithcm.edu.vn |
| 2 | **Mạc Thanh Toàn** | n24dece096@student.ptithcm.edu.vn |
| 3 | **Nguyễn Thanh Tú** | n24decce100@student.ptithcm.edu.vn |

---

# DATABASE SYSTEM

## Phase 1 – Conceptual Design

### Đề tài: SUPPLY CHAIN & WAREHOUSE LOGISTICS NETWORK

---

## 1. Giới thiệu

Hệ thống cơ sở dữ liệu được xây dựng nhằm quản lý mạng lưới **Supply Chain & Warehouse Logistics Network**.

Hệ thống hỗ trợ quản lý:

- Kho hàng (Warehouse)
- Sản phẩm (Product)
- Nhà cung cấp (Supplier)
- Đơn hàng (Order)
- Khách hàng (Customer)
- Vận chuyển (Shipment)
- Tồn kho (Inventory)
- Các hoạt động nhập và xuất hàng

Mục tiêu của hệ thống là giúp doanh nghiệp quản lý hiệu quả quá trình lưu trữ, phân phối và vận chuyển hàng hóa trong chuỗi cung ứng.

---

# 2. Conceptual Design

## 2.1. Warehouse

**Warehouse** đại diện cho một kho hàng cụ thể trong mạng lưới logistics.

### Attributes

- `WarehouseID` – Mã kho
- `WarehouseName` – Tên kho
- `Address` – Địa chỉ
- `City` – Thành phố
- `Country` – Quốc gia
- `Capacity` – Sức chứa

### Ví dụ

```text
WarehouseID: WH001
WarehouseName: Hanoi Warehouse
Address: 123 ABC Street
City: Hanoi
Country: Vietnam
Capacity: 10000

