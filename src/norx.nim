import os

import norx/[incl, param, module, event, clock]

when not defined(PLUGIN):
  ## Should stop execution by default event handling?
  var sbStopByEvent* = false

  ##  Orx default basic event handler
  ##  @param[in]   pstEvent                     Sent event
  ##  @return      orxSTATUS_SUCCESS if handled / orxSTATUS_FAILURE otherwise
  proc orx_DefaultEventHandler*(pstEvent: ptr orxEVENT): orxSTATUS {.cdecl.} =
    ##  Checks
    assert(pstEvent.eType == orxEVENT_TYPE_SYSTEM)
    #echo "pstEvent.eType: " & $pstEvent.eType
    #echo "pstEvent.eID: " & $pstEvent.eID
    ##  Depending on event ID
    case pstEvent.eID:
      of ord(orxSYSTEM_EVENT_CLOSE):
        ##  Updates status
        sbStopByEvent = true
      else:
        discard
    return orxSTATUS_SUCCESS

  ## Default main setup (module dependencies)
  proc orx_MainSetup*() {.cdecl.} =
    ##  Adds module dependencies
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_PARAM)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_CLOCK)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_CONFIG)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_INPUT)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_EVENT)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_FILE)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_LOCALE)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_PLUGIN)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_OBJECT)
    addDependency(orxMODULE_ID_MAIN, orxMODULE_ID_RENDER)
    addOptionalDependency(orxMODULE_ID_MAIN, orxMODULE_ID_CONSOLE)
    addOptionalDependency(orxMODULE_ID_MAIN, orxMODULE_ID_PROFILER)
    addOptionalDependency(orxMODULE_ID_MAIN, orxMODULE_ID_SCREENSHOT)

  when defined(iOS):
    discard
  else:
    when defined(Android) or defined(ANDROID_NATIVE):
      import norx/[android, thread]

      ## Orx main execution function
      ##  @param[in]   initProc      Main init function (should init all the main stuff and register the main event handler to override the default one)
      ##  @param[in]   runProc       Main run function (will be called once per frame, should return orxSTATUS_SUCCESS to continue processing)
      ##  @param[in]   exitProc      Main exit function (should clean all the main stuff)
      proc execute*(initProc: proc(): orxSTATUS {.cdecl.};
                       runProc: proc(): orxSTATUS {.cdecl.};
                       exitProc: proc() {.cdecl.}) {.inline} =
        ## Inits the Debug System
        orxDEBUG_INIT_MACRO()
        ## Checks
        assert(runProc != nil)
        ##  Registers main module
        register(orxMODULE_ID_MAIN, "MAIN", orx_MainSetup, initProc, exitProc)
        ## On Android this is 0, null.
        if setArgs(0, nil) != orxSTATUS_FAILURE:
          ##  Sets thread callbacks
          discard setCallbacks(orxAndroid_JNI_SetupThread, nil, nil)
          ##  Inits the engine
          if moduleInit(orxMODULE_ID_MAIN) != orxSTATUS_FAILURE:
            var
              stPayload: orxSYSTEM_EVENT_PAYLOAD
              eClockStatus: orxSTATUS
              eMainStatus: orxSTATUS

            ##  Registers default event handler
            var st = addHandler(orxEVENT_TYPE_SYSTEM, orx_DefaultEventHandler)
            ##  Clears payload
            zeroMem(addr(stPayload), sizeof(orxSYSTEM_EVENT_PAYLOAD).orxU32)
            ##  Main loop
            var bStop = false
            sbStopByEvent = false
            while not bStop:
              orxAndroid_PumpEvents()
              ##  Sends frame start event
              orxEVENT_SEND_MACRO(orxEVENT_TYPE_SYSTEM, orxSYSTEM_EVENT_GAME_LOOP_START, nil, nil, addr(stPayload))
              ##  Runs the engine
              eMainStatus = runProc()
              ##  Updates clock system
              eClockStatus = update()
              ##  Sends frame stop event
              orxEVENT_SEND_MACRO(orxEVENT_TYPE_SYSTEM, orxSYSTEM_EVENT_GAME_LOOP_STOP, nil, nil, addr(stPayload))
              ##  Updates frame count
              stPayload.u32FrameCount += 1
              bStop = (sbStopByEvent or (eMainStatus == orxSTATUS_FAILURE) or (eClockStatus == orxSTATUS_FAILURE))
          discard removeHandler(orxEVENT_TYPE_SYSTEM, cast[orxEVENT_HANDLER](orx_DefaultEventHandler))
          ##  Exits from engine
          moduleExit(orxMODULE_ID_MAIN)
        orxDEBUG_EXIT_MACRO()
    else:
      ## Orx main execution function
      ##  @param[in]   initProc      Main init function (should init all the main stuff and register the main event handler to override the default one)
      ##  @param[in]   runProc       Main run function (will be called once per frame, should return orxSTATUS_SUCCESS to continue processing)
      ##  @param[in]   exitProc      Main exit function (should clean all the main stuff)
      proc execute*(initProc: proc(): orxSTATUS {.cdecl.};
                       runProc: proc(): orxSTATUS {.cdecl.};
                       exitProc: proc() {.cdecl.}) {.inline} =
        ## Inits the Debug System
        orxDEBUG_INIT_MACRO()
        ## Checks
        assert(runProc != nil)
        ##  Registers main module
        register(orxMODULE_ID_MAIN, "MAIN", orx_MainSetup, initProc, exitProc)
        # Hack to produce C style argc/argv to pass on
        var argc = paramCount()
        var nargv = newSeq[string](argc + 1)
        nargv[0] = getAppFilename()  # Better than paramStr(0)
        var x = 1
        while x <= argc:
          nargv[x] = paramStr(x)
          inc(x)
        var argv: cstringArray = nargv.allocCStringArray()
        inc(argc)
        ##  Sends the command line arguments to orxParam module
        if setArgs(argc.orxU32, argv) != orxSTATUS_FAILURE:
          ##  Inits the engine
          if moduleInit(orxMODULE_ID_MAIN) != orxSTATUS_FAILURE:
            var
              stPayload: orxSYSTEM_EVENT_PAYLOAD
              eClockStatus: orxSTATUS
              eMainStatus: orxSTATUS
            ##  Registers default event handler
            var st = addHandler(orxEVENT_TYPE_SYSTEM, orx_DefaultEventHandler)
            ##  Clears payload
            zeroMem(addr(stPayload), sizeof(orxSYSTEM_EVENT_PAYLOAD).orxU32)
            ##  Main loop
            var bStop = false
            sbStopByEvent = false
            while not bStop:
              ##  Sends frame start event
              orxEVENT_SEND_MACRO(orxEVENT_TYPE_SYSTEM, orxSYSTEM_EVENT_GAME_LOOP_START, nil, nil, addr(stPayload))
              ##  Runs the engine
              eMainStatus = runProc()
              ##  Updates clock system
              eClockStatus = update()
              ##  Sends frame stop event
              orxEVENT_SEND_MACRO(orxEVENT_TYPE_SYSTEM, orxSYSTEM_EVENT_GAME_LOOP_STOP, nil, nil, addr(stPayload))
              ##  Updates frame count
              stPayload.u32FrameCount += 1
              bStop = (sbStopByEvent or (eMainStatus == orxSTATUS_FAILURE) or (eClockStatus == orxSTATUS_FAILURE))
          discard removeHandler(orxEVENT_TYPE_SYSTEM, cast[orxEVENT_HANDLER](orx_DefaultEventHandler))
          ##  Exits from engine
          moduleExit(orxMODULE_ID_MAIN)
        orxDEBUG_EXIT_MACRO()