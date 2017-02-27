Task Cleanup {
    $buildPath = Get-Conventions buildPath
        
    if(Test-Path $buildPath){
        Write-Host "Cleaning $buildPath"    
        Get-ChildItem $buildPath | ForEach { Remove-Item $_.FullName -Recurse -Force }
    }else{
        Write-Host "Creating $buildPath"  
        New-Item -ItemType directory $buildPath    
    }
}
