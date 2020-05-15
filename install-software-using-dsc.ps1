# every DSC file must have one main Configuration function
Configuration MyExample
{

  # import necessary modules
  Import-DscResource -Module PSDesiredStateConfiguration

  # define the 'node' using one or more target machine names
  Node $('localhost', 'server1', 'server2', 'server3')
  {

    # define configurations for target machine

    # install Notepad++
    Script NotepadPlusPlus {
      GetScript  = { 
            
      }
            
      SetScript  = {
        Start-Process -FilePath "c:\installers\npp.7.8.2.Installer.x64.exe" -ArgumentList "/S" -Wait 
      }
  
            
      TestScript = {
        (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -ilike "Notepad++*" -and $_.DisplayVersion -like "7.8.2" }) -ne $null
      }
    }

  }

}

# compile above configuration into .mof file
MyExample