param(
    [switch] $RunImmediately
)

$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName= 'chocolatey-bginfo-startup' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$arguments = @{}
$packageParameters = $env:chocolateyPackageParameters

# Now parse the packageParameters using good old regular expression
if ($packageParameters) {
    $match_pattern = "\/(?<option>([a-zA-Z]+)):(?<value>([`"'])?([a-zA-Z0-9- _\\:\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
    $option_name = 'option'
    $value_name = 'value'

    if ($packageParameters -match $match_pattern ){
        $results = $packageParameters | Select-String $match_pattern -AllMatches
        $results.matches | % {
        $arguments.Add(
            $_.Groups[$option_name].Value.Trim(),
            $_.Groups[$value_name].Value.Trim())
    }
    }
    else
    {
        Throw "Package Parameters were found but were invalid (REGEX Failure)"
    }

    if ($arguments.ContainsKey("RunImmediately")) {
        Write-Verbose "You want to run bginfo"
        $RunImmediately = [switch]::Present
    }
} else {
    Write-Debug "No Package Parameters Passed in"
}

# Copy custom.bgi if it doesn't already exist
if (-not (Test-Path "c:\ProgramData\SysInternals\BGInfo\custom.bgi"))
{
    if (-not (Test-Path "c:\ProgramData\SysInternals\BGInfo"))
    {
        New-Item "c:\ProgramData\SysInternals\BGInfo" -ItemType Container | Out-Null
    }

    Copy-Item -Path "$toolsDir\custom.bgi" -Destination "c:\ProgramData\SysInternals\BGInfo\custom.bgi"
}

Install-ChocolateyShortcut -shortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\bginfo.lnk" -targetPath "C:\ProgramData\chocolatey\bin\Bginfo.exe" -arguments "c:\ProgramData\SysInternals\BGInfo\custom.bgi /nolicprompt /timer:0" -description "Launch bginfo silently and use custom.bgi"

if ($RunImmediately.IsPresent)
{
    & "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\bginfo.lnk"
}