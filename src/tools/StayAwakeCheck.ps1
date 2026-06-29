[CmdletBinding()]
Param(
        [Parameter(Position = 0, Mandatory = $false)]
	[string]$StayAwake = "Y"
    )

Get-Date
Get-Date | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8

powercfg /query SCHEME_CURRENT SUB_SLEEP 29f6c1db-86da-48c5-9fdb-f2b67b1f44da | findstr /i /c:"ac power"
powercfg /query SCHEME_CURRENT SUB_SLEEP 29f6c1db-86da-48c5-9fdb-f2b67b1f44da | findstr /i /c:"ac power" | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8

if ($StayAwake -eq "Y") {
   powercfg /change standby-timeout-ac 0
   Write-Host "sleep disabled"
   "sleep disabled" | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8
} else {
   powercfg /change standby-timeout-ac $StayAwake
   Write-Host "sleep after $StayAwake mins"
   "sleep after $StayAwake mins" | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8
}

powercfg /query SCHEME_CURRENT SUB_SLEEP 29f6c1db-86da-48c5-9fdb-f2b67b1f44da | findstr /i /c:"ac power"
powercfg /query SCHEME_CURRENT SUB_SLEEP 29f6c1db-86da-48c5-9fdb-f2b67b1f44da | findstr /i /c:"ac power" | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8

#############################

# Feign human presence, or it will go back to sleep after 30 mins (hidden setting on wake from sleep, no unlock)

$wsh = New-Object -ComObject WScript.Shell
Add-Type -AssemblyName System.Windows.Forms
$Pos = [System.Windows.Forms.Cursor]::Position

for ($i=0; $i -le 80; $i++) {
	$wsh.SendKeys('+{SCROLLLOCK}')
	$wsh.SendKeys('+{SCROLLLOCK}')
	Write-Host "Hit scroll lock twice"
	"Hit scroll lock twice" | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8

	$x = ($pos.X) + (((get-random) % 2) *2) -1
	$y = ($pos.Y) + (((get-random) % 2) *2) -1
	[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
	Write-Host "Moved mouse to $x,$y"
	"Moved mouse to $x,$y" | Out-File C:\pga\tools\wakecheck.log -Append -Encoding UTF8

	Start-Sleep 60
}
