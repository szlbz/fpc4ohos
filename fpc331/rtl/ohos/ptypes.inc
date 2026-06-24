{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2001 by Free Pascal development team

    HarmonyOS (OpenHarmony) port - musl libc ptypes.

    This file implements all the base types and limits required
    for a minimal POSIX compliant subset required to port the compiler
    to a new OS.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{***********************************************************************}
{                       POSIX TYPE DEFINITIONS                          }
{***********************************************************************}

{ HarmonyOS uses musl libc.
  musl pthread types use a uniform union-of-int-array structure,
  consistent across all architectures of the same pointer size.
  Unlike glibc, there are no aarch64-specific larger sizes.
}

{ musl pthread type sizes:
  64-bit (aarch64, x86_64, riscv64, loongarch64):
    pthread_attr_t       = 14 ints = 56 bytes
    pthread_mutex_t      = 10 ints = 40 bytes  (see pmutext.inc)
    pthread_mutexattr_t  =  1 unsigned =  4 bytes
    pthread_cond_t       = 12 ints = 48 bytes
    pthread_condattr_t   =  1 unsigned =  4 bytes
    pthread_rwlock_t     = 14 ints = 56 bytes
    pthread_rwlockattr_t =  2 unsigned =  8 bytes
    pthread_barrier_t    =  8 ints = 32 bytes
    pthread_barrierattr_t=  1 unsigned =  4 bytes
    sem_t                =  8 ints = 32 bytes

  32-bit (arm):
    pthread_attr_t       =  9 ints = 36 bytes
    pthread_mutex_t      =  6 ints = 24 bytes  (see pmutext.inc)
    pthread_mutexattr_t  =  1 unsigned =  4 bytes
    pthread_cond_t       = 12 ints = 48 bytes
    pthread_condattr_t   =  1 unsigned =  4 bytes
    pthread_rwlock_t     =  8 ints = 32 bytes
    pthread_rwlockattr_t =  2 unsigned =  8 bytes
    pthread_barrier_t    =  5 ints = 20 bytes
    pthread_barrierattr_t=  1 unsigned =  4 bytes
    sem_t                =  4 ints = 16 bytes
}

{$if defined(CPU64)}
const
  __SIZEOF_PTHREAD_ATTR_T = 56;
  __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
  __SIZEOF_PTHREAD_COND_T = 48;
  __SIZEOF_PTHREAD_CONDATTR_T = 4;
  __SIZEOF_PTHREAD_RWLOCK_T = 56;
  __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
  __SIZEOF_PTHREAD_BARRIER_T = 32;
  __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
  __SIZEOF_SEM_T = 32;
{$else : not CPU64, i.e. CPU32}
const
  __SIZEOF_PTHREAD_ATTR_T = 36;
  __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
  __SIZEOF_PTHREAD_COND_T = 48;
  __SIZEOF_PTHREAD_CONDATTR_T = 4;
  __SIZEOF_PTHREAD_RWLOCK_T = 32;
  __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
  __SIZEOF_PTHREAD_BARRIER_T = 20;
  __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
  __SIZEOF_SEM_T = 16;
{$endif CPU32}

{$I ctypes.inc}
{$packrecords c}

Type

    dev_t    = cuint64;         { used for device numbers      }
    TDev     = dev_t;
    pDev     = ^dev_t;

    ino_t    = cuint64;         { used for file serial numbers }
    TIno     = ino_t;
    pIno     = ^ino_t;

    ino64_t  = cuint64;
    TIno64   = ino64_t;
    pIno64   = ^ino64_t;

{$ifdef cpu64}
    mode_t   = cint;         { used for file attributes     }
{$else cpu64}
    mode_t   = cuint32;      { used for file attributes     }
{$endif cpu64}
    TMode    = mode_t;
    pMode    = ^mode_t;

    nlink_t  = cuint32;         { used for link counts         }
    TnLink   = nlink_t;
    pnLink   = ^nlink_t;

    kDev_t   = cushort;         { kernel device number convention }
    TkDev    = kDev_t;
    pkDev    = ^kdev_t;

    off_t    = cint64;          { used for file sizes          }
    TOff     = off_t;
    pOff     = ^off_t;

    off64_t  = cint64;
    TOff64   = off64_t;
    pOff64   = ^off64_t;

    pid_t    = cint;          { used as process identifier   }
    TPid     = pid_t;
    pPid     = ^pid_t;

{$ifdef cpu64}
    size_t   = cuint64;         { as defined in the C standard}
    ssize_t  = cint64;          { used by function for returning number of bytes }
    clock_t  = culong;
{$else}
    size_t   = cuint32;         { as defined in the C standard}
    ssize_t  = cint32;          { used by function for returning number of bytes }
    clock_t  = culong;
{$endif}
    { musl uses 64-bit time_t on ALL architectures (Y2038-safe, __USE_TIME_BITS64) }
    time_t   = cint64;           { used for returning the time  }
    { musl: suseconds_t = _Int64 = 8 bytes on all architectures }
    suseconds_t = cint64;
    TSuseconds = suseconds_t;
    wint_t    = cint32;
    TSize     = size_t;
    pSize     = ^size_t;
    psize_t   = pSize;
    TSSize    = ssize_t;
    pSSize    = ^ssize_t;
    TClock    = clock_t;
    pClock    = ^clock_t;

    pTime     = ^time_t;
    ptime_t   = ^time_t;

    wchar_t   = cint32;
    pwchar_t  = ^wchar_t;

{$ifdef cpu64}
    uid_t    = cuint32;         { used for user ID type        }
    gid_t    = cuint32;         { used for group IDs           }
    ipc_pid_t = cint;
{$else cpu64}
    uid_t    = cuint32;         { used for user ID type        }
    gid_t    = cuint32;         { used for group IDs           }
    ipc_pid_t = cushort;        { still 16-bit on 32-bit }
{$endif cpu64}
    TUid     = uid_t;
    pUid     = ^uid_t;
    TGid     = gid_t;
    pGid     = ^gid_t;

    TIOCtlRequest = culong;

    socklen_t= cuint32;
    TSockLen = socklen_t;
    pSockLen = ^socklen_t;

  { musl: struct timeval { time_t tv_sec; suseconds_t tv_usec; };
    Both time_t and suseconds_t are 8 bytes on all architectures }
  timeval     = record
                 tv_sec:time_t;
                 tv_usec:suseconds_t;
                end;
  ptimeval    = ^timeval;
  TTimeVal    = timeval;

  { musl: struct timespec { time_t tv_sec; ... long tv_nsec; ... };
    On 32-bit: time_t(8) + tv_nsec(4) + pad(4) = 16 bytes with C packing.
    On 64-bit: time_t(8) + tv_nsec(8) = 16 bytes. }
  timespec    = record
                 tv_sec   : time_t;
                 tv_nsec  : clong;
                end;
  ptimespec   = ^timespec;
  TTimeSpec   = timespec;

  {$ifdef cpu64}
  TStatfs = record
    fstype,            { File system type }
    bsize   : clong;    { Optimal block transfer size }
    blocks,            { Data blocks in system }
    bfree,             { free blocks in system }
    bavail,            { Available free blocks to non-root users }
    files,             { File nodes in system }
    ffree   : culong;             { Free file nodes in system }
    fsid    : array[0..1] of cint;          { File system ID }
    namelen : clong; { Maximum name length in system }
    frsize  : clong;
    flags   : clong;
    spare   : array [0..3] of clong; { For later use }
  end;
  {$else}
  TStatfs = record
    fstype,            { File system type }
    bsize   : cint;    { Optimal block transfer size }
    blocks,            { Data blocks in system }
    bfree,             { free blocks in system }
    bavail,            { Available free blocks to non-root users }
    files,             { File nodes in system }
    ffree   : culonglong;  { Free file nodes in system }
    fsid    : array[0..1] of cint;          { File system ID }
    namelen,           { Maximum name length in system }
    frsize  : cint;
    flags   : cint;
    spare   : array [0..3] of cint; { For later use }
  end;
  {$endif}
  PStatFS=^TStatFS;

  mbstate_value_t = record
    case byte of
      0: (__wch: wint_t);
      1: (__wchb: array[0..3] of AnsiChar);
  end;

  mbstate_t = record
    __count: cint;
    __value: mbstate_value_t;
  end;
  pmbstate_t = ^mbstate_t;

  { musl: pthread_t = struct __pthread * (C) or unsigned long (C++)
    In OHOS (non-C++), pthread_t is a pointer to opaque struct }
  pthread_t = pointer;

  { glibc-compatibility type used by pthreads package (pthrlinux.inc).
    Not present in musl but needed for compilation of the pthreads unit.
    Size: clong + cint = 12 bytes (32-bit) / 16 bytes padded (64-bit) }
  _pthread_fastlock = record
    __status: clong;
    __spinlock: cint;
  end;

  sched_param = record
    __sched_priority: cint;
  end;

  pthread_attr_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_PTHREAD_ATTR_T-1] of AnsiChar;
          );
      1 : (
             __align : clong;
          );
  end;

{$macro on}
{$define MUTEXTYPENAME := pthread_mutex_t}
{$i pmutext.inc}
{$undef MUTEXTYPENAME}
{$macro off}

  pthread_mutexattr_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_PTHREAD_MUTEXATTR_T-1] of AnsiChar;
          );
      1 : (
             __align : cint;
          );
  end;

  pthread_cond_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_PTHREAD_COND_T-1] of AnsiChar;
          );
      1 : (
             ___align : clonglong;
          );
  end;

  pthread_condattr_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_PTHREAD_CONDATTR_T-1] of AnsiChar;
          );
      1 : (
             __align : cint;
          );
  end;

  pthread_key_t = cuint;

  pthread_rwlock_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_PTHREAD_RWLOCK_T-1] of AnsiChar;
          );
      1 : (
             __align : clong;
         );
  end;

  pthread_rwlockattr_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_PTHREAD_RWLOCKATTR_T-1] of AnsiChar;
          );
      1 : (
             __align : cint;
          );
  end;

  sem_t = record
    case byte of
      0 : (
             __size : array[0..__SIZEOF_SEM_T-1] of AnsiChar;
          );
      1 : (
             __align : clonglong;
          );
  end;



CONST
    { musl mutex type constants (from pthread.h) }
    _PTHREAD_MUTEX_NORMAL     = 0;
    _PTHREAD_MUTEX_RECURSIVE  = 1;
    _PTHREAD_MUTEX_ERRORCHECK = 2;

    _PTHREAD_MUTEX_DEFAULT    = _PTHREAD_MUTEX_NORMAL;

    { glibc-compatibility aliases used by pthreads package (pthrlinux.inc).
      Values match musl POSIX constants where applicable. }
    _PTHREAD_MUTEX_TIMED_NP      = 0;
    _PTHREAD_MUTEX_RECURSIVE_NP  = 1;
    _PTHREAD_MUTEX_ERRORCHECK_NP = 2;
    _PTHREAD_MUTEX_ADAPTIVE_NP   = 3;  { glibc-only, not in musl }
    _PTHREAD_MUTEX_FAST_NP       = 0;  { alias for TIMED_NP }

   { System limits, POSIX value in parentheses, used for buffer and stack allocation }

    ARG_MAX        = 131072;   {4096}  { Maximum number of argument size     }
    NAME_MAX       = 255;      {14}    { Maximum number of bytes in filename }
    PATH_MAX       = 4095;     {255}   { Maximum number of bytes in pathname }
    SYS_NMLN       = 65;
    SIG_MAXSIG     = 128;       // highest signal version


 { For getting/setting priority }
  Prio_Process = 0;
  Prio_PGrp    = 1;
  Prio_User    = 2;

