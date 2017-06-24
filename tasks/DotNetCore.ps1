$Local:dotnetConfiguration = "Release"
$Local:dotnetFramework = "netcoreapp1.1"
$Local:dotnetRuntime = "win10-x64"
#debian.8-x64

Task DotnetcoreBuild{
    $sourcePath = Get-Conventions sourcePath
    $projectPath = Join-Path $sourcePath "$($config.applicationName).sln"

    Exec { & dotnet clean --framework $dotnetFramework --configuration $dotnetConfiguration --verbosity normal $projectPath }
    Exec { & dotnet restore --runtime $dotnetRuntime --verbosity normal $projectPath }
    Exec { & dotnet build --runtime $dotnetRuntime --framework $dotnetFramework --configuration $dotnetConfiguration --verbosity normal $projectPath }
}


Task DotnetcoreTest{
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    (Get-ChildItem -Path $sourcePath -Recurse -Filter "*.UnitTests.csproj") | ForEach {
        $outputPath = Join-Path $_.Directory "bin/$dotnetConfiguration/$dotnetFramework/$dotnetRuntime"

        Exec { & dotnet test --framework $dotnetFramework --configuration $dotnetConfiguration --no-build --output $outputPath $_.FullName }
    }
}

Task DotnetcorePublish {
    $buildPath, $sourcePath = Get-Conventions buildPath sourcePath
    $projectPath = Join-Path $sourcePath "$($config.applicationName)/$($config.applicationName).csproj"
    $publishPath = Join-Path $buildPath "published-apps/$($config.applicationName)"

    Exec { & dotnet publish --runtime $dotnetRuntime --framework $dotnetFramework --configuration $dotnetConfiguration --output $publishPath --verbosity normal $projectPath }
}