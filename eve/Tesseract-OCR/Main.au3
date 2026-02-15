$ImageToReadPath = @ScriptDir & "\image.bmp"
$ResultTextPath = @ScriptDir & "\Result"
$OutPutPath = $ResultTextPath & ".txt"
$TesseractExePath = @ScriptDir & "\Tesseract.exe"

ShellExecuteWait($TesseractExePath, '"' & $ImageToReadPath & '" "' & $ResultTextPath & '"', "", "", @SW_HIDE)

If @error Then
	Exit MsgBox(0, "Error", @error)
EndIf

MsgBox(0, "Result", FileRead($OutPutPath))

FileDelete($OutPutPath)