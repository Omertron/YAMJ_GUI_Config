#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Comment=Allows you to create the required library file for YAMJ. Will also generate a CMD file for one click running of your jukebox.
#AutoIt3Wrapper_Res_Description=YAMJ GUI Config
#AutoIt3Wrapper_Res_Fileversion=0.2
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
Global $mTitle = "YAMJ GUI Config v0.2"
Global $mSubTitle = "Download from http://omertron.com/pch/YAMJ_GUI_Config"
Global $mSettingsFile = "YAMJ GUI Config.ini"

; Main window dimensions
Global $mWidth = 440, $mHeight = 265, $mLeft = 100, $mTop = 100, $mWindow = 0

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
	
	; Create the PC location control including the directory search button
	GUICtrlCreateLabel("Location of your movie directory to scan:", 10, 5)
	$VIDEO_DIR = GUICtrlCreateInput("C:\", 10, 20, 310, 20)
	$BTNDIR = GUICtrlCreateButton("S&elect Dir", $mWidth - 110, 17, 100)
	GUICtrlSetTip(-1, "Choose the directory on your PC")
	
	; Create the NMT Path group
	GUICtrlCreateGroup("NMT Path", 10, 50, 150, 110)
	$nmtUSB = GUICtrlCreateRadio("USB", 20, 70, 100, 20)
	$nmtNetwork = GUICtrlCreateRadio("Network Path", 20, 90, 100, 20)
	$nmtHardDisk = GUICtrlCreateRadio("NMT Hard Disk", 20, 110, 100, 20)
	$nmtLocalPC = GUICtrlCreateRadio("Local PC", 20, 130, 100, 20)
	
	; Create the NMT Path controls
	GUICtrlCreateLabel("NMT Path:  (WARNING: Edit this only if you know what you are doing)", 10, 170, $mWidth - 20)
	$NMT_PATH = GUICtrlCreateInput("Select an option above", 10, 185, $mWidth - 20, 20)
	
	; Create the ADD button
	$BTNADD = GUICtrlCreateButton("&Add", 10, $mHeight - 50, 100)
	GUICtrlSetState($BTNADD, $GUI_DISABLE)
	GUICtrlSetTip($BTNADD, "Add the selection to the library file")
	
	; Create the SAVE button
	$BTNSAVE = GUICtrlCreateButton("&Save", 120, $mHeight - 50, 100)
	GUICtrlSetState($BTNSAVE, $GUI_DISABLE)
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
				GUICtrlSetData($NMT_PATH, "file:///opt/sybhttpd/localhost.drives/USB_DRIVE_A-1/" & stripPath(GUICtrlRead($VIDEO_DIR)))
				GUICtrlSetState($BTNADD, $GUI_ENABLE)
				
			Case $MSG = $nmtNetwork
				getNmtShare()
				
			Case $MSG = $nmtHardDisk
				deleteRightOptionGroup()
				GUICtrlSetData($NMT_PATH, "file:///opt/sybhttpd/localhost.drives/HARD_DISK/" & stripPath(GUICtrlRead($VIDEO_DIR)))
				GUICtrlSetState($BTNADD, $GUI_ENABLE)
				
			Case $MSG = $nmtLocalPC
				deleteRightOptionGroup()
				GUICtrlSetData($NMT_PATH, "file:///" & cleanPath(GUICtrlRead($VIDEO_DIR)))
				GUICtrlSetState($BTNADD, $GUI_ENABLE)
				
			Case $MSG = $otherOpt1 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt1)
				generateNMTPath(1)
			Case $MSG = $otherOpt2 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt2)
				generateNMTPath(2)
			Case $MSG = $otherOpt3 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt3)
				generateNMTPath(3)
			Case $MSG = $otherOpt4 And $mRightOptionGroup <> 0 And GUICtrlRead($otherOpt4)
				generateNMTPath(4)
		EndSelect
	WEnd
EndFunc   ;==>_Main

;--------------------------------------------------

Func cleanPath($cpPath)
	; tidy up the passed path, replacing \ with / and adding a / to the end if needed
	$cpPath = StringReplace($cpPath, "\", "/")
	
	If (StringLen($cpPath) > 0) And (StringRight($cpPath, 1) <> "/") Then
		$cpPath = $cpPath & "/"
	EndIf
	
	Return $cpPath
EndFunc   ;==>cleanPath

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

Func generateNMTPath($gnpOption)
	$gnpSharePath = ""
	Select
		Case $gnpOption = 1
			$gnpSharePath = GUICtrlRead($otherOpt1, 1)
			GUICtrlSetState($otherOpt2, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt3, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt4, $GUI_UNCHECKED)
		Case $gnpOption = 2
			$gnpSharePath = GUICtrlRead($otherOpt2, 1)
			GUICtrlSetState($otherOpt1, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt3, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt4, $GUI_UNCHECKED)
		Case $gnpOption = 3
			$gnpSharePath = GUICtrlRead($otherOpt3, 1)
			GUICtrlSetState($otherOpt1, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt2, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt4, $GUI_UNCHECKED)
		Case $gnpOption = 4
			$gnpSharePath = GUICtrlRead($otherOpt4, 1)
			GUICtrlSetState($otherOpt1, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt2, $GUI_UNCHECKED)
			GUICtrlSetState($otherOpt3, $GUI_UNCHECKED)
	EndSelect
	
	GUICtrlSetState($BTNADD, $GUI_ENABLE)
	$gnpSubPath = stripPath(GUICtrlRead($VIDEO_DIR))
	GUICtrlSetData($NMT_PATH, "file:///opt/sybhttpd/localhost.drives/NETWORK_SHARE/" & $gnpSharePath & "/" & $gnpSubPath)
	Return
EndFunc   ;==>generateNMTPath

;--------------------------------------------------

Func getNmtShare()
	Dim $gnsArray1[10]
	Dim $gnsArray2[10]
	Dim $gnsArray3[10]
	Dim $gnsArray4[10]
	$gnsFilename = "YAMJ_GUI_Config_Share.txt"

	If $YAMJ_skipNMTcheck = "False" Then
		$YAMJ_nmtIPAddress = InputBox("Network Media Tank IP Address", "Please type in the IP Address of your NMT and click OK", $YAMJ_nmtIPAddress, "", 300, Default)
		If @error > 0 Then
			MsgBox(16, $mTitle, "Error connecting to the IP Address" & @CRLF & $YAMJ_nmtIPAddress)
			Exit
		EndIf
	EndIf
	$gnsNmtFile = "http://" & $YAMJ_nmtIPAddress & ":8883/network_share.html"
	InetGet($gnsNmtFile, $gnsFilename, 1, 0)
	$gnsFile = FileOpen($gnsFilename, 0)
	If $gnsFile = -1 Then
		MsgBox(16, $mTitle, "Unable to save information to temporary file.")
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
		$mRightOptionGroup = GUICtrlCreateGroup("Network Shares", 170, 50, $mWidth - 180, 110)
		If $gnsShare1 <> "" Then $otherOpt1 = GUICtrlCreateRadio($gnsShare1, 180, 70, 100, 20)
		If $gnsShare2 <> "" Then $otherOpt2 = GUICtrlCreateRadio($gnsShare2, 180, 90, 100, 20)
		If $gnsShare3 <> "" Then $otherOpt3 = GUICtrlCreateRadio($gnsShare3, 180, 110, 100, 20)
		If $gnsShare4 <> "" Then $otherOpt4 = GUICtrlCreateRadio($gnsShare4, 180, 130, 100, 20)
	EndIf
EndFunc   ;==>getNmtShare

;--------------------------------------------------

Func libraryAdd($laVideoPath, $laNMTPath)
	; Enable the save button now we have something to save
	GUICtrlSetState($BTNSAVE, $GUI_ENABLE)
	
	; Disable the add button again until there's something to add
	GUICtrlSetState($BTNADD, $GUI_DISABLE)

	MsgBox(16, $mTitle, "Added to the library:" & @CRLF & "Video Path: " & $laVideoPath & @CRLF & "Nmtpath: " & $laNMTPath)
	
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
	
	$slFileCMD = FileOpen("My_YAMJ.cmd", 2)
	If $slFileCMD = -1 Then
		MsgBox(16, "Error", "Error saving the command file")
		Return
	Else
		FileWriteLine($slFileCMD, "@Echo OFF")
		FileWriteLine($slFileCMD, StringLeft($slPath, 2))
		If StringInStr($slPath, " ") Then
			FileWriteLine($slFileCMD, "CD """ & StringRight($slPath, StringLen($slPath) - 2) & """")
		Else
			FileWriteLine($slFileCMD, "CD " & StringRight($slPath, StringLen($slPath) - 2))
		EndIf
		FileWriteLine($slFileCMD, "moviejukebox My_Library.xml -o " & $slVideoPath)
		FileWriteLine($slFileCMD, "exit")
		FileClose($slFileCMD)
	EndIf
	
	$slFileLib = FileOpen("My_Library.xml", 2)
	If $slFileLib = -1 Then
		FileClose($slFileCMD)
		MsgBox(16, "Error", "Error saving the library file")
		Return
	Else
		FileWriteLine($slFileLib, "<!-- Library file generated by Omertron's GUI Config -->")
		FileWriteLine($slFileLib, "<!-- http://omertron.com/pch/YAMJ_GUI_Config -->")
		FileWriteLine($slFileLib, "")
		FileWriteLine($slFileLib, "<libraries>")
		
		For $lsLoop = 0 To $LibraryArrayCounter - 1
			FileWriteLine($slFileLib, "  <library>")
			FileWriteLine($slFileLib, "    <path>" & $LibraryArray[$lsLoop][0] & "</path>")
			FileWriteLine($slFileLib, "    <nmtpath>" & $LibraryArray[$lsLoop][1] & "</nmtpath>")
			FileWriteLine($slFileLib, "    <exclude name=""sample,tmp/,temp/""/>")
			FileWriteLine($slFileLib, "  </library>")
			FileWriteLine($slFileLib, "")
		Next
		
		FileWriteLine($slFileLib, "</libraries>")
		FileClose($slFileLib)
	EndIf

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

Func SetScanDir()
	$ssdScanDir = FileSelectFolder("Select the media folder to scan", "", 2, GUICtrlRead($VIDEO_DIR))
	If $ssdScanDir <> "" Then
		GUICtrlSetData($VIDEO_DIR, $ssdScanDir)
		; Clear the selections to ensure the path is clean
		GUICtrlSetData($NMT_PATH, "Scan dir changed, please select an option above")
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
		$YAMJ_nmtIPAddress = "192.168.2.100"
		$YAMJ_skipNMTcheck = False
		IniWrite($srFilename, "Settings", "NMTIP", $YAMJ_nmtIPAddress)
		IniWrite($srFilename, "Settings", "SkipNMTcheck", $YAMJ_skipNMTcheck)
	EndIf
EndFunc   ;==>settingsRead

;--------------------------------------------------

Func stripPath($spPath)
	$spPath = cleanPath($spPath)
	
	If $spPath = "" Then
		$spPath = ""
	ElseIf StringLeft($spPath, 1) = "/" Then
		$spPath = StringMid($spPath, 3)
	ElseIf StringMid($spPath, 2, 1) = ":" Then
		If StringLen($spPath) > 3 Then
			$spPath = StringMid($spPath, 4)
		Else
			$spPath = ""
		EndIf
	EndIf
	
	Return $spPath
EndFunc   ;==>stripPath

;--------------------------------------------------

Func uncheckOptions()
	GUICtrlSetState($nmtUSB, $GUI_UNCHECKED)
	GUICtrlSetState($nmtHardDisk, $GUI_UNCHECKED)
	GUICtrlSetState($nmtLocalPC, $GUI_UNCHECKED)
	GUICtrlSetState($nmtNetwork, $GUI_UNCHECKED)
EndFunc   ;==>uncheckOptions