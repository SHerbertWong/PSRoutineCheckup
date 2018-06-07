#REQUIRES -version 2.0

if ($__Module__PSRoutineCheckup) {exit}

Import-Module $PSScriptRoot\..\PSNtObjectManager
Get-ChildItem -Path $PSScriptRoot\*.ps1 | Foreach-Object {. $_.FullName}
New-Variable -Name '__Module__PSRoutineCheckup' -Value $TRUE -Option Constant -Scope Global -Force
