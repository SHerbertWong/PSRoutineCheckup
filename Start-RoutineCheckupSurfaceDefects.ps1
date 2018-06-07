Function Start-RoutineCheckupSurfaceDefects
{
	Function Get-DiskDriveDeviceID
	{
		Param
		(
			[String] $DriveLetter
		)

		$DiskPartitionName = Get-WmiObject -Class Win32_LogicalDiskToPartition | `
				Where-Object {$_.Dependent -match "cimv2\:Win32_LogicalDisk\.DeviceID=`"$([Regex]::Escape(($DriveLetter -replace '\\$', '')))`""} | `
				ForEach-Object {$_.Antecedent -match "cimv2\:Win32_DiskPartition\.DeviceID=`"(.+?)`"" > $NULL; $Matches[1]}

		if (-not ([Object]::ReferenceEquals($DiskPartitionName, $NULL)))
		{
			$DiskDriveDeviceID = Get-WmiObject -Class Win32_DiskDriveToDiskPartition | `
					Where-Object {$_.Dependent -match "cimv2\:Win32_DiskPartition\.DeviceID=`"$DiskPartitionName`""} | `
					ForEach-Object {$_.Antecedent -match "cimv2\:Win32_DiskDrive\.DeviceID=`"(\\\\\\\\\.\\.+?)`"" > $NULL; $Matches[1] -replace "\\\\","\"}
		}

		return $DiskDriveDeviceID
	}

	$NTNameDiskDriveTable = @{}
	$DiskDriveBadBlockTable = @{}
	$DiskDriveDriveLetterTable = @{}

	Write-Host -Object "Mapping disk drives with their NT namespace counterpart... " -NoNewline
	Get-WmiObject -Class Win32_DiskDrive | ForEach-Object `
	{
		$NTNameDiskDriveTable[(Get-NtSymbolicLinkObjectTargetName -LinkName $_.DeviceID)] = $_;
		# For marking disk drives as containing bad blocks
		$DiskDriveBadBlockTable[$_] = $FALSE
		# For mapping between disk drives and DOS device paths
		$DiskDriveDriveLetterTable[$_] = @()
	}
	Write-Host -Object "Done." -ForegroundColor Green

	Write-Host -Object "Mapping disk drives with existing DOS device paths... " -NoNewline
	Get-WmiObject -Class Win32_Volume | ForEach-Object `
	{
		$Volume = $_

		$DiskDriveBadBlockTable.Keys | ForEach-Object `
		{
			if ($_.DeviceID -eq (Get-DiskDriveDeviceID -DriveLetter $Volume.Name))
			{
				$DiskDriveDriveLetterTable[$_] += $Volume.Name
			}
		}
	}
	Write-Host -Object "Done." -ForegroundColor Green

	Write-Host -Object "Searching for bad block event records... " -NoNewline
	Get-EventLog -LogName System | Where-Object {$_.Source -eq "Disk" -and $_.EntryType -eq "Error" -and $_.EventID -eq 7} | ForEach-Object `
	{
		$EventLogMessage = $_.Message

		$NTNameDiskDriveTable.Keys | ForEach-Object `
		{
			if ($EventLogMessage -match $_)
			{
				$DiskDriveBadBlockTable[$_] = $TRUE
			}
		}
	}
	Write-Host -Object "Done." -ForegroundColor Green

	Write-Host
	Write-Host -Object "Results:"
	$DiskDriveDriveLetterTable.Keys | ForEach-Object `
	{
		Write-Host -Object "$([Char] 0x2022) Status of " -NoNewline
		Write-Host -Object $_.Model -NoNewline -ForegroundColor Cyan
		if ($DiskDriveDriveLetterTable[$_].length -gt -0)
		{
			Write-Host -Object " (contains " -NoNewline
			Write-Host -Object ($DiskDriveDriveLetterTable[$_] -join ", ") -NoNewline -ForegroundColor Cyan
			Write-Host -Object ")" -NoNewline
		}
		Write-Host -Object ": " -NoNewline
		if ($DiskDriveBadBlockTable[$_])
		{
			Write-Host -Object "Faulty." -ForegroundColor Red
		}
		else
		{
			Write-Host -Object "OK." -ForegroundColor Green
		}
	}
}
