function Join-PathImproved {
    param (
        [parameter(ValueFromPipeline)]
        [string]
        $LeftPath,
        [parameter(Position=1)]
        [string[]]
        $RightPath=@("")
    )
    process{
        Join-Path (Resolve-PathImproved $LeftPath) ($RightPath|Resolve-PathImproved)
    }    
}
function Rename-ItemToBak{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $FilePath
    )
    process{
        if(Test-Path $FilePath){
            if(Test-Path "$FilePath.bak"){
                Remove-Item "$FilePath.bak" -Force
            }
            Rename-Item -Path $FilePath -NewName "$FilePath.bak" -Force
        }
    }
}
function Compare-ArrayItems{
    param(
        [array[]]
        $CompareArrays
    )
    process{
        # compare length equal
        $startLength=$CompareArrays[0].Length
        foreach ($currentItemName in $CompareArrays) {
            if($currentItemName.Length -ne $startLength){
                return $false
            }
        }
        for ($i = 1; $i -lt $CompareArrays.Count; $i++) {
            if($CompareArrays[$i].Length -ne $startLength){
                return $false
            }
            for ($j = 0; $j -lt $CompareArrays[$j].Count; $j++) {
                if($CompareArrays[$j] -ne $CompareArrays[$j-1]){
                    return $false
                }
            }
        }
        return $true
    }
}
function Resolve-PathImproved{
    param(
        [parameter(ValueFromPipeline,Position=1)]
        [string]
        $Path
    )
    process{
        $Path -replace "[\\/]+", "$([System.IO.Path]::DirectorySeparatorChar)"
    }
}
function Select-ObjectImproved{
    param(
        [parameter(ValueFromPipeline)]
        $InputObject,
        [int]
        $First=-1,
        [int]
        $Last=-1,    
        [scriptblock]    
        $HashScript
    )
    begin{
        $CurrentOutputNumber=0
        $CurrentInputObject=[System.Collections.ArrayList]@()
        $CurrentHashList=@{}
    }
    process{
        $continueProcess=$true
        if($HashScript){     
            $currentHash=$HashScript.InvokeWithContext($null,@(
                [psvariable]::new("_",$InputObject)
            ),$null)[0]
            if($CurrentHashList.ContainsKey($currentHash)){
                Write-Verbose "Find duplicate hash $currentHash with $InputObject at $($CurrentHashList[$currentHash])"
                $continueProcess=$false
            }
            else{
                $CurrentHashList[$currentHash]=$InputObject
            }
        }
        else{

        }
        if($continueProcess){
            if(($Last-eq -1)-and ($CurrentOutputNumber -ne $First)){
            
                $CurrentOutputNumber++
                return $InputObject
            }
            elseif($Last -gt 0){
                $CurrentInputObject.Add($InputObject)|Out-Null
            }
        }        
    }
    end{
        if($Last -gt 0){
            $CurrentInputObject[(0-$Last)..-1]
        }
        
    }
}
function Resolve-PSModuleDependenctForPester{
    param(
        [parameter(ValueFromPipeline,Position=1)]
        [string]
        $ModuleName
    )
    process{
        
    }
}
function Import-ModuleFromGallery{
    param(
        [parameter(ValueFromPipeline,Position=1)]
        [string]
        $ModuleName,
        [switch]
        $Force
    )
    process{
        if(Get-Module $ModuleName){

        }
        else{
            Install-Module $ModuleName -Force -Scope CurrentUser
        }
        $currentVersion=(Get-Module $ModuleName).Version
        $cloudVersion=(Find-Module $ModuleName).Version
        if($currentVersion -ne $cloudVersion){
            Update-Module $ModuleName
        }
        Import-Module $ModuleName -Force:$Force

    }
}
function Get-RelativePath{
    param (
        [parameter(ValueFromPipeline)]
        [string]
        $Path,
        [parameter(Position=0)]
        [string]
        $RootPath
    )
    process{
        [System.IO.Path]::GetRelativePath($RootPath,$Path)
    }
    
}
function Split-String{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $InputString,
        [parameter(Position=1)]
        [string]
        $Seperator
    )
    process{
        $InputString.Split("$Seperator")
    }
}
function Get-FileNameFromPath{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $Path
    )
    process{
        ($Path|Resolve-PathImproved|Split-String ([System.IO.Path]::DirectorySeparatorChar) |Select-ObjectImproved -Last 1)
    }
}
function Get-EnvironmentVariable{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $Name
    )
    process{
        Get-Item -Path "Env:\$Name"
    }
}
function Set-EnvironmentVariable{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $Name,
        [string]
        $Value
    )
    process{
        Set-Item -Path "Env:\$Name" -Value $Value
    }
}
function Add-ModulePathToEnv{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $Path,
        [switch]
        $First
    )
    process{
        $value="PSModulePath"|Get-EnvironmentVariable
        $paths=[System.Collections.ArrayList]$value.Split("[IO.Path]::PathSeparator")
        $overWrite=$false
        if($paths.Contains($Path)){
            if($First){
                if($paths[0] -ne $Path){
                    $paths.Remove($Path)
                    $paths.Insert(0,$Path)
                    $overWrite=$true
                }
            }
        }
        else{
            if($First){
                $paths.Insert(0,$Path)
            }
            else{
                $paths.Add($path)
            }
            $overWrite=$true
        }
        if($overWrite){
            "PSModulePath"|Set-EnvironmentVariable -Value ($paths -join "[IO.Path]::PathSeparator")
        }
    }
}
function Remove-ModulePathToEnv{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $Path
    )
    process{
        $value="PSModulePath"|Get-EnvironmentVariable
        $paths=[System.Collections.ArrayList]$value.Split("[IO.Path]::PathSeparator")
        $overWrite=$false
        if($paths.Contains($Path)){
            $overWrite=$true
            $paths.Remove($Path)
        }
        if($overWrite){
            "PSModulePath"|Set-EnvironmentVariable -Value ($paths -join "[IO.Path]::PathSeparator")
        }
    }
}