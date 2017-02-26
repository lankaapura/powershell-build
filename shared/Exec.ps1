function Exec(
    [ScriptBlock] $ScriptBlock,
    [string] $StderrPrefix = "",
    [int[]] $AllowedExitCodes = @(0),
    [string] $execDir = "")
{ 
    $backupCurrentLocation = Get-Location
 
    if(-not($execDir -eq "")){
        Write-Host "Changing location to $execDir"
        Set-Location $execDir
    }
    
    try
    {
        & $ScriptBlock 2>&1 | ForEach-Object -Process {
            if ($_ -is [System.Management.Automation.ErrorRecord])
            {
                Write-Host "$StderrPrefix$_"
            }
            else
            {
                Write-Host "$_"
            }
        }
        if ($AllowedExitCodes -notcontains $LASTEXITCODE)
        {
            throw "Execution failed with exit code $LASTEXITCODE"
        }
    }
    finally
    {
        if(-not($execDir -eq "")){
            Write-Host "Reverting location to $backupCurrentLocation"
            Set-Location $backupCurrentLocation
        }        
    }
}