Get-GQL
-------

### Synopsis
Gets a GraphQL query.

---

### Description

Gets a GraphQL query and returns the results as a PowerShell object.

---

### Examples
Getting git sponsorship information from GitHub GraphQL.
**To use this example, we'll need to provide `$MyPat` with a Personal Access Token.**        

```PowerShell
Get-GQL -Query ./Examples/GitSponsors.gql -PersonalAccessToken $myPat
```
We can decorate graph object results to customize them.
Let's add a Sponsors property to the output object that returns the sponsor nodes.

```PowerShell
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
```

---

### Parameters
#### **Query**
One or more queries to run.

|Type        |Required|Position|PipelineInput        |Aliases |
|------------|--------|--------|---------------------|--------|
|`[String[]]`|false   |1       |true (ByPropertyName)|FullName|

#### **PersonalAccessToken**
The Personal Access Token to use for the query.

|Type      |Required|Position|PipelineInput        |Aliases                      |
|----------|--------|--------|---------------------|-----------------------------|
|`[String]`|false   |2       |true (ByPropertyName)|Token<br/>PAT<br/>AccessToken|

#### **GraphQLUri**
The GraphQL endpoint to query.

|Type   |Required|Position|PipelineInput        |Aliases|
|-------|--------|--------|---------------------|-------|
|`[Uri]`|false   |3       |true (ByPropertyName)|uri    |

#### **Parameter**
Any variables or parameters to provide to the query.

|Type           |Required|Position|PipelineInput        |Aliases                              |
|---------------|--------|--------|---------------------|-------------------------------------|
|`[IDictionary]`|false   |4       |true (ByPropertyName)|Parameters<br/>Variable<br/>Variables|

#### **Header**
Any additional headers to include in the request

|Type           |Required|Position|PipelineInput|Aliases|
|---------------|--------|--------|-------------|-------|
|`[IDictionary]`|false   |5       |false        |Headers|

#### **PSTypeName**
Adds PSTypeName(s) to use for the output object, making it a decorated object.
By decorating an object with one or more typenames, we can:
* Add additional properties and methods to the object
* Format the output object any way we want

|Type        |Required|Position|PipelineInput|Aliases                                                                    |
|------------|--------|--------|-------------|---------------------------------------------------------------------------|
|`[String[]]`|false   |6       |false        |Decorate<br/>Decoration<br/>PSTypeNames<br/>TypeName<br/>TypeNames<br/>Type|

#### **Cache**
If set, will cache the results of the query.
This can be useful for queries that would be run frequently, but change infrequently.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|

#### **Refresh**
If set, will refresh the cache.
This can be useful to force an update of cached information.
`-Refresh` implies `-Cache` (it just will not return an uncached value).

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|

#### **WhatIf**
-WhatIf is an automatic variable that is created when a command has ```[CmdletBinding(SupportsShouldProcess)]```.
-WhatIf is used to see what would happen, or return operations without executing them
#### **Confirm**
-Confirm is an automatic variable that is created when a command has ```[CmdletBinding(SupportsShouldProcess)]```.
-Confirm is used to -Confirm each operation.

If you pass ```-Confirm:$false``` you will not be prompted.

If the command sets a ```[ConfirmImpact("Medium")]``` which is lower than ```$confirmImpactPreference```, you will not be prompted unless -Confirm is passed.

---

### Syntax
```PowerShell
Get-GQL [[-Query] <String[]>] [[-PersonalAccessToken] <String>] [[-GraphQLUri] <Uri>] [[-Parameter] <IDictionary>] [[-Header] <IDictionary>] [[-PSTypeName] <String[]>] [-Cache] [-Refresh] [-WhatIf] [-Confirm] [<CommonParameters>]
```
