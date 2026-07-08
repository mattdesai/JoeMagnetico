[CmdletBinding()]
Param(
    [Int] $LoopTime = 0
)

$RunningFile  = Join-Path $PSScriptRoot "publishrunning.txt"
$stopFtpFile  = Join-Path $PSScriptRoot "stopftp.txt"
$psStatusFile = ".\html\jm.golfpool.us\htdocs\psStatus.html"


function Keep-Awake()
{
	# Changed this to ensure sleep is disabled when plugged in
	# $wsh = New-Object -ComObject WScript.Shell
	# $wsh.SendKeys('+{capslock}')
	# $wsh.SendKeys('+{capslock}')
	Write-Host "Disabled standy/sleep via powercfg"
	powercfg /change standby-timeout-ac 0
}

function Check-ForExit()
{
	if (Test-Path $stopFtpFile -PathType Leaf)
	{
		Write-Host "`rEnding."
		Remove-item $stopFtpFile -ErrorAction Ignore
		return $true
	}
	return $false
}

function Insert-Html {
	param(
		[string]$origFile
	)

	# $x = (gc $origFile)  -as [Collections.ArrayList]
	# $x.Insert(7,'<meta http-equiv="refresh" content="60" />')
	# $x.Insert(7,'<meta http-equiv="Pragma" content="no-cache" />')
	# $x.Insert(7,'<meta http-equiv="Expires" content="0" />')
	# $x.Insert(7,'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />')
	# $x.Insert(7,"<style> {margin:0;padding:0;} html { background: url('bg.jpg') no-repeat center center fixed; background-color: rgba(255,255,255,0.81); background-blend-mode: lighten; background-size: cover;} </style>")
	# # Used to have a sleep 1 before deleting all the temp files.  sharing violation?
	# Remove-Item $origFile
	# return ,$x

	# Read all lines natively as a string array
	$lines = Get-Content $origFile

	$tagsToInsert = @(
		'<meta http-equiv="refresh" content="60" />',
		'<meta http-equiv="Pragma" content="no-cache" />',
		'<meta http-equiv="Expires" content="0" />',
		'<meta http-equiv="Cache-control" content="no-cache, must-revalidate" />',
		"<style> {margin:0;padding:0;} html { background: url('bg.jpg') no-repeat center center fixed; background-color: rgba(255,255,255,0.81); background-blend-mode: lighten; background-size: cover;} </style>"
	)

	$output = @()
	$output += $lines[0..6]
	$output += $tagsToInsert
	if ($lines.Count -gt 7) {
		$output += $lines[7..($lines.Count - 1)]
	}

	Remove-Item $origFile -Force -ErrorAction Ignore

	return ,$output
}


# Initialization
Set-Location -Path "C:\pga" -ErrorAction Stop
Remove-item $stopFtpFile -ErrorAction Ignore
Keep-Awake
$currentDate = Get-Date -Format MM/dd

$statusMsg = "$($currentDate): Add-AutorefreshAndFtp Running.  LoopTime = $($LoopTime);  dir=$($(Get-Location).Path)"
Write-Host $statusMsg
"$statusMsg</br>" | Out-File -FilePath $psStatusFile -Append
$statusMsg | Out-File $RunningFile


Write-Host "1=No Update in >30 mins; 2=Updates Ready; 4=Status ready"
$lastUploadTime = Get-Date

try {

    do {

	try {
		if (Check-ForExit) { break }

		$currentTime = Get-Date
	        $state = 0

		if ($currentDate -lt (Get-Date -Format MM/dd))
		{
			$currentDate = Get-Date -Format MM/dd
			write-Host "`nNew date: $currentDate"
			"$currentDate</br>" | Out-File -FilePath $psStatusFile -Append
		}

		Write-Host -NoNewline "."

		$deltaTime = $currentTime - $lastUploadTime
		if ($deltaTime.TotalMinutes -ge 30)
		{
			$state = $state -bor 1
		}

		if (Test-Path '.\html\JoeMagnetico.htm')
		{
			# Immediately copy and remove
			(Get-Content .\html\JoeMagnetico.htm -Raw).Replace(";color:white;",";color:transparent;") | Set-Content .\html\tempJ.html
			(Get-Content .\html\Micro.htm -Raw).Replace(";color:white;",";color:transparent;") | Set-Content .\html\tempM.html
			Remove-Item '.\html\JoeMagnetico.htm', '.\html\Micro.htm' -Force -ErrorAction Ignore

			$hasStandings = $false
			if (Test-Path '.\html\JMStandings.htm')
			{
				$hasStandings = $true
				(Get-Content .\html\JMStandings.htm -Raw).Replace(";color:white;",";color:transparent;") | Set-Content .\html\tempJS.html
				(Get-Content .\html\MicroStandings.htm -Raw).Replace(";color:white;",";color:transparent;") | Set-Content .\html\tempMS.html
				Remove-Item '.\html\JMStandings.htm', '.\html\MicroStandings.htm' -Force -ErrorAction Ignore
			}

			# Write-Verbose "new html files to upload"
			$state = $state -bor 2

			$x = Insert-Html -origFile '.\html\tempJ.html'
			$y = Insert-Html -origFile '.\html\tempM.html'

			$x | Set-Content '.\html\jm.golfpool.us\htdocs\index.html' -Force # -Encoding UTF8
			$y | Set-Content '.\html\micro.golfpool.us\htdocs\index.html' -Force # -Encoding UTF8

			if ($hasStandings)
			{
				$a = Insert-Html -origFile '.\html\tempJS.html'
				$b = Insert-Html -origFile '.\html\tempMS.html'

				$a | Set-Content '.\html\jm.golfpool.us\htdocs\Standings.html' -Force # -Encoding UTF8
				$b | Set-Content '.\html\micro.golfpool.us\htdocs\Standings.html' -Force # -Encoding UTF8
			}
		}

		if (Test-Path '.\html\status.htm')
		{
			# Immediately copy and remove
			Copy-Item -Path .\html\status.htm -Destination .\html\jm.golfpool.us\htdocs\status.html -ErrorAction Ignore 
			Copy-Item -Path .\html\status.htm -Destination .\html\micro.golfpool.us\htdocs\status.html -ErrorAction Ignore 
			Remove-Item '.\html\status.htm' -ErrorAction Ignore 
			$state = $state -bor 4
		}

		if ($state -gt 0)
		{
			Write-Verbose "call winscp to upload..."
			$v = "$state - $((Get-Date -Format "HH:mm:ss").ToString()) - ftp."
			Write-Host $v
			"$v</br>" | Out-File -FilePath $psStatusFile -Append
			Copy-Item -Path  $psStatusFile -Destination .\html\micro.golfpool.us\htdocs -ErrorAction Ignore
			$lastUploadTime = Get-Date

			Start-Process -wait "\Program Files (x86)\WinSCP\WinSCP.exe" "/script=ftpUpload.txt"
		}
	}
	catch [System.Management.Automation.PipelineStoppedException] {
		# If Ctrl+C happens to hit inside the try block, throw to outer finally block
		throw 
        }
	catch {
		Write-Error $($_.Exception.Message)
	}

	Start-Sleep $LoopTime

    } while ($LoopTime)

}
finally
{
	write-host "`nExiting."
	Remove-Item $RunningFile -ErrorAction Ignore

	# if it exits prematurely/crash, dont want machine to sleep
	# powercfg /change standby-timeout-ac 90
}