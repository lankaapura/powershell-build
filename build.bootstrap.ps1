param(
    [Parameter(Mandatory=$true)]
    [string]$baseDir,
    [string]$workflow = "build",
    [string]$environment = "dev",
    [string]$buildNumber="1.0.0")

$PSBuildPath = Join-Path $baseDir "PSBuild"
$private:taskExecutionInfo = @();
$private:totalBuildTime = New-TimeSpan;

Get-ChildItem (Join-Path $PSBuildPath "shared") | Where { $_.Name -like '*.ps1'} | ForEach { . $_.FullName }

$private:buildPath, $private:configPath = Get-Conventions buildPath configPath
$private:configFilePath = Join-Path $configPath "config.ps1"
$private:configFileEnvPath = Join-Path $configPath "${environment}.ps1"

if (-not (Test-Path $configFilePath)) { 
    throw "Configuration file not found: ${configFilePath}"
}

. $configFilePath

if (Test-Path $configFileEnvPath) { 
    . $configFileEnvPath
}

Get-ChildItem (Join-Path $PSBuildPath "tasks") | Where { $_.Name -like '*.ps1'} | ForEach { . $_.FullName }

Write-Host "base dir: $baseDir"
Write-Host "workflow: $workflow"
Write-Host "environment: $environment"
Write-Host "build number: $buildNumber"

try{
    $config.workflows.$workflow | foreach {
        Write-Host "Task started: $_"
        $sw = [Diagnostics.Stopwatch]::StartNew()
        Run-Task $_
        $sw.Stop()
        $totalBuildTime += $sw.Elapsed
        $taskExecutionInfo += @{ "Name" = $_; "Elapsed" = $sw.Elapsed; }
        Write-Host "Task completed: $_"
    }
}catch{
    Write-Host -ForegroundColor Red "Build FAILED!"
    Write-Error $_
    exit 1
}

$taskExecutionInfo += @{ "Name" = "TOTAL"; "Elapsed" = $totalBuildTime; }
$taskExecutionInfo | % { new-object PSObject -Property $_} | Format-Table -AutoSize
Write-Host -ForegroundColor Green "Build OK!"
exit 0
