// Available syscalls for riscv64-harmonyos.
// Uses same syscall numbers as Linux riscv64 (generic table + riscv-specific).
{$i ../../linux/sysnr-gen.inc}

  syscall_nr_riscv_hwprobe                      = 258;
  syscall_nr_riscv_flush_icache                 = 259;
