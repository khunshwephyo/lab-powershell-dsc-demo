Configuration MyFile {
  # create a text file at C:\temp\hello.txt
  File myFile {
    Ensure          = 'Present'
    Contents        = 'Hello World'
    DestinationPath = 'C:\temp\hello.txt'
    Type            = 'File'
  }
}

Configuration MySoftware {
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

Configuration MyWindowsFeatures {
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

Configuration MyScheduledTask {

  Import-DscResource -Module ComputerManagementDsc

  # note that Enable must be set to $true for the scheduled task to run according to its schedule
  ScheduledTask setupMyTask {
    TaskPath          = '\my-path'
    TaskName          = 'my-task'
    Description       = 'dummy scheduled task for demo purpose with pull client'
    ActionExecutable  = 'c:\projects\my-project\my-test.exe'
    ActionWorkingPath = 'c:\projects\my-project'
    ActionArguments   = $null
    Enable            = $false
    ExecuteAsGMSA     = $null
    ScheduleType      = 'Daily'
    DaysOfWeek        = $null
    StartTime         = '2019-12-12T07:00:00'
  }

}

Configuration MyWebApplication {
  
  Import-DscResource -Module xWebAdministration

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

Configuration MyExample
{

  Import-DscResource -Module PSDesiredStateConfiguration

  Node $('localhost','server1','server2','server3')
  {

    MyFile createFile { }

    MySoftware installSoftware { }

    MyWindowsFeatures addWindowsFeatures { }

    MyScheduledTask createScheduledTask { }

    MyWebApplication createWebApplication { }
    
  }

}

# compile above configuration into .mof file
MyExample