# every DSC file must have one main Configuration function
Configuration MyExample
{

  # import necessary modules
  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Import-DscResource -ModuleName xPSDesiredStateConfiguration 
  Import-DscResource -ModuleName xSmbShare


  # define the 'node' using one or more target machine names
  Node localhost
  {

    # define configurations for target machine
  
    WindowsFeature DSCServiceFeature {
      Ensure = 'Present'
      Name   = 'DSC-Service'
    }

    # registration key file for Pull Client to register with
    # generate a new GUID and replace Contents value accordingly
    File RegistrationKeyFile {
      Ensure          = 'Present'
      DestinationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\RegistrationKeys.txt"
      Contents        = '2d776741-33dd-4935-b90f-c3fa287b80cd'
      DependsOn       = @("[WindowsFeature]DSCServiceFeature")
    }

    # web service for Pull Client to retrieve their configuration data
    # check target server's thumbprint and replace CertificateThumbPrint value accordingly 
    xDSCWebService PSDSCPullServer {
      Ensure                       = "Present"
      EndpointName                 = 'PSDSCPullServer'
      Port                         = 4431
      PhysicalPath                 = "$env:SystemDrive\inetpub\PSDSCPullServer"
      ModulePath                   = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
      ConfigurationPath            = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
      RegistrationKeyPath          = "$env:PROGRAMFILES\WindowsPowerShell\DscService"
      CertificateThumbPrint        = '662083F811541A37E3BF5D769EC707D414AE40CB'
      AcceptSelfSignedCertificates = $true
      UseSecurityBestPractices     = $true
      State                        = "Started"
      DependsOn                    = @("[WindowsFeature]DSCServiceFeature", "[File]RegistrationKeyFile")
    }

    # share folder for Pull Client to download large files such as installers, deployment files, etc.
    File SmbShareFolder {
      Ensure          = 'Present'
      DestinationPath = 'c:\my-sources'
      Type            = 'Directory'
    }

    # allow Read access to one or more Pull Clients
    # as many server names as necessary to ReadAccess
    # as demo purpose, we use 'NETWORK SERVICE' instead of server name
    xSMBShare CreateSmbShare {
      Ensure                = 'Present'
      Name                  = 'my-sources'
      Path                  = 'c:\my-sources\'
      FolderEnumerationMode = 'AccessBased'
      DependsOn             = '[File]SmbShareFolder'
      ReadAccess            = @(
        'NETWORK SERVICE'
      )
    }    
  }

}

# compile above configuration into .mof file
MyExample