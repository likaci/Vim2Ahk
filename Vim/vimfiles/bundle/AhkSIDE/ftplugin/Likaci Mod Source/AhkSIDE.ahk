#NoEnv
;#NoTrayIcon
#SingleInstance force
;#SingleInstance ignore
SendMode Input
SetWorkingDir %A_ScriptDir%

; COM interface of Vim {{{
; oVim.Eval("expr")
; oVim.SendKeys("Key Sequence") '<C-x>' is valid.
; oVim.SetForeground()
; oVim.GetHwnd()
; }}}

; 'How to manipulate multiple Vim ?'
oVim := ComObjActive("Vim.Application")

; AhkChm_Idx.txt is made from 'idx.hhk'
; "idx.hhk" is extracted from 'AutoHotkey_L.chm'.
FileRead tmp,%A_ScriptDir%\Ahk_Chm_Idx.txt

AhkIdx := {}
loop Parse,tmp,`n
{
	StringSplit tmp,A_LoopField,`,
	AhkIdx[tmp1]:= tmp2
}
tmp := tmp0 = tmp1 = tmp2 = ""

AhkChm := oVim.Eval("g:AhkSIDE_AhkChm")

hVim := oVim.GetHwnd()

; Setup Hotkey
Hotkey IfWinActive,ahk_id %hVim%
Hotkey % oVim.Eval("g:AhkSIDE_hk_in_Help"),Help,On
Hotkey % oVim.Eval("g:AhkSIDE_hk_in_RunScript"),RunScript,On
Hotkey % oVim.Eval("g:AhkSIDE_hk_in_StopScript"),StopScript,On

WinWaitClose ahk_id %hVim%
ExitApp

; Help {{{
Help:
	if ( hVim = WinExist()) && ( oVim.Eval("&filetype") = "autohotkey" ) && oVim.Eval("mode()") ~= "^n|i"
	{
		OutputDebug % cword := oVim.Eval("Ahk_cword()")

		; Check if chm exists.
		IfWinNotExist AutoHotkey 中文帮助 ahk_class HH Parent
		{
			Run %AhkChm%
			WinWait AutoHotkey 中文帮助 ahk_class HH Parent
			Sleep 100
		}
		If AhkIdx[cword]
		{
		;以下十八行加末尾的函数参照自cando
		WinActivate AutoHotkey 中文帮助 ahk_class HH Parent
		ProperClick("SysTabControl321")
		SendMessage 0x130C,0,, SysTabControl321,AutoHotkey 中文帮助 ahk_class HH Parent
		ProperClick("SysTabControl321")
		Sleep,100
		StringReplace,直接打开,CandySelected,#,_
		Ahk跳转的地址:= AhkIdx[cword]
		Send !gu
		Loop 3
			IfWinNotActive Ahk_Class #32770  ; Is it still searching?
				Sleep 100
		IfWinActive Ahk_Class #32770  ; Error dialog
		{
			ControlSetText,edit1,%Ahk跳转的地址%
			sleep,10
			send,{enter}
		}

		;以下四行为原版		
		;	ControlGet hIESvr,Hwnd,,Internet Explorer_Server1
			; mk:@MSITStore:"Path_Of_AutoHotkey_L.chm"::/"Path_In_Chm"
		;	HHLoadURL("mk:@MSITStore:" . AhkChm . "::/" . AhkIdx[cword],hIESvr)
		;	WinActivate
		}
	}
	else
	{
		hk := RegExReplace(A_ThisHotkey,"i)F([1-9]|1[0-2])|space|enter|tab|ins(ert)?|del(ete)?|home|end|capslock|numlock","{$0}")
		Send %hk%
	}
	return

	ProperClick(ControlName)
	{
		BlockInput MouseMove  ; Disable Mouse movement to prevent user interaction
		ControlClick %ControlName%, Ahk_Class HH Parent, , , , NA  ; Perform the Click (NA Is required!)
		BlockInput MouseMoveOff  ; Enable Mouse movement
	}
; }}}
; Run / Stop Script {{{
RunScript:
StopScript:
	DetectHiddenWindows On
	if (hVim != WinExist() ||  oVim.Eval("&filetype") != "autohotkey" )
	{
		hk := RegExReplace(A_ThisHotkey,"i)F([1-9]|1[0-2])|space|enter|tab|ins(ert)?|del(ete)?|home|end|capslock|numlock","{$0}")
		Send %hk%
		return
	}
	IfEqual A_ThisLabel,RunScript
	{
		; Only work in "Normal" or "Insert" mode.
		if (mode := oVim.Eval("mode()")) ~= "^n|i"
		{
			oVim.Eval("AhkRunStopScript(1)")
			; Solve the cursor problem in "Insert" mode.
			`(mode = "n") ? oVim.SendKeys("<C-\><C-n>")
						  :	oVim.SendKeys(oVim.Eval("strlen(getline('.')) < col('.')") ? "<C-o>a" : "<C-o>i")

			; Run Script and get ErrStdOut {{{
			cmdline := oVim.Eval("g:AhkSIDE_AhkExe") . " /ErrorStdOut " . oVim.Eval("g:AhkRunningFile")
			cwd := oVim.Eval("getcwd()")
			ErrStdOut := ""

			ConsoleAppHandle := ConsoleApp_Run(cmdline, cwd)
			Loop
			{
				ConsoleAppStillRunning := ConsoleApp_GetStdOut(ConsoleAppHandle, ErrStdOut, BytesAppended, ExitCode)
				if (!ConsoleAppStillRunning)
					break
				sleep 150
			}
			ConsoleApp_CloseHandle(ConsoleAppHandle)
			ErrStdOut := "`n" . ErrStdOut ; }}}

			StringReplace ErrStdOut,ErrStdOut,`r,,All
			AhkInfo := oVim.Eval("g:AhkInfo")
			StringReplace,AhkInfo,AhkInfo,`nRunning,,All
			oVim.Eval("AhkRunStopScript(0,'" . AhkInfo . "`nExitCode: " . ExitCode . ErrStdOut . "')")
			;oVim.Eval("AhkRunStopScript(0,'" . oVim.Eval("g:AhkInfo") . "`nExitCode: " . ExitCode . ErrStdOut . "')")
			; Solve the cursor problem in "Insert" mode.
			`(mode = "n") ? oVim.SendKeys("<C-\><C-n>")
						  :	oVim.SendKeys(oVim.Eval("strlen(getline('.')) < col('.')") ? "<C-o>a" : "<C-o>i")
		}
	}
	else ; Stop script
	{
		if oVim.Eval("exists('g:AhkRunningFile')")
		&& WinExist(oVim.Eval("g:AhkRunningFile") " ahk_class AutoHotkey")
			WinClose ; The ConsoleApp_RunWaitScript() will continue the subsequent steps.
	}
	return
; }}}
HHLoadURL(sURL,hIESvr) ; {{{
{
	COM_CoInitialize()
	DllCall("SendMessageTimeout", "Uint", hIESvr
								, "Uint", DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
								, "Uint", 0 , "Uint", 0 , "Uint", 2
								, "Uint", 1000 , "UintP", lResult)
	DllCall("oleacc\ObjectFromLresult", "Uint", lResult
									  , "Uint", COM_GUID4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}")
									  , "int", 0 , "UintP", pdoc)
	IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	pweb := COM_QueryService(pdoc,IID_IWebBrowserApp,IID_IWebBrowserApp)
	COM_Invoke(pweb, "Navigate", sURL)
	COM_Release(pweb)
	COM_Release(pdoc)
	COM_CoUninitialize()
	Return
}
; }}}

#include Lib\ConsoleApp.ahk
#include Lib\COM.ahk
