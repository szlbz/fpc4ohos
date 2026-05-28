{
    Copyright (c) 1998-2024 by the Free Pascal development team

    This unit implements support import,export,link routines
    for the HarmonyOS target

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************}
unit t_harmonyos;

{$i fpcdefs.inc}

interface

  uses
    globtype,
    aasmdata,
    symsym,
    import,export,expunix,link;

  type
    timportlibharmonyos=class(timportlib)
      procedure generatelib;override;
    end;

    texportlibharmonyos=class(texportlibunix)
      procedure setfininame(list: TAsmList; const s: string); override;
    end;

    tlinkerharmonyos=class(texternallinker)
    private
      prtobj  : string[80];
      Function  WriteResponseFile(isdll:boolean) : Boolean;
      function DoLink(IsSharedLib: boolean): boolean;
    public
      constructor Create;override;
      procedure SetDefaultInfo;override;
      procedure InitSysInitUnitName;override;
      function  MakeExecutable:boolean;override;
      function  MakeSharedLibrary:boolean;override;
      procedure LoadPredefinedLibraryOrder; override;
    end;


implementation

  uses
    SysUtils,
    cutils,cfileutl,cclasses,
    verbose,systems,globals,
    cscript,
    fmodule,
    aasmbase,aasmtai,aasmcpu,cpubase,
    cgbase,ogbase,
    comprsrc,
    rescmn, i_harmonyos
    ;

{*****************************************************************************
                           TIMPORTLIBHARMONYOS
*****************************************************************************}

    procedure timportlibharmonyos.generatelib;
      var
        i : longint;
        ImportLibrary : TImportLibrary;
      begin
        for i:=0 to current_module.ImportLibraryList.Count-1 do
          begin
            ImportLibrary:=TImportLibrary(current_module.ImportLibraryList[i]);
            current_module.linkothersharedlibs.add(ImportLibrary.Name,link_always);
          end;
      end;


{*****************************************************************************
                           TEXPORTLIBHARMONYOS
*****************************************************************************}

    procedure texportlibharmonyos.setfininame(list: TAsmList; const s: string);
      begin
        new_section(list,sec_fpc,'links',0);
        list.concat(Tai_const.Createname(s,0));
        inherited setfininame(list,s);
      end;


{*****************************************************************************
                              TLINKERHARMONYOS
*****************************************************************************}

Constructor TLinkerHarmonyOS.Create;
begin
  Inherited Create;
end;


procedure TLinkerHarmonyOS.SetDefaultInfo;
var
  s: string;
begin
  with Info do
   begin
     s:='ld -z max-page-size=0x1000 -z common-page-size=0x1000 -z noexecstack -z now -z relro --build-id $OPT -L. -T $RES -o $EXE';
     ExeCmd[1]:=s + ' --entry=_start';
     DllCmd[1]:=s + ' -shared -soname $SONAME';
     DllCmd[2]:='strip --strip-unneeded $EXE';
     ExtDbgCmd[1]:='objcopy --only-keep-debug $EXE $DBG';
     ExtDbgCmd[2]:='objcopy --add-gnu-debuglink=$DBG $EXE';
     ExtDbgCmd[3]:='strip --strip-unneeded $EXE';
{$ifdef cpu64bitalu}
     DynamicLinker:='/system/bin/linker64';
{$else}
     DynamicLinker:='/system/bin/linker';
{$endif cpu64bitalu}
   end;
end;


procedure TLinkerHarmonyOS.LoadPredefinedLibraryOrder;
Begin
   if not (cs_link_no_default_lib_order in  current_settings.globalswitches) Then
        Begin
          LinkLibraryOrder.add('gcc','',15);
          LinkLibraryOrder.add('c','',100);
          LinkLibraryOrder.add('gmon','',120);
          LinkLibraryOrder.add('dl','',140);
          LinkLibraryOrder.add('pthread','',160);
         end;
end;

Procedure TLinkerHarmonyOS.InitSysInitUnitName;
begin
  if current_module.islibrary then
    prtobj:='dllprt0'
  else
    prtobj:='prt0';
end;

Function TLinkerHarmonyOS.WriteResponseFile(isdll:boolean) : Boolean;
Var
  linkres      : TLinkRes;
  i            : longint;
  HPath        : TCmdStrListItem;
  s,s1         : TCmdStr;
begin
  result:=False;
  { Always link to libc (musl-based on HarmonyOS) }
  AddSharedLibrary('c');

  { Add default library search paths for HarmonyOS sysroot }
  if sysrootpath<>'' then
    LibrarySearchPath.AddLibraryPath(sysrootpath,'=/usr/lib/x86_64-linux-ohos;=/lib/x86_64-linux-ohos',true);

  { Open link.res file }
  LinkRes:=TLinkRes.Create(outputexedir+Info.ResName,true);
  with linkres do
    begin
      { Write path to search libraries }
      HPath:=TCmdStrListItem(current_module.locallibrarysearchpath.First);
      while assigned(HPath) do
       begin
         Add('SEARCH_DIR('+maybequoted(HPath.Str)+')');
         HPath:=TCmdStrListItem(HPath.Next);
       end;
      HPath:=TCmdStrListItem(LibrarySearchPath.First);
      while assigned(HPath) do
       begin
         Add('SEARCH_DIR('+maybequoted(HPath.Str)+')');
         HPath:=TCmdStrListItem(HPath.Next);
       end;

      { force local symbol resolution (i.e., inside the shared }
      { library itself) for all non-exported symbols }
      if isdll or (cs_create_pic in current_settings.moduleswitches) then
        begin
      add('VERSION');
      add('{');
      add('  {');
      if not texportlibunix(exportlib).exportedsymnames.empty then
        begin
          add('    global:');
          repeat
            add('      '+texportlibunix(exportlib).exportedsymnames.getfirst+';');
          until texportlibunix(exportlib).exportedsymnames.empty;
        end;
      add('    local:');
      add('      *;');
      add('  };');
      add('}');
        end;

      StartSection('INPUT(');
      { add objectfiles, start with prt0 always }
      if not (target_info.system in systems_internal_sysinit) and (prtobj<>'') then
        AddFileName(maybequoted(FindObjectFile(prtobj,'',false)));
      { Add libc startup object file (musl-based) }
      s:='';
      { try Scrt1.o (PIE), then crt1.o (non-PIE) for programs }
      if not isdll then
        begin
          if cs_create_pic in current_settings.moduleswitches then
            s:='Scrt1.o'
          else
            s:='crt1.o';
          if not librarysearchpath.FindFile(s,false,s1) then
            s:='crt1.o';
        end;
      { for DLLs, try crti.o first }
      if isdll then
        s:='crti.o';
      librarysearchpath.FindFile(s,false,s1);
      if s1<>'' then
        AddFileName(maybequoted(s1));
      { also try crti.o if not a DLL (needed for proper init/fini) }
      if not isdll then
        begin
          s:='crti.o';
          librarysearchpath.FindFile(s,false,s1);
          if s1<>'' then
            AddFileName(maybequoted(s1));
        end;
      { main objectfiles }
      while not ObjectFiles.Empty do
       begin
         s:=ObjectFiles.GetFirst;
         if s<>'' then
          AddFileName(maybequoted(s));
       end;
      EndSection(')');

      { Write staticlibraries }
      if not StaticLibFiles.Empty then
       begin
         Add('GROUP(');
         While not StaticLibFiles.Empty do
          begin
            S:=StaticLibFiles.GetFirst;
            AddFileName(maybequoted(s))
          end;
         Add(')');
       end;

      if not SharedLibFiles.Empty then
       begin
         { Write shared library references }
         Add('INPUT(');
         While not SharedLibFiles.Empty do
          begin
            S:=SharedLibFiles.GetFirst;
            i:=Pos(target_info.sharedlibext,S);
            if i>0 then
              Delete(S,i,255);
            Add('-l'+s);
          end;
         Add(')');

         { Ensure libc is always in the link for both static and dynamic linking }
         Add('GROUP(');
         if (cs_link_staticflag in current_settings.globalswitches) then
           begin
             Add('-lgcc');
             if librarysearchpath.FindFile('libgcc_eh.a',false,s1) then
               Add('-lgcc_eh');
           end;
         Add('-lc');
         Add(')');
       end;

      { objects which must be at the end }
      { Add libc finalization object file }
      s:='crtn.o';
      if librarysearchpath.FindFile(s,false,s1) then
        begin
          Add('INPUT(');
          AddFileName(maybequoted(s1));
          Add(')');
        end;

      { Add data sections using INSERT to merge with default linker script }
      add('SECTIONS');
      add('{');
      add('  .fpcdata           :');
      add('  {');
      add('    KEEP (*(.fpc .fpc.n_version .fpc.n_links .fpc.n_resources))');
      add('    *(.rodata.n_FPC_*)');
      add('  }');
      add('  .threadvar : { *(.threadvar .threadvar.* .gnu.linkonce.tv.*) }');
      add('}');
      add('INSERT AFTER .data;');
      add('PROVIDE (FPC_LIB_MAIN_HARMONYOS = PASCALMAIN);');

      { Write and Close response }
      writetodisk;
      Free;
    end;

  WriteResponseFile:=True;
end;

function tlinkerharmonyos.DoLink(IsSharedLib: boolean): boolean;
var
  i: longint;
  binstr, cmdstr: TCmdStr;
  s, opts, outname: TCmdStr;
  success: boolean;
begin
  Result:=False;
  if IsSharedLib then
    outname:=current_module.sharedlibfilename
  else
    outname:=current_module.exefilename;
  if not(cs_link_nolink in current_settings.globalswitches) then
    Message1(exec_i_linking, outname);

  opts:='';
  if not IsSharedLib and (cs_create_pic in current_settings.moduleswitches) then
    opts:=opts + ' --pic-executable';
  if (cs_link_strip in current_settings.globalswitches) and
     not (cs_link_separate_dbg_file in current_settings.globalswitches) then
    opts:=opts + ' -s';
  if (cs_link_map in current_settings.globalswitches) then
    opts:=opts + ' -Map '+maybequoted(ChangeFileExt(outname,'.map'));
  if create_smartlink_sections then
    opts:=opts + ' --gc-sections';
  if (cs_link_staticflag in current_settings.globalswitches) then
    opts:=opts + ' -static'
  else
    if cshared then
      opts:=opts + ' -call_shared';
  if rlinkpath<>'' then
    opts:=opts+' --rpath-link '+rlinkpath;

  if not IsSharedLib then
    begin
      opts:=opts + ' --dynamic-linker ' + Info.DynamicLinker;
      if HasExports then
        opts:=opts+' -E';
    end
  else
    opts:=opts + ' -init FPC_LIB_START_HARMONYOS';

  opts:=Trim(opts + ' ' + Info.ExtraOptions);

{ Write used files and libraries }
  WriteResponseFile(IsSharedLib);

{ Call linker }
  if IsSharedLib then
    s:=Info.DllCmd[1]
  else
    s:=Info.ExeCmd[1];
  SplitBinCmd(s, binstr, cmdstr);
  Replace(cmdstr,'$EXE',maybequoted(outname));
  Replace(cmdstr,'$OPT',opts);
  Replace(cmdstr,'$RES',maybequoted(outputexedir+Info.ResName));
  if IsSharedLib then
    Replace(cmdstr,'$SONAME',ExtractFileName(outname));

  { prefer BFD version of LD if available }
  s:=utilsprefix+binstr+'.bfd';
  if (source_info.exeext<>'') then
    s:=s+source_info.exeext;
  s:=FindUtil(s,false);
  if FileExists(s, True) then
    binstr:=s
  else
    binstr:=FindUtil(utilsprefix+BinStr);

  success:=DoExec(binstr,CmdStr,true,false);

  { Create external .dbg file with debuginfo }
  if success and (cs_link_separate_dbg_file in current_settings.globalswitches) then
    begin
      for i:=1 to 3 do
        begin
          SplitBinCmd(Info.ExtDbgCmd[i],binstr,cmdstr);
          Replace(cmdstr,'$EXE',maybequoted(outname));
          Replace(cmdstr,'$DBGFN',maybequoted(extractfilename(current_module.dbgfilename)));
          Replace(cmdstr,'$DBG',maybequoted(current_module.dbgfilename));
          success:=DoExec(FindUtil(utilsprefix+BinStr),CmdStr,true,false);
          if not success then
            break;
        end;
    end;

  { Remove ResponseFile }
  if (success) and not(cs_link_nolink in current_settings.globalswitches) then
    DeleteFile(outputexedir+Info.ResName);

  Result:=success;
end;

function TLinkerHarmonyOS.MakeExecutable:boolean;
begin
  Result:=DoLink(False);
end;

Function TLinkerHarmonyOS.MakeSharedLibrary:boolean;
begin
  Result:=DoLink(True);
end;

{*****************************************************************************
                                  Initialize
*****************************************************************************}

initialization
  RegisterLinker(ld_harmonyos,TLinkerHarmonyOS);
{$ifdef ARM}
  RegisterImport(system_arm_harmonyos,timportlibharmonyos);
  RegisterExport(system_arm_harmonyos,texportlibharmonyos);
  RegisterTarget(system_arm_harmonyos_info);
{$endif ARM}
{$ifdef AARCH64}
  RegisterImport(system_aarch64_harmonyos,timportlibharmonyos);
  RegisterExport(system_aarch64_harmonyos,texportlibharmonyos);
  RegisterTarget(system_aarch64_harmonyos_info);
{$endif AARCH64}
{$ifdef X86_64}
  RegisterImport(system_x86_64_harmonyos,timportlibharmonyos);
  RegisterExport(system_x86_64_harmonyos,texportlibharmonyos);
  RegisterTarget(system_x86_64_harmonyos_info);
{$endif X86_64}
  RegisterRes(res_elf_info,TWinLikeResourceFile);
end.
