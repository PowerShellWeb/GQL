<div align='center'>
    <img alt='GQL Logo (Animated)' style='width:33%' src='Assets/GQL-Animated.svg' />
</div>

# GQL

Get Graph Query Language with PowerShell.

GQL is a small PowerShell module for GraphQL.

It is designed to provide a simple GraphQL client in PowerShell.

We can use this as a direct client to GraphQL, without having to involve any other layer.


## GQL Container

You can use the GQL module within a container:

~~~powershell
docker pull ghcr.io/powershellweb/gql
docker run -it ghcr.io/powershellweb/gql
~~~

### Installing and Importing

~~~PowerShell
Install-Module GQL -Scope CurrentUser -Force
Import-Module GQL -Force -PassThru
~~~

### Get-GQL

To connect to a GQL and get results, use [Get-GQL](Get-GQL.md), or, simply `GQL`.

(like all functions in PowerShell, it is case-insensitive)

### More Examples

#### Get-GQL Example 1

~~~powershell
# Getting git sponsorship information from GitHub GraphQL.
# **To use this example, we'll need to provide `$MyPat` with a Personal Access Token.**        
Get-GQL -Query ./Examples/GitSponsors.gql -PersonalAccessToken $myPat
~~~
 #### Get-GQL Example 2

~~~powershell
# We can decorate graph object results to customize them.
~~~
