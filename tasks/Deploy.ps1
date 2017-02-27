function Deploy-Filesystem($artifactPath, $artifactConfig){
    Write-Host "Deploying artifact $artifactPath with filesystem strategy"

    if($artifactConfig.path -eq $null -or $artifactConfig.path.length -eq 0){
        throw "Deploy configuration invalid: missing 'path'"
    }

    if(-not (Test-Path $artifactConfig.path)){
        Write-Host "Creating target path: $($artifactConfig.path)"
        New-Item -ItemType Directory $artifactConfig.path
    }else{
        Write-Host "Target path exists, cleaning: $($artifactConfig.path)"
        $fso = New-Object -ComObject scripting.filesystemobject
        $fso.DeleteFolder(“$($artifactConfig.path)\*”)
        Get-ChildItem -Path $artifactConfig.path -Include * | ForEach { Remove-Item $_.FullName }
    }

    Write-Host "Extracting artifact to $($artifactConfig.path)"
    Invoke-ZipExtract $artifactPath $artifactConfig.path
}

Task Deploy {
    $buildPath = Get-Conventions buildPath

	if($config.artifact -eq $null){
		throw "Artifact configuration not defined"
	}	
	
	if($config.artifact.deploy -eq $null){
		throw "Deploy configuration not defined"
	}		
	
	$artifactPath = Join-Path $buildPath $config.artifact.name
	if(-not (Test-Path $artifactPath)){
		throw "Artifact not found: $artifactPath"
	}

	switch ($config.artifact.deploy.strategy) 
	{ 
		"filesystem" { Deploy-Filesystem $artifactPath $config.artifact.deploy }
		default { throw "Deploy strategy not implemented: $($artifactConfig.deploy.strategy)" }
	}
}