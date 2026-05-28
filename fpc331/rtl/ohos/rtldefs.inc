{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2024 by Free Pascal development team

    This file contains platform-specific defines that are used in
    multiple RTL units.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ HarmonyOS uses single byte OS API (UTF-8) }
{$define FPCRTL_FILESYSTEM_SINGLE_BYTE_API}
