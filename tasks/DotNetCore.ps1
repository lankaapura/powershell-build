$Local:dotnetConfiguration = "Release"
$Local:dotnetFramework = "netcoreapp1.1"
$Local:dotnetRuntime = "portable"
#debian.8-x64

function XUnitTests([string]$sourcePath, [string]$projectFilter){
    (Get-ChildItem -Path $sourcePath -Recurse -Filter $projectFilter) | ForEach {
        $outputPath = Join-Path $_.Directory "bin/$dotnetConfiguration/$dotnetFramework"

        Exec { & dotnet test --framework $dotnetFramework --configuration $dotnetConfiguration --no-build --output $outputPath --verbosity normal $_.FullName }
    }    
}

Task DotnetBuild{
    $sourcePath = Get-Conventions sourcePath
    $projectPath = Join-Path $sourcePath "$($config.applicationName).sln"

    Write-Host "Build runtime: $dotnetRuntime"

    Exec { & dotnet clean --framework $dotnetFramework --configuration $dotnetConfiguration --verbosity normal $projectPath }
    Exec { & dotnet restore --verbosity normal $projectPath }
    Exec { & dotnet build --framework $dotnetFramework --configuration $dotnetConfiguration --verbosity normal $projectPath }
}

Task DotnetUnitTests{
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    XUnitTests $sourcePath "*.UnitTests.csproj"
}

Task DotnetIntegrationTests{
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    XUnitTests $sourcePath "*.IntegrationTests.csproj"
}

Task DotnetRegressionTests{
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    XUnitTests $sourcePath "*.RegressionTests.csproj"
}

Task DotnetPublish {
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    $projectPath = Join-Path $sourcePath "$($config.applicationName)/$($config.applicationName).csproj"
    $publishPath = Join-Path $buildPath "published-apps/$($config.applicationName)"

    Exec { & dotnet publish --framework $dotnetFramework --configuration $dotnetConfiguration --output $publishPath --verbosity normal $projectPath }
}