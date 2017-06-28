Task Artifacts {
    $buildPath, $configPath = Get-Conventions buildPath configPath
	
	if($config.artifact -eq $null){
		throw "Artifact configuration not defined"
	}
	
	$sourcePath = Join-Path $buildPath $config.artifact.source
	$archivePath = Join-Path $buildPath $config.artifact.name	
	$hashPath = "$($archivePath).SHA256"
	
	if(-not (Test-Path $sourcePath)){
		throw "Artifact source not found: $sourcePath"
	}	
	
    $envConfigPath = Join-Path $configPath $environment
    if(Test-Path -PathType Container $envConfigPath){
        Write-Host "Copying environment configuration"
        Get-ChildItem -Path $envConfigPath | ForEach {
            Write-Host " - $($_.FullName) -> $sourcePath"
            Copy-Item $_.FullName -Destination $sourcePath -Recurse -Force
        }
    }	

	Write-Host "Creating artifact: $archivePath"
	Invoke-ZipCreate $sourcePath $archivePath
	[System.IO.File]::WriteAllText($hashPath, (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash, [System.Text.Encoding]::ASCII)	
}