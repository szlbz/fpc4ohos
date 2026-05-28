{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2024 by Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

  // add the rtl to the list of fpmake targets
  if CurrentEngine=rte_FPC then
    begin
{$ifdef fpc}
      if target_os in systems_harmonyos then
        begin
          fpmake_add('rtl-ohos','rtl/ohos',target_os,systems_harmonyos,
            {$ifdef cpuarm}CPUARM{$else}
            {$ifdef cpuaarch64}CPUAARCH64{$else}
            {$ifdef cpux86_64}CPUX86_64{$endif}
            {$endif}
            {$endif});
        end;
{$endif fpc}
    end;
