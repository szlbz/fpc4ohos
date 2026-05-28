{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2024 by Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit si_dll;

{$ifdef CPUSPARC64}
  {$PIC ON}
{$endif CPUSPARC64}

interface

{$i si_intf.inc}

implementation

{$i sysnr.inc}
{$i si_impl.inc}
{$i si_dll.inc}

end.
