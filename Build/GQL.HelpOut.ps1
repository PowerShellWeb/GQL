#requires -Module HelpOut

#region Load the Module
Push-Location ($PSScriptRoot | Split-Path)
$importedModule = Import-Module .\ -Global -PassThru
#endregion Load the Module

# This will save the MarkdownHelp to the docs folder, and output all of the files created.
Save-MarkdownHelp -PassThru -Module $importedModule.Name -ExcludeCommandType Alias

Pop-Location