[CmdletBinding()]
Param(
    [Int] $LoopTime = 0
)

$wsh = New-Object -ComObject WScript.Shell
$RunningFile = $PSScriptRoot + "\publishrunning.txt"

function Keep-Awake()
{
	$wsh.SendKeys('+{capslock}')
	$wsh.SendKeys('+{capslock}')
}

function CheckForExit()
{
	$stopFtpFile = $PSScriptRoot + "\stopftp.txt"
	

	if (Test-Path $stopFtpFile -PathType Leaf)
	{
		Write-Host "`rEnding."
		Remove-item $stopFtpFile -ErrorAction Ignore
		Remove-Item $RunningFile -ErrorAction Ignore
		exit 5
	}
}

Set-Location -Path "C:\pga"
Write-Host "Add-AutorefreshAndFtp Running.  LoopTime = $($LoopTime);  dir=$($(Get-Location).Path)"
"Running" | Out-File $RunningFile

do {

	Keep-Awake
	CheckForExit

	Write-Host -NoNewline "."

	if (Test-Path '.\html\JoeMagnetico.htm')
	{
		Write-Verbose "new html files to upload"

		(Get-Content .\html\JoeMagnetico.htm).Replace(";color:white;",";color:transparent;") | Set-Content .\html\tempJ.html
		(Get-Content .\html\Micro.htm).Replace(";color:white;",";color:transparent;") | Set-Content .\html\tempM.html

		$x = (gc .\html\tempJ.html) -as [Collections.ArrayList]
		$y = (gc .\html\tempM.html) -as [Collections.ArrayList]

		if (Test-Path '.\html\LeadChanges.htm')
		{
			Copy-Item -Path ".\html\LeadChanges.htm" -Destination ".\html\LeadChanges.html"    # just for consistency 
		}

        Start-Sleep 1
		Remove-Item '.\html\JoeMagnetico.htm'
		Remove-Item '.\html\Micro.htm'
		Remove-Item '.\html\tempJ.html'
		Remove-Item '.\html\tempM.html'
		
		$x.Insert(7,'<meta http-equiv="refresh" content="60" />')
		$x.Insert(7,'<meta http-equiv="Pragma" content="no-cache" />')
		$x.Insert(7,'<meta http-equiv="Expires" content="0" />')
		$x.Insert(7,'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />')
		$x.Insert(7,"<style> {margin:0;padding:0;} html { background: url('bg.jpg') no-repeat center center fixed; background-color: rgba(255,255,255,0.81); background-blend-mode: lighten; background-size: cover;} </style>")

		$x | Set-Content '.\html\index.html' -Force -Encoding UTF8

		$y.Insert(7,'<meta http-equiv="refresh" content="60" />')
		$y.Insert(7,'<meta http-equiv="Pragma" content="no-cache" />')
		$y.Insert(7,'<meta http-equiv="Expires" content="0" />')
		$y.Insert(7,'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />')
		$y.Insert(7,"<style> {margin:0;padding:0;} html { background: url('bg.jpg') no-repeat center center fixed; background-color: rgba(255,255,255,0.81); background-blend-mode: lighten; background-size: cover;} </style>")

		$y | Set-Content '.\html\micro.html' -Force -Encoding UTF8

		Write-Verbose "call winscp to upload..."
		if (Test-Path '.\html\LeadChanges.htm')
		{
			Start-Process -wait "\Program Files (x86)\WinSCP\WinSCP.exe" "/script=ftpSettingsLeaders.txt"
			Remove-Item '.\html\LeadChanges.htm'
		} else {
			Start-Process -wait "\Program Files (x86)\WinSCP\WinSCP.exe" "/script=ftpSettingsBoth.txt"
		}

		Write-Host "`r$((Get-Date -Format "HH-mm-ss.MM-dd").ToString()) - ftp upload complete."
	}

	Start-Sleep $LoopTime

} while ($LoopTime)

Remove-Item $RunningFile -ErrorAction Ignore
