# ⚡ Buông Lơi Hub — iOS Super App (`Enterprise Command Center & Hay Day 2D`)

> **Buông Lơi Hub iOS Native Wrapper**  
> Siêu ứng dụng (Super App) iOS điều hành toàn bộ 12+ trạm dịch vụ trong hệ sinh thái `buongloi.live` / `buongloi.me` tại [https://hub.buongloi.me](https://hub.buongloi.me) — kết hợp giao diện **Enterprise Command Center (6 Themes)** và **Nông Trại Tương Tác Hay Day 2D**.

---

## 📱 Thông Tin Ứng Dụng

| Hạng mục | Chi tiết |
|---|---|
| **Tên ứng dụng** | Buông Lơi Hub |
| **Bundle Identifier** | `me.buongloi.hub` |
| **Phiên bản** | `2.0.0` (Build `2`) |
| **Yêu cầu hệ điều hành** | iOS 16.0 trở lên (Tương thích iPhone & iPad, hỗ trợ xoay ngang/dọc) |
| **Máy chủ Web App** | `https://hub.buongloi.me` |
| **Hình thức đóng gói** | Unsigned IPA (Cài đặt qua ESign / TrollStore / AltStore / Sideloadly) |

---

## ✨ Tính Năng Nổi Bật Trên iOS

- **Super App All-in-One**: Mở trực tiếp mọi ứng dụng trong hệ sinh thái (`Report Hub`, `PPTX Generator`, `Price Checker`, `Bitcoin Dashboard`, `Gmail Manager`, `News Digest`, `Buông Lơi Music`, `Thiên Tượng`, `Giveaway Bot`...) ngay bên trong một ứng dụng duy nhất.
- **Nút nổi "Về Hub" thông minh**: Khi đang ở trong bất kỳ ứng dụng con nào, nút nổi `Về Hub` ở góc dưới bên trái (hoặc thao tác vuốt cạnh trái) giúp quay về Trung tâm Điều khiển ngay lập tức.
- **Dual-Mode (Command Center & Nông Trại 2D)**: Chuyển đổi mượt mà giữa bảng điều khiển Bento 6 Themes và chế độ Nông trại Hay Day 2D (hỗ trợ cả màn hình dọc và xoay ngang trên iPhone/iPad).
- **Haptic Feedback & Pull-to-Refresh**: Phản hồi rung xúc giác khi thu hoạch xu, ghim ứng dụng, chuyển chế độ và kéo làm mới trạng thái Ping.

---

## 🚀 Cách Build File `.ipa` qua GitHub Actions

Dự án sử dụng **GitHub Actions** với runner `macos-14` + `Xcode 16` + `XcodeGen` để tự động biên dịch ra file `BuongLoiHub.ipa`.

### 1. Tự động khi Push code:
```bash
git add .
git commit -m "feat: update BuongLoiHub iOS"
git push origin main
```

### 2. Kích hoạt thủ công:
1. Truy cập mục **Actions**: [https://github.com/BuongLoi/buongloi-hub-ios/actions](https://github.com/BuongLoi/buongloi-hub-ios/actions)
2. Chọn workflow **`Build iOS (.ipa)`** ở cột trái.
3. Bấm **`Run workflow`** ➔ Chọn branch `main` ➔ Bấm **`Run workflow`**.

---

## 📥 Tải & Cài Đặt Lên iPhone Bằng ESign / TrollStore

1. Vào [https://github.com/BuongLoi/buongloi-hub-ios/actions](https://github.com/BuongLoi/buongloi-hub-ios/actions).
2. Chọn lượt chạy thành công mới nhất (dấu tích xanh ✅).
3. Cuộn xuống mục **Artifacts** ➔ Tải file **`BuongLoiHub-ipa`** (dạng `.zip`).
4. Giải nén trong ứng dụng **Tệp (Files)** trên iPhone để lấy file **`BuongLoiHub.ipa`**.
5. Mở **ESign** (hoặc **TrollStore** / **Sideloadly**) ➔ Nhập file `BuongLoiHub.ipa` ➔ Ký chứng chỉ cá nhân và bấm **Cài đặt**.
