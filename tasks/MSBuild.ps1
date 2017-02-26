Task MsBuild {
    $msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
    $buildPath, $configPath, $sourcePath = Get-Conventions buildPath configPath sourcePath
    $solutionPath = Join-Path $sourcePath "$($config.applicationName).sln"

    if(-not (Test-Path $msbuild)){
        throw "MSBuild not found: $msbuild"
    }

    if(-not (Test-Path $solutionPath)){
        throw "Solution path not found: $solutionPath"
    }


    # OutDir property MUST end with two slashes when called through powershell
    Exec { & $msbuild $solutionPath "/target:Rebuild" "/p:OutDir=$buildPath\\" "/p:Configuration=Release" "/p:Platform=Any Cpu" }

    $envConfigPath = Join-Path $configPath $environment
    if(Test-Path -PathType Container $envConfigPath){
        $destinationPath = Join-Path $buildPath "_PublishedWebsites\$($config.applicationName)"
        Write-Host "Copying environment configuration"
        Get-ChildItem -Path $envConfigPath | ForEach {
            Write-Host " - $($_.FullName) -> " + $destinationPath
            Copy-Item $_.FullName -Destination $destinationPath -Recurse -Force
        }
    }
}