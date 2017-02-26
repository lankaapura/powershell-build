Task Cleanup {
    $buildPath = Get-Conventions buildPath
        
    if(Test-Path $buildPath){
        Write-Host "Cleaning $buildPath"    
        Remove-Item -Recurse $buildPath\*
    }else{
        Write-Host "Creating $buildPath"  
        New-Item -ItemType directory $buildPath    
    }
}