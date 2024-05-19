Param(
    [Int] $LoopTime = 0
)

function CheckForExit()
{
	$stopFtpFile = $PSScriptRoot + "\stopftp.txt"

	if (Test-Path $stopFtpFile -PathType Leaf)
	{
		Write-Host "Ending..."
		Remove-item $stopFtpFile -ErrorAction Ignore
		exit 5
	}
}

do {

	CheckForExit

	Write-Host -NoNewline "."

	if (Test-Path '.\html\JoeMagneticoPGATour.htm')
	{
		$x = (gc .\html\JoeMagneticoPGATour.htm) -as [Collections.ArrayList]
		$y = (gc .\html\Micro.htm) -as [Collections.ArrayList]

		Remove-Item '.\html\JoeMagneticoPGATour.htm'
		Remove-Item '.\html\Micro.htm'

		$x.Insert(7,'<meta http-equiv="refresh" content="60" />')
		$x.Insert(7,'<meta http-equiv="Pragma" content="no-cache" />')
		$x.Insert(7,'<meta http-equiv="Expires" content="0" />')
		$x.Insert(7,'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />')
		$x.Insert(7,"<style> {margin:0;padding:0;} html { background: url('bg.jpg') no-repeat center center fixed; background-color: rgba(255,255,255,0.81); background-blend-mode: lighten; background-size: cover;} </style>")
		#$x.Insert(7,'<style> body:before { content: ""; position: absolute; top: 0; bottom: -50; left: 0; right: -200; z-index: 1; background-image: url(''bg.jpg''); opacity: 0.2; } </style>')

		$x | Set-Content '.\html\index.html' -Force -Encoding UTF8

		$y.Insert(7,'<meta http-equiv="refresh" content="60" />')
		$y.Insert(7,'<meta http-equiv="Pragma" content="no-cache" />')
		$y.Insert(7,'<meta http-equiv="Expires" content="0" />')
		$y.Insert(7,'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />')
		$y.Insert(7,"<style> {margin:0;padding:0;} html { background: url('bg.jpg') no-repeat center center fixed; background-color: rgba(255,255,255,0.81); background-blend-mode: lighten; background-size: cover;} </style>")
		#$y.Insert(7,'<style> body:before { content: ""; position: absolute; top: 0; bottom: -50; left: 0; right: -200; z-index: 1; background-image: url(''bg.jpg''); opacity: 0.2; } </style>')

		$y | Set-Content '.\html\micro.html' -Force -Encoding UTF8

		Start-Process -wait "\Program Files (x86)\WinSCP\WinSCP.exe" "/script=ftpSettings.txt"
		Start-Process -wait "\Program Files (x86)\WinSCP\WinSCP.exe" "/script=ftpSettingsMicro.txt"

		Write-Host "`r$((Get-Date -Format "HH-mm-ss.MM-dd").ToString()) - ftp upload complete."
	}

	Start-Sleep $LoopTime

} while ($LoopTime)
