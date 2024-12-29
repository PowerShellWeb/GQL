# Security

We take security seriously.  If you believe you have discovered a vulnerability, please [file an issue](https://github.com/PowerShellWeb/GQL/issues).

## Special Security Considerations

When using this module, take care to secure your GraphQL token.  _Never_ hardcode a value, even as an example.

GraphQL is very powerful, and the Graph API should be queried carefully.

It is also highly recommended you use a Graph API token with limited rights.  

Using your own personal access token can compromise your account.

Finally, and importantly, review any queries that you run before you run them.  

Any GraphQL query you did not write could do more than you expect it to.

### -WhatIf and -Confirm for extra safety

For safety purposes, GQL SupportsShouldProcess.

This adds two parameters, -WhatIf and -Confirm.

Use -WhatIf to determine how to run the query with Invoke-RestMethod, without running it directly.

Use -Confirm to prompt for confirmation before each query is executed.

~~~PowerShell
GQL ./Examples/GetSchemaTypes.gql -Confirm
~~~

### Use Variables for more security

Hardcoded values can reveal insecure information.

## Never Execute Result Data

Seriously:

**Never Execute Result Data**

In PowerShell, on of the most dangerous things you can do is `Invoke-Expression`.

This runs whatever is in the data, and is the path to code injection attacks.

Another dangerous thing you can do is `$executionContext.SessionState.InvokeCommand.ExpandString`.

This expands a string containing subexpressions, which can also inject code.

If you were to directly Invoke or expand code from a GraphQL result, it could compromise your system (and possibly your network)

If you were to directly evaluate code from a GraphQL result in any other language, it could compromise that application (and possibly your network)

So, once more:

*Never Execute Result Data*

## Please Enjoy Responsibly
