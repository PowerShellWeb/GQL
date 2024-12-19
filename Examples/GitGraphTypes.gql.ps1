#requires -Module GQL
if (-not $GitHubToken) {
    Write-Warning "No GitHubToken found."
    return
}

Push-Location $PSScriptRoot

# First, let's get the query
gql -Query ./GetSchemaTypes.gql -PersonalAccessToken $GitHubToken -Cache -OutputPath ./GitHubGraphTypes.json

Pop-Location