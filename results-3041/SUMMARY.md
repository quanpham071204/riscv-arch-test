<!-- SPDX-License-Identifier: Apache-2.0 -->

# Kết quả ACT cho cv64a6_imafdc_sv39 (riscv-arch-test#3041, sau rebase)

Trạng thái: **đang chạy**. File này được cập nhật dần.

- Commit test: `75687708d15d273a852dc503b1752190b048ff58` (nhánh `rebase/3041-act4`)
- Máy: 4 CPU (Intel(R) Xeon(R) Processor @ 2.10GHz), 15 GB RAM, không swap, Ubuntu 24.04.5 LTS, container cloud tạm.
- Nhánh này chỉ để lưu kết quả. Người dùng cấm mở PR cho nhánh `results/3041-act4`.

## Môi trường

- apt: `autoconf flex bison help2man libfl-dev ccache zlib1g-dev device-tree-compiler libboost-regex-dev libboost-system-dev` (từ `ci.yaml`).
- Sail 0.16 và riscv64-elf GCC 2026.08.27 tải từ release giống `.github/actions/setup-tools`, giải nén vào `/opt/act4-tools/{sail,gcc}`.
- uv 0.11.32 và Ruby 3.3.6 có sẵn trong container.
- **Sửa môi trường:** container có hai bản Ruby 3.3.6 (`/opt/ruby-3.3.6` trên PATH qua `/usr/local/bin`, và rbenv `/opt/rbenv/versions/3.3.6`). Gem `udb` được cài vào rbenv, nhưng `bundle exec udb` báo `bundler: command not found: udb`. Đã sửa bằng cách đặt `/opt/rbenv/versions/3.3.6/bin` lên đầu `PATH`. Đây là lỗi của container, không phải của repo.
- `install-cva6.sh` chạy từ bản sao ngoài repo, chỉ đổi `TARGETS` thành biến môi trường để chỉ verilate `cv64a6_imafdc_sv39_hpdcache`. Không commit thay đổi này.

## Exclusion (`ci_config.py --exclusions`, 21 mục)

```
PMP_Sm_cfg_A_tor_zero,Exceptions_Zalrsc,PMP_Zalrsc_cfg_wr,Sv_ExceptionsZalrsc_sv32,Sv_ExceptionsZalrscSm_sv32,Sv_ExceptionsZalrsc_sv39_exceptions_Zalrsc,Sv_ExceptionsZalrscSm_sv39_exceptions_Zalrsc_mprv_S_Mmode,Sv_ExceptionsZalrscSm_sv39_medeleg_Zalrsc,InterruptsSm_priority_mip_M,InterruptsSm_priority_mideleg_M,InterruptsSm_priority_mideleg_S,InterruptsSm_priority_mideleg_U,PMP_Sm_grain-,PMP_Sv_sv32_pmp_on_pte,Sv_sv32_spage_Smode,Sv_sv32_spage_mstatus_sum_set_Smode,Sv_sv32_upage_Umode,S_F,Sm_F,U_F,Sv_Zicbo_sv39_zicbom_exceptions
```

## Số test (đã build ELF, chưa chạy DUT)

- Không loại trừ: 676 ELF (`test_list_cv64_full.md`), build 181 s.
- Có exclusion: 658 ELF. 18 test cv64 bị loại, liệt kê trong `excluded_cv64.txt`.
  So với trước rebase (17), mục mới là `InterruptsSm_priority_mip_M-00`.
- ELF có exclusion được build trong `WORKDIR=work-excl`, vì thư mục `work/<config>/elfs` giữ lại ELF cũ của các test bị loại.

## Build CVA6

- `TARGETS="cv64a6_imafdc_sv39_hpdcache" install-cva6.sh /home/user/cva6-builds`: thành công, 1915 s (gồm clone CVA6 `81245a4`, build Verilator, Spike và verilate testharness). Thư mục cài đặt 4,5 GB.
- `PATH=/home/user/cva6-builds/bin:$PATH`, `CVA6_SNAPSHOT=/home/user/cva6-builds`.

## Lần chạy 1: cv64a6_imafdc_sv39 có exclusion

```bash
EXCL="$(.github/scripts/ci_config.py --exclusions config/cores/cva6/ci.yaml)"
make cv64a6_imafdc_sv39 WORKDIR=work-excl EXCLUDE_EXTENSIONS="$EXCL"
```

- Kết quả: **658/658 pass, 0 fail** (`RESULT: All 658 tests passed.`, `make` rc=0).
- Thời gian chạy mô phỏng: 3144 s, 4 job song song (mặc định `nproc` của `run_tests.py`).
- Log: `summary_cv64_excl.log`, gồm các dòng `RVCP-SUMMARY` đã sắp xếp.

## Lần chạy 2: cv64a6_imafdc_sv39 không loại trừ

```bash
make cv64a6_imafdc_sv39
```

- Kết quả: **658/676 pass, 18 fail** (`RESULT: 18 failed, 658 passed out of 676 tests.`). `make` rc=2 là do có test fail.
- Thời gian chạy mô phỏng: 3152 s, 4 job.
- Trước rebase là 659/676 với 17 fail. Sau rebase có thêm 1 fail, là `InterruptsSm_priority_mip_M-00`.
- **Tập 18 test fail trùng chính xác với 18 test cv64 bị exclusion loại** (`diff` rỗng giữa `failed_cv64_full.txt` và `excluded_cv64.txt`).
  - Không có fail nào nằm ngoài exclusion.
  - Mọi exclusion áp dụng cho cv64 vẫn còn fail, nên không có exclusion nào thừa với cv64.
  - `InterruptsSm_priority_mip_M-00` (mới từ `act4`) fail đúng như exclusion dự đoán. Trap signature word 0 kỳ vọng `0x0000000003101e63` nhưng nhận `0x0000000003100e63`, `mcause=0x8000000000000009` (SEI).
- Các mục exclusion chỉ khớp test sv32 nên không có test nào trên cv64: `Sv_ExceptionsZalrsc_sv32`, `Sv_ExceptionsZalrscSm_sv32`, `PMP_Sv_sv32_pmp_on_pte`, `Sv_sv32_spage_Smode`, `Sv_sv32_spage_mstatus_sum_set_Smode`, `Sv_sv32_upage_Umode`. Lần chạy này không kiểm tra được chúng.

Danh sách test fail:

```
Exceptions_Zalrsc-00
InterruptsSm_priority_mideleg_M-00
InterruptsSm_priority_mideleg_S-00
InterruptsSm_priority_mideleg_U-00
InterruptsSm_priority_mip_M-00
PMP_Sm_cfg_A_tor_zero-00
PMP_Sm_grain-00
PMP_Zalrsc_cfg_wr-00
S_F-00
Sm_F-00
Sv_ExceptionsZalrscSm_sv39_exceptions_Zalrsc_mprv_S_Mmode-00
Sv_ExceptionsZalrscSm_sv39_medeleg_Zalrsc_Smode-00
Sv_ExceptionsZalrscSm_sv39_medeleg_Zalrsc_Umode-00
Sv_ExceptionsZalrsc_sv39_exceptions_Zalrsc_Smode-00
Sv_ExceptionsZalrsc_sv39_exceptions_Zalrsc_Umode-00
Sv_Zicbo_sv39_zicbom_exceptions_Smode-00
Sv_Zicbo_sv39_zicbom_exceptions_Umode-00
U_F-00
```

File:

- `summary_cv64_full.log`: 676 dòng `RVCP-SUMMARY`.
- `failures_cv64_full.log`: phần chẩn đoán `RVCP:` của từng test fail.

## Đề xuất

- Exclusion hiện tại khớp hoàn toàn với cv64a6_imafdc_sv39 sau rebase. Không cần đổi gì cho cv64.
