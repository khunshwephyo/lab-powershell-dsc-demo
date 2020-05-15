function Show-CompanyInfo {
  param (
    $companyName,
    $founderName,
    $dateFounded
  )
  
  Write-Output "$companyName was founded on $dateFounded by $founderName"

}

# Without splatting.  Note the parameters are passed in individually
Show-CompanyInfo -companyName "Disney" -founderName "Walt Disney" -dateFounded "October 16, 1923"

# define hash table
$disney = @{
  CompanyName = "Disney"
  Founder = "Walt Disney"
  DateFounded = "October 16, 1923"
}

# With splatting.  Note the @ sign used 
Show-CompanyInfo @disney