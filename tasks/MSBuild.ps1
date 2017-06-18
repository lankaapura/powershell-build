Task MsBuild {
    $buildPath, $configPath, $sourcePath = Get-Conventions buildPath configPath sourcePath
    $solutionPath = Join-Path $sourcePath "$($config.applicationName).sln"
	
	if(-not (Test-Path $solutionPath)){
        throw "Solution path not found: $solutionPath"
    }
	
	if($env:MSBUILD -eq $null){
		throw "MSBUILD environment variable not defined"
	}
	
	if(-not (Test-Path $env:MSBUILD)){
		throw "MSBUILD not found: ${$env:MSBUILD}"
	}

	Write-Host "Using MSBUILD: ${$env:MSBUILD}"
    # OutDir property MUST end with two slashes when called through powershell
    Exec { & $env:MSBUILD $solutionPath "/target:Rebuild" "/p:OutDir=$buildPath\\" "/p:Configuration=Release" "/p:Platform=Any Cpu" }
}