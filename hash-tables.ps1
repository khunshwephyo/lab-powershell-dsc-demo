# define hash table
$disney = @{
  CompanyName = "Disney"
  FamousCharacters = $("Mickey", "Donald", "Chip", "Dale")
  TotalFans = @{
    Singapore = 100000
    China = 1000000000
  }
}

Write-Output "---Hash table keys---"
Write-Output $disney.Keys
Write-Output "---"

Write-Output "--Hash table values---"
Write-Output $disney.Values
Write-Output "---"

# in a string, use $() to bring out hash table's value
Write-Output "Company name is : $($disney.CompanyName)"
Write-Output "---"
Write-Output "Famous characters are : "
Write-Output $disney.FamousCharacters
Write-Output "---"
Write-Output "Total Fans of Disney"
Write-Output $disney.TotalFans
