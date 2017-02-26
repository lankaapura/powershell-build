Task Artifacts {
    $buildPath = Get-Conventions buildPath

    $config.artifacts.Keys | % { 
        $artifactConfig = $config.artifacts.Item($_)
        $artifactTargetPath = Join-Path $buildPath $_
        $artifactSourcePath = Join-Path $buildPath $artifactConfig.source;

        Write-Host "Creating artifact: $artifactTargetPath"
        Invoke-ZipCreate $artifactSourcePath $artifactTargetPath
    }
}