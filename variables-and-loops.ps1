# define a single variable
$x = "This is X. A single variable."
Write-Output $x

# define an array variable
$cartoonCharacters = $("Mickey", "Donald", "Chip", "Dale")
Write-Output $cartoonCharacters

# loop
$cartoonCharacters | ForEach-Object {
  
  $current = $_

  Write-Output "Current cartoon character is: $current"

  # conditional
  if($current -eq "Dale")
  {
    Write-Output "$current is my favorite!!!"
  }  
  
}