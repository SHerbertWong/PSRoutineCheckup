Function Start-RoutineCheckup
{
	Clear-Host
	Write-Host
	Write-Host -Object "Stage 1: Disk drive surface defects"
	Write-Host -Object "==================================="
	Write-Host
	Start-RoutineCheckupSurfaceDefects
	Write-Host
	& CMD /C PAUSE
	
	Clear-Host
	Write-Host
	Write-Host -Object "Stage 2: Free space availability on logical drives"
	Write-Host -Object "=================================================="
	Write-Host
	Start-RoutineCheckupFreeSpace
	Write-Host
	& CMD /C PAUSE

	Clear-Host
	Write-Host
	Write-Host -Object "Stage 3: Event log clean-up"
	Write-Host -Object "==========================="
	Write-Host
	Start-RoutineCheckupEventLogCleanUp
	Write-Host
	& CMD /C PAUSE

	Clear-Host
	Write-Host
    Write-Host -Object "Stage 4: Temporary file clean-up"
    Write-Host -Object "================================"
    Write-Host
	Start-RoutineCheckupTempFileCleanUp
	Write-Host
	& CMD /C PAUSE

	Write-Host
	Write-Host -Object "End of Routine Checkup. " -NoNewline
	& CMD /C PAUSE
}
