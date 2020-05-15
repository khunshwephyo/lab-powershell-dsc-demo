[CmdletBinding()]
param(
  $configData,
  $outputPath
)

Configuration MySoftware {
  param(
    $source
  )

  # install Notepad++
  Script NotepadPlusPlus {
    GetScript  = { 
            
    }
            
    SetScript  = {
      $installer = "$source\npp.7.8.2.Installer.x64.exe"
      Start-Process -FilePath $installer -ArgumentList "/S" -Wait 
    }
  
            
    TestScript = {
      (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -ilike "Notepad++*" -and $_.DisplayVersion -like "7.8.2" }) -ne $null
    }
  }
}

Configuration MyScheduledTask {
  param(
    $jobs
  )

  Import-DscResource -Module ComputerManagementDsc

  if ($jobs) {

    foreach ($key in $jobs.Keys) {

      $job = $jobs[$key]

      ScheduledTask $key {
        TaskPath          = $job.TaskPath
        TaskName          = $job.TaskName
        Description       = $job.TaskDescription
        ActionExecutable  = $job.ActionExecutable
        ActionWorkingPath = $job.ActionWorkingPath
        ActionArguments   = $job.ActionArguments
        Enable            = $job.Enable
        ExecuteAsGMSA     = $job.ExecuteAsGMSA
        ScheduleType      = $job.ScheduleType
        DaysOfWeek        = $job.DaysOfWeek
        StartTime         = $job.StartTime
      }
    
    }  
  }
}

Configuration MyWebApplication {
  param(
    $apps
  )
  
  Import-DscResource -Module xWebAdministration

  if ($apps) {

    foreach ($key in $apps.Keys) {

      $app = $apps[$key]

      # we need to use 'unique' configuration names
      # so we append the $key 
      File $("copyFiles_$key") {
        Ensure          = 'Present'
        Type            = 'Directory'
        SourcePath      = $app.CopyFrom
        DestinationPath = $app.CopyTo
        Recurse         = $true
        MatchSource     = $true
        Checksum        = 'ModifiedDate'
      }
    
      xWebAppPool $("createPool_$key") {
        Ensure                = 'Present'
        State                 = $app.PoolState
        Name                  = $app.Pool
        enable32BitAppOnWin64 = $app.Allow32Bit
        managedPipelineMode   = $app.Pipeline
        managedRuntimeVersion = $app.Runtime
        loadUserProfile       = $true
        identityType          = 'ApplicationPoolIdentity'
      }
    
      xWebApplication $("createApp_$key") {
        Ensure                  = 'Present'
        Name                    = $app.Name
        WebAppPool              = $app.Pool
        Website                 = $app.WebSite
        PreloadEnabled          = $true
        ServiceAutoStartEnabled = $true
        AuthenticationInfo      = MSFT_xWebApplicationAuthenticationInformation {
          Anonymous = $true
          Basic     = $false
          Digest    = $false
          Windows   = $false
        }
        SslFlags                = ''
        PhysicalPath            = $app.CopyTo
        DependsOn               = "[xWebAppPool]$("createPool_$key")"
      }
    
    }  
  }

  
}

Configuration GenerateMof
{
  Import-DscResource -Module PSDesiredStateConfiguration
  
  Node $AllNodes.NodeName
  {

    MySoftware installSoftware {
      source = $Node.SoftwareInstallers
    }

    MyScheduledTask createJobs {
      jobs = $Node.Jobs
    }

    MyWebApplication createApps {
      apps = $Node.WebApps
    }

  }

}

GenerateMof -OutputPath $outputPath -ConfigurationData $configData