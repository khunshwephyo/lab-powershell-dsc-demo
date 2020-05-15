# every DSC file must have one main Configuration function
Configuration MyExample
{

  # import necessary modules
  Import-DscResource -Module PSDesiredStateConfiguration

  # define the 'node' using one or more target machine names
  Node $('localhost', 'server1', 'server2', 'server3')
  {

    # active directory module
    WindowsFeature ActiveDirectoryPowerShell {
      Ensure = "Present"
      Name   = "RSAT-AD-PowerShell"
    }

    # IIS
    WindowsFeature IIS {
      Ensure = "Present"
      Name   = "Web-Server"
    }
  
    # asp.net 2.0 and 3.5
    # this requires a specific intaller called "microsoft-windows-netfx3-ondemand-package" 
    # the installer is extracted from Windows Installation .iso file 
    # Windows will automatically look for this installer
    # we only need to specify the path to installer
    WindowsFeature AspNet35 {
      Ensure    = "Present"
      Name      = "Web-Asp-Net"
      Source    = "c:\installers\"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # asp.net 4
    WindowsFeature AspNet45 {
      Ensure    = "Present"
      Name      = "Web-Asp-Net45"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # web socket protocol support
    WindowsFeature WebSocket {
      Ensure    = "Present"
      Name      = "Web-WebSockets"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # IIS management service
    WindowsFeature IISManagement {
      Ensure    = "Present"
      Name      = "Web-Mgmt-Service"
      DependsOn = "[WindowsFeature]IIS"
    }

    # http redirection
    WindowsFeature HttpRedirect {
      Name      = "Web-Http-Redirect"
      Ensure    = "Present"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # URL authorization 
    WindowsFeature URLAuthorization {
      Name      = "Web-Url-Auth"
      Ensure    = "Present"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # windows authentication
    WindowsFeature WindowsAuthentication {
      Name      = "Web-Windows-Auth"
      Ensure    = "Present"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # user interface for IIS management (aka) inetmgr
    WindowsFeature IISManagementConsole {
      Ensure    = "Present"
      Name      = "Web-Mgmt-Console"
      DependsOn = "[WindowsFeature]IIS"
    }
  
    # IIS compatibility for IIS 6.0
    # commented features below are required only if your server need to send email using SMTP 
    # WindowsFeature IISManagementCompatibility {
    #   Name      = "Web-Mgmt-Compat"
    #   Ensure    = "Present"
    #   DependsOn = "[WindowsFeature]IIS"
    # }
  
    # WindowsFeature IISMetabaseCompatibility {
    #   Name      = "Web-Metabase"
    #   Ensure    = "Present"
    #   DependsOn = "[WindowsFeature]IISManagementCompatibility"
    # }
  
    # WindowsFeature IISLegacyManagementConsole {
    #   Name      = "Web-Lgcy-Mgmt-Console"
    #   Ensure    = "Present"
    #   DependsOn = "[WindowsFeature]IISManagementCompatibility"
    # }

    # WindowsFeature IISWMICompatibility {
    #   Name      = "Web-WMI"
    #   Ensure    = "Present"
    #   DependsOn = "[WindowsFeature]IISManagementCompatibility"
    # }
  
    # WindowsFeature SMTP {
    #   Name                 = "SMTP-Server"          
    #   Ensure               = "Present"
    #   IncludeAllSubFeature = $true
    #   DependsOn            = "[WindowsFeature]IIS"
    # }

    # Service SMTP {
    #   Name        = "SMTPSVC"
    #   StartupType = "Automatic"
    #   State       = "Running"
    #   DependsOn   = "[Service]IIS"
    # }

    # start IIS ADMIN service
    # Service IIS {
    #   Name        = "IISADMIN"
    #   StartupType = "Automatic"
    #   State       = "Running"
    # }      
  
  
    # enable remote management so that we can manage server using IIS console remotely
    Registry RemoteManagement {
      Key       = "HKLM:\SOFTWARE\Microsoft\WebManagement\Server"
      ValueName = "EnableRemoteManagement"
      ValueType = "Dword"
      ValueData = "1"
      DependsOn = "[WindowsFeature]IIS", "[WindowsFeature]IISManagement"
    }
  
    # start remote management service
    Service StartWMSVC {
      Name        = "WMSVC"
      StartupType = "Automatic"
      State       = "Running"
      DependsOn   = "[Registry]RemoteManagement"
    }
  
    # install application request routing so that we can use its URL Rewrite feature
    Script ApplicationRequestRouting {
      GetScript  = { 
      
      }
      
      SetScript  = {
        Start-Process -FilePath "c:\installers\ARRv3_setup_amd64_en-us.EXE" -ArgumentList "/q" -Wait 
      }
  
      
      TestScript = {
        (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -ieq "Microsoft Application Request Routing 3.0" }) -ne $null
      }
      
    }

  }

}

# compile above configuration into .mof file
MyExample