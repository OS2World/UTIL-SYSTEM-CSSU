/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         _ButtonsDisable
*/
_ButtonsDisable: 
    ok = VRSet("PB_Reboot","Enabled",0)
    ok = VRSet("PB_Store","Enabled",0)
    ok = VRSet("PB_Update","Enabled",0)
    ok = VRSet("PB_KillConn","Enabled",0)
    ok = VRSet("PB_Reboot","Enabled",0)
    ok = VRSet("PB_Reset","Enabled",0)
    ok = VRSet("PB_Exit","Enabled",0)
return

/*:VRX         _ButtonsEnable
*/
_ButtonsEnable: 
    ok = VRSet("PB_Store","Enabled",1)
    ok = VRSet("PB_Update","Enabled",1)
    ok = VRSet("PB_KillConn","Enabled",1)
    ok = VRSet("PB_Reboot","Enabled",1)
    ok = VRSet("PB_Reset","Enabled",1)
    ok = VRSet("PB_Exit","Enabled",1)
return

/*:VRX         _CiscoCommand
*/
_CiscoCommand: procedure expose Port SystemName
    parse arg Command
    PH = _PortOpen(Port)
    ok = _PortWrite(PH, Command)
    MsgLine = _PortRead(PH)
    if pos('>',MsgLine) > 1 then SystemName= left(MsgLine,pos('>',MsgLine))
    if length(MsgLine) > 1 then ok = VRMethod("LB_Console","AddString",MsgLine)    
    ok = _PortClose(PH)
    if SystemName <> 'Unknown' then ok = VRset("EF_SystemName","value",SystemName)
return 0

/*:VRX         _CiscoSetDateTime
*/
_CiscoSetDateTime: 
    Datum = date('S')
    Datum = substr(Datum,5,2) || '/' || right(Datum,2) || '/' || left(Datum,4)
    PH = _PortOpen(Port)
    ok = _PortWrite(PH,'SET DATE 'Datum)
    BootMsg = _PortRead(PH)
    if pos('>',BootMsg) > 1 then SystemName= left(BootMsg,pos('>',BootMsg))
    if length(BootMsg) > 1 then ok = VRMethod("LB_Console","AddString",BootMsg)
    call SysSleep 1
    ok = _PortWrite(PH,'SET TIME 'time())
    BootMsg = _PortRead(PH)
    if pos('>',BootMsg) > 1 then SystemName= left(BootMsg,pos('>',BootMsg))
    if length(BootMsg) > 1 then ok = VRMethod("LB_Console","AddString",BootMsg)
    ok = _PortClose(PH)
    if SystemName <> 'Unknown' then ok = VRset("EF_SystemName","value",SystemName)
return

/*:VRX         _GetCFG
*/
_GetCFG: 

return

/*:VRX         _INIRead
*/
_INIRead: 
    SystemName      = 'Unknown'
    Port            = VRGetIni( "CSSU", "Port", "CSSU.INI" )
    AutoClose       = VRGetIni( "CSSU", "AutoClose", "CSSU.INI" )
    AutoSetDateTime = VRGetIni( "CSSU", "AutoSetDateTime", "CSSU.INI" )
    if Port = ''            then Port = 'COM2'
    if AutoClose = ''       then AutoClose = 0
    if AutoSetDateTime = '' then AutoSetDateTime = 0
return

/*:VRX         _InitGUI
*/
_InitGUI: 
    ok = VRSet("DDCB_Port","Value",Port)
    ok = VRSet("CB_AutoClose","Set",AutoClose)
    ok = VRSet("CB_AutoSetDateTime","Set",AutoSetDateTime)
    ok = VRSet("EF_SystemName","Value",SystemName)
return

/*:VRX         _INIWrite
*/
_INIWrite: 
    ok = VRSetIni( "CSSU", "Port",            Port,            "CSSU.INI", 'NoClose' )
    ok = VRSetIni( "CSSU", "AutoClose",       AutoClose,       "CSSU.INI", 'NoClose' )
    ok = VRSetIni( "CSSU", "AutoSetDateTime", AutoSetDateTime, "CSSU.INI" )
return


/*:VRX         _LoadOtherFuncs
*/
_LoadOtherFuncs: 
    /* Register RXAsync-API */
    call RxFuncAdd 'RxAsyncLoadFuncs', 'RXASYNC', 'RxAsyncLoadFuncs'
    call RxAsyncLoadFuncs

    /* Register RxExtras-API */
    Call RxFuncAdd 'RxExtra', 'RxExtras', 'RxExtra'
    Call RxExtra 'Load'
return

/*:VRX         _PortClose
*/
_PortClose: procedure
    parse arg Porthandle
    RC = RxAsyncClose( PortHandle )
    RC = RxAsyncPriority( 2, 0 ) /* 2,0 */
return 0

/*:VRX         _PortOpen
*/
_PortOpen: procedure
    parse arg PortName /* full name of port i.e. COM1, not 1 */
    EnableUseFIFO = 1  /* could be configurable */
    PortHandle = ''    /* will be returned */
    NotWritten = 0
    RC = RxAsyncPriority(3, 0)
    RC = RxAsyncOpen(PortName, 'PortHandle' )
/*  say 'RC='RC
    say 'Porthandle='Porthandle
 */
    RC = RxAsyncSetLnCtrl( PortHandle, 9600,8,'N',1 )
    if EnableUseFIFO 
        then Flags3 = '11010010' /* 16550A(FN) */
        else Flags3 = '00000010' /* 8250/14450/16550 */
    RC = RxAsyncSetDcbInfo( PortHandle, 50, 50, '00001001','10100000', Flags3, '00', '00', '11', '13' )
    RC = RxAsyncSetEnhParm( PortHandle, '00000010')
return Porthandle

/*:VRX         _PortRead
*/
_PortRead: procedure
    parse arg Porthandle
    InpStr = ""
    RC = RxAsyncRead( PortHandle, 0, 3000, 'InpStr' )
    InpStr = strip(strip(InpStr,'T',d2c(10)),'T',d2c(13))
return InpStr

/*:VRX         _PortWrite
*/
_PortWrite: procedure
    parse arg Porthandle,Line
    NotWritten = 0
/*  say 'Porthandle='Porthandle */
    RC = RxAsyncWrite( PortHandle, 0, Line || d2c(13), 'NotWritten' )
/*  say 'RC='RC
    say 'NotWritten='NotWritten
    say 'Line='Line */
    if (RC \= 0) | (NotWritten > 0) then WriteOk = 0
                                    else WriteOk = 1
    if WriteOK = 0 then call beep 880, 200
return WriteOK

/*:VRX         _SendToRouter
*/
_SendToRouter: 
    parse arg Port SendString
    PortHandle = ''
    NotWritten = 0
    RC = RxAsyncPriority(3, 0) /* oder 2,0 */
    RC = 1
/*    do until RC = 0 */
        RC = RxAsyncOpen(Port, 'PortHandle' )
/*    end */
    RC = RxAsyncSetLnCtrl( PortHandle, 9600,8,'N',1 )
    if EnableUseFIFO 
        then Flags3 = '11010010' /* 16550A(FN) */
        else Flags3 = '00000010' /* 8250/14450/16550 */
    RC = RxAsyncSetDcbInfo( PortHandle, 50, 50, '00001001','10100000', Flags3, '00', '00', '11', '13' )
    RC = RxAsyncSetEnhParm( PortHandle, '00000010')
    RC = RxAsyncWrite( PortHandle, 0, SendString||D2C(13), 'NotWritten' )
    if (RC \= 0)| (NotWritten > 0) then say '_SendToRouter failed.'
    InpStr = ""
    do I = 1 to 10 While left(InpStr,2) \= 'OK'
        rc = RxAsyncRead( PortHandle, 0, 3000, 'InpStr' )
        if RC \= 0 then say '_ReadCOMPortUntilOK Failed'
    end
    if I = 10 then say '_ReadCOMPortUntilOK Failed'
    RC = RxAsyncClose( PortHandle )
    RC = RxAsyncPriority( 2, 0 ) /* 2,0 */
return

/*:VRX         _SetCFG
*/
_SetCFG: 

return

/*:VRX         CB_AutoClose_Click
*/
CB_AutoClose_Click: 
    AutoClose = VRGet("CB_AutoClose","set")
return

/*:VRX         CB_AutoSetDateTime_Click
*/
CB_AutoSetDateTime_Click: 
    AutoSetDateTime = VRGet("CB_AutoSetDateTime","Set")
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         Main_Close
*/
Main_Close:
    call Quit
return

/*:VRX         Main_Create
*/
Main_Create: 
    call _LoadOtherFuncs
    call _INIRead
    call _InitGUI
    if AutoSetDateTime then call _CiscoSetDateTime
return

/*:VRX         PB_Exit_Click
*/
PB_Exit_Click: 
    call Quit
return

/*:VRX         PB_KillConn_Click
*/
PB_KillConn_Click: 
    call _ButtonsDisable
    ok = _CiscoCommand('DI ALL')
    call _ButtonsEnable
return

/*:VRX         PB_Reboot_Click
*/
PB_Reboot_Click: 
    call _ButtonsDisable
    ok = _CiscoCommand('REBOOT')
    PH = _PortOpen(Port)
    ok = VRMethod("LB_Console","Reset")
    BootMsg = ''
    do until BootMsg = SystemName
        BootMsg = _PortRead(PH)
        if pos('>',BootMsg) > 1 then SystemName= left(BootMsg,pos('>',BootMsg))
        if length(BootMsg) > 1 then ok = VRMethod("LB_Console","AddString",BootMsg)
    end
    if SystemName <> 'Unknown' then ok = VRset("EF_SystemName","value",SystemName)
    ok = _PortClose(PH)
    call _CiscoSetDateTime
    call _ButtonsEnable
return

/*:VRX         PB_Reset_Click
*/
PB_Reset_Click: 
    Buttons.1 = "Yes"
    Buttons.2 = "No"
    Buttons.0 = 2
    id = VRMessage( VRWindow(), "Are you sure? All configuration profiles will be lost!", "Reset router to factory defaults", "Query", "Buttons.", 2, 2 )
    if id = 1 then do
        call _ButtonsDisable
        ok = _CiscoCommand('SET DEFAULT')
        PH = _PortOpen(Port)
        ok = VRMethod("LB_Console","Reset")
        BootMsg = ''
        do until BootMsg = SystemName
            BootMsg = _PortRead(PH)
            if pos('>',BootMsg) > 1 then SystemName= left(BootMsg,pos('>',BootMsg))
            if length(BootMsg) > 1 then ok = VRMethod("LB_Console","AddString",BootMsg)
        end
        if SystemName <> 'Unknown' then ok = VRset("EF_SystemName","value",SystemName)
        ok = _PortClose(PH)
        call _ButtonsEnable
    end
return

/*:VRX         PB_Store_Click
*/
PB_Store_Click: 
    CFGFile = VRFileDialog( VRWindow(), "Save configuration th file", "Save", "*.CFG")
    if CFGFile = '' then return
    call _ButtonsDisable
    ok = SysFileDelete(CFGFile)
    PH = _PortOpen(Port)
    ok = _PortWrite(PH,'UPLOAD')
    Zeile = _PortRead(PH)
    do forever
        Zeile = _PortRead(PH)
        call lineout CFGFile, Zeile
        ok = VRMethod("LB_Console","AddString",Zeile)
        if left(Zeile,6) = 'LOGOUT' then leave
    end
    call lineout CFGFile
    ok = _PortClose(PH)
    call _ButtonsEnable
return
/*:VRX         PB_Update_Click
*/
PB_Update_Click: 
    CFGFile = VRFileDialog( VRWindow(), "Select a configuration file", "Open", "*.CFG")
    if CFGFile = '' then return
    call _ButtonsDisable
    /*  get number of lines of CFG */
    J = 0
    do until lines(CFGFile)= 0
        Zeile = linein(CFGFile)
        J = J + 1
    end
    call lineout CFGFile
    window = VRLoadSecondary( "ProgressBar" )
return

/*:VRX         ProgressBar_Close
*/
ProgressBar_Close: 
    call ProgressBar_Fini
return

/*:VRX         ProgressBar_Create
*/
ProgressBar_Create: 
    call ProgressBar_Init
    ok = VRMethod("LB_Console", "Reset")
    I = 0
    PH = _PortOpen(Port)
    do until lines(CFGFile) = 0
        Zeile = linein(CFGFile)
        ok = _PortWrite(PH,Zeile)
        I = I + 1
        Perc = I * 100 % J
        ok = VRSet("SL_PB","Percentile",Perc)
        ok = VRSet("EF_Perc","Value", Perc||'%')
        call rxnap 500
        MsgLine = _PortRead(PH)
        ok = VRMethod("LB_Console", "AddString", MsgLine) 
    end
    call rxnap 500
    ok = _PortWrite(PH,'CD')
    call lineout CFGFile
    ok = _PortClose(PH)    
    call ProgressBar_Close
    call _ButtonsEnable
    call PB_Reboot_Click
return

/*:VRX         ProgressBar_Fini
*/
ProgressBar_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         ProgressBar_Init
*/
ProgressBar_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         Quit
*/
Quit:
    call _INIWrite
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         TM_AutoClose_Trigger
*/
TM_AutoClose_Trigger: 
    if VRGet("CB_AutoClose","set") then call Quit
        else ok = VRSEt("TM_AutoClose","Enabled",  0)
return

