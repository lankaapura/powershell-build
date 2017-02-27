Task NuGet {
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    $nuget = Join-Path $PSBuildPath "vendors\NuGet\nuget.exe"

    if(-not (Test-Path $nuget)){
        throw "NuGet not found: $nuget"
    }

    Get-ChildItem $sourcePath -Recurse -Filter "*.nuspec" | ? { $_.FullName -notmatch "\\packages\\?" } | ForEach {
        $projectDir = $_.Directory.FullName
        Write-Host "Creating NuGet package: $projectDir"
        Exec { & $nuget pack $projectDir -Version $buildNumber -OutputDirectory $buildPath -Properties "OutDir=$buildPath" }
    }
}