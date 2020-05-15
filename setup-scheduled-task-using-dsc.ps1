# every DSC file must have one main Configuration function
Configuration MyExample
{

  # import necessary modules
  Import-DscResource -Module PSDesiredStateConfiguration
  Import-DscResource -Module ComputerManagementDsc

  # define the 'node' using one or more target machine names
  Node $('localhost', 'server1', 'server2', 'server3')
  {

    # define configurations for target machine
  
    # note that Enable must be set to $true for the scheduled task to run according to its schedule
    ScheduledTask setupMyTask {
      TaskPath          = '\TP'
      TaskName          = 'my-task'
      Description       = 'dummy scheduled task for demo purpose'
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

}

# compile above configuration into .mof file
MyExample