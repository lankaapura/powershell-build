Task Cleanup {
    $buildPath = Get-Conventions buildPath
        
    if(Test-Path $buildPath){
        Write-Host "Cleaning $buildPath"    
        $fso = New-Object -ComObject scripting.filesystemobject
        $fso.DeleteFolder(“$buildPath\*”)
        Get-ChildItem -Path $buildPath -Include * | ForEach { Remove-Item $_.FullName -Force }
    }else{
        Write-Host "Creating $buildPath"  
        New-Item -ItemType directory $buildPath    
    }
}
