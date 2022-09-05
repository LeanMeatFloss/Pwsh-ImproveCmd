BeforeAll{
    $env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "$PSScriptRoot/..")
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
AfterAll{

}