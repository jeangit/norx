##  Orx - Portable Game Engine
##
##  Copyright (c) 2008-2020 Orx-Project
##
##  This software is provided 'as-is', without any express or implied
##  warranty. In no event will the authors be held liable for any damages
##  arising from the use of this software.
##
##  Permission is granted to anyone to use this software for any purpose,
##  including commercial applications, and to alter it and redistribute it
##  freely, subject to the following restrictions:
##
##     1. The origin of this software must not be misrepresented; you must not
##     claim that you wrote the original software. If you use this software
##     in a product, an acknowledgment in the product documentation would be
##     appreciated but is not required.
##
##     2. Altered source versions must be plainly marked as such, and must not be
##     misrepresented as being the original software.
##
##     3. This notice may not be removed or altered from any source
##     distribution.

import norx/typ

type
  orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD* {.size: sizeof(cint).} = enum
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_INIT = 0,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_EXIT,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_IS_KEY_PRESSED,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_GET_KEY_DISPLAY_NAME,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_READ_KEY,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_READ_STRING,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_CLEAR_BUFFER,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_SHOW,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_NUMBER,
    orxPLUGIN_FUNCTION_BASE_ID_KEYBOARD_NONE = orxENUM_NONE