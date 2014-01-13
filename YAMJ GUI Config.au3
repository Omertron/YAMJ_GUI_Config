#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=YAMJ GUI Config v0.6.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Allows you to create the required library file for YAMJ. Will also generate a CMD file for one click running of your jukebox.
#AutoIt3Wrapper_Res_Description=YAMJ GUI Config
#AutoIt3Wrapper_Res_Fileversion=0.6	; Note: Only have one decimal point otherwise it confuses the web check
#AutoIt3Wrapper_Res_LegalCopyright=(c) Omertron 2009
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/sf
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.2.12.1
	Author:         Stuart Boston
	
	Script Function:
	Allows you to create the required library file for YAMJ.
	Will also generate a CMD file for one click running of your jukebox.
	
	To do:
	- Create a log file of clicks for de-bugging
	- Update with option for scanning myiHome from the NMT
	- Ability to change the names of the output files
	- Ability to specify the moviejukebox.properties file
	
	Known issues:
	- None :-D
#ce ----------------------------------------------------------------------------

Opt('MustDeclareVars', 1)

#include <Array.au3>
#include <Date.au3>
#include <String.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; Title variables to be used by the program
Global $mVersion = "0.6"
Global $mTitle = "YAMJ GUI Config v" & $mVersion
Global $mWebURL = "http://mediaplayersite.com/YAMJ_GUI_Config"
Global $mSettingsFile = "YAMJ GUI Config.ini"

; Main window dimensions
Global $mWidth = 440, $mHeight = 440, $mLeft = 100, $mTop = 100, $mWindow = 0

; Button / GUI controls
Global $mRightOptionGroup = 0, $otherOpt1, $otherOpt2, $otherOpt3, $otherOpt4
Global $MSG, $VIDEO_DIR, $VIDEO_DIR_DECODE, $ADD_BTN, $SAVE_BTN, $EXIT_BTN
Global $VIDEO_BTN, $NMT_PATH, $WEBLINK, $JUKEBOX_DIR, $JUKEBOX_BTN, $USB_BTN, $NHD_BTN, $PATH_BTN
Global $nmtUSB, $nmtNetwork, $nmtHardDisk, $nmtLocalPC, $nmtLightTPD, $nmtModel

; Other global variables
Global $LibraryArray[10][3]
Global $LibraryArrayCounter = 0
Global $GUILibraryCounter
Global $WebVersion

; INI Variables
Global $YAMJ_nmtIPAddress, $YAMJ_skipNMTcheck, $YAMJ_skipWebcheck, $YAMJ_skipWarning, $YAMJ_nmtModel

_Main()

Func _Main()
	ProgressOn($mTitle, "Please wait, starting")
	ProgressSet(0, "Loading settings")
	settingsRead($mSettingsFile)
	Sleep(500)
	ProgressSet(50, "Checking web version")
	webVersion($mSettingsFile)
	ProgressSet(100, "Done")
	Sleep(500)
	ProgressOff()

	; Create the main GUI
	GUICreate($mTitle, $mWidth, $mHeight, $mLeft, $mTop)

	; Create Logo
	FileInstall("D:\YAMJ\Development\yamj_logo.jpg", @ScriptDir & "\yamj_logo.jpg", 1)
	GUICtrlCreatePic("yamj_logo.jpg", 0, 0, 440, 100)
	FileDelete("yamj_logo.jpg")

	; Create the NMT Model selection
	;GUICtrlCreateLabel("Select your NMT Model:", 10, 105, 125)
	;$nmtModel = GUICtrlCreateCombo("", 130, 102, 75)
	;GUICtrlSetData($nmtModel, "A1x0|C200|Other", $YAMJ_nmtModel)

	; Create the PC location control including the directory search button
	GUICtrlCreateLabel("Location of your movie directory to scan:", 10, 125)
	$VIDEO_DIR = GUICtrlCreateInput("C:\", 10, 140, 310, 20)
	$VIDEO_BTN = GUICtrlCreateButton("S&elect Dir", $mWidth - 110, 137, 100)
	GUICtrlSetTip(-1, "Choose the directory on your PC")
	$VIDEO_DIR_DECODE = GUICtrlCreateInput("C:\", 10, 165, $mWidth - 20, 20, $ES_READONLY);

	; Create the NMT Path group
	GUICtrlCreateGroup("My video files are on:", 10, 190, 200, 110)
	$nmtUSB = GUICtrlCreateRadio("a USB drive attached to the NMT", 20, 210)
	$nmtNetwork = GUICtrlCreateRadio("on a Network Path on the NMT", 20, 230)
	$nmtHardDisk = GUICtrlCreateRadio("on the NMT's Hard Disk", 20, 250)
	$nmtLocalPC = GUICtrlCreateRadio("Jukebox only for my PC", 20, 270)
	GUICtrlSetTip(-1, "Note: This jukebox will NOT work on the NMT")

	; Create the NMT Path controls
	GUICtrlCreateLabel("NMT Path:  (WARNING: Edit this only if you know what you are doing)", 10, 310, $mWidth - 20)
	$NMT_PATH = GUICtrlCreateInput("Select an option above", 10, 325, $mWidth - 20)

	$USB_BTN = GUICtrlCreateCombo("USB_DRIVE_A-1", 220, 205, 150, -1, $CBS_DROPDOWNLIST)
	GUICtrlSetData($USB_BTN, "USB_DRIVE_B-1|USB_DRIVE_C-1|USB_DRIVE_D-1")
	GUICtrlSetState($USB_BTN, $GUI_DISABLE)

	$PATH_BTN = GUICtrlCreateCombo("Network Path", 220, 230, 150, -1, $CBS_DROPDOWNLIST)
	GUICtrlSetState($PATH_BTN, $GUI_DISABLE)

	$NHD_BTN = GUICtrlCreateCombo("HARD_DISK", 220, 255, 150, -1, $CBS_DROPDOWNLIST)
	GUICtrlSetData($NHD_BTN, "SATA_DISK|SATA_DISK_A1|SATA_DISK_B1")
	GUICtrlSetState($NHD_BTN, $GUI_DISABLE)

	; Jukebox Output Directory
	GUICtrlCreateLabel("Location of where you want the jukebox to be stored:", 10, 350)
	$JUKEBOX_DIR = GUICtrlCreateInput("Please select a location -->", 10, 365, 310)
	$JUKEBOX_BTN = GUICtrlCreateButton("S&elect Dir", $mWidth - 110, 362, 100)

	; Create the ADD button
	$ADD_BTN = GUICtrlCreateButton("&Add", 10, $mHeight - 45, 100)
	setButtonAdd(False)
	GUICtrlSetTip($ADD_BTN, "Add the selection to the library file")

	; Create the SAVE button
	$SAVE_BTN = GUICtrlCreateButton("&Save", 120, $mHeight - 45, 100)
	setButtonSave(False)
	GUICtrlSetTip($SAVE_BTN, "Save the library file")

	; Create the library counter
	$GUILibraryCounter = GUICtrlCreateLabel("0 Library Entries", 230, $mHeight - 38, 100)

	; Create the EXIT button
	$EXIT_BTN = GUICtrlCreateButton("&Exit", $mWidth - 110, $mHeight - 45, 100)
	GUICtrlSetTip(-1, "Quit the program")

	If Number($WebVersion) > Number($mVersion) Then
		; Later version on the web
		$WEBLINK = GUICtrlCreateLabel("New version (" & $WebVersion & ") here - " & $mWebURL, 10, $mHeight - 15, $mWidth - 20, 20, $SS_CENTER)
		GUICtrlSetFont(-1, 8.5, 600) ; Bold
		GUICtrlSetColor(-1, 0xff0000) ; Red
	Else
		; Version is current
		$WEBLINK = GUICtrlCreateLabel("Downloaded from " & $mWebURL, 10, $mHeight - 15, $mWidth - 20, 20, $SS_CENTER)
	EndIf

	; Display the GUI
	GUISetState()

	; Run the GUI until the dialog is closed
	While 1
		$MSG = GUIGetMsg()
		Select
			Case $MSG = $GUI_EVENT_CLOSE Or $MSG = $EXIT_BTN
				Exit

			Case $MSG = $WEBLINK
				webLink($mWebURL)

			Case $MSG = $ADD_BTN
				libraryAdd(GUICtrlRead($VIDEO_DIR), GUICtrlRead($NMT_PATH))

			Case $MSG = $SAVE_BTN
				librarySave(GUICtrlRead($VIDEO_DIR), GUICtrlRead($NMT_PATH), GUICtrlRead($JUKEBOX_DIR))

			Case $MSG = $VIDEO_BTN
				toggleControls("NONE")
				setScanDir(True)

			Case $MSG = $JUKEBOX_BTN
				selectJukeboxDir()

			Case $MSG = $nmtUSB
				toggleControls("USB")
				setScanDir(False)
				GUICtrlSetData($NMT_PATH, calculateUSBpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)

			Case $MSG = $USB_BTN ; USB Combobox
				setScanDir(False)
				GUICtrlSetData($NMT_PATH, calculateUSBpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)

			Case $MSG = $nmtNetwork
				toggleControls("NETWORK")
				setScanDir(False)
				getNmtShare()
				GUICtrlSetData($NMT_PATH, calculateNMTPath(GUICtrlRead($VIDEO_DIR)))

			Case $MSG = $PATH_BTN ; NETWORK combobox
				setScanDir(False)
				GUICtrlSetData($NMT_PATH, calculateNMTPath(GUICtrlRead($VIDEO_DIR)))

			Case $MSG = $nmtHardDisk
				toggleControls("HD")
				setScanDir(False)
				GUICtrlSetData($NMT_PATH, calculateNHDpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)

			Case $MSG = $NHD_BTN; Do the HARDDISK drop down here
				setScanDir(False)
				GUICtrlSetData($NMT_PATH, calculateNHDpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)

			Case $MSG = $nmtLocalPC
				toggleControls("PC")
				setScanDir(False)
				MsgBox(64, $mTitle, "Note: This is used to create a jukebox that will" & @CRLF & "ONLY run on a PC." & @CRLF & "Any jukebox generated will NOT work on the NMT.")
				GUICtrlSetData($NMT_PATH, calculateLPCpath(GUICtrlRead($VIDEO_DIR)))
				setButtonAdd(True)
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
	$cpVideoPath = "file:///opt/sybhttpd/localhost.drives/" & GUICtrlRead($NHD_BTN) & "/" & $cpVideoPath
	Return $cpVideoPath
EndFunc   ;==>calculateNHDpath

;--------------------------------------------------

Func calculateNMTPath($cpVideoPath)
	Local $cpShareName = ""

	$cpShareName = GUICtrlRead($PATH_BTN)
	setButtonAdd(True)
	$cpVideoPath = "file:///opt/sybhttpd/localhost.drives/NETWORK_SHARE/" & $cpShareName & "/" & pathStrip($cpVideoPath)

	Return $cpVideoPath
EndFunc   ;==>calculateNMTPath

;--------------------------------------------------

Func calculateUSBpath($cpVideoPath)
	$cpVideoPath = pathStrip($cpVideoPath)
	$cpVideoPath = "file:///opt/sybhttpd/localhost.drives/" & GUICtrlRead($USB_BTN) & "/" & $cpVideoPath
	Return $cpVideoPath
EndFunc   ;==>calculateUSBpath

;--------------------------------------------------

Func getNmtShare()
	Dim $gnsArray[10]
	Local $gnsCount = 0, $gnsFilename, $gnsFile, $gnsTempIP, $gnsNmtFile, $gnsFileRead

	$gnsFilename = @WorkingDir & "\YAMJ_GUI_Config_Share.txt"

	$gnsTempIP = $YAMJ_nmtIPAddress

	If StringCompare($YAMJ_skipNMTcheck, "True") <> 0 Then
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

	If Not FileExists($gnsFilename) Then
		; Check to see if the file exists, if it does, don't overwrite it.
		; Mainly used for testing, program will still try and delete the file
		$gnsNmtFile = "http://" & $YAMJ_nmtIPAddress & ":8883/network_share.html"
		InetGet($gnsNmtFile, $gnsFilename, 1, 0)
	EndIf

	$gnsFile = FileOpen($gnsFilename, 0 + 128)
	If $gnsFile = -1 Then
		MsgBox(16, $mTitle, "Unable to save information from the" & @CRLF & "NMT to a temporary file. Please" & @CRLF & "check the IP address for the NMT")
		Return
	EndIf

	$gnsFileRead = FileRead($gnsFile, 6500)
	FileClose($gnsFile)
	FileDelete($gnsFilename)

	; Clear the list
	GUICtrlSetData($PATH_BTN, "")

	; This test for the change to the C-200 firmware that lists the network shares differently
	If (StringInStr($gnsFileRead, "1.&nbsp;", 0) > 0) Then
		; Old style A100/A110/C-200 format
		$gnsArray = _StringBetween($gnsFileRead, "1.&nbsp;", "</td>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0], $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, "2.&nbsp;", "</td>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, "3.&nbsp;", "</td>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, "4.&nbsp;", "</td>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, "5.&nbsp;", "</td>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, "6.&nbsp;", "</td>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf
	Else
		; New format C-200 firmware network shares
		$gnsArray = _StringBetween($gnsFileRead, '<option value="1">', "</option>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0], $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, '<option value="2">', "</option>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, '<option value="3">', "</option>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, '<option value="4">', "</option>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, '<option value="5">', "</option>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

		$gnsArray = _StringBetween($gnsFileRead, '<option value="6">', "</option>")
		If IsArray($gnsArray) Then
			GUICtrlSetData($PATH_BTN, $gnsArray[0])
			$gnsCount += 1
		EndIf

	EndIf

	If $gnsCount = 0 Then
		MsgBox(16 + 4096, $mTitle, "You don't seem to have any shares set on the NMT" & @CRLF & "Please create a share before selecting this option.")
	EndIf
EndFunc   ;==>getNmtShare

;--------------------------------------------------

Func libraryAdd($laVideoPath, $laNMTPath)
	Local $laResult, $laDescription
	; Check to see if this is a local disk and a network share.
	; Warn the user that the path may be incorrect.
	If (StringCompare($YAMJ_skipWarning, "False") = 0) Then
		If (StringCompare(GUICtrlRead($VIDEO_DIR), GUICtrlRead($VIDEO_DIR_DECODE)) = 0) And (GUICtrlRead($nmtNetwork) = 1) Then
			$laResult = MsgBox(3 + 64 + 256, $mTitle, "Warning: Possible path error" & @CRLF & _
					"Please see this web page" & @CRLF & _
					"http://mediaplayersite.com/GUI_Config_Path_Error" & @CRLF & _
					"Visit page?")
			Switch $laResult
				Case 2 ; Cancel
					Return
				Case 6 ; Yes
					webLink("http://mediaplayersite.com/GUI_Config_Path_Error")
					Return
				Case 7 ; No
					; Continue with the processing
			EndSwitch
		EndIf
	EndIf

	; Enable the save button now we have something to save
	setButtonSave(True)

	; Disable the add button again until there's something to add
	setButtonAdd(False)

	$laDescription = InputBox($mTitle, "Do you wish to add a description for the library entry?" & @CRLF & "Some skins can display this value so you can see where the files are located." & @CRLF & "E.G. Internal Hard Disk, Server, etc." & @CRLF & "Note: You do not need to enter anything here.", "", " ", "300", "-1", "-1", "-1")
	Select
		Case @error = 0 ;OK - The string returned is valid

		Case @error = 1 ;The Cancel button was pushed
			$laDescription = ""
		Case @error = 3 ;The InputBox failed to open
			$laDescription = ""
	EndSelect

	; Check to see if the library path has changed, if it hasn't use this one.
	If StringLeft(GUICtrlRead($JUKEBOX_DIR), 6) = "Please" Then
		GUICtrlSetData($JUKEBOX_DIR, $laVideoPath)
	EndIf
	MsgBox(64, $mTitle, "Added to the library:" & @CRLF & "Video Path: " & $laVideoPath & @CRLF & "Nmtpath: " & $laNMTPath)

	Dim $lArray[1][2]
	$LibraryArray[$LibraryArrayCounter][0] = $laVideoPath
	$LibraryArray[$LibraryArrayCounter][1] = $laNMTPath
	$LibraryArray[$LibraryArrayCounter][2] = $laDescription
	$LibraryArrayCounter = $LibraryArrayCounter + 1

	If $LibraryArrayCounter = 1 Then
		GUICtrlSetData($GUILibraryCounter, "1 library entry")
	Else
		GUICtrlSetData($GUILibraryCounter, $LibraryArrayCounter & " library entries")
	EndIf

	GUICtrlSetData($NMT_PATH, "Saved. Please set additional options above")
	toggleControls("NONE")
	Return
EndFunc   ;==>libraryAdd

;--------------------------------------------------

Func librarySave($slVideoPath, $slNMTPath, $slJukeboxOutput)
	Local $slPath, $slAnswer, $slExitLoop
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
	; Note: the last parameter needs changing to the jukebox output path
	writeCMD("My_YAMJ.cmd", $slPath, $slVideoPath, $slJukeboxOutput)

	; Write the library file
	writeLibrary("My_Library.xml", $slPath, $slVideoPath)

	$slAnswer = MsgBox(32 + 4, "File Save", "Library file saved to - " & $slPath & @CRLF & "Do you want to open this folder now?")
	If $slAnswer = 6 Then
		Run("Explorer.exe " & $slPath)
	EndIf

	; Clear the saved data
	toggleControls("NONE")
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
	Local $psPos
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

Func selectJukeboxDir()
	Local $sjdScanDir

	If StringLeft(GUICtrlRead($JUKEBOX_DIR), 6) = "Please" Then
		; No path set, so use the video directory to start.
		$sjdScanDir = GUICtrlRead($VIDEO_DIR)
	Else
		; Use the one in the jukebox directory
		$sjdScanDir = GUICtrlRead($JUKEBOX_DIR)
	EndIf

	$sjdScanDir = FileSelectFolder("Select the folder to save the jukebox to", "", 2, $sjdScanDir)

	If $sjdScanDir <> "" Then
		GUICtrlSetData($JUKEBOX_DIR, $sjdScanDir)
	EndIf
EndFunc   ;==>selectJukeboxDir

;--------------------------------------------------

Func setButtonAdd($sbEnable)
	; Enable or disable the add button
	If $sbEnable = True Then
		GUICtrlSetState($ADD_BTN, $GUI_ENABLE)
	Else
		GUICtrlSetState($ADD_BTN, $GUI_DISABLE)
	EndIf
EndFunc   ;==>setButtonAdd

;--------------------------------------------------

Func setButtonSave($sbEnable)
	; Enable or disable the save button
	If $sbEnable = True Then
		GUICtrlSetState($SAVE_BTN, $GUI_ENABLE)
	Else
		GUICtrlSetState($SAVE_BTN, $GUI_DISABLE)
	EndIf
EndFunc   ;==>setButtonSave

;--------------------------------------------------

Func setScanDir($ssdSelectFolder)
	Local $ssdScanDir, $ssdDecode

	If $ssdSelectFolder Then
		$ssdScanDir = FileSelectFolder("Select the media folder to scan", "", 2, GUICtrlRead($VIDEO_DIR))
	Else
		$ssdScanDir = GUICtrlRead($VIDEO_DIR)
	EndIf

	If $ssdScanDir <> "" Then
		GUICtrlSetData($VIDEO_DIR, $ssdScanDir)
		; Clear the selections to ensure the path is clean
		GUICtrlSetData($NMT_PATH, "Scan dir changed, please select an option above")
		setButtonAdd(False)

		If StringInStr($ssdScanDir, ":") > 0 Then
			$ssdDecode = DriveMapGet(StringLeft($ssdScanDir, 2))
			If $ssdDecode = "" Then
				$ssdDecode = $ssdScanDir
			Else
				$ssdDecode = $ssdDecode & StringMid($ssdScanDir, 3)
			EndIf

			GUICtrlSetData($VIDEO_DIR_DECODE, $ssdDecode)
		EndIf
	EndIf
EndFunc   ;==>setScanDir

;--------------------------------------------------

Func settingsRead($srFilename)
	If FileExists($srFilename) Then
		; INI file was found, so read the settings from there
		$YAMJ_nmtIPAddress = IniRead($srFilename, "Settings", "NMTIP", "192.168.2.100")
		$YAMJ_skipNMTcheck = IniRead($srFilename, "Settings", "SkipNMTcheck", "False")
		$YAMJ_skipWebcheck = IniRead($srFilename, "Settings", "SkipWebcheck", "False")
		$YAMJ_skipWarning = IniRead($srFilename, "Settings", "SkipPathWarning", "False")
		$YAMJ_nmtModel = IniRead($srFilename, "Settings", "nmtModel", "A1x0")
	Else
		; No INI file was found, so create a new one
		IniWrite($srFilename, "Settings", "NMTIP", "192.168.2.100")
		IniWrite($srFilename, "Settings", "SkipNMTcheck", False)
		IniWrite($srFilename, "Settings", "SkipWebcheck", False)
		IniWrite($srFilename, "Settings", "SkipPathWarning", False)
		IniWrite($srFilename, "Settings", "nmtModel", "A1x0")

		If FileExists($srFilename) Then
			; Now Read the file to get the correct settings
			settingsRead($srFilename)
		Else
			MsgBox(16, $mTitle, "There seems to be an error writing the ini file." & @CRLF & "Please ensure the directory" & @CRLF & @WorkingDir & " is writeable")
			Exit
		EndIf
	EndIf
EndFunc   ;==>settingsRead

;--------------------------------------------------

Func toggleControls($tcControl)

	If StringCompare($tcControl, "NONE") = 0 Then
		GUICtrlSetState($nmtHardDisk, $GUI_UNCHECKED)
		GUICtrlSetState($nmtNetwork, $GUI_UNCHECKED)
		GUICtrlSetState($nmtUSB, $GUI_UNCHECKED)
	EndIf

	If StringCompare($tcControl, "USB") = 0 Then
		GUICtrlSetState($USB_BTN, $GUI_ENABLE)
	Else
		GUICtrlSetState($USB_BTN, $GUI_DISABLE)
	EndIf

	If StringCompare($tcControl, "HD") = 0 Then
		GUICtrlSetState($NHD_BTN, $GUI_ENABLE)
	Else
		GUICtrlSetState($NHD_BTN, $GUI_DISABLE)
	EndIf

	If StringCompare($tcControl, "NETWORK") = 0 Then
		GUICtrlSetState($PATH_BTN, $GUI_ENABLE)
	Else
		GUICtrlSetState($PATH_BTN, $GUI_DISABLE)
	EndIf

	If StringCompare($tcControl, "PC") = 0 Then
		GUICtrlSetState($nmtLocalPC, $GUI_CHECKED)
	Else
		GUICtrlSetState($nmtLocalPC, $GUI_UNCHECKED)
	EndIf

EndFunc   ;==>toggleControls

;--------------------------------------------------

Func webLink($wlWebURL)
	ShellExecute($wlWebURL)
EndFunc   ;==>webLink

;--------------------------------------------------

Func webVersion($wvSettingsFile)
	Dim $wvArray[10]
	Dim $wvSettings[3]
	Local $wvFile, $wvFilename, $wvFileRead, $wvWebPage, $wvLastCheck, $wvArrayFound, $wvDateDiff

	If FileExists($wvSettingsFile) Then
		$wvSettings = IniReadSection($wvSettingsFile, "WebVersion")
	EndIf

	; See if we have a Version setting. If not, create the version section
	$wvArrayFound = _ArraySearch($wvSettings, "Version")
	If $wvArrayFound = -1 Then
		IniWrite($wvSettingsFile, "WebVersion", "Version", "0.0")
		$WebVersion = "0.0"
	Else
		$WebVersion = $wvSettings[$wvArrayFound][1]
	EndIf

	; If we are skipping the web check, then exit at this point
	If StringCompare($YAMJ_skipWebcheck, "True") = 0 Then
		Return
	EndIf

	$wvArrayFound = _ArraySearch($wvSettings, "LastCheck")
	If $wvArrayFound = -1 Then
		$wvLastCheck = _NowCalcDate()
		IniWrite($wvSettingsFile, "WebVersion", "LastCheck", $wvLastCheck)
		; We have no last check date, so always check
		$wvDateDiff = 99
	Else
		$wvLastCheck = $wvSettings[$wvArrayFound][1]
		$wvDateDiff = _DateDiff("D", $wvLastCheck, _NowCalcDate())
	EndIf

	; Only run the check once a week
	If $wvDateDiff < 7 Then
		Return
	EndIf

	$wvFilename = @WorkingDir & "\YAMJ_GUI_Config_Version.txt"

	If Not FileExists($wvFilename) Then
		; Check to see if the file exists, if it does, don't overwrite it.
		; Mainly used for testing, program will still try and delete the file
		$wvWebPage = "http://mediaplayersite.com/YAMJ_GUI_Config/"
		InetGet($wvWebPage, $wvFilename, 1, 0)
	EndIf

	$wvFile = FileOpen($wvFilename, 0 + 128)
	If $wvFile = -1 Then
		; Unable to get the version from the web.
		Return
	EndIf

	$wvFileRead = FileRead($wvFile)
	FileClose($wvFile)
	FileDelete($wvFilename)

	$wvArray = _StringBetween($wvFileRead, "Latest Version: ", "</p>")

	If @error = 1 Then
		$WebVersion = "0.0"
	Else
		$WebVersion = $wvArray[0]

		; Check was sucessful, so save the settings to the ini file.
		IniWrite($wvSettingsFile, "WebVersion", "Version", $WebVersion)
		IniWrite($wvSettingsFile, "WebVersion", "LastCheck", _NowCalcDate())
	EndIf

EndFunc   ;==>webVersion

;--------------------------------------------------

Func writeCMD($wcFilename, $wcPath, $wcVideoPath, $wcJukeboxOutput)
	Local $wcFileCMD
	Local $wcPause
	Local $iMsgBoxAnswer

	$iMsgBoxAnswer = MsgBox(36, "YAMJ", "Do you want to pause at the end of the YAMJ run?" & @CRLF & "Note: This will keep the command window open" & @CRLF & "until you close it with a key press.", 5)
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			$wcPause = True;
		Case $iMsgBoxAnswer = 7 ;No
			$wcPause = False;
		Case $iMsgBoxAnswer = -1 ;Timeout
			$wcPause = True;
	EndSelect

	$wcFileCMD = FileOpen($wcFilename, 2 + 128)
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

		If StringInStr($wcJukeboxOutput, " ") Then
			FileWriteLine($wcFileCMD, "CALL moviejukebox My_Library.xml -o """ & $wcJukeboxOutput & """")
		Else
			FileWriteLine($wcFileCMD, "CALL moviejukebox My_Library.xml -o " & $wcJukeboxOutput)
		EndIf

		If $wcPause Then FileWriteLine($wcFileCMD, "pause")
		FileWriteLine($wcFileCMD, "exit")
		FileClose($wcFileCMD)
	EndIf
	Return
EndFunc   ;==>writeCMD

;--------------------------------------------------

Func writeLibrary($wlFilename, $wlPath, $wlVideoPath)
	Local $wlFileLib

	$wlFileLib = FileOpen($wlFilename, 2 + 128)
	If $wlFileLib = -1 Then
		MsgBox(16, $mTitle, "Error saving the library file")
		Return
	Else
		FileWriteLine($wlFileLib, "<!-- Library file generated by Omertron's GUI Config -->")
		FileWriteLine($wlFileLib, "<!-- " & $mTitle & " -->")
		FileWriteLine($wlFileLib, "<!-- " & $mWebURL & " -->")
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
			FileWriteLine($wlFileLib, "    <playerpath>" & $LibraryArray[$lsLoop][1] & "</playerpath>")
			FileWriteLine($wlFileLib, "    <exclude name=""sample,tmp/,temp/,RECYCLER/,RECYCLE.BIN/""/>")
			If (StringLen($LibraryArray[$lsLoop][2]) > 0) Then
				FileWriteLine($wlFileLib, "    <description>" & $LibraryArray[$lsLoop][2] & "</description>")
			Else
				FileWriteLine($wlFileLib, "    <description></description>")
			EndIf
			FileWriteLine($wlFileLib, "    <prebuf></prebuf>")
			FileWriteLine($wlFileLib, "    <scrapeLibrary>true</scrapeLibrary>")
			FileWriteLine($wlFileLib, "  </library>")
			FileWriteLine($wlFileLib, "")
		Next

		FileWriteLine($wlFileLib, "</libraries>")
		FileClose($wlFileLib)
	EndIf

EndFunc   ;==>writeLibrary