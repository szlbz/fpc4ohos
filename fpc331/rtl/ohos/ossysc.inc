{
    Copyright (c) 2024 by the Free Pascal development team

    The base HarmonyOS syscalls required to implement the system unit. These
    are aliased for use in other units.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 ****************************************************************************
}

{*****************************************************************************
                     --- Main:The System Call Self ---
*****************************************************************************}

function Fptime(tloc:pTime_t): Time_t; [public, alias : 'FPC_SYSC_TIME'];
{$if defined(generic_linux_syscalls) or defined(FPC_USEGETTIMEOFDAY)}
VAR tv     : timeval;
    tz     : timezone;
    retval : longint;

begin
  Retval:=do_syscall(syscall_nr_gettimeofday,TSysParam(@tv),TSysParam(@tz));
  If retval=-1 then
   Fptime:=-1
  else
   Begin
   If Assigned(tloc) Then
     TLoc^:=tv.tv_sec;
    Fptime:=tv.tv_sec;
   End;
End;
{$else FPC_USEGETTIMEOFDAY}
begin
  Fptime:=do_syscall(syscall_nr_time,TSysParam(tloc));
end;
{$endif FPC_USEGETTIMEOFDAY}

{*****************************************************************************
               --- File:File handling related calls ---
*****************************************************************************}

function Fpopen(path: PAnsiChar; flags : cint; mode: mode_t):cint; [public, alias : 'FPC_SYSC_OPEN'];
begin
  fpopen:=do_syscall(syscall_nr_open,TSysParam(path),TSysParam(flags),TSysParam(mode));
end;

function Fpclose(fd: cint):cint; [public, alias : 'FPC_SYSC_CLOSE'];
begin
  fpclose:=do_syscall(syscall_nr_close,TSysParam(fd));
end;

function Fpread(fd: cint; buf: pointer; nbytes: size_t):ssize_t; [public, alias : 'FPC_SYSC_READ'];
begin
  fpread:=do_syscall(syscall_nr_read,TSysParam(fd),TSysParam(buf),TSysParam(nbytes));
end;

function Fpwrite(fd: cint; buf: pointer; nbytes: size_t):ssize_t; [public, alias : 'FPC_SYSC_WRITE'];
begin
  fpwrite:=do_syscall(syscall_nr_write,TSysParam(fd),TSysParam(buf),TSysParam(nbytes));
end;

function FpLseek(fd: cint; offset: off_t; whence: cint):off_t; [public, alias : 'FPC_SYSC_LSEEK'];
begin
  fplseek:=do_syscall(syscall_nr_lseek,TSysParam(fd),TSysParam(offset),TSysParam(whence));
end;

function FpFcntl(fd: cint; cmd: cint; arg: TSysParam):cint; [public, alias : 'FPC_SYSC_FCNTL'];
begin
  fpfcntl:=do_syscall(syscall_nr_fcntl,TSysParam(fd),TSysParam(cmd),arg);
end;

function FpIoctl(fd: cint; request: cint; argp: pointer):cint; [public, alias : 'FPC_SYSC_IOCTL'];
begin
  fpioctl:=do_syscall(syscall_nr_ioctl,TSysParam(fd),TSysParam(request),TSysParam(argp));
end;

Function FpFstat(fd: cint; sbuf: pStat): cint; [public, alias : 'FPC_SYSC_FSTAT'];
begin
  fpfstat:=do_syscall(syscall_nr_fstat64,TSysParam(fd),TSysParam(sbuf));
end;

function FpStat(path: PAnsiChar; sbuf: pStat): cint; [public, alias : 'FPC_SYSC_STAT'];
begin
  fpstat:=do_syscall(syscall_nr_stat64,TSysParam(path),TSysParam(sbuf));
end;

function FpLstat(path: PAnsiChar; sbuf: pStat): cint; [public, alias : 'FPC_SYSC_LSTAT'];
begin
  fplstat:=do_syscall(syscall_nr_lstat64,TSysParam(path),TSysParam(sbuf));
end;

function FpAccess(path: PAnsiChar; amode: cint):cint; [public, alias : 'FPC_SYSC_ACCESS'];
begin
  fpaccess:=do_syscall(syscall_nr_access,TSysParam(path),TSysParam(amode));
end;

function FpChdir(path: PAnsiChar):cint; [public, alias : 'FPC_SYSC_CHDIR'];
begin
  fpchdir:=do_syscall(syscall_nr_chdir,TSysParam(path));
end;

function FpFchdir(fd: cint):cint; [public, alias : 'FPC_SYSC_FCHDIR'];
begin
  fpfchdir:=do_syscall(syscall_nr_fchdir,TSysParam(fd));
end;

function FpMkdir(path: PAnsiChar; mode: mode_t):cint; [public, alias : 'FPC_SYSC_MKDIR'];
begin
  fpmkdir:=do_syscall(syscall_nr_mkdir,TSysParam(path),TSysParam(mode));
end;

function FpRmdir(path: PAnsiChar):cint; [public, alias : 'FPC_SYSC_RMDIR'];
begin
  fprmdir:=do_syscall(syscall_nr_rmdir,TSysParam(path));
end;

function FpUnlink(path: PAnsiChar):cint; [public, alias : 'FPC_SYSC_UNLINK'];
begin
  fpunlink:=do_syscall(syscall_nr_unlink,TSysParam(path));
end;

function FpRename(old, newpath: PAnsiChar):cint; [public, alias : 'FPC_SYSC_RENAME'];
begin
  fpreplace:=do_syscall(syscall_nr_rename,TSysParam(old),TSysParam(newpath));
end;

Function FpGetCwd(buf: PAnsiChar; size: size_t): PAnsiChar; [public, alias : 'FPC_SYSC_GETCWD'];
begin
  if do_syscall(syscall_nr_getcwd,TSysParam(buf),TSysParam(size))<>-1 then
   fpgetcwd:=buf
  else
   fpgetcwd:=nil;
end;

Function FpChmod(path: PAnsiChar; mode: mode_t):cint; [public, alias : 'FPC_SYSC_CHMOD'];
begin
  fpchmod:=do_syscall(syscall_nr_chmod,TSysParam(path),TSysParam(mode));
end;

Function FpChown(path: PAnsiChar; owner: uid_t; group: gid_t):cint; [public, alias : 'FPC_SYSC_CHOWN'];
begin
  fpchown:=do_syscall(syscall_nr_chown,TSysParam(path),TSysParam(owner),TSysParam(group));
end;

Function FpDup2(oldfd, newfd: cint):cint; [public, alias : 'FPC_SYSC_DUP2'];
begin
  fpdup2:=do_syscall(syscall_nr_dup2,TSysParam(oldfd),TSysParam(newfd));
end;

Function FpSelect(nfds: cint; readfds, writefds, exceptfds: pfdset; timeout: ptimeval): cint; [public, alias : 'FPC_SYSC_SELECT'];
begin
  fpselect:=do_syscall(syscall_nr_select,TSysParam(nfds),TSysParam(readfds),TSysParam(writefds),TSysParam(exceptfds),TSysParam(timeout));
end;

Function FpGetTimeOfDay(tp: ptimeval; tzp: ptimezone):cint; [public, alias : 'FPC_SYSC_GETTIMEOFDAY'];
begin
  fpgettimeofday:=do_syscall(syscall_nr_gettimeofday,TSysParam(tp),TSysParam(tzp));
end;

Function FpUMask(mask: mode_t): mode_t; [public, alias : 'FPC_SYSC_UMASK'];
begin
  fpmask:=do_syscall(syscall_nr_umask,TSysParam(mask));
end;

Function FpFTruncate(fd: cint; size: off_t):cint; [public, alias : 'FPC_SYSC_FTRUNCATE'];
begin
  fptruncate:=do_syscall(syscall_nr_ftruncate64,TSysParam(fd),TSysParam(size));
end;

Function FpGetpid: pid_t; [public, alias : 'FPC_SYSC_GETPID'];
begin
  fpgetpid:=do_syscall(syscall_nr_getpid);
end;

Function FpGetppid: pid_t; [public, alias : 'FPC_SYSC_GETPPID'];
begin
  fpgetppid:=do_syscall(syscall_nr_getppid);
end;

Function Fpgeteuid: uid_t; [public, alias : 'FPC_SYSC_GETEUID'];
begin
  fpgeteuid:=do_syscall(syscall_nr_geteuid);
end;

Function Fpgetuid: uid_t; [public, alias : 'FPC_SYSC_GETEUID'];
begin
  fpgetuid:=do_syscall(syscall_nr_getuid);
end;

Function Fpgetgid: gid_t; [public, alias : 'FPC_SYSC_GETEGID'];
begin
  fpgetgid:=do_syscall(syscall_nr_getgid);
end;

Function Fpgetegid: gid_t; [public, alias : 'FPC_SYSC_GETGID'];
begin
  fpgetegid:=do_syscall(syscall_nr_getegid);
end;

Function FpGetGroups(size: cint; list: pgid_t):cint; [public, alias : 'FPC_SYSC_GETGROUPS'];
begin
  fpgetgroups:=do_syscall(syscall_nr_getgroups,TSysParam(size),TSysParam(list));
end;

Function FpSetGroups(size: cint; list: pgid_t):cint; [public, alias : 'FPC_SYSC_SETGROUPS'];
begin
  fpsetgroups:=do_syscall(syscall_nr_setgroups,TSysParam(size),TSysParam(list));
end;

Function FpGetPgid(pid: pid_t): pid_t; [public, alias : 'FPC_SYSC_GETPGID'];
begin
  fpgetpgid:=do_syscall(syscall_nr_getpgid,TSysParam(pid));
end;

Function FpSetSid: pid_t; [public, alias : 'FPC_SYSC_SETSID'];
begin
  fpsetsid:=do_syscall(syscall_nr_setsid);
end;

Function FpGetSid(pid: pid_t): pid_t; [public, alias : 'FPC_SYSC_GETSID'];
begin
  fpgetsid:=do_syscall(syscall_nr_getsid,TSysParam(pid));
end;

Function FpGetRLimit(resource: cint; rlim: prlimit):cint; [public, alias : 'FPC_SYSC_GETRLIMIT'];
begin
  fpgetrlimit:=do_syscall(syscall_nr_ugetrlimit,TSysParam(resource),TSysParam(rlim));
end;

Function FpSetRLimit(resource: cint; rlim: prlimit):cint; [public, alias : 'FPC_SYSC_SETRLIMIT'];
begin
  fpsetrlimit:=do_syscall(syscall_nr_setrlimit,TSysParam(resource),TSysParam(rlim));
end;

Function FpGetPriority(which: cint; who: id_t):cint; [public, alias : 'FPC_SYSC_GETPRIORITY'];
begin
  fpgetpriority:=do_syscall(syscall_nr_getpriority,TSysParam(which),TSysParam(who));
end;

Function FpSetPriority(which: cint; who: id_t; prio: cint):cint; [public, alias : 'FPC_SYSC_SETPRIORITY'];
begin
  fpsetpriority:=do_syscall(syscall_nr_setpriority,TSysParam(which),TSysParam(who),TSysParam(prio));
end;

Function FpSysInfo(var info: tsysinfo):cint; [public, alias : 'FPC_SYSC_SYSINFO'];
begin
  fpsysinfo:=do_syscall(syscall_nr_sysinfo,TSysParam(@info));
end;

Function FpUName(buf: PutSName):cint; [public, alias : 'FPC_SYSC_UNAME'];
begin
  fpuname:=do_syscall(syscall_nr_uname,TSysParam(buf));
end;

Function FpMkTemp(template: PAnsiChar):cint; [public, alias : 'FPC_SYSC_MKTEMP'];
begin
  fpmktemp:=do_syscall(syscall_nr_mkdtemp,TSysParam(template));
end;

Function FpNanoSleep(req, rem: ptimespec):cint; [public, alias : 'FPC_SYSC_NANOSLEEP'];
begin
  fpnanoSleep:=do_syscall(syscall_nr_nanosleep,TSysParam(req),TSysParam(rem));
end;

Function FpSymlink(target, linkname: PAnsiChar):cint; [public, alias : 'FPC_SYSC_SYMLINK'];
begin
  fpsymlink:=do_syscall(syscall_nr_symlink,TSysParam(target),TSysParam(linkname));
end;

Function FpReadLink(path: PAnsiChar; buf: PAnsiChar; bufsiz: size_t):ssize_t; [public, alias : 'FPC_SYSC_READLINK'];
begin
  fpreadlink:=do_syscall(syscall_nr_readlink,TSysParam(path),TSysParam(buf),TSysParam(bufsiz));
end;

Function FpTruncate(path: PAnsiChar; size: off_t):cint; [public, alias : 'FPC_SYSC_TRUNCATE'];
begin
  fptruncate:=do_syscall(syscall_nr_truncate64,TSysParam(path),TSysParam(size));
end;

Function FpLink(oldpath, newpath: PAnsiChar):cint; [public, alias : 'FPC_SYSC_LINK'];
begin
  fplink:=do_syscall(syscall_nr_link,TSysParam(oldpath),TSysParam(newpath));
end;

Function FpPipe(fildes: tfildes):cint; [public, alias : 'FPC_SYSC_PIPE'];
begin
  fppipe:=do_syscall(syscall_nr_pipe2,TSysParam(fildes),0);
end;

Function FpGetEnviron: PPAnsiChar; [public, alias : 'FPC_SYSC_GETENVIRON'];
begin
  fpgetenviron:=operatingsystem_parameter_envp;
end;
