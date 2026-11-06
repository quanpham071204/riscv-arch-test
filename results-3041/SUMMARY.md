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
- `install-cva6.sh` chạy từ bản sao ngoài repo, chỉ đổi `TARGETS` thành biến môi trường để chỉ verilate `cv64a6_imafdc_sv39_hpdcache`. Không commit thay đổi này.

## Exclusion (`ci_config.py --exclusions`, 21 mục)

```
PMP_Sm_cfg_A_tor_zero,Exceptions_Zalrsc,PMP_Zalrsc_cfg_wr,Sv_ExceptionsZalrsc_sv32,Sv_ExceptionsZalrscSm_sv32,Sv_ExceptionsZalrsc_sv39_exceptions_Zalrsc,Sv_ExceptionsZalrscSm_sv39_exceptions_Zalrsc_mprv_S_Mmode,Sv_ExceptionsZalrscSm_sv39_medeleg_Zalrsc,InterruptsSm_priority_mip_M,InterruptsSm_priority_mideleg_M,InterruptsSm_priority_mideleg_S,InterruptsSm_priority_mideleg_U,PMP_Sm_grain-,PMP_Sv_sv32_pmp_on_pte,Sv_sv32_spage_Smode,Sv_sv32_spage_mstatus_sum_set_Smode,Sv_sv32_upage_Umode,S_F,Sm_F,U_F,Sv_Zicbo_sv39_zicbom_exceptions
```
