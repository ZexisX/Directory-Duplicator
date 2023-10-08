#include <File.au3>
#include <GUIConstantsEx.au3>
#include <Date.au3>

Global $hGUI, $hBrowseButton, $hScanButton, $sSelectedFolder

; Create the main GUI window
$hGUI = GUICreate("Directory Scanner", 300, 150, -1, -1)

; Set a modern font
GUISetFont(10, 400, 0, "Arial")

; Create the "Choose Directory" button
$hBrowseButton = GUICtrlCreateButton("Choose Directory", 50, 30, 200, 40)

; Create the "Start Scan" button
$hScanButton = GUICtrlCreateButton("Start Scan", 50, 80, 200, 40)
GUICtrlSetState($hScanButton, $GUI_DISABLE) ; Disable the "Start Scan" button initially

; Display the main GUI
GUISetState(@SW_SHOW, $hGUI)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $hBrowseButton
            $sSelectedFolder = FileSelectFolder("Select directory to scan", "")
            If Not @error Then
                GUICtrlSetState($hScanButton, $GUI_ENABLE) ; Enable the "Start Scan" button
            EndIf
        Case $hScanButton
            If $sSelectedFolder <> "" Then
                ScanDirectory($sSelectedFolder)
            EndIf
            GUICtrlSetState($hScanButton, $GUI_DISABLE) ; Disable the "Start Scan" button after scanning
    EndSwitch
WEnd

Func ScanDirectory($sPath)
    ; Get the current date and time
    Local $sTimestamp = _Now()

    ; Open save.txt for writing
    Local $hFile = FileOpen("save.txt", $FO_APPEND + $FO_CREATEPATH)
    If $hFile = -1 Then
        MsgBox(0, "Error", "Unable to create or open save.txt.")
        Return
    EndIf

    ; Add comments to the file
    FileWriteLine($hFile, "# Le Vinh Khang (Aedotris)")
    FileWriteLine($hFile, "# Github: https://github.com/levinhkhangzz")
    FileWriteLine($hFile, "# Timestamp: " & $sTimestamp)
    FileWriteLine($hFile, "")

    ; Start scanning the directory
    RecursiveScan($sPath, $hFile)

    ; Close the file
    FileClose($hFile)

    ; Notify the user that the scan is complete
    MsgBox(0, "Notification", "Directory scanning complete!")
EndFunc

Func RecursiveScan($sPath, $hFile)
    Local $sSearch = FileFindFirstFile($sPath & "\*.*")
    If $sSearch = -1 Then Return

    While 1
        Local $sDir = FileFindNextFile($sSearch)
        If @error Then ExitLoop

        If (@extended = 1) Then ; Check if it's a directory
            FileWriteLine($hFile, $sPath & "\" & $sDir)
            ; Recursively scan subdirectories
            RecursiveScan($sPath & "\" & $sDir, $hFile)
        EndIf
    WEnd

    FileClose($sSearch)
EndFunc
