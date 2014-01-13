#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=YAMJ GUI Config v0.3.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Allows you to create the required library file for YAMJ. Will also generate a CMD file for one click running of your jukebox.
#AutoIt3Wrapper_Res_Description=YAMJ GUI Config
#AutoIt3Wrapper_Res_Fileversion=0.3
#AutoIt3Wrapper_Res_LegalCopyright=(c) Omertron 2008
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/sf
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.2.12.1
	Author:         Stuart Boston
	
	Script Function:
	Allows you to create the required library file for YAMJ.
	Will also generate a CMD file for one click running of your jukebox.
	
	To do:
	Ability to specify output path for the jukebox
	Ability to scan multiple pages of the network share from the PCH
#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <String.au3>
#include <Array.au3>

; Title variables to be used by the program
Global $mTitle = "YAMJ GUI Config v0.3"
Global $mSubTitle = "Download from http://omertron.com/pch/YAMJ_GUI_Config"
Global $mSettingsFile = "YAMJ GUI Config.ini"

; Main window dimensions
Global $mWidth = 440, $mHeight = 365, $mLeft = 100, $mTop = 100, $mWindow = 0

; Button / GUI controls
Global $mRightOptionGroup = 0, $otherOpt1, $otherOpt2, $otherOpt3, $otherOpt4
Global $MSG, $VIDEO_DIR, $BTNADD, $BTNSAVE, $BTNEXIT, $BTNDIR, $NMT_PATH
Global $nmtUSB, $nmtNetwork, $nmtHardDisk, $nmtLocalPC, $nmtLightTPD

; Other global variables
Global $LibraryArray[10][2]
Global $LibraryArrayCounter = 0
Global $GUILibraryCounter

; INI Variables
Global $YAMJ_nmtIPAddress
Global $YAMJ_skipNMTcheck

_Main()

Func _Main()
	settingsRead($mSettingsFile)
	
	; Create the main GUI
	GUICreate($mTitle, $mWidth, $mHeight, $mLeft, $mTop)
	
	; Create Logo
	FileInstall("H:\YAMJ\Development\yamj_logo.jpg", @ScriptDir & "\yamj_logo.jpg", 1)
	GUICtrlCreatePic("yamj_logo.jpg", 0, 0, 440, 100)
	FileDelete("yamj_logo.jpg")
	
	; Create the PC location control including the directory search button
	GUICtrlCreateLabel("Location of your movie directory to scan:", 10, 105)
	$VIDEO_DIR = GUICtrlCreateInput("C:\", 10, 120, 310, 20)
	$BTNDIR = GUICtrlCreateButton("S&elect Dir", $mWidth - 110, 117, 100)
	GUICtrlSetTip(-1, "Choose the directory on your PC")
	
	; Create the NMT Path group
	GUICtrlCreateGroup("NMT Path", 10, 150, 150, 110)
	$nmtUSB = GUICtrlCreateRadio("USB", 20, 170, 100, 20)
	$nmtNetwork = GUICtrlCreateRadio("Network Path", 20, 190, 100, 20)
	$nmtHardDisk = GUICtrlCreateRadio("NMT Hard Disk", 20, 210, 100, 20)
	$nmtLocalPC = GUICtrlCreateRadio("Run from my PC", 20, 230, 100, 20)
	GUICtrlSetTip(-1, "Note: This jukebox will NOT work on the NMT")
	
	; Create the NMT Path controls
	GUICtrlCreateLabel("NMT Path:  (WARNING: Edit this only if you know what you are doing)", 10, 270, $mWidth - 20)
	$NMT_PATH = GUICtrlCreateInput("Select an option above", 10, 285, $mWidth - 20, 20)
	
	; Create the ADD button
	$BTNADD = GUICtrlCreateButton("&Add", 10, $mHeight - 50, 100)
	setButtonAdd(False)
	GUICtrlSetTip($BTNADD, "Add the selection to the library file")
	
	; Create the SAVE button
	$BTNSAVE = GUICtrlCreateButton("&Save", 120, $mHeight - 50, 100)
	setButtonSave(False)
	GUICtrlSetTip($BTNSAVE, "Save the library file")
	
	; Create the library counter
	$GUILibraryCounter = GUICtrlCreateLabel("0 Libraries Set", 230, $mHeight - 43, 100)

	; Create the EXIT button
	$BTNEXIT = GUICtrlCreateButton("&Exit", $mWidth - 110, $mHeight - 50, 100)
	GUICtrlSetTip(-1, "Quit the program")
	
	GUICtrlCreateLabel($mSubTitle, 10, $mHeight - 15, $mWidth - 20, 20, $SS_CENTER)

	; Display the GUI
	GUISetState()

	; Run the GUI until the dialog is closed
	While 1
		$MSG = GUIGetMsg()
		Select
			Case $MSG = $GUI_EVENT_CLOSE Or $MSG = $BTNEXIT
				Exit
				
			Case $MSG = $BTNADD
				libraryAdd(GUICtrlRead($VIDEO_DIR), GUICtrlRead($NMT_PATH))
				
			Case $MSG = $BTNSAVE
				librarySave(GUICtrlRead($VIDEO_DIR), GUICtrlRead($NMT_PATH))

			Case $MSG = $BTNDIR
				SetScanDir()
				
			Case $MSG = $nmtUSB
				deleteRightOptionGroup()
				GUICtrlSetData($NMT_PATH, calculateUSBpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)
				
			Case $MSG = $nmtNetwork
				getNmtShare()
				
			Case $MSG = $nmtHardDisk
				deleteRightOptionGroup()
				GUICtrlSetData($NMT_PATH, calculateNHDpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)
				
			Case $MSG = $nmtLocalPC
				deleteRightOptionGroup()
				GUICtrlSetData($NMT_PATH, calculateLPCpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)
				
			Case $MSG = $otherOpt1 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt1)
				GUICtrlSetData($NMT_PATH, calculateNMTPath(1, GUICtrlRead($VIDEO_DIR)))
			Case $MSG = $otherOpt2 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt2)
				GUICtrlSetData($NMT_PATH, calculateNMTPath(2, GUICtrlRead($VIDEO_DIR)))
			Case $MSG = $otherOpt3 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt3)
				GUICtrlSetData($NMT_PATH, calculateNMTPath(3, GUICtrlRead($VIDEO_DIR)))
			Case $MSG = $otherOpt4 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt4)
				GUICtrlSetData($NMT_PATH, calculateNMTPath(4, GUICtrlRead($VIDEO_DIR)))
		EndSelect
	WEnd
EndFunc   ;==>_Main

;--------------------------------------------------

Func calculateLPCpath($cpVideoPath)
	$cpVideoPath = pathClean($cpVideoPath)
	
	If StringLeft($cpVideoPath, 2) = "//" Then
		$cpVideoPath = StringRight($cpVideoPath, StringLen($cpVideoPath) - 2)
	EndIf
	
	$cpVideoPath = "file:///" & $cpVideoPath
	
	Return $cpVideoPath
EndFunc   ;==>calculateLPCpath

;--------------------------------------------------

Func calculateNHDpath($cpVideoPath)
	$cpVideoPath = pathStrip($cpVideoPath)
	$cpVideoPath = "file:///opt/sybhttpd/localhost.drives/HARD_DISK/" & $cpVideoPath
	Return $cpVideoPath
EndFunc   ;==>calculateNHDpath

;--------------------------------------------------

Func calculateNMTPath($cpOption, $cpVideoPath)
	$cpShareName = ""
	Select
		Case $cpOption = 1
			$cpShareName = GUICtrlRead($otherOpt1, 1)
			GUICtrlSetState($otherOpt2, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt3, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt4, $GUI_UNCHECKED)
		Case $cpOption = 2
			$cpShareName = GUICtrlRead($otherOpt2, 1)
			GUICtrlSetState($otherOpt1, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt3, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt4, $GUI_UNCHECKED)
		Case $cpOption = 3
			$cpShareName = GUICtrlRead($otherOpt3, 1)
			GUICtrlSetState($otherOpt1, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt2, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt4, $GUI_UNCHECKED)
		Case $cpOption = 4
			$cpShareName = GUICtrlRead($otherOpt4, 1)
			GUICtrlSetState($otherOpt1, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt2, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt3, $GUI_UNCHECKED)
	EndSelect
	
	setButtonAdd(True)
	$cpVideoPath = "file:///opt/sybhttpd/localhost.drives/NETWORK_SHARE/" & $cpShareName & "/" & pathStrip($cpVideoPath)
	
	Return $cpVideoPath
EndFunc   ;==>calculateNMTPath

;--------------------------------------------------

Func calculateUSBpath($cpVideoPath)
	$cpVideoPath = pathStrip($cpVideoPath)
	$cpVideoPath = "file:///opt/sybhttpd/localhost.drives/USB_DRIVE_A-1/" & $cpVideoPath
	Return $cpVideoPath
EndFunc   ;==>calculateUSBpath

;--------------------------------------------------

Func deleteRightOptionGroup()
	GUICtrlDelete($mRightOptionGroup)
	GUICtrlDelete($otherOpt1)
	GUICtrlDelete($otherOpt2)
	GUICtrlDelete($otherOpt3)
	GUICtrlDelete($otherOpt4)
	$mRightOptionGroup = 0
EndFunc   ;==>deleteRightOptionGroup

;--------------------------------------------------

Func getNmtShare()
	Dim $gnsArray1[10]
	Dim $gnsArray2[10]
	Dim $gnsArray3[10]
	Dim $gnsArray4[10]
	$gnsFilename = "YAMJ_GUI_Config_Share.txt"
	
	$gnsTempIP = $YAMJ_nmtIPAddress

	If $YAMJ_skipNMTcheck <> "True" Then
		$YAMJ_nmtIPAddress = InputBox("Network Media Tank IP Address", "Please type in the IP Address of your NMT and click OK", $YAMJ_nmtIPAddress, "", 300, Default)
		If @error > 0 Then
			MsgBox(16, $mTitle, "Error connecting to the IP Address" & @CRLF & $YAMJ_nmtIPAddress)
			Return
		Else
			If $gnsTempIP <> $YAMJ_nmtIPAddress Then
				; Save the changed IP address
				IniWrite($mSettingsFile, "Settings", "NMTIP", $YAMJ_nmtIPAddress)
			EndIf
		EndIf
	EndIf
	
	$gnsNmtFile = "http://" & $YAMJ_nmtIPAddress & ":8883/network_share.html"
	InetGet($gnsNmtFile, $gnsFilename, 1, 0)
	$gnsFile = FileOpen($gnsFilename, 0)
	If $gnsFile = -1 Then
		MsgBox(16, $mTitle, "Unable to save information from the " & @CRLF & " NMT to a temporary file.")
		Return
	EndIf
	
	$gnsFileRead = FileRead($gnsFile, 6500)
	FileClose($gnsFile)
	FileDelete($gnsFilename)
	
	$gnsArray1 = _StringBetween($gnsFileRead, "1.&nbsp;", "</td>")
	If @error = 1 Then
		$gnsShare1 = ""
	Else
		$gnsShare1 = $gnsArray1[0]
	EndIf
	$gnsArray2 = _StringBetween($gnsFileRead, "2.&nbsp;", "</td>")
	If @error = 1 Then
		$gnsShare2 = ""
	Else
		$gnsShare2 = $gnsArray2[0]
	EndIf
	
	$gnsArray3 = _StringBetween($gnsFileRead, "3.&nbsp;", "</td>")
	If @error = 1 Then
		$gnsShare3 = ""
	Else
		$gnsShare3 = $gnsArray3[0]
	EndIf
	$gnsArray4 = _StringBetween($gnsFileRead, "4.&nbsp;", "</td>")
	If @error = 1 Then
		$gnsShare4 = ""
	Else
		$gnsShare4 = $gnsArray4[0]
	EndIf

	If $gnsShare1 <> "" Or $gnsShare2 <> "" Or $gnsShare3 <> "" Or $gnsShare4 <> "" Then
		; Create the other options group
		$mRightOptionGroup = GUICtrlCreateGroup("Network Shares", 170, 150, $mWidth - 180, 110)
		If $gnsShare1 <> "" Then $otherOpt1 = GUICtrlCreateRadio($gnsShare1, 180, 170, 100, 20)
		If $gnsShare2 <> "" Then $otherOpt2 = GUICtrlCreateRadio($gnsShare2, 180, 190, 100, 20)
		If $gnsShare3 <> "" Then $otherOpt3 = GUICtrlCreateRadio($gnsShare3, 180, 210, 100, 20)
		If $gnsShare4 <> "" Then $otherOpt4 = GUICtrlCreateRadio($gnsShare4, 180, 230, 100, 20)
	EndIf
EndFunc   ;==>getNmtShare

;--------------------------------------------------

Func libraryAdd($laVideoPath, $laNMTPath)
	; Enable the save button now we have something to save
	setButtonSave(True)
	
	; Disable the add button again until there's something to add
	setButtonAdd(False)

	MsgBox(64, $mTitle, "Added to the library:" & @CRLF & "Video Path: " & $laVideoPath & @CRLF & "Nmtpath: " & $laNMTPath)
	
	Dim $lArray[1][2]
	$LibraryArray[$LibraryArrayCounter][0] = $laVideoPath
	$LibraryArray[$LibraryArrayCounter][1] = $laNMTPath
	$LibraryArrayCounter = $LibraryArrayCounter + 1
	
	If $LibraryArrayCounter = 1 Then
		GUICtrlSetData($GUILibraryCounter, "1 library")
	Else
		GUICtrlSetData($GUILibraryCounter, $LibraryArrayCounter & " libraries")
	EndIf
	;_ArrayDisplay($LibraryArray)

	GUICtrlSetData($NMT_PATH, "Saved. Please set additional options above")
	uncheckOptions()
	Return
EndFunc   ;==>libraryAdd

;--------------------------------------------------

Func librarySave($slVideoPath, $slNMTPath)
	; Let see if we can find a default path, otherwise revert to the base dir.
	If FileExists(@WorkingDir & "\MovieJukebox.bat") Then
		$slPath = @WorkingDir
	ElseIf FileExists("C:\YAMJ\MovieJukebox.bat") Then
		$slPath = "C:\YAMJ"
	ElseIf FileExists("D:\YAMJ\MovieJukebox.bat") Then
		$slPath = "D:\YAMJ"
	Else
		$slPath = ""
	EndIf
	
	$slExitLoop = False
	Do
		$slPath = FileSelectFolder("Select your YAMJ Install Directory" & @CRLF & "This should be where your 'MovieJukebox.bat' file is located", "", 2, $slPath)
		If $slPath = "" Then
			Return
		EndIf

		If FileExists($slPath & "\moviejukebox.bat") Then
			FileChangeDir($slPath)
			$slExitLoop = True
		Else
			$slAnswer = MsgBox(32 + 4, $mTitle, "MovieJukebox.bat does not seem to be in this directory." & @CRLF & "Are you sure you want to save here?")
			If $slAnswer = 6 Then
				FileChangeDir($slPath)
				$slExitLoop = True
			EndIf
		EndIf
	Until $slExitLoop = True
	
	; Write the command file
	writeCMD("My_YAMJ.cmd", $slPath, $slVideoPath)
	
	; Write the library file
	writeLibrary("My_Library.xml", $slPath, $slVideoPath)

	$slAnswer = MsgBox(32 + 4, "File Save", "Library file saved to - " & $slPath & @CRLF & "Do you want to open this folder now?")
	If $slAnswer = 6 Then
		Run("Explorer.exe " & $slPath)
	EndIf
	
	; Clear the saved data
	uncheckOptions()
	Dim $LibraryArray[10][2]
	$LibraryArrayCounter = 0
EndFunc   ;==>librarySave

;--------------------------------------------------

Func pathClean($pcPath)
	; tidy up the passed path, replacing \ with / and adding a / to the end if needed
	$pcPath = StringReplace($pcPath, "\", "/")
	
	If (StringLen($pcPath) > 0) And (StringRight($pcPath, 1) <> "/") Then
		$pcPath = $pcPath & "/"
	EndIf
	
	Return $pcPath
EndFunc   ;==>pathClean

;--------------------------------------------------

Func pathStrip($psPath)
	$psPath = pathClean($psPath)
	
	If $psPath = "" Then
		$psPath = ""
	ElseIf StringLeft($psPath, 2) = "//" Then
		; Strip the UNC path (\\SERVER\Share\) from the path
		$psPos = StringInStr($psPath, "/", 0, 4)
		If $psPos > 0 Then $psPath = StringMid($psPath, $psPos + 1)
	ElseIf StringMid($psPath, 2, 1) = ":" Then
		If StringLen($psPath) > 3 Then
			$psPath = StringMid($psPath, 4)
		Else
			$psPath = ""
		EndIf
	EndIf
	
	Return $psPath
EndFunc   ;==>pathStrip

;--------------------------------------------------

Func setButtonAdd($sbEnable)
	; Enable or disable the add button
	If $sbEnable = True Then
		GUICtrlSetState($BTNADD, $GUI_ENABLE)
	Else
		GUICtrlSetState($BTNADD, $GUI_DISABLE)
	EndIf
EndFunc   ;==>setButtonAdd

;--------------------------------------------------

Func setButtonSave($sbEnable)
	; Enable or disable the save button
	If $sbEnable = True Then
		GUICtrlSetState($BTNSAVE, $GUI_ENABLE)
	Else
		GUICtrlSetState($BTNSAVE, $GUI_DISABLE)
	EndIf
EndFunc   ;==>setButtonSave

;--------------------------------------------------

Func SetScanDir()
	$ssdScanDir = FileSelectFolder("Select the media folder to scan", "", 2, GUICtrlRead($VIDEO_DIR))
	If $ssdScanDir <> "" Then
		GUICtrlSetData($VIDEO_DIR, $ssdScanDir)
		; Clear the selections to ensure the path is clean
		GUICtrlSetData($NMT_PATH, "Scan dir changed, please select an option above")
		setButtonAdd(False)
	EndIf
EndFunc   ;==>SetScanDir

;--------------------------------------------------

Func settingsRead($srFilename)
	If FileExists($srFilename) Then
		; INI file was found, so read the settings from there
		$YAMJ_nmtIPAddress = IniRead($srFilename, "Settings", "NMTIP", "192.168.2.100")
		$YAMJ_skipNMTcheck = IniRead($srFilename, "Settings", "SkipNMTcheck", "False")
	Else
		; No INI file was found, so create a new one
		IniWrite($srFilename, "Settings", "NMTIP", "192.168.2.100")
		IniWrite($srFilename, "Settings", "SkipNMTcheck", False)
		
		; Now Read the file to get the correct settings
		settingsRead($srFilename)
	EndIf
EndFunc   ;==>settingsRead

;--------------------------------------------------

Func uncheckOptions()
	GUICtrlSetState($nmtUSB, $GUI_UNCHECKED)
	GUICtrlSetState($nmtHardDisk, $GUI_UNCHECKED)
	GUICtrlSetState($nmtLocalPC, $GUI_UNCHECKED)
	GUICtrlSetState($nmtNetwork, $GUI_UNCHECKED)
EndFunc   ;==>uncheckOptions

;--------------------------------------------------

Func writeCMD($wcFilename, $wcPath, $wcVideoPath)
	$wcFileCMD = FileOpen($wcFilename, 2)
	If $wcFileCMD = -1 Then
		MsgBox(16, $mTitle, "Error saving the command file")
		Return
	Else
		FileWriteLine($wcFileCMD, "@Echo OFF")
		FileWriteLine($wcFileCMD, StringLeft($wcPath, 2))
		If StringInStr($wcPath, " ") Then
			FileWriteLine($wcFileCMD, "CD """ & StringRight($wcPath, StringLen($wcPath) - 2) & """")
		Else
			FileWriteLine($wcFileCMD, "CD " & StringRight($wcPath, StringLen($wcPath) - 2))
		EndIf
		FileWriteLine($wcFileCMD, "moviejukebox My_Library.xml -o " & $wcVideoPath)
		FileWriteLine($wcFileCMD, "pause")
		FileWriteLine($wcFileCMD, "exit")
		FileClose($wcFileCMD)
	EndIf
	Return
EndFunc   ;==>writeCMD

;--------------------------------------------------

Func writeLibrary($wlFilename, $wlPath, $wlVideoPath)
	$wlFileLib = FileOpen($wlFilename, 2)
	If $wlFileLib = -1 Then
		MsgBox(16, $mTitle, "Error saving the library file")
		Return
	Else
		FileWriteLine($wlFileLib, "<!-- Library file generated by Omertron's GUI Config -->")
		FileWriteLine($wlFileLib, "<!-- http://omertron.com/pch/YAMJ_GUI_Config -->")
		FileWriteLine($wlFileLib, "<!-- " & $mTitle & "-->")
		FileWriteLine($wlFileLib, "")
		FileWriteLine($wlFileLib, "<libraries>")
		FileWriteLine($wlFileLib, "")
		
		For $lsLoop = 0 To $LibraryArrayCounter - 1
			; if this is a UNC path, add the appropriate delimiters to the path
			If StringLeft($LibraryArray[$lsLoop][0], 2) = "\\" Then
				$LibraryArray[$lsLoop][0] = "\\" & $LibraryArray[$lsLoop][0]
			ElseIf StringLeft($LibraryArray[$lsLoop][0], 2) = "//" Then
				$LibraryArray[$lsLoop][0] = "//" & $LibraryArray[$lsLoop][0]
			EndIf
			
			FileWriteLine($wlFileLib, "  <library>")
			FileWriteLine($wlFileLib, "    <path>" & $LibraryArray[$lsLoop][0] & "</path>")
			FileWriteLine($wlFileLib, "    <nmtpath>" & $LibraryArray[$lsLoop][1] & "</nmtpath>")
			FileWriteLine($wlFileLib, "    <exclude name=""sample,tmp/,temp/""/>")
			FileWriteLine($wlFileLib, "  </library>")
			FileWriteLine($wlFileLib, "")
		Next
		
		FileWriteLine($wlFileLib, "</libraries>")
		FileClose($wlFileLib)
	EndIf

EndFunc   ;==>writeLibrary