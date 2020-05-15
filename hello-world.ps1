# define one or more parameters
[CmdletBinding()]
param(
  $personName
)

# define one or more functions
function Say-Hello {
  param (
    $name
  )
  
  Write-Output "Hello $name"
}

# call functions
Say-Hello -name $personName

