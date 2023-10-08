#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>

Global $hProgressBar

; Create the main GUI window
$hGUI = GUICreate("Directory Duplicator By Le Vinh Khang", 500, 280, -1, -1)

; Set a modern font
GUISetFont(10, 400, 0, "Arial")

; Create input fields and labels with group controls for better distinction
$hSourceGroup = GUICtrlCreateGroup("Source Directories", 20, 20, 460, 130)
$hSourceInput = GUICtrlCreateEdit("", 40, 50, 340, 90, $ES_AUTOVSCROLL + $WS_VSCROLL)
$hSourceBrowse = GUICtrlCreateButton("Browse", 390, 50, 80, 30)
$hSourceClear = GUICtrlCreateButton("Clear", 390, 100, 80, 30)

$hDestGroup = GUICtrlCreateGroup("Destination Directory", 20, 160, 460, 70)
$hDestInput = GUICtrlCreateInput("", 40, 190, 340, 30)
$hDestBrowse = GUICtrlCreateButton("Browse", 390, 190, 80, 30)

; Close the group controls for layout purposes
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Create the copy button
$hCopyButton = GUICtrlCreateButton("Duplicate", 210, 240, 80, 40)

GUISetState(@SW_SHOW)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $hSourceBrowse
            $selectedDir = FileSelectFolder("Select Source Directories", "", 2 + 4) ; 2+4 allows multi-select
            If Not @error Then 
                If GUICtrlRead($hSourceInput) <> "" Then
                    GUICtrlSetData($hSourceInput, GUICtrlRead($hSourceInput) & @CRLF & $selectedDir)
                Else
                    GUICtrlSetData($hSourceInput, $selectedDir)
                EndIf
            EndIf
        Case $hSourceClear
            GUICtrlSetData($hSourceInput, "")
        Case $hDestBrowse
            $selectedDir = FileSelectFolder("Select Destination Directory", "", 2)
            If Not @error Then GUICtrlSetData($hDestInput, $selectedDir)
        Case $hCopyButton
            DuplicateDirectories()
    EndSwitch
WEnd

Func CreateProgressBar($iTotal)
    ; Create a GUI for the progress bar
    Local $hProgressGUI = GUICreate("Duplicating...", 300, 60, -1, -1, $WS_POPUP, $WS_EX_TOOLWINDOW)

    ; Create the progress bar
    $hProgressBar = GUICtrlCreateProgress(10, 10, 280, 20)
    GUICtrlSetColor(-1, 0x00FF00) ; Green
    GUICtrlSetBkColor(-1, 0x000000) ; Black

    ; Set the range for the progress bar based on the total count of directories
    GUICtrlSetLimit($hProgressBar, 100, 0) ; Setting range from 0 to 100

    ; Display the progress bar GUI
    GUISetState(@SW_SHOW, $hProgressGUI)
    Return $hProgressGUI
EndFunc

Func UpdateProgressBar($iCurrent, $iTotal)
    Local $iPercentage = ($iCurrent / $iTotal) * 100
    GUICtrlSetData($hProgressBar, $iPercentage)
EndFunc

Func DuplicateDirectories()
    $sourceDirs = StringSplit(GUICtrlRead($hSourceInput), @CRLF, 1)
    $destDir = GUICtrlRead($hDestInput)
    $allSuccessful = True
    $failedDirs = ""

    ; Create the progress bar
    Local $hProgressGUI = CreateProgressBar($sourceDirs[0])

    For $i = 1 To $sourceDirs[0]
        $sourceDir = $sourceDirs[$i]
        
        If Not FileExists($sourceDir) Then
            $allSuccessful = False
            $failedDirs &= "Source directory does not exist: " & $sourceDir & @CRLF
            UpdateProgressBar($i, $sourceDirs[0]) ; Update progress even if there's an error
            ContinueLoop
        EndIf

        If FileExists($destDir & "\" & StringTrimLeft($sourceDir, StringInStr($sourceDir, "\", 0, -1))) Then
            $allSuccessful = False
            $failedDirs &= "Destination directory already exists for: " & $sourceDir & @CRLF
            UpdateProgressBar($i, $sourceDirs[0]) ; Update progress even if there's an error
            ContinueLoop
        EndIf

        If Not DirCopy($sourceDir, $destDir & "\" & StringTrimLeft($sourceDir, StringInStr($sourceDir, "\", 0, -1)), 1) Then
            $allSuccessful = False
            $failedDirs &= "Failed to duplicate directory: " & $sourceDir & @CRLF
        EndIf

        ; Update the progress bar based on the current directory index and total directories
        UpdateProgressBar($i, $sourceDirs[0])
    Next

    ; Close the progress bar GUI
    GUIDelete($hProgressGUI)

    If $allSuccessful Then
        MsgBox(0, "Success", "All directories duplicated successfully!")
    Else
        MsgBox(0, "Error", "Some directories failed to duplicate:" & @CRLF & $failedDirs)
    EndIf
EndFunc