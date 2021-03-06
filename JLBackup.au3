; *******************************************************************************************************************************************************
; JL backup, program for moving joblistfiles on Tecan Twin (Green and Blue) system
; Sanquin IPB Laboratory of Biologicals
;
; version 1.3, 20 august 2014 by Dion Methorst
; version 1.4, 03 february 2015
; version 1.5, 17 september 2015
; version 1.6, 23 september 2015
; version 1.7, 23 september 2015
;
; changelog:
; v1.1		added 5 more EL folders for new CLIS worklist , these numbers are arbitrary and will be replaced for real world worklists later
; v1.2		line 104 and 119, Enbrel changed worklistnumber 699 to 923
; v1.3		line 109 & 123, arrays with worklistnumbers for EVO $Blue[7] and $Green[7] changed to Golimumab
; 			line 85-100, size of arrays $Blue and $Green now set as amount of ELn folders counted in C:\Apps\EVO\Job\
; 			line 85-100, added errorhandling to check for existing ELn folders
;			added checking of existing files in joblist folder, existing joblist files in folder are not overwritten.
;			adjusted messagebox icon and messages for clarity
; v1.4		reading EL folders and joblistfiles from ini file:
; v1.5		Added RenameJoblist function: Resets the count of the joblists in each ELx folder
; v1.6		Rename Joblist function opening joblist folder to check joblists.
;			Transparent GUI
; v1.7		added buttons to open EVO file folders
;
; TO DO ZIp To Archive?
;
; *******************************************************************************************************************************************************
;
; Upon execution of the  main GUI window with 4 buttons pops up:
;
; move joblists
; reset joblists
; exit
; delete joblists
;
; each of the buttons executes a function of the same name as the button as described below.
;
; function MoveJoblist()
;
; script to move Tecan Freedom joblist files
; The script executes the following procedure:
;
;			FileMove("C:\APPS\EVO\JOB\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl", "C:\APPS\EVO\JLbackup\" & $Blue[$B][1] & $File & ".twl", 1 + 8)
;			FileCopy("C:\APPS\EVO\JLbackup\" & $Blue[$B][1] & $File & ".twl", "C:\APPS\EVO\archief\" & $Blue[$B][1] & $File & "_" & $moveDate & ".twl", 1 + 8)
;			FileSetTime("C:APPS\EVO\JLbackup\" & $Blue[$B][1] & $File  & ".twl", "", 1)
;
; $Blue[$B][0] is the EL[$B] folder in C:\APPS\EVO\JOB\EL[$B]
; Files are moved from C:\APPS\EVO\JOB\EL[$B] ($B= 1 tot Ubound$Blue)
; Files are moved to C:\APPS\EVO\JLbackup
; The joblistfiles are then copied from C:\APPS\EVO\JLbackup\ to C:\APPS\EVO\Archief,
; time of copying is set to JLBackup folder and all files as file attribute "date created"
; date and timestamp are inserted into the filename of files in C:\APPS\EVO\Archief
;
; function ResetJoblist()
;
; script to reset Tecan Freedom joblist files from JLbackup folder
; this function reverses the MoveJoblist() and puts the files back into the EL Joblist folders
; existing files in the joblistfolders are checked out first in order that existing joblist files are NOT overwritten!!!
;
;			Before moving files, 1st check if file already in joblist folder, if NOT then joblists ar moved to backup folder and archief, timestamp added.
;			existing files are not overwritten
;			If FileExists("C:\APPS\EVO\Job\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl") Then
;				MsgBox(4096, "JLBackup", "C:\APPS\EVO\Job\"  & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl already exists in joblist folder!" &  @CRLF & _
;				"This file is not resetted and will be kept in C:\apps\EVO\JLBackup")
;			Else
;				FileMove("C:\APPS\EVO\JLbackup\" & $Blue[$B][1] & $File & ".twl", "C:\APPS\EVO\Job\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl", 0 + 8)
;				FileSetTime("C:\APPS\EVO\Job\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl", "", 1)
;			EndIf
;
; The script executes the following procedure:
; Files are copied from C:\APPS\EVO\JLbackup
; Files are copied to C:\APPS\EVO\JOB\ELn (n= 1 tot $B)
;
; funcrtion DeleteJoblist()
;
; script to delete ALL joblists from C:\APPS\EVO\job\ELn folders
; if not backupped beforehand, all files will be lost forevermore :)
; therefore the main() gui pops a message if you're sure about throwing away your joblists
;
;			FileDelete("C:\apps\EVO\job\EL" & $EL) ; deletes *.* in folder
;
; the array is put in a loop which designates a number to the ELx [1-x] folders
; the loop is executed x-1 times, thus EL1, EL2... EL5 are named
; This loop can also be extended up to as many ELx folders as you wish
;
;
; C:\APPS\EVO\JLbackup\Jlbackup.ini   >> a default JLBackup is created after deletion of the ini file.
;
;[Blue]
;EL1= \682_2_		 infliximab = remicade
;EL2= \923_2_		enbrel = etanercept
;EL3 = \683_2_		adalimumab = humera
;EL4 = \697_2_		rituximab = mapthera
;EL5 = \800_2_		trastuzumab = herceptin
;EL6 = \856_2_		tocilizumab
;EL7 = \922_2_		golimumab
;EL8 = \999_2_		bloedspot ADA
;EL9 = \998_2_		bloedspot ETN
;EL10 = \997_2_

;[Green]
;EL1 = \682_1_
;EL2 = \923_1_
;EL3 = \683_1_
;EL4 = \697_1_
;EL5 = \800_1_
;EL6 = \856_1_
;EL7 = \922_1_
;EL8 = \999_1_
;EL9 = \998_1_
;
;******************************************************************************************************************************************************
; Start of script

#include <Array.au3>
#include <file.au3>
#include <Date.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#include <Math.au3>

;on error msgbox

If not FileExists("C:\APPS\EVO\JLbackup\Jlbackup.ini") then
	Local $BlueAssay = "EL1=\682_2_" & @CRLF &"EL2=\923_2_" & @CRLF &"EL3=\683_2_" & @CRLF &"EL4=\697_2_" & @CRLF &"EL5=\800_2_" _
	& @CRLF &"EL6=\856_2_" & @CRLF &"EL7=\922_2_" & @CRLF &"EL8=\999_2_" & @CRLF &"EL9=\998_2_"
	Local $GreenAssay = "EL1=\682_1_" & @CRLF &"EL2=\923_1_" & @CRLF &"EL3=\683_1_" & @CRLF &"EL4=\697_1_" & @CRLF &"EL5 =\800_1_" _
	& @CRLF &"EL6=\856_1_" & @CRLF &"EL7=\922_1_" & @CRLF &"EL8=\999_1_" & @CRLF &"EL9=\998_1_"
	IniWriteSection("C:\APPS\EVO\JlBackup\Jlbackup.ini", "Blue", $BlueAssay)
	IniWriteSection("C:\APPS\EVO\JLbackup\Jlbackup.ini", "Green", $GreenAssay)
	Endif

$Blue = IniReadSection("C:\APPS\EVO\JLbackup\Jlbackup.ini", "Blue")
$Green = IniReadSection("C:\APPS\EVO\JLbackup\Jlbackup.ini", "Green")

;_ArrayDisplay($Blue)
;_ArrayDisplay($Green)
;================== START FUNCTION Move Joblist=======================================================================================================

; function for use in GUI, this script transfers all  Joblist files to the C:\apps\EVO\archief folder
Func MoveJoblist()

dim $File = ""
dim $moveDate

;_ArrayDisplay($Blue)
;_ArrayDisplay($Green)

local $moveDate = @mday & @mon & @year & @hour & @min & @sec

For $B = 1 to Ubound($Blue)-1

		For $File = 1 to 5
			; move files $Blue, joblists ar moved to backup folder and archief, timestamp added
			FileMove("C:\APPS\EVO\JOB\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl", "C:\APPS\EVO\JLbackup\" & $Blue[$B][1] & $File & ".twl", 1 + 8)
			FileCopy("C:\APPS\EVO\JLbackup\" & $Blue[$B][1] & $File & ".twl", "C:\APPS\EVO\archief\" & $Blue[$B][1] & $File & "_" & $moveDate & ".twl", 1 + 8)
			FileSetTime("C:APPS\EVO\JLbackup\" & $Blue[$B][1] & $File  & ".twl", "", 1)
		next
Next

For $G = 1 to Ubound($Green)-1

		For $File = 1 to 5
			; move files $Green, joblists ar moved to backup folder and archief, timestamp added
			FileMove("C:\APPS\EVO\JOB\" & $Green[$G][0] & $Green[$G][1] & $File & ".twl", "C:\APPS\EVO\JLbackup\" & $Green[$G][1] & $File & ".twl", 1 + 8)
			FileCopy("C:\APPS\EVO\JLbackup\" & $Green[$G][1] & $File & ".twl", "C:\APPS\EVO\archief\" & $Green[$G][1] & $File & "_" & $moveDate & ".twl", 1 + 8)
			FileSetTime("C:APPS\EVO\JLbackup\" & $Green[$G][1] & $File  & ".twl", "", 1)
		next
Next

EndFunc
;================== END FUNCTION move Joblist =====================================================================================================
;================== START FUNCTION Reset Joblist ========================================================================================================
Func ResetJoblist()

Local $File = ""
Local $moveDate

For $B = 1 to Ubound($Blue)-1

		For $File = 1 to 5
			If FileExists("C:\APPS\EVO\Job\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl") Then
				MsgBox(4096, "JLBackup", "C:\APPS\EVO\Job\"  & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl already exists in joblist folder!" &  @CRLF & _
				"This file is not resetted and will be kept in C:\apps\EVO\JLBackup")
			Else
				FileMove("C:\APPS\EVO\JLbackup\" & $Blue[$B][1] & $File & ".twl", "C:\APPS\EVO\Job\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl", 0 + 8)
				FileSetTime("C:\APPS\EVO\Job\" & $Blue[$B][0] & $Blue[$B][1] & $File & ".twl", "", 1)
			EndIf
		next

Next

For $G = 1 to Ubound($Green)-1

		For $File = 1 to 5
			If FileExists("C:\APPS\EVO\Job\" & $Green[$G][0] & $Green[$G][1] & $File & ".twl") Then
				MsgBox(4096, "JLBackup", "C:\APPS\EVO\Job\"  & $Green[$G][0] & $Green[$G][1] & $File & ".twl already exists in joblist folder!" &  @CRLF & _
				"This file is not resetted and will be kept in C:\apps\EVO\JLBackup")
			Else
				FileMove("C:\APPS\EVO\JLbackup\" & $Green[$G][1] & $File & ".twl", "C:\APPS\EVO\Job\" & $Green[$G][0] & $Green[$G][1] & $File & ".twl", 0 + 8)
				FileSetTime("C:\APPS\EVO\Job\" & $Green[$G][0] & $Green[$G][1] & $File & ".twl", "", 1)
			EndIf
		next

Next

EndFunc
;================== END FUNCTION Reset Joblist ================================================================================================
;================== START FUNCTION Delete Joblist ========================================================================================================
Func DeleteJoblist()

$max = _Max ($Green[0][0], $Blue[0][0])

For $EL = 1 to $max
			FileDelete("C:\apps\EVO\job\EL" & $EL) ; deletes *.* in folder
Next

EndFunc
;================== END FUNCTION Delete Joblist ================================================================================================
;================== START FUNCTION Rename Joblist ========================================================================================================

Func RenameJoblist()

 $aFileList = _FileListToArray("C:\apps\EVO\job\", "*")
 $aFileList2 = _FileListToArray("C:\apps\EVO\job\", Default, Default, True)
;_arraydisplay($aFilelist2)

$JLcount = 1
For $i = 1 to Ubound($aFileList2)-1
	   $aJobList = _FileListToArray("C:\apps\EVO\job\"& $aFileList[$i] & "\" , "*.twl")
	   ;_arraydisplay($aJobList)
	  for $j = 1 to Ubound($aJobList)-1
		 $pos =stringinstr($aJobList[$j], ".", 0,1)-1
		 filemove($aFileList2[$i] & "\" & $aJobList[$j] , $aFileList2[$i] & "\" & StringReplace($aJobList[$j], $pos, $j & ".twl"), 1 +8)
		 $JLcount = $JLcount + 1
	  next
	  ;msgbox(0, "", $JLcount)
Next

if $JLcount >5 then msgbox($MB_ICONWARNING, "Opgepast!", "Er zijn meer dan " & $JLcount & " joblists aanwezig" & @CRLF & "Dat zijn er meer dan 5!")

EndFunc
;================== END FUNCTION Rename Joblist ================================================================================================
;================== Start Main() ==============================================================================================================

; GUI Creation
GUISetFont(9, 500, 2, 45)
Global const $JLbu = GuiCreate("EVO Joblist Backup", 255, 165, -1, -1, -1, BitOr($WS_EX_TOOLWINDOW, $WS_EX_LAYERED)) ;BitOr($WS_EX_TRANSPARENT, $WS_EX_TOOLWINDOW , $WS_EX_LAYERED))
GuiSetIcon("B:\Programmeren\programmeren_Dion\TECAN\EVO joblist backup Allergie\icons\JLbackup2.ico", 0)
;DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $JLbu, "int", 1000, "long", 0x00080000) ; fade-in

; Button advanced, menu
$RenameJoblist = GUICtrlCreateButton("Set Joblists 1 to 5",15,10,165,25)
$MoveJoblist = GUICtrlCreateButton("Move Joblists",15,40,165,25)
$ResetJoblist = GUICtrlCreateButton("Reset all Joblists",15,70,165,25)
$DeleteButton = GUICtrlCreateButton("Delete Joblists",15,100,165,25)
$ExitButton = GUICtrlCreateButton("Exit",15,130,165,25)

$Jobfile = GUICtrlCreateButton("JOB",190,10,50,25)
$TplFile = GUICtrlCreateButton("TPL",190,40,50,25)
$AscFile = GUICtrlCreateButton("ASC",190,70,50,25)
$TplascFile = GUICtrlCreateButton("TPLASC",190,100,50,25)
$ArchFile = GUICtrlCreateButton("Archief",190,130,50,25)

; Close Group
GUICtrlCreateGroup("",-99,-99,1,1)
_WinAPI_SetLayeredWindowAttributes($JLbu, 0xABCDEF);, 125)
GUISetBkColor(0xABCDEF)
; Show windows with buttons
GuiSetState(@SW_SHOW)
;GUISetState()

; Continuous Loop to check for GUI Events, upon event the corresponding command or function is exectuted
While 1
$guimsg = GUIGetMsg()
	Select
		 Case $guimsg = $GUI_EVENT_CLOSE
			ExitLoop
		 Case $guimsg = $RenameJoblist
			RenameJoblist()
			   MsgBox(0,"Joblist Count","Joblists Count Done!")
				  Local $iPID = Run("explorer.exe " & "C:\Apps\EVO\Job")
				  WinWait("[CLASS:explorer]", "", 1)
				  Sleep(10)
				  ProcessClose($iPID)
			   MsgBox ($MB_ICONINFORMATION + $MB_TOPMOST + $MB_SETFOREGROUND, "", "Check Joblists!",5)
		 Case $guimsg = $Jobfile
			Local $iPID = Run("explorer.exe " & "C:\Apps\EVO\Job")
			WinWait("[CLASS:explorer]", "", 1)
			Sleep(10)
			ProcessClose($iPID)
		 Case $guimsg = $TplFile
			Local $iPID = Run("explorer.exe " & "C:\Apps\EVO\TPL")
			WinWait("[CLASS:explorer]", "", 1)
			Sleep(10)
			ProcessClose($iPID)
		 Case $guimsg = $AscFile
			Local $iPID = Run("explorer.exe " & "C:\Apps\EVO\ASC")
			WinWait("[CLASS:explorer]", "", 1)
			Sleep(10)
			ProcessClose($iPID)
		 Case $guimsg = $TplascFile
			Local $iPID = Run("explorer.exe " & "C:\Apps\EVO\TPLASC")
			WinWait("[CLASS:explorer]", "", 1)
			Sleep(10)
			ProcessClose($iPID)
		 Case $guimsg = $ArchFile
			Local $iPID = Run("explorer.exe " & "C:\Apps\EVO\Archief")
			WinWait("[CLASS:explorer]", "", 1)
			Sleep(10)
			ProcessClose($iPID)
		 Case $guimsg = $MoveJoblist
			MoveJoblist()
			MsgBox(0,"Move Joblist","Joblists moved to C:\APPS\EVO\JOB\JLbackup")
		 Case $guimsg = $ResetJoblist
			Resetjoblist()
			MsgBox(0,"Reset Joblist","Joblists resetted to C:\APPS\EVO\Job")
		 Case $guimsg = $ExitButton
			Exit
		 Case $guimsg = $DeleteButton
			Dim $iMsgBoxAnswer
			$iMsgBoxAnswer = MsgBox(52,"DELETE Joblists"," Weet u dit heel erg zeker?")
			Select
				Case $iMsgBoxAnswer = 6 ;Yes
					DeleteJoblist()
					MsgBox(64,"Joblist DELETE","Joblists Deleted")
				Case $iMsgBoxAnswer = 7 ;No
					MsgBox(64,"Joblist DELETE","Joblists NOT Deleted")
			EndSelect
	EndSelect
Wend
;================== END Main() ==============================================================================================================