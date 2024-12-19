#requires -Module GQL
if (-not $env:GitHubToken) {
    Write-Warning "No GitHubToken found."
    return
}

Push-Location $PSScriptRoot

# First, let's get the query
gql -Query ./GetSchemaTypes.gql -PersonalAccessToken $env:GitHubToken -Cache -OutputPath ./GitHubGraphTypes.json

Pop-Location