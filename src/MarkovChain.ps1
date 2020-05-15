class ValidSets : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return (Get-Content "$PSScriptRoot\dataconfig.json" | ConvertFrom-Json).Name
    }
}

function Get-GeneratedName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$Order = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 20,
        
        [ValidateSet([ValidSets])]
        [Parameter(Mandatory = $true)]
        [string[]]$DataSet
    )
           
    $Config = Get-Content "$PSScriptRoot\dataconfig.json" | ConvertFrom-Json

    $Names = @()
    foreach ($Set in $DataSet) {
        $DataFile = ($Config | Where-Object Name -eq $Set).FileName
        
        # Import all names to string array
        $Names += Get-Content "$PSScriptRoot\data\$DataFile"
    }

    # Create Markov Chain hashtable
    $MarkovChain = @{}

    # Loop through names and populate Markov Chain hashtable with probable characters
    foreach ($Name in $Names) {
        # Add spaces to indicate start and end of words when added to hashtable
        [string]$Name = " $Name "

        # Loop through each character of the name length - $Order times to make sure not to have index out of bounds
        for ($i = 0; $i -lt $Name.Length - $Order; $i++) {
            # For each character, add it to an array with the key of the previous two characters
            $MarkovChain[$Name.Substring($i, $Order)] += [char[]]$Name[$i + $Order]
        }
    }

    # Generate $Count names
    1..$Count | ForEach-Object {
        # Get a random word that starts with whitespace, a random start of the name
        [string]$Name = Get-Random ($MarkovChain.Keys | Where-Object { $_ -match '^\s' })

        # Loop until reaching a space, a random end of the name
        while ($Name -notmatch '\s$') {
            $Next = $MarkovChain[$Name.Substring($Name.Length - $Order, $Order)]

            $Name += Get-Random ([object[]]$Next)
        }

        Write-Output $Name.Trim()
    }
}