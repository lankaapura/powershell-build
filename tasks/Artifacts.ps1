Task Artifacts {
    $buildPath, $configPath = Get-Conventions buildPath configPath
	
	if($config.artifact -eq $null){
		throw "Artifact configuration not defined"
	}
	
	$artifactSourcePath = Join-Path $buildPath $config.artifact.source
	$artifactTargetPath = Join-Path $buildPath $config.artifact.name	
	
	if(-not (Test-Path $artifactSourcePath)){
		throw "Artifact source not found: $artifactSourcePath"
	}	
	
    $envConfigPath = Join-Path $configPath $environment
    if(Test-Path -PathType Container $envConfigPath){
        Write-Host "Copying environment configuration"
        Get-ChildItem -Path $envConfigPath | ForEach {
            Write-Host " - $($_.FullName) -> $artifactSourcePath"
            Copy-Item $_.FullName -Destination $artifactSourcePath -Recurse -Force
        }
    }	

	Write-Host "Creating artifact: $artifactTargetPath"
	Invoke-ZipCreate $artifactSourcePath $artifactTargetPath
}