$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName = 'chocolatey-bginfo-startup'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Remove shortcut
if (Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\bginfo.lnk")
{
    Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\bginfo.lnk" -ErrorAction Ignore -Force
}

# Only remove bgi file if it is unmodified
$packageDate = (Get-Item "$toolsDir\custom.bgi").LastWriteTimeUtc
$installedDate = (Get-Item "c:\ProgramData\SysInternals\BGInfo\custom.bgi").LastWriteTimeUtc

if ($packageDate -eq $installedDate)
{
    Remove-Item "c:\ProgramData\SysInternals\BGInfo\custom.bgi"

    # Remove directories only if they are empty
    if ((Get-ChildItem "c:\ProgramData\SysInternals\BGInfo" -Force | Measure-Object).Count -eq 0)
    {
        Remove-Item "c:\ProgramData\SysInternals\BGInfo"
    }

        if ((Get-ChildItem "c:\ProgramData\SysInternals" -Force | Measure-Object).Count -eq 0)
    {
        Remove-Item "c:\ProgramData\SysInternals"
    }
}