$local:conventions = @{
    "buildPath" = Join-Path $baseDir "build";
    "configPath" = Join-Path $baseDir "buildconfig";
    "sourcePath" = Join-Path $baseDir "Source";
}

function Get-Conventions(){
    $args | foreach {
        if($conventions.$_ -eq $null){
            throw "Convention not found: $_"
        }
        $conventions.$_
    }
}