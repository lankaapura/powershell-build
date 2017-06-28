function Deploy-Filesystem($artifactPath, $hashPath, $artifactConfig){
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

function Deploy-Ssh($artifactPath, $hashPath, $artifactConfig){
    $scpexe = [System.IO.Path]::Combine($PSBuildPath, "vendors", "Putty", "pscp.exe")
    $privateKeyPath = [System.IO.Path]::Combine($home, '.ssh', "$($artifactConfig.user)@$($artifactConfig.host)")

    if(-not (Test-Path $scpexe)){
        Write-Host -ForegroundColor Red "SCP not installed: $scpexe"
        exit 1
    }

    if(-not (Test-Path $privateKeyPath)){
        Write-Host -ForegroundColor Red "SSH private  key not found: $privateKeyPath"
        exit 1
    }

    Write-Host "Copying artifact to $($artifactConfig.host)"
	Exec { & $scpexe "-batch" "-q" "-i" "$privateKeyPath" "$artifactPath" "$hashPath" "$($artifactConfig.user)@$($artifactConfig.host):$($artifactConfig.target)" } 
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
    $hashPath = "$($artifactPath).SHA256"

	if(-not (Test-Path $artifactPath)){
		throw "Artifact not found: $artifactPath"
	}

	if(-not (Test-Path $hashPath)){
		throw "SHA256 file not found: $hashPath"
	}

	Write-Host "Deploying artifact $artifactPath with $($config.artifact.deploy.strategy) strategy"
	
	switch ($config.artifact.deploy.strategy) 
	{ 
		"filesystem" { Deploy-Filesystem $artifactPath $hashPath $config.artifact.deploy }
		"ssh" { Deploy-Ssh $artifactPath $hashPath $config.artifact.deploy }
		default { throw "Deploy strategy not implemented: $($artifactConfig.deploy.strategy)" }
	}
}