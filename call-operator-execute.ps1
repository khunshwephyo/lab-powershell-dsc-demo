function Show-CompanyInfo {
  param (
    $companyName,
    $founderName,
    $dateFounded
  )
  
  Write-Output "$companyName was founded on $dateFounded by $founderName"

}

# note the & sign which is the 'call operator'
$disney = $(&'.\call-operator-data.ps1')

# With splatting.  Note the @ sign used 
Show-CompanyInfo @disney