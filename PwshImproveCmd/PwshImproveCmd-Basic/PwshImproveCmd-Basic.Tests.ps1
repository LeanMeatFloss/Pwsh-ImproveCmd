BeforeAll{
    $env:PSModulePath=(Resolve-Path "$PSScriptRoot/..").Path+[IO.Path]::PathSeparator+$env:PSModulePath
    Import-Module PwshImproveCmd-Basic -Force
}
Describe "Get-FileNameFromPath" {
    It "Test for Get-FileNameFromPath" -Foreach @(
        @{Validate="C:\sdsdsds\ffff"; Expect="ffff"},
        @{Validate="C:/sdsdsds\ffff"; Expect="ffff"},
        @{Validate="C:\sdsdsds/ffff"; Expect="ffff"},
        @{Validate="C:\sdsdsds/ffff.sss"; Expect="ffff.sss"}
    ){
        $Validate|Get-FileNameFromPath|Should -Be $Expect
    }
}
Describe "Resolve-PathImproved" {
    It "Test for Resolve-PathImproved" -Foreach @(
        @{Validate="\sdsdsds\ffff"; Expect=("{0}sdsdsds{0}ffff" -f "$([System.IO.Path]::DirectorySeparatorChar)")},
        @{Validate="/sdsdsds\ffff"; Expect=("{0}sdsdsds{0}ffff" -f "$([System.IO.Path]::DirectorySeparatorChar)")},
        @{Validate="\sdsdsds/ffff"; Expect=("{0}sdsdsds{0}ffff" -f "$([System.IO.Path]::DirectorySeparatorChar)")},
        @{Validate="\sdsdsds/ffff.sss"; Expect=("{0}sdsdsds{0}ffff.sss" -f "$([System.IO.Path]::DirectorySeparatorChar)")},
        @{Validate="\\\sdsdsds///ffff.sss"; Expect=("{0}sdsdsds{0}ffff.sss" -f "$([System.IO.Path]::DirectorySeparatorChar)")},
        @{Validate="\/\sdsdsds////ffff.sss"; Expect=("{0}sdsdsds{0}ffff.sss" -f "$([System.IO.Path]::DirectorySeparatorChar)")}
    ){
        $Validate|Resolve-PathImproved|Should -Be $Expect
    }
}
Describe "Join-PathImproved" {
    It "Test for Join-PathImproved" -Foreach @(
        @{Arg1="\sdsdsds\ffff";Arg2="cccc\sss";Expect=("{0}sdsdsds{0}ffff{0}cccc{0}sss" -f "$([System.IO.Path]::DirectorySeparatorChar)")},
        @{Arg1="sdsdsds\ffff";Arg2="cccc/sss";Expect=("sdsdsds{0}ffff{0}cccc{0}sss" -f "$([System.IO.Path]::DirectorySeparatorChar)")}
    ){
        $Arg1|Join-PathImproved $Arg2|Should -Be $Expect
    }
}
Describe "Select-ObjectImproved" {
    It "Test Select First Items" {
        @(1212,434343,121256)|Select-ObjectImproved -First 2|Should -Be @(1212,434343)
        @(1212,434343,121256)|Select-ObjectImproved -First 1|Should -Be @(1212)
        @(1212,434343,121256)|Select-ObjectImproved -First 1|Should -Be 1212
    }
    It "Test Select Last Items" {
        @(123,222,123)|Select-ObjectImproved -Last 2|Should -Be @(222,123)
    }
    It "Test Select Unique Items" {
        @(123,222,123)|Select-ObjectImproved -HashScript {
            $_
        }|Should -Be @(123,222)
    }
    It "Test Select Unique Items" {
        @(123,"23232",123,"sfdsdsds")|Select-ObjectImproved -HashScript {
            0
        }|Should -Be @(123)
    }
}
Describe "Compare-ArrayItems"{
    It "Compare Array Length Mismatch"{
        Compare-ArrayItems @(1212),@(2323,443434)|Should -Be $false
    }
    It "Compare Array Content Mismatch"{
        Compare-ArrayItems @(1212,23232),@(2323,443434)|Should -Be $false
    }
    It "Compare Array Content match"{
        Compare-ArrayItems @(1212,23232),@(1212,23232)|Should -Be $false
    }
}
Describe "Rename-ItemToBak"{
    It "Test rename behavior"{   
        Mock -ModuleName PwshImproveCmd-Basic Test-Path{
            return $true
        }
        Mock -ModuleName PwshImproveCmd-Basic Remove-Item{
            return $true
        }   
        Mock -ModuleName PwshImproveCmd-Basic Rename-Item{
            
        }   
        "testhelper"|Rename-ItemToBak
        Should -Invoke -ModuleName PwshImproveCmd-Basic -CommandName 'Test-Path' -Times 1 -ParameterFilter {$PesterBoundParameters["Path"]-eq "testhelper"}
        Should -Invoke -ModuleName PwshImproveCmd-Basic -CommandName 'Test-Path' -Times 1 -ParameterFilter {$PesterBoundParameters["Path"]-eq "testhelper.bak"}
    }
}
Describe "Import-ModuleFromGallery"{
    BeforeAll{
        
    }
    It "Module shall not be updated if version not update"{        
        Mock -ModuleName PwshImproveCmd-Basic Get-InstalledModule{
            return @{Version="1.3.4"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Find-Module{
            return @{Version="1.3.4"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Update-Module{
            
        }
        Mock -ModuleName PwshImproveCmd-Basic Import-Module{
            
        }
        Import-ModuleFromGallery -ModuleName "Test"
        Should -Not -Invoke Update-Module -ModuleName PwshImproveCmd-Basic 
        Should -Invoke Get-InstalledModule  -ModuleName PwshImproveCmd-Basic
        Should -Invoke Find-Module -ModuleName PwshImproveCmd-Basic
        Should -Invoke Import-Module -ModuleName PwshImproveCmd-Basic
    }
    It "Module shall be updated if version not match"{        
        Mock -ModuleName PwshImproveCmd-Basic Get-InstalledModule{
            return @{Version="1.3.4"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Find-Module{
            return @{Version="1.3.6"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Update-Module{
            
        }
        Mock -ModuleName PwshImproveCmd-Basic Import-Module{
            
        }
        Import-ModuleFromGallery -ModuleName "Test"
        Should -Invoke Update-Module -ModuleName PwshImproveCmd-Basic 
        Should -Invoke Get-InstalledModule  -ModuleName PwshImproveCmd-Basic
        Should -Invoke Find-Module -ModuleName PwshImproveCmd-Basic
        Should -Invoke Import-Module -ModuleName PwshImproveCmd-Basic
    }
    It "Module shall be installed if module not existed"{      
        $script:CalledTimes=0  
        Mock -ModuleName PwshImproveCmd-Basic Get-InstalledModule{
            if($script:CalledTimes -eq 0){
                $script:CalledTimes++
                return
            }
            else{
                return @{Version="1.3.4"}
            }
            
        }
        Mock -ModuleName PwshImproveCmd-Basic Find-Module{
            return @{Version="1.3.4"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Update-Module{
            
        }
        Mock -ModuleName PwshImproveCmd-Basic Install-Module{
            
        }
        Mock -ModuleName PwshImproveCmd-Basic Import-Module{
            
        }
        Import-ModuleFromGallery -ModuleName "Test"
        Should -Not -Invoke Update-Module -ModuleName PwshImproveCmd-Basic 
        Should -Invoke Get-InstalledModule  -ModuleName PwshImproveCmd-Basic -Times 2
        Should -Invoke Find-Module -ModuleName PwshImproveCmd-Basic
        Should -Invoke Install-Module -ModuleName PwshImproveCmd-Basic
        Should -Invoke Import-Module -ModuleName PwshImproveCmd-Basic
    }
    It "Force shall be passed to Import-Module"{
        Mock -ModuleName PwshImproveCmd-Basic Get-InstalledModule{
            return @{Version="1.3.4"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Find-Module{
            return @{Version="1.3.4"}
        }
        Mock -ModuleName PwshImproveCmd-Basic Update-Module{
            
        }
        Mock -ModuleName PwshImproveCmd-Basic Import-Module{
            
        }
        Import-ModuleFromGallery -ModuleName "Test" -Force
        Should -Not -Invoke Update-Module -ModuleName PwshImproveCmd-Basic 
        Should -Invoke Get-InstalledModule  -ModuleName PwshImproveCmd-Basic
        Should -Invoke Find-Module -ModuleName PwshImproveCmd-Basic
        Should -Invoke Import-Module -ModuleName PwshImproveCmd-Basic -ParameterFilter {$PesterBoundParameters["Force"]}
    }
}
AfterAll{

}