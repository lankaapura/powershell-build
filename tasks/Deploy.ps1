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
        Remove-Item "$($artifactConfig.path)\*" -Recurse -Force 
    }

    Write-Host "Extracting artifact to $($artifactConfig.path)"
    Invoke-ZipExtract $artifactPath $artifactConfig.path
}

Task Deploy {
    $buildPath = Get-Conventions buildPath

    $config.artifacts.Keys | % { 
        $artifactConfig = $config.artifacts.Item($_)
        $artifactPath = Join-Path $buildPath $_

        if($artifactConfig.deploy -ne $null){
            if(-not (Test-Path $artifactPath)){
                throw "Artifact not found: $artifactPath"
            }

            switch ($artifactConfig.deploy.strategy) 
            { 
                "filesystem" { Deploy-Filesystem $artifactPath $artifactConfig.deploy }
                default { throw "Deploy strategy not implemented: $($artifactConfig.deploy.strategy)" }
            }
        }
    }
}