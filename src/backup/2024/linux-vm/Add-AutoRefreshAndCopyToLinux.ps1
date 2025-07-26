Param(
    [Int] $LoopTime = 0
)

do {
	
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
		$x.Insert(7,'<style> body:before { content: ""; position: absolute; top: 0; bottom: 0; left: 0; right: -70; z-index: 1; background-image: url(''bg.jpg''); opacity: 0.15; } </style>')

		$x | Set-Content '.\html\index.html' -Force -Encoding UTF8

		$y.Insert(7,'<meta http-equiv="refresh" content="60" />')
		$y.Insert(7,'<meta http-equiv="Pragma" content="no-cache" />')
		$y.Insert(7,'<meta http-equiv="Expires" content="0" />')
		$y.Insert(7,'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />')
		$y.Insert(7,'<style> body:before { content: ""; position: absolute; top: 0; bottom: 0; left: 0; right: -70; z-index: 1; background-image: url(''bg.jpg''); opacity: 0.15; } </style>')

		$y | Set-Content '.\html\micro.html' -Force -Encoding UTF8

		# Start-Process -wait "\Program Files (x86)\WinSCP\WinSCP.exe" "/script=ftpSettingsMicro.txt"
		# Write-Host "$((Get-Date -Format "HH-mm-ss.MM-dd").ToString()) - ftp upload complete."
		.\tolinux.ps1 | Out-Null

		Write-Host "$((Get-Date -Format "HH-mm-ss").ToString()) - html copied to linux."
	}

	Start-Sleep $LoopTime

} while ($LoopTime)
