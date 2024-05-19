Param(
    [Int] $LoopTime = 0
)

# Add-Type -AssemblyName System.Windows.Forms
$wsh = New-Object -ComObject WScript.Shell

function Keep-Awake()
{
	$wsh.SendKeys('+{capslock}')
	$wsh.SendKeys('+{capslock}')

	# $Pos = [System.Windows.Forms.Cursor]::Position
	# $x = ($pos.X) + (((get-random) % 2) *2) - 1
	# $y = ($pos.Y) + (((get-random) % 2) *2) - 1

	# [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
}

function CheckForExit()
{
	$stopFile    = $PSScriptRoot + "\stop.txt"
	$stopXlsFile = $PSScriptRoot + "\stopxls.txt"

	if (Test-Path $stopFile -PathType Leaf)
	{
		Write-Host "Ending..."
		Remove-item $stopFile -ErrorAction Ignore
		"exit" | Out-File $stopXlsFile
		exit 5
	}
}

$url = 'https://www.pgatour.com/leaderboard'

$scoresFile  = $PSScriptRoot + "\scores.csv"
$fieldFile   = $PSScriptRoot + "\field.csv"
$doneFile    = $PSScriptRoot + "\GetScores.done"


do {
	CheckForExit

	Remove-item $scoresFile -ErrorAction Ignore
	Remove-item $fieldFile  -ErrorAction Ignore

	$html = Invoke-WebRequest $url -method GET   # -outfile XXXX -and- #$html= gc XXXX -Encoding utf8 -Raw

	$start = $html.content.IndexOf('"players":[{"__typename":"PlayerRowV')
	$end = $html.content.IndexOf('}],',$start) + 2
	$len = $end - $start

	$substr = $html.content.Substring($start,$len)

	$jsonText = "{" + $substr + "}"

	$leaderboard = $jsonText | ConvertFrom-Json

	$array = @()
	$cutline = $false

	foreach ($entry in $leaderboard.players)
	{
		if ($entry.__typename -eq "InformationRow")
		{
			#if (($entry.displaytext -match 'cut') -and (-not ($entry.displaytext -match 'Projected cut line')))
			if ($entry.displaytext -match 'failed to make the cut')
			{
				$cutline = $true
			}
		}
		else
		{
			$score = $($entry.scoringData.total)
			if (($cutline) -or ($($score) -eq '-'))
			{
				$score = "50"
			}
			else
			{
				if (($($score) -eq "E") -or ($($score) -eq $null))
				{
					$score = "0";
				}
				$score = [int]$($score)
			}
			$array += [pscustomobject]@{Name="$($entry.player.displayName)";Score=$score}
		}
	}

	"Player, Score" | Out-file $scoresFile -Encoding UTF8

	$array | % { $_.Name + ", " + $_.Score | Out-File -FilePath $scoresFile -Encoding UTF8 -Append }
	$array | % { $_.Name | Out-File -FilePath $fieldFile -Encoding UTF8 -Append }

	Write-Host "$((Get-Date -Format "HH-mm-ss").ToString()) - Leaderboard saved to $scoresFile"
	"Done" | Out-file $doneFile

	Keep-Awake
	Start-Sleep $LoopTime

} while ($LoopTime)
