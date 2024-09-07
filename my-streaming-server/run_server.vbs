Option Explicit

Dim objShell, objFSO, strServerDir, strBatFile, strLogFile

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strServerDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
strBatFile = objFSO.BuildPath(strServerDir, "start-server.bat")
strLogFile = objFSO.BuildPath(strServerDir, "obs-macro.log")

' Log the execution
LogMessage "OBS macro script started"

' Check if the batch file exists
If objFSO.FileExists(strBatFile) Then
    ' Run the batch file
    objShell.Run "cmd /c """ & strBatFile & """ start", 0, False
    LogMessage "Executed start-server.bat"
Else
    LogMessage "Error: start-server.bat not found"
End If

' Log function
Sub LogMessage(message)
    Dim objFile
    Set objFile = objFSO.OpenTextFile(strLogFile, 8, True)
    objFile.WriteLine Now & " - " & message
    objFile.Close
End Sub

Set objShell = Nothing
Set objFSO = Nothing