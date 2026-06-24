{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Peter Vreman
    member of the Free Pascal development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ definition of pthread_mutex_t, because needed in both ptypes.inc and }
{ in sysosh.inc                                                        }

{ use a macro rather than a constant, so this name doesn't get exported
  from the system unit interface; macro's have to be on at this point
  because they're use to propagate the MUTEXTYPENAME here }

{$define USE_PTHREAD_SIZEOF}

{ HarmonyOS uses musl libc.
  musl pthread_mutex_t = struct { union { int __i[N]; ... } __u; }
  where N = 10 on 64-bit (40 bytes), N = 6 on 32-bit (24 bytes).
  All 64-bit architectures (aarch64, x86_64, riscv64, loongarch64)
  use the same size in musl. }
{$if defined(CPU64)}
  {$define __SIZEOF_PTHREAD_MUTEX_T := 40}
{$else CPU64}
  {$define __SIZEOF_PTHREAD_MUTEX_T := 24}
{$endif CPU64}

  MUTEXTYPENAME = record
    case byte of
      0 : (
             { opaque size, used by pthread API }
             __size : array[0..__SIZEOF_PTHREAD_MUTEX_T-1] of AnsiChar;
          );
      1 : (
             { alignment for the struct }
             __align : sizeint;
          );
  end;

{$ifdef __SIZEOF_PTHREAD_MUTEX_T}
{$undef __SIZEOF_PTHREAD_MUTEX_T}
{$endif __SIZEOF_PTHREAD_MUTEX_T}
{$macro off}
