# Import all names to string array
$Names = Get-Content '.\SwedishLastNames.txt'
$Names += Get-Content .\MedievalSwedishFirstNames.txt

# Create Markov Chain hashtable
$MarkovChain = @{}

$Order = 6
$NameCount = 20

# Loop through names
foreach ($Name in $Names) {
    $Name = " $Name "

    # Loop through each character of the name length - $Order times to make sure not to have index out of bounds
    for ($i = 0; $i -lt $Name.Length - $Order; $i++) {
        # For each character, add it to an array with the key of the previous two characters
        $KeyValue = $Name.Substring($i, $Order)
        $MarkovChain[$KeyValue] += [char[]]$Name[$i + $Order]
    }
}

for ($i = 0; $i -lt $NameCount; $i++) {
    # Get a random word that starts with whitespace
    $Name = Get-Random ($MarkovChain.Keys | Where-Object { $_ -match '^\s' })

    # Loop until reaching a space
    while ($Name -notmatch '\s$') {
        $Next = $MarkovChain[$Name.Substring($Name.Length - $Order, $Order)]

        $Name += Get-Random ([object[]]$Next)
    }

    $Name.Trim()   
}