
import norx/typ

type
  orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK* {.size: sizeof(cint).} = enum
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_INIT = 0,
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_EXIT,
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_GET_AXIS_VALUE,
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_IS_BUTTON_PRESSED,
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_IS_CONNECTED,
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_NUMBER,
    orxPLUGIN_FUNCTION_BASE_ID_JOYSTICK_NONE = orxENUM_NONE