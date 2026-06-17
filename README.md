# <p align="center"> <a href="https://github.com/TuanDanny/laptop-full-test-kit"> <img src="https://readme-typing-svg.herokuapp.com/?font=Fira+Code&weight=600&size=30&pause=1000&color=2196F3&center=true&vCenter=true&width=600&lines=Laptop+Full+Test+Kit;Automated+Hardware+Diagnostic+Tool;Plug+%26+Play+via+USB!"/> </a> </p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue?style=for-the-badge&logo=windows" />
  <img src="https://img.shields.io/badge/Script-PowerShell-112233?style=for-the-badge&logo=powershell" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
</p>

## 🌟 Giới thiệu (Overview)
Bộ công cụ **Laptop Full Test Kit V2** là "vũ khí" đắc lực dành cho những ai đi mua laptop cũ/mới tại cửa hàng. Chỉ cần copy vào USB, cắm vào máy và chạy **1 click**, tool sẽ tự động rà quét và xuất báo cáo toàn bộ sức khỏe phần cứng của chiếc máy.

Đặc biệt hữu ích để tránh bị lừa đảo (luộc đồ), mua nhầm máy lỗi hoặc cấu hình không đúng quảng cáo!

## 🔥 Tính năng nổi bật
- **⚡ 1-Click Run:** Giao diện thân thiện, chỉ cần chạy file `Run_Laptop_Test_Admin.bat`. Không cần cài đặt bất kỳ phần mềm bên thứ 3 nào.
- **🖥️ Trích xuất TGP NVIDIA:** Tự động lấy chuẩn xác công suất tối đa (Max Power Limit) của card đồ họa rời - thông số cực kỳ quan trọng đối với Laptop Gaming.
- **🚀 Stress Test & Benchmark:** Tích hợp kiểm tra chịu tải CPU ngắn hạn và đo tốc độ đọc/ghi của ổ cứng NVMe để kiểm tra độ ổn định.
- **📊 Báo cáo thông minh:** Toàn bộ lịch sử test, thông số (RAM, SSD, Serial, CPU, Tình trạng Pin...) được xuất ra file `.txt` và `.html` ngay tại thư mục hiện tại. Tên file được tự động gắn timestamp (ngày giờ chạy) chống ghi đè!
- **🎨 Giao diện Test trực quan:** Bao gồm các trang HTML (không cần internet) để bạn test Màu sắc màn hình (điểm ảnh chết), test Bàn phím & Touchpad, test Loa / Mic / Webcam.

## 🚀 Hướng dẫn sử dụng (How to use)
1. **Tải về:** Clone repository này hoặc tải file ZIP và giải nén.
   ```bash
   git clone https://github.com/TuanDanny/laptop-full-test-kit.git
   ```
2. **Copy vào USB:** Copy toàn bộ nội dung repo vào USB của bạn để mang ra cửa hàng.
3. **Chạy Tool:**
   - Cắm USB vào máy cần test.
   - Nhấn đúp (Double-click) vào file **`Run_Laptop_Test_Admin.bat`**.
   - Bấm `Yes` nếu hệ thống hỏi quyền Administrator (UAC).
4. **Xem kết quả:** Đợi màn hình đen chạy xong. Kết quả cấu hình sẽ được lưu ra các file `Laptop_Full_Check_Report_[Ngày_Giờ].txt`. Tool cũng sẽ tự động mở lên màn hình test Loa/Mic, test Bàn phím và test Màn hình để bạn làm nốt các bước thủ công.

## 🧰 Cấu trúc thư mục
- `Run_Laptop_Test_Admin.bat`: File chạy chính (Khởi động quyền Admin).
- `Laptop_Full_Check.ps1`: Script lõi PowerShell thực thi các câu lệnh trích xuất cấu hình.
- `Audio_Webcam_Mic_Test.html`: Trang test thiết bị âm thanh và hình ảnh.
- `Keyboard_Test.html`: Trang test bàn phím và Touchpad.
- `Screen_Color_Test.html`: Trang test hở sáng, điểm ảnh chết (Dead pixels).
- `CHECKLIST_TAI_CUA_HANG.txt`: Danh sách các bước dặn dò nhắc nhở bạn không quên kiểm tra ốc vít, bản lề, cổng sạc...

---
<p align="center"><i>Phát triển bởi <a href="https://github.com/TuanDanny">TuanDanny</a></i></p>
