---
name: deploy-branch-guard
description: Hướng dẫn và quy tắc bảo mật cho AI Agent khi làm việc trên nhánh deploy (deploy-fe / deploy-fexx) hướng tới remote lo (kiennguyenkt/sea-union). Giúp nhận diện, dọn dẹp và ngăn chặn rò rỉ mã nguồn backend crawler, WebSocket decoder, hoặc tài liệu reverse-engineering nhạy cảm.
---

# Deploy Branch Guard — Hướng Dẫn & Quy Tắc An Toàn Cho Agent

## 1. Bối cảnh & Mục đích của Nhánh

Nhánh này (`deploy-fexx` / `deploy-fe`) là nhánh đặc biệt được dùng để **build và deploy giao diện tĩnh Web UI lên GitHub Pages (remote `lo` - `kiennguyenkt/sea-union`)**.
Do tính chất public của bản deploy, mục tiêu tối quan trọng là:

- **Giấu hoàn toàn mã nguồn Backend Crawler** (Playwright bot, WebSocket sniffer, decoder, unpacker, session token).
- **Loại bỏ toàn bộ tài liệu giải mã nội bộ nhạy cảm** (wire format, opcode hex, protobuf body, thuật toán nén QuickLZ).
- **Dữ liệu tĩnh đã crawl (`src/data/sea-live*.json`) là PUBLIC** và được bake vào build để web hoạt động độc lập không cần server.
- **Bảo toàn 100% cấu trúc Frontend React + Vite** (`src/`, `package.json`, pnpm), đảm bảo `pnpm test` pass và `pnpm run build` thành công.

---

## 2. Quy Tắc Bất Khả Xâm Phạm (Security & Code Integrity)

Khi làm việc tại nhánh này, Agent **BẮT BUỘC** tuân thủ các quy tắc sau:

1. **Tuyệt đối KHÔNG tái tạo hoặc commit mã backend/crawler:**
   - Không tạo lại thư mục `tools/` hay `tools/socket_log/`.
   - Không commit `pyproject.toml`, `uv.lock`, hay các dependency Python / Playwright.
   - Không commit cache session browser (`.tmp/`, `.playwright-mcp/`).
2. **Tuyệt đối KHÔNG khôi phục hoặc ghi lại tài liệu reverse-engineering:**
   - Không tạo lại các tài liệu như `SOCKET_PROTOCOL.md`, `SEA_PACKET_ANALYSE.md`, `mine_docs/`.
   - Không đưa chi tiết opcode hex (ví dụ `0x72/0x000c`, `0x48/0x0002`), protobuf tag/varint hay lệnh Python runner vào `README.md` hoặc các file docs.
3. **Chỉ tập trung vào Frontend React & UX:**
   - Mọi thay đổi logic chỉ thực hiện trong `src/` (components, stores, domain selectors, styles).
   - Dữ liệu mới được nạp trực tiếp qua các file snapshot `src/data/sea-live*.json`.

---

## 3. Quy Trình Dọn Dẹp Chuẩn (Cleanup Workflow)

Mỗi khi người dùng yêu cầu sync code từ branch tính năng (ví dụ `main`, `feat/*`) sang nhánh deploy này, Agent cần thực hiện ngay các bước sau:

### Bước 1: Kích hoạt Script dọn dẹp tự động
Chạy script dọn dẹp đã chuẩn bị sẵn ở thư mục `scripts/`:

```powershell
# Trên Windows PowerShell
powershell -ExecutionPolicy Bypass -File scripts/cleanup-deploy-branch.ps1
```

Hoặc trên môi trường Bash:
```bash
bash scripts/cleanup-deploy-branch.sh
```

### Bước 2: Kiểm tra danh sách file bị xóa / sửa đổi
Đảm bảo các mục sau không còn xuất hiện trong git working tree:
- `tools/`
- `docs/assets/`
- `docs/mine_docs/`
- `docs/sea/`
- `pyproject.toml`, `uv.lock`
- `README.BE.md`

### Bước 3: Kiểm tra tính toàn vẹn Frontend
Chạy kiểm tra tự động:
```sh
pnpm test
pnpm run build
```
Cả hai lệnh phải kết thúc với mã thoát `0` (pass 100%).

---

## 4. Cấu Trúc Thư Mục Hợp Lệ Của Nhánh Deploy

Nhánh deploy sạch chỉ bao gồm các thành phần sau:

```
├── .agents/                    # Agent skills & conventions
│   ├── conventions/
│   └── skills/deploy-branch-guard/
├── .github/
│   └── workflows/
│       └── deploy-pages.yml    # CI/CD deploy GitHub Pages
├── docs/                       # Tài liệu FE, game rule và specs thuần túy
│   ├── BACKLOG.md
│   ├── DOCS_GUIDE.md
│   ├── LEADERBOARD_SPECS.md
│   ├── PROJECT_INTENT.md
│   └── SEA_EVENT_RULE.md
├── public/                     # Static assets public (favicon)
├── scripts/                    # Scripts dọn dẹp tự động
├── specs/                      # Ảnh mockup giao diện & layout tham chiếu
├── src/                        # Toàn bộ mã nguồn React Web UI & data JSON
├── index.html
├── package.json
├── pnpm-lock.yaml
├── README.md                   # Hướng dẫn chạy Web UI thuần túy (được thay từ README.FE.md)
├── tsconfig.json
└── vite.config.ts
```
