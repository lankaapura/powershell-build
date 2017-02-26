Task NUnitTestCoverage {
    $buildPath = Get-Conventions buildPath

    $opencover = "$PSBuildPath\vendors\OpenCover\OpenCover.Console.exe"
    $nunit = "$PSBuildPath\vendors\NUnit.Console\nunit3-console.exe"
    $reportGenerator = "$PSBuildPath\vendors\ReportGenerator\ReportGenerator.exe"
    $xpathQuery = "$PSBuildPath\vendors\XPathQuery\XPathQuery.exe"

    if(-not (Test-Path $opencover)){
        throw "OpenCover not found: $opencover"
    }

    if(-not (Test-Path $nunit)){
        throw "NUnit not found: $nunit"
    }

    if(-not (Test-Path $reportGenerator)){
        throw "ReportGenerator not found: $reportGenerator"
    }

    if(-not (Test-Path $xpathQuery)){
        throw "XPathQuery not found: $xpathQuery"
    }

    $testPaths = (Get-ChildItem -Path $buildPath -Recurse -Filter "*.Tests.dll" | select -ExpandProperty FullName) -join ' '
    $testResultPath = Join-Path $buildPath "TestResults.xml"
    $coverageResultPath = Join-Path $buildPath "CoverageResults.xml"
    $coverageReportPath = Join-Path $buildPath "CoverageReport"
    
    Exec { 
        & $opencover `
        "-target:$nunit" `
        "-targetargs:$testPaths --result=$testResultPath" `
        "-filter:+[*]* -[$($config.applicationName)*.Tests]* $COVERAGE_FILTERS" `
        "-output:$coverageResultPath" `
        "-skipautoprops" `
        "-register:user" `
        "-returntargetcode"
    }

    Exec { 
        & $reportGenerator `
        "-reports:$coverageResultPath" `
        "-targetdir:$coverageReportPath" `
        "-verbosity:Error"
    }

    $coveragePerc = (& $xpathQuery "//Summary/@sequenceCoverage" $coverageResultPath) -as [double]

    if($coveragePerc -lt $config.coverageThreshold){
        Write-Host "Code coverage does not meet threshold: $($config.coverageThreshold)"
        exit 1        
    }

    Write-Host "Code coverage is $coveragePerc (Threshold: $($config.coverageThreshold))"
}