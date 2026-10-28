# INTENT — Mục Tiêu & Bối Cảnh Nhánh Deploy (`deploy-fexx` / `deploy-fe`)

> **Tài liệu hand-off nhanh:** Ghi lại mục đích, bối cảnh và các nguyên tắc bảo mật của nhánh deploy này để bất kỳ ai hoặc AI Agent nào tiếp quản đều nắm bắt ngay lập tức mà không cần đào lại lịch sử commit.

---

## 1. Bối Cảnh & Vì Sao Nhánh Này Tồn Tại

- **Mục đích của nhánh:** Nhánh này là nhánh đặc biệt dùng để đóng gói và deploy Web UI giao diện tĩnh lên GitHub Pages.
- **Lịch sử phát triển & Ràng buộc thời gian:** Do codebase ban đầu phát triển chung giữa Frontend và Backend Crawler, nhánh này phải **giữ nguyên cấu trúc code Frontend hiện tại** (`src/`, `package.json`, Vite, pnpm) để không làm gián đoạn tiến độ và không cần đập đi xây lại cấu trúc dự án.
- **Tính chất bảo mật:** Vì remote để deploy là môi trường public/production, mục tiêu sống còn là **giấu hoàn toàn mã nguồn và nghiệp vụ của Backend Crawler**.

---

## 2. Ranh Giới Dữ Liệu & Mã Nguồn (Boundary)

| Thành phần                                       | Trạng thái trên nhánh này | Ghi chú                                                                                                   |
| :----------------------------------------------- | :------------------------ | :-------------------------------------------------------------------------------------------------------- |
| **Mã nguồn Backend Crawler** (`tools/`)          | **TUYỆT ĐỐI XÓA**         | Không để lại code Python, Playwright bot, WebSocket sniffer, QuickLZ decoder.                             |
| **Cấu hình môi trường Python**                   | **TUYỆT ĐỐI XÓA**         | Xóa `pyproject.toml`, `uv.lock`, `.playwright-mcp/`, `.tmp/`.                                             |
| **Tài liệu decode & reverse-engineering**        | **TUYỆT ĐỐI XÓA**         | Xóa toàn bộ `docs/sea/` (chứa opcode, packet analyse, socket protocol, spec crawler) và `docs/mine_docs/`. |
| **Ảnh bằng chứng & Screenshot** (`docs/assets/`) | **TUYỆT ĐỐI XÓA**         | Toàn bộ ảnh capture gameplay / popup.                                                                     |
| **Dữ liệu crawl (`src/data/sea-live*.json`)**    | **PUBLIC ĐƯỢC**           | Dữ liệu tĩnh đã xuất ra là public; phục vụ trực tiếp cho Web UI bake vào bundle build tĩnh.               |
| **Mã nguồn Frontend (`src/`)**                   | **BẢO TOÀN 100%**         | Toàn bộ code React Flow, Store Zustand, CSS Modules, Selector. Phải pass `pnpm test` và `pnpm run build`. |

---

## 3. Quy Trình Handoff Khi Sync Code Từ Dev Vào Nhánh Deploy

Mỗi khi sync/merge commit mới từ các nhánh dev (`main`, `feat/*`) sang nhánh deploy này:

1. **Chạy ngay script dọn dẹp tối giản:**

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/cleanup-deploy-branch.ps1
   # hoặc: bash scripts/cleanup-deploy-branch.sh
   ```

   Script này sẽ xóa dứt điểm toàn bộ danh sách đen (thư mục `tools/`, `docs/assets/`, `docs/mine_docs/`, `docs/sea/`, config python, `README.BE.md`)

2. **Kiểm tra tài liệu `docs/`:**
   - Đảm bảo không commit lại bất kỳ tài liệu nào mô tả opcode WebSocket (`0x..`), cấu trúc frame nhị phân, thuật toán nén QuickLZ hay lệnh chạy Python.
   - Các docs giữ lại (`README.md`, `docs/BACKLOG.md`, `docs/DOCS_GUIDE.md`, `docs/LEADERBOARD_SPECS.md`, `docs/PROJECT_INTENT.md`, `docs/SEA_EVENT_RULE.md`) chỉ phục vụ góc nhìn Frontend và trải nghiệm người dùng.

3. **Kiểm tra file Deploy:**
   - `.github/workflows/deploy-pages.yml` đã được cấu hình để trigger khi push lên các nhánh deploy (`main`, `master`, `deploy-fe`, `deploy-fexx`) hoặc chạy thủ công bằng `workflow_dispatch`.

4. **Nghiệm thu trước khi push lên remote `lo`:**
   ```sh
   pnpm test        # Phải pass toàn bộ unit tests
   pnpm run build   # Phải build thành công dist/ (chunk sea-data nạp sea-live.json)
   ```
