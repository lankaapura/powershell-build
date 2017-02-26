$local:7zexe = "$PSBuildPath\vendors\7z\7za.exe"

if(-not(Test-Path $7zexe)){
    Write-Host -ForegroundColor Red "7zip not installed: $7zexe"
    exit 1
}

function Invoke-ZipCreate{
    param(
        [Parameter(Mandatory=$true)]
        [string] $dir,
        [Parameter(Mandatory=$true)]
        [string] $target
    )
    
    if(Test-Path $target){
        Write-Host "Removing $target"
        Remove-Item $target
    }

    Exec -execDir $dir { & $7zexe "a" "-tzip" "$target" "*" }
}

function Invoke-ZipExtract{
    param(
        [Parameter(Mandatory=$true)]
        [string] $target,
        [Parameter(Mandatory=$true)]
        [string] $dir
    )

    Write-Host "target $target"
    Write-Host "dir $dir"
    Exec { & $7zexe "x" "$target" "-o$dir" }
}