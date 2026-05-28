{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2024 by the Free Pascal development team

    Target dependent defines used when compiling the baseunix unit

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$ifdef FPC_USE_LIBC}
  {$define usegetcwd}
{$endif}

{$ifdef cpux86_64}
  {$define WAIT4}
{$endif}

{$ifdef cpuaarch64}
  {$define WAIT4}
  {$define userenameat}
{$endif}

{$ifdef cpuarm}
  {$define WAIT4}
  {$define HAS_UGETRLIMIT}
  {$define FPC_USEGETTIMEOFDAY}
  {$define MMAP2}
  {$define NO_SYSCALL_TIME}
  {$define NO_SYSCALL_UMOUNT}
  {$define NO_SYSCALL_STIME}
  {$define NO_SYSCALL_ALARM}
  {$define NO_SYSCALL_UTIME}
  {$define NO_SYSCALL_GETRLIMIT}
  {$define NO_SYSCALL_SELECT}
  {$define NO_SYSCALL_READDIR}
  {$define NO_SYSCALL_MMAP}
  {$define NO_SYSCALL_SOCKETCALL}
  {$define NO_SYSCALL_SYSCALL}
  {$define NO_SYSCALL_IPC}
{$endif cpuarm}

{$ifdef cpui386}
  {$define OLDMMAP}
{$endif}

{$if not defined(cpux86) and not defined(cpux86_64)}
  {$linklib m}
{$endif}
