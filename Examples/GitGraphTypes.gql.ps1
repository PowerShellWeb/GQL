#requires -Module GQL
if (-not $env:ReadOnlyToken) {
    Write-Warning "No ReadOnlyToken found."
    return
}

Push-Location $PSScriptRoot

# First, let's get the query
gql -Query ./GetSchemaTypeNames.gql -PersonalAccessToken $env:ReadOnlyToken -Cache -OutputPath ./GetSchemaTypeNames.json

Pop-Location