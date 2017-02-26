$local:mytasks = @{}

function Task([string]$name, [scriptblock]$scriptBlock){
    if($mytasks.$name -ne $null){
        throw "Task already defined: $name"
    }

    $mytasks.Add($name, $scriptBlock)
}

function Run-Task([string]$name){
    if($mytasks.$name -eq $null){
        throw "Task not defined: $name"
    }
    & $mytasks.$name
}