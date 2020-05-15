# every DSC file must have one main Configuration function
Configuration MyExample
{

  # import necessary modules
  Import-DscResource -Module PSDesiredStateConfiguration
  Import-DscResource -Module xWebAdministration

  # define the 'node' using one or more target machine names
  Node $('localhost', 'server1', 'server2', 'server3')
  {

    # define configurations for target machine
  
    File copyFiles {
      Ensure          = 'Present'
      Type            = 'Directory'
      SourcePath      = 'c:\my-sources\my-web-app\'
      DestinationPath = 'c:\projects\my-web-app\'
      Recurse         = $true
      MatchSource     = $true
      Checksum        = 'ModifiedDate'
    }
  
    xWebAppPool createPool {
      Ensure                = 'Present'
      State                 = 'Started'
      Name                  = 'my-web-app-pool'
      enable32BitAppOnWin64 = $false
      managedPipelineMode   = 'Integrated'
      managedRuntimeVersion = 'v4.0'
      loadUserProfile       = $true
      identityType          = 'ApplicationPoolIdentity'
    }

    xWebApplication createApp {
      Ensure                  = 'Present'
      Name                    = 'my-web-app'
      WebAppPool              = 'my-web-app-pool'
      Website                 = 'Default Web Site'
      PreloadEnabled          = $true
      ServiceAutoStartEnabled = $true
      AuthenticationInfo      = MSFT_xWebApplicationAuthenticationInformation {
        Anonymous = $true
        Basic     = $false
        Digest    = $false
        Windows   = $false
      }
      SslFlags                = ''
      PhysicalPath            = 'c:\projects\my-web-app'
      DependsOn               = '[xWebAppPool]createPool'
    }

  }

}

# compile above configuration into .mof file
MyExample