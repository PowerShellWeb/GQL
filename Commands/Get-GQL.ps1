function Get-GQL
{
    <#
    .SYNOPSIS
        Gets a GraphQL query.
    .DESCRIPTION
        Gets a GraphQL query and returns the results as a PowerShell object.
    .EXAMPLE
        # Getting git sponsorship information from GitHub GraphQL.
        # **To use this example, we'll need to provide `$MyPat` with a Personal Access Token.**        
        Get-GQL -Query ./Examples/GitSponsors.gql -PersonalAccessToken $myPat
    .EXAMPLE
        # We can decorate graph object results to customize them.
        
        # Let's add a Sponsors property to the output object that returns the sponsor nodes.
        Update-TypeData -TypeName 'GitSponsors' -MemberName 'Sponsors' -MemberType ScriptProperty -Value {
            $this.viewer.sponsors.nodes
        } -Force

        # And let's add a Sponsoring property to the output object that returns the sponsoring nodes.
        Update-TypeData -TypeName 'GitSponsors' -MemberName 'Sponsoring' -MemberType ScriptProperty -Value {
            $this.viewer.sponsoring.nodes
        } -Force

        # And let's display sponsoring and sponsors by default
        Update-TypeData -TypeName 'GitSponsors' -DefaultDisplayPropertySet 'Sponsors','Sponsoring' -Force
        
        # Now we can run the query and get the results.
        Get-GQL -Query ./Examples/GitSponsors.gql -PersonalAccessToken $myPat -PSTypeName 'GitSponsors' | 
            Select-Object -Property Sponsors,Sponsoring
    #>
    [Alias('GQL','GraphAPI','GraphQL','GraphQueryLanguage')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
    # One or more queries to run.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string[]]
    $Query,

    # The Personal Access Token to use for the query.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Token','PAT','AccessToken')]
    [string]
    $PersonalAccessToken,

    # The GraphQL endpoint to query.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('uri')]
    [uri]
    $GraphQLUri = "https://api.github.com/graphql",

    # Any variables or parameters to provide to the query.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Parameters','Variable','Variables')]
    [Collections.IDictionary]
    $Parameter,

    # Any additional headers to include in the request
    [Alias('Headers')]
    [Collections.IDictionary]
    $Header,

    # Adds PSTypeName(s) to use for the output object, making it a decorated object.
    # By decorating an object with one or more typenames, we can:
    # 
    # * Add additional properties and methods to the object
    # * Format the output object any way we want    
    [Alias('Decorate','Decoration','PSTypeNames','TypeName','TypeNames','Type')]
    [string[]]
    $PSTypeName,

    # If set, will cache the results of the query.
    # This can be useful for queries that would be run frequently, but change infrequently.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Cache,

    # If set, will refresh the cache.
    # This can be useful to force an update of cached information.
    # `-Refresh` implies `-Cache` (it just will not return an uncached value).
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Refresh,

    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidatePattern('\.json$')]
    [string[]]
    $OutputPath
    )

    process {
        #region Handle Input
        # Capture the input object
        $inputObject = $_
        if ($inputObject -is [IO.FileInfo]) {
            if ($inputObject.Extension -notin '.gql','.graphql') {
                Write-Verbose "Skipping non-GQL file: $($inputObject.FullName)"
                continue
            }
        }
        #endregion Handle Input 
        
        #region Optionally Determine GraphQLUri from InvocationName
        if (-not $PSBoundParameters['GraphQLUri'] -and 
            $MyInvocation.InvocationName -match '\w+\.\w+/') {
            $GraphQLUri = $MyInvocation.InvocationName
        }
        #endregion Optionally Determine GraphQLUri from InvocationName

        #region Cache the Access Token
        if (-not $PSBoundParameters['PersonalAccessToken']) {
            if ($script:GraphQLTokenCache -is [Collections.IDictionary] -and 
                $script:GraphQLTokenCache.Contains($GraphQLUri)) {
                $PersonalAccessToken = $script:GraphQLTokenCache[$GraphQLUri]
            }
        } elseif ($PSBoundParameters['PersonalAccessToken']) {
            if (-not $script:GraphQLTokenCache) {
                $script:GraphQLTokenCache = [Ordered]@{}
            }
            $script:GraphQLTokenCache[$GraphQLUri] = $PersonalAccessToken
        }
        #endregion Cache the Access Token

        #region Prepare the REST Parameters
        $invokeSplat = @{
            Headers = if ($header) {
                $invokeSplat.Headers = [Ordered]@{} + $header
            } else {
                [Ordered]@{}
            }
            Uri = $GraphQLUri
            Method = 'POST'
        }
        $invokeSplat.Headers.Authorization = "bearer $PersonalAccessToken"
        #endregion Prepare the REST Parameters        

        #region Handle Each Query
        $queryNumber = -1
        :nextQuery foreach ($gqlQuery in $Query) {
            $queryNumber++
            $queryLines = @($gqlQuery -split '(?>\r\n|\n)')
            #region Check for File or Cached Query
            if ($queryLines.Length -eq 1) {                
                if ($script:GraphQLQueries -is [Collections.IDictionary] -and 
                    $script:GraphQLQueries.Contains($gqlQuery)) {
                    $gqlQuery = $script:GraphQLQueries[$gqlQuery]
                }

                if (Test-Path $gqlQuery) {
                    $newQuery = Get-Content -Path $gqlQuery -Raw
                    $gqlQuery = $newQuery
                } elseif ($query -match '[\\/]') {
                    $psCmdlet.WriteError(
                        [Management.Automation.ErrorRecord]::new(
                            [Exception]::new("Query file not found: '$gqlQuery'"),
                            'NotFound',
                            'ObjectNotFound',
                            $gqlQuery
                        )
                    )
                    continue nextQuery
                }
            }
            #endregion Check for File or Cached Query

            if ($PSBoundParameters['Refresh']) {
                $Cache = $true
            }

            $queryCacheKey = "$gqlQuery$(if ($Parameter) { $Parameter | ConvertTo-Json -Depth 10})"
            if ($Cache -and -not $script:GraphQLOutputCache) {
                $script:GraphQLOutputCache = [Ordered]@{}
            }

            if ($script:GraphQLOutputCache.$queryCacheKey -and                
                -not $Refresh
            ) {
                $script:GraphQLOutputCache.$queryCacheKey
                continue nextQuery
            }

            $queryOutPath =
                if ($OutputPath) {
                    if ($OutputPath[$queryNumber]) {
                        $OutputPath[$queryNumber]
                    } else {
                        $OutputPath[-1]
                    }
                }
                


            #region Run the Query
            $invokeSplat.Body = [Ordered]@{query = $gqlQuery}
            if ($Parameter) {
                $invokeSplat.Body.variables = $Parameter
            }
            if ($WhatIfPreference) {
                $invokeSplat.Headers.Clear()
                $invokeSplat
                continue nextQuery
            }
            $invokeSplat.Body = ConvertTo-Json -InputObject $invokeSplat.Body -Depth 10
            $shouldProcessMessage = "Querying $GraphQLUri with $gqlQuery"
            if (-not $PSCmdlet.ShouldProcess($shouldProcessMessage)) {
                continue nextQuery
            }
            $gqlOutput = Invoke-RestMethod @invokeSplat *>&1
            if ($gqlOutput -is [Management.Automation.ErrorRecord]) {
                $PSCmdlet.WriteError($gqlOutput)
                continue nextQuery
            }
            
            if ($gqlOutput.errors) {
                foreach ($gqlError in $gqlOutput.errors) {
                    $psCmdlet.WriteError((
                        [Management.Automation.ErrorRecord]::new(
                            [Exception]::new($gqlError.message), 
                            'GQLError', 
                            'NotSpecified', $gqlError
                        )
                    ))
                }
                continue nextQuery
            } 
                        
            if ($gqlOutput.data) {                
                $gqlOutput = $gqlOutput.data                
            }
                        
            if (-not $gqlOutput) {
                continue nextQuery
            }

            if ($PSTypeName) {
                $gqlOutput.pstypenames.clear()
                for ($goBackwards = $pstypename.Length - 1; $goBackwards -ge 0; $goBackwards--) {
                    $gqlOutput.pstypenames.add($pstypename[$goBackwards])
                }
            }
            if ($Cache) {
                $script:GraphQLOutputCache[$queryCacheKey] = $gqlOutput
            }
            if ($queryOutPath) {
                New-Item -ItemType File -Path $queryOutPath -Force -Value (
                    ConvertTo-Json -Depth 100 -InputObject $gqlOutput
                )
            } else {
                $gqlOutput
            }            
            #endregion Run the Query
            #endregion Handle Each Query
        }
    }
}
