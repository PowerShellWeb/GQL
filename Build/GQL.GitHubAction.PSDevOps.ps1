#requires -Module PSDevOps
Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubAction

$PSScriptRoot | Split-Path | Push-Location

New-GitHubAction -Name "GetGQL" -Description 'Get GraphQL with PowerShell' -Action GQLAction -Icon chevron-right -OutputPath .\action.yml

Pop-Location